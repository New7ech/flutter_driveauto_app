/// DriveAuto — sync_manager.dart
/// Rôle : Synchronisation des données locales vers Firestore
/// Auteur : DriveAuto Team
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SyncManager {
  final FirebaseFirestore firestore;

  SyncManager(this.firestore);

  Future<void> syncAll() async {
    try {
      final syncBox = await Hive.openBox('sync_queue');

      final keys = syncBox.keys.toList();
      for (var key in keys) {
        final pendingData = syncBox.get(key);
        if (pendingData != null && pendingData is Map) {
          final table = pendingData['table'] as String;
          final payload = Map<String, dynamic>.from(pendingData['payload']);
          final id = payload['id'] as String?;

          if (id == null) continue;

          try {
            await firestore
                .collection(table)
                .doc(id)
                .set(payload, SetOptions(merge: true));
            await syncBox.delete(key);
          } catch (e) {
            // Echec pour cet élément, on le garde pour la prochaine tentative
          }
        }
      }
    } catch (e) {
      // Erreur globale de sync : on retentera plus tard
    }
  }
}
