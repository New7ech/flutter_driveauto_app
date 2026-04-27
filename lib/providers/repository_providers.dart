/// DriveAuto — repository_providers.dart
/// Rôle : Injection de dépendances globales pour les Repositories (Data Layer)
/// Auteur : DriveAuto Team
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/lecon_repository.dart';
import '../data/repositories/practice_repository.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/repositories/serie_repository.dart';
import '../data/repositories/user_repository.dart';

// --- FOURNISSEURS DE BASE (Core Clients) ---

final firebaseFirestoreProvider = Provider<FirebaseFirestore?>((ref) {
  if (Firebase.apps.isEmpty) return null;
  return FirebaseFirestore.instance;
});

final hiveLeconsBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.hiveLeconsBox);
});

final hiveQuizzesBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.hiveQuizzesBox);
});

// --- FOURNISSEURS DES REPOSITORIES ---

/// Fournit l'accès aux données des Leçons (Offline First)
final leconRepositoryProvider = Provider<LeconRepository>((ref) {
  return LeconRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    box: ref.watch(hiveLeconsBoxProvider),
  );
});

/// Fournit l'accès aux données des Quizzes (Offline First)
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
    box: ref.watch(hiveQuizzesBoxProvider),
  );
});

/// Fournit l'accès à la progression utilisateur dans Firestore
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(firestore: ref.watch(firebaseFirestoreProvider));
});

final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  return PracticeRepository();
});

final hiveSeriesBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.hiveSeriesBox);
});

/// Fournit l'accès CRUD aux séries de cours (données locales persistées)
final serieRepositoryProvider = Provider<SerieRepository>((ref) {
  return SerieRepository(ref.watch(hiveSeriesBoxProvider));
});
