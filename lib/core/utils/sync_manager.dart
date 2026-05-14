/// DriveAuto — sync_manager.dart
/// Rôle : Synchronisation des données locales vers Firestore
/// Auteur : DriveAuto Team
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SyncManager {
  final FirebaseFirestore firestore;

  SyncManager(this.firestore);

  Future<void> syncAll() async {
    Box? syncBox;
    try {
      syncBox = await Hive.openBox('sync_queue');

      final keys = syncBox.keys.toList();
      for (var key in keys) {
        final pendingData = syncBox.get(key);
        if (pendingData != null && pendingData is Map) {
          final table = pendingData['table'] as String?;
          final payload = pendingData['payload'];
          
          if (table == null || payload is! Map<String, dynamic>) {
            await syncBox.delete(key);
            continue;
          }

          final id = payload['id'] as String?;
          if (id == null) {
            await syncBox.delete(key);
            continue;
          }

          try {
            await firestore
                .collection(table)
                .doc(id)
                .set(payload, SetOptions(merge: true));
            await syncBox.delete(key);
          } catch (e) {
            debugPrint('Sync error for $table/$id: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('SyncManager error: $e');
    } finally {
      await syncBox?.close();
    }
  }
}
