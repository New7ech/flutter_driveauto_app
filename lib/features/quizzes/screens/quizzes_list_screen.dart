/// DriveAuto — quizzes_list_screen.dart
/// Rôle : Interface listant les Quizzes et Examens blancs
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/quiz.dart';
import '../../../providers/repository_providers.dart';

final quizzesListProvider = FutureProvider<List<Quiz>>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.getQuizzes();
});

class QuizzesListScreen extends ConsumerWidget {
  const QuizzesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesState = ref.watch(quizzesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examens Blancs & Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(quizzesListProvider),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: quizzesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppConstants.secondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(quizzesListProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const Center(
              child: Text('Aucun quiz disponible pour le moment.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(quizzesListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                // TODO: Retrieve actual progress from UserProgress
                final hasPassed = false;
                final score = 0.0;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: hasPassed
                          ? Colors.green.withOpacity(0.1)
                          : AppConstants.primaryColor.withOpacity(0.1),
                      child: Icon(
                        hasPassed ? Icons.emoji_events : Icons.quiz,
                        color: hasPassed
                            ? Colors.green
                            : AppConstants.primaryColor,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      quiz.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.format_list_bulleted,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${quiz.questions.length} questions',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            hasPassed ? Icons.check_circle : Icons.schedule,
                            size: 16,
                            color: hasPassed
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasPassed ? '${score.toInt()}%' : 'À passer',
                            style: TextStyle(
                              color: hasPassed
                                  ? Colors.green
                                  : Colors.grey.shade600,
                              fontWeight: hasPassed
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                    onTap: () {
                      context.push('/quiz/${quiz.id}', extra: quiz);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
