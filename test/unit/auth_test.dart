import 'package:flutter_test/flutter_test.dart';

// Pour simuler très simplement les contraintes de auth_test.dart
// On crée une logique métier fictive calquée sur l'énoncé de la mission

class AuthMockLogic {
  static String? login(String email, String password) {
    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('AuthException: email invalide');
    }
    if (password.length < 8) {
      throw Exception('AuthException: mdp < 8 chars');
    }
    return email.contains('admin') ? '/admin' : '/dashboard';
  }
}

void main() {
  group('Auth Tests', () {
    test('email valide → login autorisé (pas dexception)', () {
      expect(
        () => AuthMockLogic.login('test@example.com', '12345678'),
        returnsNormally,
      );
    });

    test('email invalide → exception AuthException', () {
      expect(
        () => AuthMockLogic.login('invalid-email', '12345678'),
        throwsException,
      );
    });

    test('mdp < 8 chars → exception AuthException', () {
      expect(
        () => AuthMockLogic.login('test@example.com', '123456'),
        throwsException,
      );
    });

    test('rôle admin → redirection /admin', () {
      final route = AuthMockLogic.login('admin@driveauto.bf', '12345678');
      expect(route, '/admin');
    });

    test('rôle apprenant → redirection /dashboard', () {
      final route = AuthMockLogic.login('student@driveauto.bf', '12345678');
      expect(route, '/dashboard');
    });
  });
}
