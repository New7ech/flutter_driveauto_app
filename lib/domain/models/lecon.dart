/// DriveAuto — lecon.dart
/// Rôle : Modèle représentant une leçon théorique de conduite
/// Auteur : DriveAuto Team
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'lecon.freezed.dart';
part 'lecon.g.dart';

@freezed
class Lecon with _$Lecon {
  @HiveType(typeId: 0, adapterName: 'LeconAdapter')
  const factory Lecon({
    @HiveField(0) required String id,
    @HiveField(1) required String titre,
    @HiveField(2) required String categorie,
    @HiveField(3) required String texteRiche,
    @HiveField(4) String? imageUrl,
    @HiveField(5) String? youtubeVideoId,
    @HiveField(6) @Default(false) bool isCompleted,
  }) = _Lecon;

  factory Lecon.fromJson(Map<String, dynamic> json) => _$LeconFromJson(json);
}
