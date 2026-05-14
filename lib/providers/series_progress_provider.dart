// DriveAuto — series_progress_provider.dart
// Rôle : Suivi local (Hive) de la progression par série pour l'apprenant.
// Clé Hive : "{userId}_{serieId}" → index de la dernière slide vue.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../features/auth/controllers/auth_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SeriesProgressNotifier extends StateNotifier<Map<String, int>> {
  SeriesProgressNotifier(this._box, this._userId) : super(_load(_box, _userId));

  final Box _box;
  final String _userId;

  static String _key(String userId, String serieId) => '${userId}_$serieId';

  static Map<String, int> _load(Box box, String userId) {
    final Map<String, int> result = {};
    for (final key in box.keys) {
      if (key is! String) continue;
      final k = key;
      if (k.startsWith('${userId}_')) {
        final serieId = k.substring(userId.length + 1);
        final val = box.get(k);
        if (val is int) result[serieId] = val;
      }
    }
    return result;
  }

  /// Enregistre la slide la plus avancée vue dans [serieId].
  /// On ne met à jour que si [slideIndex] est plus grand que la valeur précédente.
  Future<void> marquerSlide(String serieId, int slideIndex) async {
    final current = state[serieId] ?? -1;
    if (slideIndex <= current) return;
    final key = _key(_userId, serieId);
    await _box.put(key, slideIndex);
    state = {...state, serieId: slideIndex};
  }

  /// Retourne l'index de la dernière slide vue (0-based), ou -1 si non commencée.
  int derniereSlideVue(String serieId) => state[serieId] ?? -1;

  /// Retourne vrai si toutes les [totalSlides] slides ont été vues.
  bool estTerminee(String serieId, int totalSlides) {
    if (totalSlides == 0) return false;
    return (state[serieId] ?? -1) >= totalSlides - 1;
  }

  /// Retourne la fraction de progression (0.0 à 1.0).
  double progression(String serieId, int totalSlides) {
    if (totalSlides == 0) return 0;
    final vu = (state[serieId] ?? -1) + 1; // slides vues = index + 1
    return (vu / totalSlides).clamp(0.0, 1.0);
  }

  Future<void> reinitialiserSerie(String serieId) async {
    final key = _key(_userId, serieId);
    await _box.delete(key);
    final updated = Map<String, int>.from(state)..remove(serieId);
    state = updated;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final seriesProgressProvider =
    StateNotifierProvider<SeriesProgressNotifier, Map<String, int>>((ref) {
      final box = Hive.box(AppConstants.hiveSeriesProgressBox);
      final user = ref.watch(currentAuthUserProvider);
      final userId = user?.id ?? 'guest';
      return SeriesProgressNotifier(box, userId);
    });
