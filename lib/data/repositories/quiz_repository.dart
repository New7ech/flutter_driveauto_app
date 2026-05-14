/// DriveAuto — quiz_repository.dart
/// Rôle : Dépôt pour les Quizzes (Firestore CRUD et cache local Hive)
/// Auteur : DriveAuto Team
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/quiz.dart';

class QuizRepository {
  final FirebaseFirestore? _firestore;
  final Box _box;

  QuizRepository({required FirebaseFirestore? firestore, required Box box})
    : _firestore = firestore,
      _box = box;

  /// Récupère les Quizzes en Offline-First
  Future<List<Quiz>> getQuizzes() async {
    try {
      if (_firestore == null) throw Exception('Mock');

      final snapshot = await _firestore.collection('quizzes').get();
      final quizzes = snapshot.docs.map((doc) {
        return Quiz.fromJson({...doc.data(), 'id': doc.id});
      }).toList();

      await _box.clear();
      for (var quiz in quizzes) {
        await _box.put(quiz.id, quiz);
      }
      return quizzes;
    } catch (e) {
      final cachedQuizzes = _box.values.cast<Quiz>().toList();
      if (cachedQuizzes.isNotEmpty) {
        return cachedQuizzes;
      }

      // Mode simulation basique
      return [
        Quiz(
          id: '1',
          titre: 'Examen Blanc 1 - Signalisation',
          categorie: 'Test',
          questions: [
            Question(
              id: 'q1',
              texte: 'Le panneau rond rouge indique une...',
              options: ['Obligation', 'Interdiction', 'Indication'],
              correctAnswerIndex: 1,
              explication:
                  'Le rond bordé de rouge signale toujours une interdiction.',
              imageUrl: '',
            ),
            Question(
              id: 'q2',
              texte: 'Quelle est la vitesse maximale en agglomération ?',
              options: ['30 km/h', '50 km/h', '70 km/h', '90 km/h'],
              correctAnswerIndex: 1,
              explication:
                  'Sauf indication contraire (ex: zone 30), la limite en ville est de 50 km/h.',
              imageUrl: '',
            ),
          ],
        ),
        Quiz(
          id: '2',
          titre: 'Test Priorités',
          categorie: 'Test',
          questions: [
            Question(
              id: 'q3',
              texte: 'Un feu jaune clignotant en bas vaut...',
              options: [
                'Arrêt absolu',
                'Priorité à droite',
                'Cédez le passage',
              ],
              correctAnswerIndex: 1,
              explication:
                  'Si le feu jaune clignote, on applique la règle de priorité à droite sauf panneau contraire.',
              imageUrl: '',
            ),
          ],
        ),
      ];
    }
  }

  /// Sauvegarde un quiz (Admin)
  Future<void> saveQuiz(Quiz quiz) async {
    try {
      if (_firestore != null) {
        await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toJson());
      }
      await _box.put(quiz.id, quiz);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du quiz : $e');
    }
  }

  /// Supprime un quiz (Admin)
  Future<void> deleteQuiz(String id) async {
    try {
      if (_firestore != null) {
        await _firestore.collection('quizzes').doc(id).delete();
      }
      await _box.delete(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du quiz : $e');
    }
  }
}
