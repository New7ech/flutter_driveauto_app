// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instructeur.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InstructeurImpl _$$InstructeurImplFromJson(Map<String, dynamic> json) =>
    _$InstructeurImpl(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      telephone: json['telephone'] as String,
      photoUrl: json['photoUrl'] as String?,
      noteMoyenne: (json['noteMoyenne'] as num).toDouble(),
    );

Map<String, dynamic> _$$InstructeurImplToJson(_$InstructeurImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'telephone': instance.telephone,
      'photoUrl': instance.photoUrl,
      'noteMoyenne': instance.noteMoyenne,
    };
