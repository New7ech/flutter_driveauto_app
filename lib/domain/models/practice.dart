/// DriveAuto — practice.dart
/// Rôle : Modèles pour les sessions de conduite pratique et les listes de vérification
/// Auteur : DriveAuto Team
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'practice.freezed.dart';
part 'practice.g.dart';

@freezed
class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    required String id,
    required String task,
    required String detail, // Petite explication ou conseil
    @Default(false) bool isChecked,
  }) = _ChecklistItem;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);
}

@freezed
class PracticeSession with _$PracticeSession {
  const factory PracticeSession({
    required String id,
    required String title,
    required String description,
    required String category, // ex: 'Vérifications intérieures', 'Manoeuvres'
    required List<ChecklistItem> items,
    @Default(false) bool isCompleted,
    String? imageUrl,
  }) = _PracticeSession;

  factory PracticeSession.fromJson(Map<String, dynamic> json) =>
      _$PracticeSessionFromJson(json);
}
