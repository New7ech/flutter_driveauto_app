/// DriveAuto — lecon_repository.dart
/// Rôle : Dépôt pour les leçons (Firestore CRUD et cache local Hive)
/// Auteur : DriveAuto Team
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/lecon.dart';

class LeconRepository {
  final FirebaseFirestore? _firestore;
  final Box _box;

  LeconRepository({required FirebaseFirestore? firestore, required Box box})
    : _firestore = firestore,
      _box = box;

  /// Récupère les leçons en Offline-First (Firestore sinon Hive)
  Future<List<Lecon>> getLecons() async {
    try {
      if (_firestore == null) throw Exception('Mock');

      final snapshot = await _firestore!.collection('lecons').get();
      final lecons = snapshot.docs.map((doc) {
        return Lecon.fromJson({...doc.data(), 'id': doc.id});
      }).toList();

      await _box.clear();
      for (var lecon in lecons) {
        await _box.put(lecon.id, lecon);
      }
      return lecons;
    } catch (e) {
      try {
        final cachedLecons = <Lecon>[];
        for (var value in _box.values) {
          if (value is Lecon) {
            cachedLecons.add(value);
          }
        }
        if (cachedLecons.isNotEmpty) {
          return cachedLecons;
        }
      } catch (_) {
        // Type mismatch — clear box and continue
        await _box.clear();
      }

      // --- MODE SIMULATION UI (MOCK) ---
      return [
        Lecon(
          id: '1',
          titre: 'Les Panneaux de Signalisation - L\'essentiel',
          texteRiche:
              'Les panneaux en **triangle** avec bord rouge indiquent un *danger*. Les ronds rouges sont des *interdictions*. Les ronds bleus sont des *obligations*. Soyez prudents !',
          categorie: 'Signalisation',
          imageUrl:
              'https://images.unsplash.com/photo-1596489370014-411a0d7f4be4',
          youtubeVideoId: 'S-7b0hI_vU0',
          isCompleted: false,
        ),
        Lecon(
          id: '2',
          titre: 'Priorités aux intersections',
          texteRiche:
              'En l\'absence de panneaux, la **priorité à droite** s\'applique systématiquement.',
          categorie: 'Règles de circulation',
          imageUrl: 'https://images.unsplash.com/photo-1554223090-bc4236a28723',
          youtubeVideoId: '',
          isCompleted: true,
        ),
        Lecon(
          id: '3',
          titre: 'Les Règles de Stationnement',
          texteRiche:
              'Il est interdit de stationner sur un passage piéton ou devant une sortie de garage...',
          categorie: 'Usage des voies',
          imageUrl: '',
          isCompleted: false,
        ),
      ];
    }
  }

  /// Sauvegarde une leçon existante ou nouvelle (Admin)
  Future<void> saveLecon(Lecon lecon) async {
    try {
      if (_firestore != null) {
        await _firestore.collection('lecons').doc(lecon.id).set(lecon.toJson());
      }
      await _box.put(lecon.id, lecon);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde de la leçon : $e');
    }
  }

  /// Supprime une leçon (Admin)
  Future<void> deleteLecon(String id) async {
    try {
      if (_firestore != null) {
        await _firestore.collection('lecons').doc(id).delete();
      }
      await _box.delete(id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la leçon : $e');
    }
  }
}
