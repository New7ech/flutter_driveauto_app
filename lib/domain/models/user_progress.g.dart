// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      userId: json['userId'] as String,
      globalScore: (json['globalScore'] as num).toDouble(),
      totalLessonsCompleted: (json['totalLessonsCompleted'] as num).toInt(),
      totalQuizzesPassed: (json['totalQuizzesPassed'] as num).toInt(),
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextPracticalLessonDate: json['nextPracticalLessonDate'] == null
          ? null
          : DateTime.parse(json['nextPracticalLessonDate'] as String),
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'globalScore': instance.globalScore,
      'totalLessonsCompleted': instance.totalLessonsCompleted,
      'totalQuizzesPassed': instance.totalQuizzesPassed,
      'completedLessonIds': instance.completedLessonIds,
      'nextPracticalLessonDate': instance.nextPracticalLessonDate
          ?.toIso8601String(),
    };
