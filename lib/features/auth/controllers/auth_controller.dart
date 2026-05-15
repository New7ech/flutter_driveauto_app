// DriveAuto - auth_controller.dart
// Role: Gestion de l'etat d'authentification (Firebase ou fallback local)
// Auteur : DriveAuto Team

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/notification_service.dart';
import '../../../providers/repository_providers.dart';
import '../models/app_auth_user.dart';
import '../services/auth_service.dart';

// Surveille le doc Firestore de l'utilisateur connecté.
// Émet false quand l'admin supprime son profil → déclenche la déconnexion.
final userDeletionWatcherProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  if (user == null || firestore == null) return const Stream.empty();
  return firestore
      .collection('users')
      .doc(user.id)
      .snapshots()
      .map((snap) => snap.exists);
});

// Émet true quand le compte est approuvé par l'admin.
// Les admins et le mode local sont toujours considérés comme approuvés.
// Utilise le dernier statut approuvé en cache pour garder l'accès hors ligne.
final userApprovalProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);

  if (user == null) return const Stream.empty();
  if (firestore == null) return Stream.value(true);

  final controller = StreamController<bool>();
  controller.add(_readCachedApproval(user.id) ?? false);
  final sub = firestore
      .collection('users')
      .doc(user.id)
      .snapshots()
      .map((snap) {
        final data = snap.data();
        if (data == null) return false;
        final approved = data['role'] == 'admin'
            ? true
            : data['approved'] as bool? ?? false;
        _writeCachedApproval(user.id, approved);
        return approved;
      })
      .listen(controller.add, onError: (_) {});
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

bool? _readCachedApproval(String userId) {
  try {
    if (!Hive.isBoxOpen(AppConstants.hiveAuthSessionBox)) return null;
    return Hive.box(AppConstants.hiveAuthSessionBox).get('approval_$userId')
        as bool?;
  } catch (_) {
    return null;
  }
}

void _writeCachedApproval(String userId, bool approved) {
  try {
    if (!Hive.isBoxOpen(AppConstants.hiveAuthSessionBox)) return;
    unawaited(
      Hive.box(
        AppConstants.hiveAuthSessionBox,
      ).put('approval_$userId', approved),
    );
  } catch (_) {}
}

final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  if (Firebase.apps.isEmpty) {
    return null;
  }
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

final authServiceProvider = Provider<AuthService>((ref) {
  Box? safeBox(String boxName) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  final service = AuthService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    localUsersBox: safeBox(AppConstants.hiveAuthUsersBox),
    localSessionBox: safeBox(AppConstants.hiveAuthSessionBox),
  );

  ref.onDispose(service.dispose);
  return service;
});

final authStateProvider = StreamProvider<AppAuthUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

final currentAuthUserProvider = Provider<AppAuthUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull ?? ref.watch(authServiceProvider).currentUser;
});

final userProfileRoleProvider = StreamProvider<String?>((ref) {
  final user = ref.watch(currentAuthUserProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  if (user == null) return Stream.value(null);
  if (firestore == null) return Stream.value(user.role);

  return firestore.collection('users').doc(user.id).snapshots().map((snap) {
    final role = snap.data()?['role'] as String?;
    return role == 'admin' ? 'admin' : AppAuthUser.defaultRole;
  });
});

final userRoleProvider = Provider<String>((ref) {
  return ref.watch(userProfileRoleProvider).valueOrNull ??
      ref.watch(currentAuthUserProvider)?.role ??
      AppAuthUser.defaultRole;
});

final authLandingRouteProvider = Provider<String>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'admin'
      ? AppConstants.routeAdmin
      : AppConstants.routeDashboard;
});

final authBackendTypeProvider = Provider<AuthBackendType>((ref) {
  return ref.watch(authServiceProvider).backendType;
});

final authBackendLabelProvider = Provider<String>((ref) {
  return ref.watch(authServiceProvider).backendLabel;
});

final googleSignInAvailableProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).supportsGoogleSignIn;
});

final isLocalAuthModeProvider = Provider<bool>((ref) {
  return ref.watch(authBackendTypeProvider) == AuthBackendType.local;
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<AppAuthUser?> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authServiceProvider)
          .login(email: email, password: password);

      await _syncUserProfile(user);
      _subscribeToTopics();
      state = const AsyncValue.data(null);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(_handleAuthError(e), st);
      return null;
    }
  }

  Future<AppAuthUser?> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref
          .read(authServiceProvider)
          .register(displayName: displayName, email: email, password: password);

      await _syncUserProfile(user, isNewUser: true);
      await _sendVerificationEmailIfPossible();
      _subscribeToTopics();
      state = const AsyncValue.data(null);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(_handleAuthError(e), st);
      return null;
    }
  }

  Future<AppAuthUser?> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authServiceProvider).loginWithGoogle();

      // Détecter si c'est un nouvel utilisateur Google (document Firestore absent)
      bool isNewGoogleUser = false;
      final firestore = ref.read(firebaseFirestoreProvider);
      if (firestore != null) {
        final doc = await firestore.collection('users').doc(user.id).get();
        isNewGoogleUser = !doc.exists;
      }

      await _syncUserProfile(user, isNewUser: isNewGoogleUser);
      _subscribeToTopics();
      state = const AsyncValue.data(null);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(_handleAuthError(e), st);
      return null;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(authServiceProvider)
          .updatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_handleAuthError(e), st);
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_handleAuthError(e), st);
      return false;
    }
  }

  Future<bool> resetLocalPassword({
    required String email,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(authServiceProvider)
          .resetLocalPassword(email: email, newPassword: newPassword);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_handleAuthError(e), st);
      return false;
    }
  }

  Future<bool> resendEmailVerification() async {
    state = const AsyncValue.loading();
    try {
      await _sendVerificationEmailIfPossible();
      final refreshedUser = await ref
          .read(authServiceProvider)
          .reloadCurrentUser();
      if (refreshedUser != null) {
        await _syncUserProfile(refreshedUser);
      }
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_handleAuthError(e), st);
      return false;
    }
  }

  Future<AppAuthUser?> refreshSession() async {
    try {
      final user = await ref.read(authServiceProvider).reloadCurrentUser();
      if (user != null) {
        await _syncUserProfile(user);
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authServiceProvider).logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error('Erreur lors de la deconnexion : $e', st);
    }
  }

  Future<void> _syncUserProfile(
    AppAuthUser user, {
    bool isNewUser = false,
  }) async {
    try {
      var shouldWriteRole = isNewUser;
      var shouldWriteInitialApproval = isNewUser;
      if (!shouldWriteRole) {
        final firestore = ref.read(firebaseFirestoreProvider);
        if (firestore != null) {
          final doc = await firestore.collection('users').doc(user.id).get();
          if (!doc.exists) {
            shouldWriteRole = true;
            shouldWriteInitialApproval = true;
          } else {
            shouldWriteRole = doc.data()?['role'] == null;
          }
        }
      }

      await ref
          .read(userRepositoryProvider)
          .saveUserProfile(
            userId: user.id,
            email: user.email,
            displayName: user.displayName,
            role: shouldWriteRole ? AppAuthUser.defaultRole : null,
            emailVerified: user.emailVerified,
            provider: user.provider,
            createdAt: user.createdAt,
            lastLoginAt: user.lastLoginAt,
            // Lors de l'inscription : pending. Lors du login : merge préserve la valeur existante.
            approved: shouldWriteInitialApproval ? false : null,
          );
    } catch (_) {
      // Le profil ne doit pas bloquer l'authentification si Firestore est indisponible.
    }
  }

  void _subscribeToTopics() {
    NotificationService().subscribeToTopic('rappel_lecon');
    NotificationService().subscribeToTopic('nouveau_cours');
  }

  Future<void> _sendVerificationEmailIfPossible() async {
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
    } catch (_) {
      // L'envoi de verification ne doit pas annuler l'authentification.
    }
  }

  String _handleAuthError(dynamic e) {
    if (e is AppAuthException) {
      if (e.code == 'local-mode-no-email') return 'local-mode';
      return e.message;
    }

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouve pour cet email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Cet email est deja utilise par un autre compte.';
        case 'invalid-email':
          return 'Format d email invalide.';
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'missing-email':
          return 'Renseignez l email du compte.';
        case 'user-disabled':
          return 'Ce compte est desactive. Contactez l administrateur.';
        case 'network-request-failed':
          return 'Connexion internet indisponible. Reessayez en ligne.';
        case 'operation-not-allowed':
          return 'La connexion par email/mot de passe n est pas activee dans Firebase.';
        case 'too-many-requests':
          return 'Trop de tentatives. Reessayez dans quelques instants.';
        default:
          return 'Erreur d authentification: ${e.message}';
      }
    }

    if (e is PlatformException) {
      switch (e.code) {
        case 'sign_in_canceled':
        case 'aborted-by-user':
          return 'Connexion Google annulée.';
        case 'sign_in_failed':
          final msg = e.message ?? '';
          if (msg.contains('ApiException: 10')) {
            return 'Connexion Google impossible : empreinte SHA-1 non enregistrée dans Firebase Console, ou la connexion Google n\'est pas activée dans Authentication > Méthodes de connexion.';
          }
          if (msg.contains('ApiException: 7')) {
            return 'Connexion Google impossible : vérifiez votre connexion internet.';
          }
          return 'Connexion Google échouée. Vérifiez la configuration Firebase. ($msg)';
        case 'network_error':
          return 'Erreur réseau. Vérifiez votre connexion internet.';
        default:
          return 'Erreur Google Sign-In (${e.code}) : ${e.message}';
      }
    }

    return 'Une erreur inattendue est survenue: $e';
  }
}
