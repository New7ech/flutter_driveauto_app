/// DriveAuto — quiz.dart
/// Rôle : Modèle représentant un quiz et ses questions (QCM)
/// Auteur : DriveAuto Team
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'quiz.freezed.dart';
part 'quiz.g.dart';

@freezed
class Quiz with _$Quiz {
  @HiveType(typeId: 1, adapterName: 'QuizAdapter')
  const factory Quiz({
    @HiveField(0) required String id,
    @HiveField(1) required String titre,
    @HiveField(2) required String categorie,
    @HiveField(3) required List<Question> questions,
  }) = _Quiz;

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);
}

@freezed
class Question with _$Question {
  @HiveType(typeId: 2, adapterName: 'QuestionAdapter')
  const factory Question({
    @HiveField(0) required String id,
    @HiveField(1) required String texte,
    @HiveField(2) required List<String> options,
    @HiveField(3) required int correctAnswerIndex,
    @HiveField(4) String? explication,
    @HiveField(5) String? imageUrl,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}
