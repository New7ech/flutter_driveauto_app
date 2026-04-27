import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driveauto_app/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('null value returns error', () {
      expect(Validators.validateEmail(null), 'Veuillez renseigner votre email');
    });

    test('empty value returns error', () {
      expect(Validators.validateEmail(''), 'Veuillez renseigner votre email');
    });

    test('invalid format returns error', () {
      expect(
        Validators.validateEmail('invalid-email'),
        'Veuillez entrer une adresse email valide',
      );
      expect(
        Validators.validateEmail('test@.com'),
        'Veuillez entrer une adresse email valide',
      );
    });

    test('valid format returns null', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });
  });

  group('Validators - Password', () {
    test('null value returns error', () {
      expect(
        Validators.validatePassword(null),
        'Veuillez renseigner votre mot de passe',
      );
    });

    test('empty value returns error', () {
      expect(
        Validators.validatePassword(''),
        'Veuillez renseigner votre mot de passe',
      );
    });

    test('less than 8 chars returns error', () {
      expect(
        Validators.validatePassword('1234567'),
        'Le mot de passe doit contenir au moins 8 caractères',
      );
    });

    test('8 or more chars returns null', () {
      expect(Validators.validatePassword('12345678'), isNull);
    });
  });

  group('Validators - Required', () {
    test('null value returns error with fieldName', () {
      expect(Validators.validateRequired(null, 'Nom'), 'Nom est obligatoire');
    });

    test('empty value returns error with fieldName', () {
      expect(
        Validators.validateRequired('   ', 'Prénom'),
        'Prénom est obligatoire',
      );
    });

    test('valid value returns null', () {
      expect(Validators.validateRequired('Jean', 'Prénom'), isNull);
    });
  });
}
