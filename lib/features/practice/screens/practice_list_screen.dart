/// DriveAuto — practice_list_screen.dart
/// Rôle : Affiche la liste des sessions pratiques (Manoeuvres, Vérifs)
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/practice.dart';
import '../../../providers/repository_providers.dart';

final practiceListProvider = FutureProvider<List<PracticeSession>>((ref) async {
  final repo = ref.watch(practiceRepositoryProvider);
  return repo.getPracticeSessions();
});

class PracticeListScreen extends ConsumerWidget {
  const PracticeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceState = ref.watch(practiceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratique & Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(practiceListProvider),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: practiceState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text('Aucune session pratique pour le moment.'),
            );
          }

          // Regrouper par catégorie
          final grouped = <String, List<PracticeSession>>{};
          for (var s in sessions) {
            grouped.putIfAbsent(s.category, () => []).add(s);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...entry.value
                      .map((session) => _PracticeCard(session: session))
                      ,
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final PracticeSession session;

  const _PracticeCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/practice/${session.id}', extra: session);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (session.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  session.imageUrl!,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 140,
                    child: Center(child: Icon(Icons.image_not_supported)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (session.isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session.description,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 16,
                        color: AppConstants.secondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${session.items.length} étapes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Text(
                        'Démarrer',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
