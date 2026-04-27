/// DriveAuto — user_progress.dart
/// Rôle : Modèle représentant la progression globale d'un apprenant
/// Auteur : DriveAuto Team
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String userId,
    required double globalScore,
    required int totalLessonsCompleted,
    required int totalQuizzesPassed,
    required List<String> completedLessonIds,
    DateTime? nextPracticalLessonDate,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
}
