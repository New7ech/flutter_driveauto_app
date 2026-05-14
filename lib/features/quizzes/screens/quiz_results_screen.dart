/// DriveAuto — quiz_results_screen.dart
/// Rôle : Page de résultats, affichage du score, de la correction et sauvegarde Firebase
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/quiz.dart';
import '../../../domain/models/user_progress.dart';
import '../../../providers/repository_providers.dart';
import '../../auth/controllers/auth_controller.dart';

class QuizResultsScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  final double score;
  final List<int> userAnswers;

  const QuizResultsScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.userAnswers,
  });

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  @override
  void initState() {
    super.initState();
    // On sauvegarde le résultat si on est connecté
    _updateUserProgress();
  }

  void _updateUserProgress() async {
    final user = ref.read(currentAuthUserProvider);
    if (user != null) {
      final repo = ref.read(userRepositoryProvider);
      UserProgress? currentProgress;
      try {
        currentProgress = await repo.getUserProgress(user.id);
      } catch (_) {
        return;
      }

      UserProgress updated;
      if (currentProgress != null) {
        updated = currentProgress.copyWith(
          globalScore: (currentProgress.globalScore + widget.score) / 2,
          totalQuizzesPassed: widget.score >= 80.0
              ? currentProgress.totalQuizzesPassed + 1
              : currentProgress.totalQuizzesPassed,
        );
      } else {
        updated = UserProgress(
          userId: user.id,
          totalLessonsCompleted: 0, // Idéalement, à compter dynamiquement
          completedLessonIds: [],
          totalQuizzesPassed: (widget.score >= 80.0) ? 1 : 0,
          globalScore: widget.score,
        );
      }

      // On ignore s'il y a une erreur réseau : en vrai on mettrait dans Hive pour resync
      try {
        await repo.saveUserProgress(updated);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dans beaucoup d'auto-écoles, la réussite est > 80% (ex: 35 bonnes réponses sur 40)
    final hasPassed = widget.score >= 80.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilan de l\'Examen'),
        automaticallyImplyLeading:
            false, // Empêche de revenir en arrière re-jouer la dernière question
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: hasPassed
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 100,
                  color: hasPassed ? Colors.green : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${widget.score.toInt()} %',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasPassed ? Colors.green : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasPassed
                    ? 'Félicitations, vous maîtrisez le sujet !'
                    : 'Continuez de réviser, vous y êtes presque !',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'CORRECTION',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              ...List.generate(widget.quiz.questions.length, (index) {
                final q = widget.quiz.questions[index];
                final userAnswer = index < widget.userAnswers.length
                    ? widget.userAnswers[index]
                    : -1;
                final isCorrect = userAnswer == q.correctAnswerIndex;

                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isCorrect
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.redAccent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: isDark ? AppConstants.cardColorDark : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isCorrect
                                  ? Colors.green
                                  : Colors.redAccent,
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          q.texte,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Réponse sélectionnée
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Votre réponse : ${_answerLabel(q, userAnswer)}',
                            style: TextStyle(
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Si la réponse est fausse, afficher la bonne !
                        if (!isCorrect) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Bonne réponse : ${_answerLabel(q, q.correctAnswerIndex)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],

                        // Explication Pédagogique
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                q.explication ?? 'Aucune explication fournie.',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Retourner au menu des Quizzes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => context.go(AppConstants.routeQuiz),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _answerLabel(Question question, int answerIndex) {
    if (answerIndex < 0 || answerIndex >= question.options.length) {
      return 'Aucune réponse';
    }
    return question.options[answerIndex];
  }
}
