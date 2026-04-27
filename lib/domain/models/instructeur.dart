/// DriveAuto — instructeur.dart
/// Rôle : Modèle représentant un instructeur pour les leçons pratiques
/// Auteur : DriveAuto Team
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'instructeur.freezed.dart';
part 'instructeur.g.dart';

@freezed
class Instructeur with _$Instructeur {
  const factory Instructeur({
    required String id,
    required String nom,
    required String prenom,
    required String telephone,
    String? photoUrl,
    required double noteMoyenne,
  }) = _Instructeur;

  factory Instructeur.fromJson(Map<String, dynamic> json) =>
      _$InstructeurFromJson(json);
}
