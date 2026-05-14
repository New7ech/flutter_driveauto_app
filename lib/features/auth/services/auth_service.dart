import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart' as crypto;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_auth_user.dart';

enum AuthBackendType { firebase, local }

class AppAuthException implements Exception {
  const AppAuthException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    required FirebaseAuth? firebaseAuth,
    required GoogleSignIn googleSignIn,
    required Box? localUsersBox,
    required Box? localSessionBox,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn,
       _localUsersBox = localUsersBox,
       _localSessionBox = localSessionBox {
    _restoreLocalSession();
  }

  static const String _currentSessionEmailKey = 'current_user_email';
  static const String _googleDemoEmail = 'google.demo@driveauto.local';

  final FirebaseAuth? _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final Box? _localUsersBox;
  final Box? _localSessionBox;
  final StreamController<AppAuthUser?> _localAuthController =
      StreamController<AppAuthUser?>.broadcast();
  final Map<String, Map<String, dynamic>> _memoryUsers =
      <String, Map<String, dynamic>>{};

  AppAuthUser? _localCurrentUser;
  String? _memorySessionEmail;

  bool get isUsingFirebase => _firebaseAuth != null;
  bool get supportsGoogleSignIn => _firebaseAuth != null;

  AuthBackendType get backendType {
    if (isUsingFirebase) {
      return AuthBackendType.firebase;
    }
    return AuthBackendType.local;
  }

  String get backendLabel {
    switch (backendType) {
      case AuthBackendType.firebase:
        return 'Firebase';
      case AuthBackendType.local:
        return 'Local';
    }
  }

  AppAuthUser? get currentUser {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      return _mapFirebaseUser(firebaseAuth.currentUser);
    }

    return _localCurrentUser;
  }

  Stream<AppAuthUser?> authStateChanges() {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      return firebaseAuth.authStateChanges().map(_mapFirebaseUser);
    }

    return (() async* {
      yield _localCurrentUser;
      yield* _localAuthController.stream;
    })();
  }

  Future<AppAuthUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = _mapFirebaseUser(credential.user);
      if (user == null) {
        throw const AppAuthException(
          code: 'missing-user',
          message:
              'Connexion impossible. Aucun profil utilisateur n a ete recupere.',
        );
      }
      return user;
    }

    final rawUser = _readLocalUser(normalizedEmail);
    if (rawUser == null) {
      throw const AppAuthException(
        code: 'user-not-found',
        message: 'Aucun utilisateur trouve pour cet email.',
      );
    }

    final expectedHash = rawUser['passwordHash'] as String?;
    if (expectedHash == null || expectedHash != _hashPassword(password)) {
      throw const AppAuthException(
        code: 'wrong-password',
        message: 'Email ou mot de passe incorrect.',
      );
    }

    final user = AppAuthUser.fromJson(
      rawUser,
    ).copyWith(lastLoginAt: DateTime.now(), hasActiveSession: true);
    await _persistLocalUser(user, passwordHash: expectedHash);
    await _writeLocalSession(normalizedEmail);
    _localCurrentUser = user;
    _localAuthController.add(user);
    return user;
  }

  Future<AppAuthUser> register({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final resolvedDisplayName = displayName.trim().isEmpty
        ? AppAuthUser.fallbackDisplayName(normalizedEmail)
        : displayName.trim();

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      if (resolvedDisplayName.isNotEmpty) {
        await credential.user?.updateDisplayName(resolvedDisplayName);
      }
      await credential.user?.reload();

      final user = _mapFirebaseUser(firebaseAuth.currentUser);
      if (user == null) {
        throw const AppAuthException(
          code: 'missing-user',
          message:
              'Inscription incomplete. Aucun profil utilisateur n a ete recupere.',
        );
      }
      return user;
    }

    if (_readLocalUser(normalizedEmail) != null) {
      throw const AppAuthException(
        code: 'email-already-in-use',
        message: 'Cet email est deja utilise par un autre compte.',
      );
    }

    final now = DateTime.now();
    final user = AppAuthUser(
      id: _generateLocalUserId(),
      email: normalizedEmail,
      displayName: resolvedDisplayName,
      role: AppAuthUser.inferRole(normalizedEmail),
      emailVerified: false,
      hasActiveSession: true,
      provider: 'local_password',
      createdAt: now,
      lastLoginAt: now,
    );

    await _persistLocalUser(user, passwordHash: _hashPassword(password));
    await _writeLocalSession(normalizedEmail);
    _localCurrentUser = user;
    _localAuthController.add(user);
    return user;
  }

  Future<AppAuthUser> loginWithGoogle() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AppAuthException(
          code: 'aborted-by-user',
          message: 'Connexion Google annulee.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await firebaseAuth.signInWithCredential(credential);
      final user = _mapFirebaseUser(result.user);
      if (user == null) {
        throw const AppAuthException(
          code: 'missing-user',
          message:
              'Connexion Google impossible. Aucun profil utilisateur n a ete recupere.',
        );
      }
      return user;
    }

    final rawGoogleUser = _readLocalUser(_googleDemoEmail);
    final now = DateTime.now();

    final user = rawGoogleUser == null
        ? AppAuthUser(
            id: _generateLocalUserId(),
            email: _googleDemoEmail,
            displayName: 'Google Demo',
            role: AppAuthUser.inferRole(_googleDemoEmail),
            emailVerified: true,
            hasActiveSession: true,
            provider: 'google',
            createdAt: now,
            lastLoginAt: now,
          )
        : AppAuthUser.fromJson(rawGoogleUser).copyWith(
            emailVerified: true,
            hasActiveSession: true,
            provider: 'google',
            lastLoginAt: now,
          );

    await _persistLocalUser(
      user,
      passwordHash: rawGoogleUser?['passwordHash'] as String?,
    );
    await _writeLocalSession(_googleDemoEmail);
    _localCurrentUser = user;
    _localAuthController.add(user);
    return user;
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw const AppAuthException(
          code: 'not-authenticated',
          message: 'Aucun utilisateur connecté.',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return;
    }

    // Fallback local
    final email = _localCurrentUser?.email;
    if (email == null) {
      throw const AppAuthException(
        code: 'not-authenticated',
        message: 'Aucun utilisateur connecté.',
      );
    }
    final rawUser = _readLocalUser(email);
    if (rawUser == null) {
      throw const AppAuthException(
        code: 'user-not-found',
        message: 'Utilisateur introuvable.',
      );
    }
    final expectedHash = rawUser['passwordHash'] as String?;
    if (expectedHash == null ||
        expectedHash != _hashPassword(currentPassword)) {
      throw const AppAuthException(
        code: 'wrong-password',
        message: 'Mot de passe actuel incorrect.',
      );
    }
    await _persistLocalUser(
      _localCurrentUser!,
      passwordHash: _hashPassword(newPassword),
    );
  }

  Future<void> sendPasswordReset(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      await firebaseAuth.sendPasswordResetEmail(email: normalizedEmail);
      return;
    }

    // Mode local : pas d'email possible — lever une erreur explicite.
    throw const AppAuthException(
      code: 'local-mode-no-email',
      message: 'local-mode', // code sentinelle capturé dans le contrôleur
    );
  }

  /// Réinitialise directement le mot de passe en mode local (sans email).
  Future<void> resetLocalPassword({
    required String email,
    required String newPassword,
  }) async {
    if (isUsingFirebase) {
      throw const AppAuthException(
        code: 'not-local-mode',
        message: 'Cette méthode est réservée au mode local.',
      );
    }
    final normalizedEmail = _normalizeEmail(email);
    final rawUser = _readLocalUser(normalizedEmail);
    if (rawUser == null) {
      throw const AppAuthException(
        code: 'user-not-found',
        message: 'Aucun compte trouvé pour cet email sur cet appareil.',
      );
    }
    final user = AppAuthUser.fromJson(rawUser);
    await _persistLocalUser(user, passwordHash: _hashPassword(newPassword));
  }

  Future<void> sendEmailVerification() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AppAuthException(
          code: 'not-authenticated',
          message: 'Aucun utilisateur connecte.',
        );
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
      return;
    }

    final currentUser = _localCurrentUser;
    if (currentUser == null) {
      throw const AppAuthException(
        code: 'not-authenticated',
        message: 'Aucun utilisateur connecte.',
      );
    }

    final existingRawUser = _readLocalUser(currentUser.email);
    final passwordHash = existingRawUser?['passwordHash'] as String?;
    final verifiedUser = currentUser.copyWith(
      emailVerified: true,
      hasActiveSession: true,
      lastLoginAt: DateTime.now(),
    );

    await _persistLocalUser(verifiedUser, passwordHash: passwordHash);
    _localCurrentUser = verifiedUser;
    _localAuthController.add(verifiedUser);
  }

  Future<AppAuthUser?> reloadCurrentUser() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      final currentFirebaseUser = firebaseAuth.currentUser;
      if (currentFirebaseUser == null) {
        return null;
      }

      await currentFirebaseUser.reload();
      return _mapFirebaseUser(firebaseAuth.currentUser);
    }

    _restoreLocalSession();
    _localAuthController.add(_localCurrentUser);
    return _localCurrentUser;
  }

  Future<void> logout() async {
    final firebaseAuth = _firebaseAuth;
    if (firebaseAuth != null) {
      await _googleSignIn.signOut();
      await firebaseAuth.signOut();
      return;
    }

    _localCurrentUser = null;
    await _clearLocalSession();
    _localAuthController.add(null);
  }

  void dispose() {
    _localAuthController.close();
  }

  AppAuthUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }

    final email = (user.email ?? '${user.uid}@driveauto.local')
        .trim()
        .toLowerCase();
    final displayName = (user.displayName ?? '').trim().isNotEmpty
        ? user.displayName?.trim() ?? AppAuthUser.fallbackDisplayName(email)
        : AppAuthUser.fallbackDisplayName(email);
    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';

    return AppAuthUser(
      id: user.uid,
      email: email,
      displayName: displayName,
      role: AppAuthUser.inferRole(email),
      emailVerified: user.emailVerified,
      hasActiveSession: true,
      provider: provider,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: user.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  void _restoreLocalSession() {
    if (isUsingFirebase) {
      return;
    }

    final sessionEmail =
        (_localSessionBox?.get(_currentSessionEmailKey) as String?) ??
        _memorySessionEmail;
    if (sessionEmail == null || sessionEmail.isEmpty) {
      _localCurrentUser = null;
      return;
    }

    final rawUser = _readLocalUser(sessionEmail);
    _localCurrentUser = rawUser == null
        ? null
        : AppAuthUser.fromJson(rawUser).copyWith(hasActiveSession: true);
  }

  Future<void> _persistLocalUser(
    AppAuthUser user, {
    required String? passwordHash,
  }) async {
    final rawUser = <String, dynamic>{
      ...user.toJson(),
      ...?passwordHash == null
          ? null
          : <String, dynamic>{'passwordHash': passwordHash},
    };

    final localUsersBox = _localUsersBox;
    if (localUsersBox != null) {
      await localUsersBox.put(user.email, rawUser);
      return;
    }

    _memoryUsers[user.email] = rawUser;
  }

  Map<String, dynamic>? _readLocalUser(String email) {
    final normalizedEmail = _normalizeEmail(email);
    final dynamic rawUser =
        _localUsersBox?.get(normalizedEmail) ?? _memoryUsers[normalizedEmail];

    if (rawUser is Map) {
      return rawUser.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return null;
  }

  Future<void> _writeLocalSession(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    final localSessionBox = _localSessionBox;
    if (localSessionBox != null) {
      await localSessionBox.put(_currentSessionEmailKey, normalizedEmail);
    }
    _memorySessionEmail = normalizedEmail;
  }

  Future<void> _clearLocalSession() async {
    final localSessionBox = _localSessionBox;
    if (localSessionBox != null) {
      await localSessionBox.delete(_currentSessionEmailKey);
    }
    _memorySessionEmail = null;
  }

  String _generateLocalUserId() {
    return 'local_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
  }

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hashed = crypto.sha256.convert(bytes);
    return hashed.toString();
  }
}
