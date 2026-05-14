/// DriveAuto — score_calculator.dart
/// Rôle : Calculs métier pour la progression et le score
/// Auteur : DriveAuto Team
library;

class ScoreCalculator {
  /// Calcule un pourcentage de progression
  static double calculateProgress(int completedLessons, int totalLessons) {
    if (totalLessons <= 0) return 0.0;
    if (completedLessons <= 0) return 0.0;
    if (completedLessons >= totalLessons) return 100.0;
    return (completedLessons / totalLessons) * 100.0;
  }

  /// Calcule le score moyen global à partir d'une liste (gère les null)
  static double calculateAverageScore(List<double?> scores) {
    if (scores.isEmpty) return 0.0;
    double sum = 0.0;
    int count = 0;
    for (final score in scores) {
      if (score != null) {
        sum += score;
        count++;
      }
    }
    return count > 0 ? (sum / count) : 0.0;
  }
}
