import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_driveauto_app/domain/models/quiz.dart';
import 'package:flutter_driveauto_app/features/quizzes/screens/quiz_active_screen.dart';

void main() {
  final fakeQuiz = Quiz(
    id: '1',
    titre: 'Examen 1',
    categorie: 'Code',
    questions: [
      const Question(
        id: 'q1',
        texte: 'Que veut dire ce panneau ?',
        options: ['A', 'B', 'C', 'D'],
        correctAnswerIndex: 0,
      ),
    ],
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      child: MaterialApp(home: QuizActiveScreen(quiz: fakeQuiz)),
    );
  }

  group('Quiz Screen Widget Tests', () {
    testWidgets('question affichée au démarrage et 4 options visibles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Vérifie que le titre est là
      expect(find.text('Que veut dire ce panneau ?'), findsOneWidget);

      // Vérifie que les 4 options sont affichées (Textes des options et boutons)
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNWidgets(4));
    });

    testWidgets('timer visible et décrémente', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Le timer commence à 30
      expect(find.text('30 s'), findsOneWidget);

      // On avance de 1 seconde
      await tester.pump(const Duration(seconds: 1));

      // Le timer passe à 29
      expect(find.text('29 s'), findsOneWidget);
    });

    testWidgets('sélection option → feedback visuel (icône change)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Par défaut, aucun n'est checké
      expect(find.byIcon(Icons.radio_button_checked), findsNothing);

      // On clique sur la première option ('A')
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // On vérifie que le feedback visuel est appliqué (icône modifiée)
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });
  });
}
