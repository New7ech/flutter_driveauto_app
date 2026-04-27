// DriveAuto — serie_repository.dart
// Role : CRUD des series et diapositives avec persistence Hive.
// Les donnees statiques de CoursData servent de seed au premier lancement.

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../data/local/cours_data.dart';
import '../../domain/models/serie.dart';

class SerieRepository {
  static const String _key = 'series_v1';

  final Box _box;

  SerieRepository(this._box) {
    _seedIfNeeded();
  }

  // ── Lecture ──────────────────────────────────────────────────────

  List<Serie> getAllSeries() {
    final raw = _box.get(_key);
    if (raw == null) return CoursData.series;
    try {
      final list = jsonDecode(raw as String) as List;
      return list
          .map((m) => _serieFromMap(m as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return CoursData.series;
    }
  }

  Serie? getSerieById(String id) {
    return getAllSeries().where((s) => s.id == id).firstOrNull;
  }

  // ── Ecriture ─────────────────────────────────────────────────────

  Future<void> saveSerie(Serie serie) async {
    final all = getAllSeries();
    final idx = all.indexWhere((s) => s.id == serie.id);
    if (idx >= 0) {
      all[idx] = serie;
    } else {
      all.add(serie);
    }
    await _persist(all);
  }

  Future<void> deleteSerie(String id) async {
    final all = getAllSeries()..removeWhere((s) => s.id == id);
    await _persist(all);
  }

  Future<void> saveDiapositive(String serieId, Diapositive diapo) async {
    final all = getAllSeries();
    final idx = all.indexWhere((s) => s.id == serieId);
    if (idx < 0) return;
    final serie = all[idx];
    final slides = List<Diapositive>.from(serie.diapositives);
    final si = slides.indexWhere((d) => d.id == diapo.id);
    if (si >= 0) {
      slides[si] = diapo;
    } else {
      slides.add(diapo);
    }
    // Re-ordonner
    final sorted = slides.toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));
    all[idx] = Serie(
      id: serie.id,
      titre: serie.titre,
      description: serie.description,
      couvertureImage: serie.couvertureImage,
      categorie: serie.categorie,
      couleurHex: serie.couleurHex,
      emoji: serie.emoji,
      diapositives: sorted,
    );
    await _persist(all);
  }

  Future<void> deleteDiapositive(String serieId, String diapoId) async {
    final all = getAllSeries();
    final idx = all.indexWhere((s) => s.id == serieId);
    if (idx < 0) return;
    final serie = all[idx];
    final slides = serie.diapositives
        .where((d) => d.id != diapoId)
        .toList();
    all[idx] = Serie(
      id: serie.id,
      titre: serie.titre,
      description: serie.description,
      couvertureImage: serie.couvertureImage,
      categorie: serie.categorie,
      couleurHex: serie.couleurHex,
      emoji: serie.emoji,
      diapositives: slides,
    );
    await _persist(all);
  }

  /// Remet les donnees par defaut (CoursData.series).
  Future<void> resetToDefaults() async {
    await _persist(CoursData.series);
  }

  // ── Persistence interne ──────────────────────────────────────────

  void _seedIfNeeded() {
    if (!_box.containsKey(_key)) {
      _box.put(
        _key,
        jsonEncode(CoursData.series.map(_serieToMap).toList()),
      );
    }
  }

  Future<void> _persist(List<Serie> series) async {
    await _box.put(_key, jsonEncode(series.map(_serieToMap).toList()));
  }

  // ── Serialisation ────────────────────────────────────────────────

  static Map<String, dynamic> serieToMap(Serie s) => _serieToMap(s);
  static Serie serieFromMap(Map<String, dynamic> m) => _serieFromMap(m);

  static Map<String, dynamic> _serieToMap(Serie s) => {
        'id': s.id,
        'titre': s.titre,
        'description': s.description,
        'couvertureImage': s.couvertureImage,
        'categorie': s.categorie,
        'couleurHex': s.couleurHex,
        'emoji': s.emoji,
        'diapositives': s.diapositives.map(_diapoToMap).toList(),
      };

  static Serie _serieFromMap(Map<String, dynamic> m) => Serie(
        id: m['id'] as String,
        titre: m['titre'] as String,
        description: m['description'] as String,
        couvertureImage: m['couvertureImage'] as String?,
        categorie: m['categorie'] as String,
        couleurHex: m['couleurHex'] as int,
        emoji: m['emoji'] as String,
        diapositives: (m['diapositives'] as List)
            .map((d) => _diapoFromMap(d as Map<String, dynamic>))
            .toList(),
      );

  static Map<String, dynamic> _diapoToMap(Diapositive d) => {
        'id': d.id,
        'serieId': d.serieId,
        'ordre': d.ordre,
        'titre': d.titre,
        'imagePath': d.imagePath,
        'contenu': d.contenu,
        'question': d.question == null ? null : _questionToMap(d.question!),
      };

  static Diapositive _diapoFromMap(Map<String, dynamic> m) => Diapositive(
        id: m['id'] as String,
        serieId: m['serieId'] as String,
        ordre: m['ordre'] as int,
        titre: m['titre'] as String,
        imagePath: m['imagePath'] as String?,
        contenu: m['contenu'] as String,
        question: m['question'] == null
            ? null
            : _questionFromMap(m['question'] as Map<String, dynamic>),
      );

  static Map<String, dynamic> _questionToMap(DiapositiveQuestion q) => {
        'id': q.id,
        'type': q.type.name,
        'texte': q.texte,
        'options': q.options,
        'reponsesCorrectes': q.reponsesCorrectes,
        'explication': q.explication,
      };

  static DiapositiveQuestion _questionFromMap(Map<String, dynamic> m) =>
      DiapositiveQuestion(
        id: m['id'] as String,
        type: m['type'] == 'checklist'
            ? TypeQuestion.checklist
            : TypeQuestion.qcm,
        texte: m['texte'] as String,
        options: (m['options'] as List).cast<String>(),
        reponsesCorrectes: (m['reponsesCorrectes'] as List).cast<int>(),
        explication: m['explication'] as String?,
      );

  // ── Generateur d'ID unique ────────────────────────────────────────

  static String generateId([String prefix = 'id']) =>
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
}
