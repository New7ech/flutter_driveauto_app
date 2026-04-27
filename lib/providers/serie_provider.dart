// DriveAuto — serie_provider.dart
// Rôle : Providers Riverpod pour les séries, slides et l'état de l'examen

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/serie_repository.dart';
import '../domain/models/serie.dart';
import 'repository_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SerieNotifier — CRUD mutable (utilisé par l'admin)
// ─────────────────────────────────────────────────────────────────────────────

class SerieNotifier extends StateNotifier<List<Serie>> {
  SerieNotifier(this._repo) : super(_repo.getAllSeries());

  final SerieRepository _repo;

  void reload() => state = _repo.getAllSeries();

  Future<void> saveSerie(Serie serie) async {
    await _repo.saveSerie(serie);
    reload();
  }

  Future<void> deleteSerie(String id) async {
    await _repo.deleteSerie(id);
    reload();
  }

  Future<void> saveDiapositive(String serieId, Diapositive diapo) async {
    await _repo.saveDiapositive(serieId, diapo);
    reload();
  }

  Future<void> deleteDiapositive(String serieId, String diapoId) async {
    await _repo.deleteDiapositive(serieId, diapoId);
    reload();
  }

  Future<void> resetToDefaults() async {
    await _repo.resetToDefaults();
    reload();
  }
}

final seriesNotifierProvider =
    StateNotifierProvider<SerieNotifier, List<Serie>>((ref) {
  return SerieNotifier(ref.watch(serieRepositoryProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// Providers de données (lecture — utilisés par toute l'app)
// ─────────────────────────────────────────────────────────────────────────────

/// Toutes les séries : lit depuis le notifier (inclut les modifs admin).
final seriesProvider = Provider<List<Serie>>((ref) {
  return ref.watch(seriesNotifierProvider);
});

/// Récupère une série par son ID. Retourne null si introuvable.
final serieByIdProvider = Provider.family<Serie?, String>((ref, id) {
  return ref.watch(seriesProvider).where((s) => s.id == id).firstOrNull;
});

// ─────────────────────────────────────────────────────────────────────────────
// Modèles pour l'examen
// ─────────────────────────────────────────────────────────────────────────────

class QuestionExamen {
  final int index;
  final Diapositive diapositive;
  final String serieTitre;
  final String serieEmoji;

  const QuestionExamen({
    required this.index,
    required this.diapositive,
    required this.serieTitre,
    required this.serieEmoji,
  });

  DiapositiveQuestion get question => diapositive.question!;
}

class ExamenState {
  final List<QuestionExamen> questions;
  final int indexActuel;

  // Clé = index dans la liste questions, valeur = index de l'option choisie
  final Map<int, int> reponsesUtilisateur;
  final bool estSoumis;

  const ExamenState({
    required this.questions,
    this.indexActuel = 0,
    this.reponsesUtilisateur = const {},
    this.estSoumis = false,
  });

  ExamenState copyWith({
    List<QuestionExamen>? questions,
    int? indexActuel,
    Map<int, int>? reponsesUtilisateur,
    bool? estSoumis,
  }) {
    return ExamenState(
      questions: questions ?? this.questions,
      indexActuel: indexActuel ?? this.indexActuel,
      reponsesUtilisateur: reponsesUtilisateur ?? this.reponsesUtilisateur,
      estSoumis: estSoumis ?? this.estSoumis,
    );
  }

  bool get estPremierQuestion => indexActuel == 0;
  bool get estDerniereQuestion => indexActuel == questions.length - 1;
  int? get reponseActuelle => reponsesUtilisateur[indexActuel];

  int get nombreReponsesCorrectes {
    int score = 0;
    for (final entry in reponsesUtilisateur.entries) {
      final q = questions[entry.key];
      if (q.question.estCorrecte(entry.value)) score++;
    }
    return score;
  }

  int get total => questions.length;
  double get pourcentage => total == 0 ? 0 : nombreReponsesCorrectes / total;

  // Seuil de réussite : 35/40 = 87,5 %
  bool get estRecu => total > 0 && nombreReponsesCorrectes >= (total * 0.875).ceil();
}

// ─────────────────────────────────────────────────────────────────────────────
// StateNotifier pour l'examen
// ─────────────────────────────────────────────────────────────────────────────

class ExamenNotifier extends StateNotifier<ExamenState> {
  ExamenNotifier() : super(const ExamenState(questions: []));

  static const int _nombreQuestionsExamen = 40;

  /// Génère les questions de l'examen depuis toutes les séries.
  void initialiser(List<Serie> series) {
    final toutesQuestions = <QuestionExamen>[];

    for (final serie in series) {
      for (final diapo in serie.diapositives) {
        if (diapo.aUneQuestion) {
          toutesQuestions.add(
            QuestionExamen(
              index: 0, // recalculé après le mélange
              diapositive: diapo,
              serieTitre: serie.titre,
              serieEmoji: serie.emoji,
            ),
          );
        }
      }
    }

    // Mélanger de façon aléatoire
    toutesQuestions.shuffle(Random());

    // Prendre au maximum 40 questions
    final selection = toutesQuestions
        .take(_nombreQuestionsExamen)
        .toList();

    // Réassigner les index après le mélange
    final questionsIndexees = [
      for (var i = 0; i < selection.length; i++)
        QuestionExamen(
          index: i,
          diapositive: selection[i].diapositive,
          serieTitre: selection[i].serieTitre,
          serieEmoji: selection[i].serieEmoji,
        ),
    ];

    state = ExamenState(questions: questionsIndexees);
  }

  void allerA(int index) {
    if (index < 0 || index >= state.questions.length) return;
    state = state.copyWith(indexActuel: index);
  }

  void questionSuivante() => allerA(state.indexActuel + 1);
  void questionPrecedente() => allerA(state.indexActuel - 1);

  void selectionnerReponse(int indexOption) {
    if (state.estSoumis) return;
    final nouvelles = Map<int, int>.from(state.reponsesUtilisateur);
    nouvelles[state.indexActuel] = indexOption;
    state = state.copyWith(reponsesUtilisateur: nouvelles);
  }

  void soumettre() {
    state = state.copyWith(estSoumis: true);
  }

  void reinitialiser(List<Serie> series) {
    state = const ExamenState(questions: []);
    initialiser(series);
  }

  /// Remet l'examen à zéro sans relancer (utilisé lors de l'abandon).
  void reset() {
    state = const ExamenState(questions: []);
  }
}

final examenProvider =
    StateNotifierProvider<ExamenNotifier, ExamenState>((ref) {
  return ExamenNotifier();
});
