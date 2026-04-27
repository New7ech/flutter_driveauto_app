// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizAdapter extends TypeAdapter<_$QuizImpl> {
  @override
  final int typeId = 1;

  @override
  _$QuizImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$QuizImpl(
      id: fields[0] as String,
      titre: fields[1] as String,
      categorie: fields[2] as String,
      questions: (fields[3] as List).cast<Question>(),
    );
  }

  @override
  void write(BinaryWriter writer, _$QuizImpl obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titre)
      ..writeByte(2)
      ..write(obj.categorie)
      ..writeByte(3)
      ..write(obj.questions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionAdapter extends TypeAdapter<_$QuestionImpl> {
  @override
  final int typeId = 2;

  @override
  _$QuestionImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$QuestionImpl(
      id: fields[0] as String,
      texte: fields[1] as String,
      options: (fields[2] as List).cast<String>(),
      correctAnswerIndex: fields[3] as int,
      explication: fields[4] as String?,
      imageUrl: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, _$QuestionImpl obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.texte)
      ..writeByte(3)
      ..write(obj.correctAnswerIndex)
      ..writeByte(4)
      ..write(obj.explication)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.options);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuizImpl _$$QuizImplFromJson(Map<String, dynamic> json) => _$QuizImpl(
  id: json['id'] as String,
  titre: json['titre'] as String,
  categorie: json['categorie'] as String,
  questions: (json['questions'] as List<dynamic>)
      .map((e) => Question.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$QuizImplToJson(_$QuizImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'categorie': instance.categorie,
      'questions': instance.questions,
    };

_$QuestionImpl _$$QuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionImpl(
      id: json['id'] as String,
      texte: json['texte'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctAnswerIndex: (json['correctAnswerIndex'] as num).toInt(),
      explication: json['explication'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$QuestionImplToJson(_$QuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'texte': instance.texte,
      'options': instance.options,
      'correctAnswerIndex': instance.correctAnswerIndex,
      'explication': instance.explication,
      'imageUrl': instance.imageUrl,
    };
