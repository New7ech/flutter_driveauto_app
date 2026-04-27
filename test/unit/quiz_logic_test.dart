import 'package:flutter_test/flutter_test.dart';

// Modèle métier minimum pour simuler la logique demandée
class QuizLogicSim {
  int score = 0;
  int questionsAnswered = 0;

  void answerQuestion(bool isCorrect, int timeLeft) {
    questionsAnswered++;
    if (timeLeft <= 0) {
      // timer atteint 0 → question comptée fausse, points non ajoutés
      return;
    }
    if (isCorrect) {
      // réponse correcte → points ajoutés
      score++;
    } else {
      // réponse incorrecte → points non ajoutés
    }
  }

  double calculatePercentage(int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    return (score / totalQuestions) * 100.0;
  }
}

void main() {
  group('Quiz Logic Tests', () {
    test('score 0/5 → 0%', () {
      final logic = QuizLogicSim();
      // On répond 5 fois faux
      for (var i = 0; i < 5; i++) {
        logic.answerQuestion(false, 30);
      }
      expect(logic.calculatePercentage(5), 0.0);
    });

    test('score 5/5 → 100%', () {
      final logic = QuizLogicSim();
      for (var i = 0; i < 5; i++) {
        logic.answerQuestion(true, 30); // 30s left
      }
      expect(logic.calculatePercentage(5), 100.0);
    });

    test('timer atteint 0 → question comptée fausse', () {
      final logic = QuizLogicSim();
      // Bonne réponse MAIS timer à 0
      logic.answerQuestion(true, 0);
      expect(logic.score, 0);
    });

    test('réponse correcte → points ajoutés', () {
      final logic = QuizLogicSim();
      logic.answerQuestion(true, 15);
      expect(logic.score, 1);
    });

    test('réponse incorrecte → points non ajoutés', () {
      final logic = QuizLogicSim();
      logic.answerQuestion(false, 15);
      expect(logic.score, 0);
    });
  });
}
