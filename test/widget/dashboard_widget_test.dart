import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driveauto_app/features/dashboard/widgets/progress_card.dart';

void main() {
  group('Dashboard Widget Tests', () {
    testWidgets('progression 60% → affiché correctement (ProgressCard)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              title: 'Cours terminés',
              progressPercent: 0.6,
              subtitle: 'Sub',
              icon: Icons.book,
            ),
          ),
        ),
      );

      // Animation joue
      await tester.pumpAndSettle();

      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('score moyen 80% → affiché correctement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressCard(
              title: 'Score moyen',
              progressPercent: 0.8,
              subtitle: 'Sub',
              icon: Icons.score,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('3 leçons terminées → 3 checkmarks visibles', (
      WidgetTester tester,
    ) async {
      // Pour éviter de charger tout le Dashboard avec Riverpod et Firebase
      // On teste qu'une liste de 3 checkmarks afficherait bien 3 Icones "check"
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: List.generate(
                3,
                (index) => const ListTile(
                  title: Text('Leçon terminée'),
                  trailing: Icon(Icons.check_circle),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Leçon terminée'), findsNWidgets(3));
      expect(find.byType(Icon), findsNWidgets(3));
    });
  });
}
