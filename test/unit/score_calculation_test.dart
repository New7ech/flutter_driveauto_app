import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driveauto_app/core/utils/score_calculator.dart';

void main() {
  group('ScoreCalculator - Progression', () {
    test('progression 0 leçon → 0%', () {
      expect(ScoreCalculator.calculateProgress(0, 10), 0.0);
    });

    test('progression toutes leçons → 100%', () {
      expect(ScoreCalculator.calculateProgress(10, 10), 100.0);
    });

    test('progression partielle → calcul correct', () {
      expect(ScoreCalculator.calculateProgress(5, 10), 50.0);
    });
  });

  group('ScoreCalculator - Score Moyen', () {
    test('score moyen avec valeurs nulles → 0% / Ignore Null', () {
      // S'il y a que des valeurs nulles, 0%
      expect(ScoreCalculator.calculateAverageScore([null, null]), 0.0);

      // Si une valeur est présente avec du null
      expect(
        ScoreCalculator.calculateAverageScore([null, 80.0, null, 100.0]),
        90.0,
      );
    });

    test('score moyen liste vide → 0%', () {
      expect(ScoreCalculator.calculateAverageScore([]), 0.0);
    });

    test('score moyen avec valeurs classiques', () {
      expect(ScoreCalculator.calculateAverageScore([50.0, 100.0]), 75.0);
    });
  });
}
