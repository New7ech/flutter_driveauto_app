/// DriveAuto — courses_list_screen.dart
/// Rôle : Écran listant toutes les leçons du code de la route, avec Lazy Loading
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/lecon.dart';
import '../../../providers/repository_providers.dart';
import '../widgets/lesson_card.dart';

// Provider générant le chargement asynchrone sécurisé en mode Offline-First
final leconsListProvider = FutureProvider<List<Lecon>>((ref) async {
  final repo = ref.watch(leconRepositoryProvider);
  return repo.getLecons(); // Tente Firestore, puis lit Hive si pas de réseau
});

class CoursesListScreen extends ConsumerWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leconsState = ref.watch(leconsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cours de Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(leconsListProvider),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: leconsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.signal_wifi_off,
                  color: AppConstants.secondaryColor,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Une erreur est survenue lors du chargement.\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(leconsListProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (lecons) {
          if (lecons.isEmpty) {
            return const Center(
              child: Text('Aucune leçon disponible pour le moment.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(leconsListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
              itemCount: lecons.length,
              // Utilisation d'un ListView.builder pour une excellente gestion de la mémoire (Lazy Loading MVP)
              itemBuilder: (context, index) {
                final lecon = lecons[index];
                return LessonCard(
                  lecon: lecon,
                  onTap: () {
                    // Passage de tout l'objet en extra pour éviter un Re-fetch côté détail !
                    context.push('/courses/${lecon.id}', extra: lecon);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
