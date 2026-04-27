// DriveAuto - user_repository.dart
// Role: Depot pour la gestion du profil et de la progression utilisateur (Firestore)
// Auteur : DriveAuto Team

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user_progress.dart';

class UserRepository {
  final FirebaseFirestore? _firestore;

  UserRepository({required FirebaseFirestore? firestore})
    : _firestore = firestore;

  Future<void> saveUserProfile({
    required String userId,
    required String email,
    required String displayName,
    required String role,
    required bool emailVerified,
    required String provider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      await firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': email,
        'displayName': displayName,
        'role': role,
        'emailVerified': emailVerified,
        'provider': provider,
        if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt),
        if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur de sauvegarde du profil utilisateur : $e');
    }
  }

  Future<UserProgress?> getUserProgress(String userId) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return null;
      final doc = await firestore
          .collection('users_progress')
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserProgress.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur de recuperation de la progression : $e');
    }
  }

  Future<void> saveUserProgress(UserProgress progress) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return;
      await firestore
          .collection('users_progress')
          .doc(progress.userId)
          .set(progress.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur de sauvegarde de la progression : $e');
    }
  }
}
