/// DriveAuto — formatters.dart
/// Rôle : Formatage de données globales (Dates, scores, durées)
/// Auteur : DriveAuto Team
library;

import 'package:intl/intl.dart';

class Formatters {
  /// Formate une `DateTime` en "jj/MM/aaaa"
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formate une `DateTime` avec heure "jj/MM/aaaa à HH:mm"
  static String formatDateTime(DateTime date) {
    return DateFormat("dd/MM/yyyy 'à' HH:mm").format(date);
  }

  /// Formate un score en pourcentage, ex: "85%"
  static String formatScore(double score) {
    return '${score.toStringAsFixed(0)}%';
  }

  /// Formate une durée (en secondes) en "mm:ss" ou "hh:mm:ss"
  static String formatDuration(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
