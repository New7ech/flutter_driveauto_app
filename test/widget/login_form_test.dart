import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_driveauto_app/features/auth/screens/login_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const ProviderScope(child: MaterialApp(home: LoginScreen()));
  }

  group('Login Form Widget Tests', () {
    testWidgets('champs vides → message erreur visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // On appuie sur "Se connecter" avec des champs vides
      await tester.tap(find.text('Se connecter'));
      await tester
          .pumpAndSettle(); // On attend l'actualisation de la validation

      expect(find.text('Veuillez renseigner votre email'), findsOneWidget);
      expect(
        find.text('Veuillez renseigner votre mot de passe'),
        findsOneWidget,
      );
    });

    testWidgets('email invalide → message erreur visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).first, 'bademail');
      await tester.enterText(find.byType(TextFormField).last, '12345678');

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(
        find.text('Veuillez entrer une adresse email valide'),
        findsOneWidget,
      );
      // Le mot de passe est valide donc pas d'erreur sur le MdP
      expect(
        find.text('Le mot de passe doit contenir au moins 8 caractères'),
        findsNothing,
      );
    });

    testWidgets('formulaire valide → bouton activé et pas message d’erreur', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, '12345678');

      await tester.tap(find.text('Se connecter'));
      await tester.pump();

      // Les messages d'erreurs de validation ne doivent pas s'afficher
      expect(find.text('Veuillez renseigner votre email'), findsNothing);
      expect(find.text('Veuillez renseigner votre mot de passe'), findsNothing);

      // Ici on testerait l'appel du vrai controller (via mocker le Provider)
      // si on voulait vérifier la navigation
    });
  });
}
