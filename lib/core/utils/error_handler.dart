/// DriveAuto — error_handler.dart
/// Rôle : Gestion centralisée des erreurs avec messages localisés et logging
/// Auteur : DriveAuto Team

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'logging_service.dart';

class AppException implements Exception {
  final String code;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.code,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class ErrorHandler {
  static AppException handle(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    LoggingService.error(
      'Error in ${context ?? "app"}',
      error: error,
      stackTrace: stackTrace,
    );

    // Firebase Auth errors
    if (error is FirebaseAuthException) {
      return _handleAuthError(error, stackTrace);
    }

    // Firestore errors
    if (error is FirebaseException) {
      return _handleFirebaseError(error, stackTrace);
    }

    // Generic errors
    if (error is AppException) {
      return error;
    }

    return AppException(
      code: 'unknown_error',
      message: 'Une erreur inconnue s\'est produite',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppException _handleAuthError(
    FirebaseAuthException error,
    StackTrace? stackTrace,
  ) {
    final message = _getAuthErrorMessage(error.code);
    return AppException(
      code: error.code,
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static AppException _handleFirebaseError(
    FirebaseException error,
    StackTrace? stackTrace,
  ) {
    final message = _getFirebaseErrorMessage(error.code);
    return AppException(
      code: error.code ?? 'firebase_error',
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  static String _getAuthErrorMessage(String code) {
    const messages = {
      'invalid-email': 'Adresse e-mail invalide',
      'user-disabled': 'Ce compte a été désactivé',
      'user-not-found': 'Utilisateur non trouvé',
      'wrong-password': 'Mot de passe incorrect',
      'email-already-in-use': 'Cet e-mail est déjà utilisé',
      'weak-password': 'Le mot de passe est trop faible',
      'operation-not-allowed': 'Opération non autorisée',
      'too-many-requests': 'Trop de tentatives. Réessayez plus tard.',
      'account-exists-with-different-credential':
          'Un compte existe avec des identifiants différents',
      'invalid-credential': 'Les identifiants fournis sont invalides',
      'network-request-failed': 'Erreur réseau. Vérifiez votre connexion.',
    };

    return messages[code] ?? 'Erreur d\'authentification';
  }

  static String _getFirebaseErrorMessage(String? code) {
    const messages = {
      'permission-denied': 'Vous n\'avez pas la permission d\'accéder à ces données',
      'not-found': 'Les données demandées n\'existent pas',
      'already-exists': 'Cet élément existe déjà',
      'failed-precondition': 'Opération échouée. Veuillez réessayer.',
      'aborted': 'Opération annulée',
      'out-of-range': 'Valeur hors limites',
      'unimplemented': 'Fonctionnalité non implémentée',
      'internal': 'Erreur interne du serveur',
      'unavailable': 'Service indisponible. Réessayez plus tard.',
      'data-loss': 'Perte de données détectée',
      'unauthenticated': 'Vous devez vous connecter',
      'network': 'Erreur réseau. Vérifiez votre connexion.',
    };

    return messages[code] ?? 'Erreur serveur';
  }
}
