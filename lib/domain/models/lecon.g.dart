// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lecon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeconAdapter extends TypeAdapter<_$LeconImpl> {
  @override
  final int typeId = 0;

  @override
  _$LeconImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$LeconImpl(
      id: fields[0] as String,
      titre: fields[1] as String,
      categorie: fields[2] as String,
      texteRiche: fields[3] as String,
      imageUrl: fields[4] as String?,
      youtubeVideoId: fields[5] as String?,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, _$LeconImpl obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titre)
      ..writeByte(2)
      ..write(obj.categorie)
      ..writeByte(3)
      ..write(obj.texteRiche)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.youtubeVideoId)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeconAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeconImpl _$$LeconImplFromJson(Map<String, dynamic> json) => _$LeconImpl(
  id: json['id'] as String,
  titre: json['titre'] as String,
  categorie: json['categorie'] as String,
  texteRiche: json['texteRiche'] as String,
  imageUrl: json['imageUrl'] as String?,
  youtubeVideoId: json['youtubeVideoId'] as String?,
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$$LeconImplToJson(_$LeconImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titre': instance.titre,
      'categorie': instance.categorie,
      'texteRiche': instance.texteRiche,
      'imageUrl': instance.imageUrl,
      'youtubeVideoId': instance.youtubeVideoId,
      'isCompleted': instance.isCompleted,
    };
