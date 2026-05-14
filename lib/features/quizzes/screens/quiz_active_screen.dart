/// DriveAuto — quiz_active_screen.dart
/// Rôle : Interface de passage d'un Quiz (QCM interactif)
/// Auteur : DriveAuto Team
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/quiz.dart';

class QuizActiveScreen extends ConsumerStatefulWidget {
  final Quiz quiz;

  const QuizActiveScreen({super.key, required this.quiz});

  @override
  ConsumerState<QuizActiveScreen> createState() => _QuizActiveScreenState();
}

class _QuizActiveScreenState extends ConsumerState<QuizActiveScreen> {
  int _currentIndex = 0;
  List<int> _selectedAnswers = [];
  Timer? _timer;
  int _timeLeft = 30; // 30 secondes par question

  @override
  void initState() {
    super.initState();
    // On initialise toutes les réponses à -1 (non répondu)
    _selectedAnswers = List.filled(widget.quiz.questions.length, -1);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        // Le temps est écoulé
        _timer?.cancel();
        // Option choisie par défaut (aucune) : on compte comme faux
        _nextQuestion(forceNext: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextQuestion({bool forceNext = false}) {
    if (!forceNext && _selectedAnswers[_currentIndex] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner une réponse pour continuer.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppConstants.secondaryColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startTimer();
    } else {
      _showResults();
    }
  }

  void _showResults() {
    int correctAnswers = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_selectedAnswers[i] == widget.quiz.questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    final score = widget.quiz.questions.isEmpty
        ? 0.0
        : (correctAnswers / widget.quiz.questions.length) * 100;

    // Le routing va vers les résultats en transmettant le score calculé et les réponses
    context.pushReplacement(
      '/quiz/results',
      extra: {
        'quiz': widget.quiz,
        'score': score,
        'userAnswers': _selectedAnswers,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.titre)),
        body: const Center(
          child: Text("Oups, ce quiz ne contient aucune question."),
        ),
      );
    }

    final question = widget.quiz.questions[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1}/${widget.quiz.questions.length}',
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicateur de progression visuelle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / widget.quiz.questions.length,
                      color: AppConstants.primaryColor,
                      backgroundColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$_timeLeft s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _timeLeft <= 5
                          ? Colors.red
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (question.imageUrl != null &&
                  question.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    question.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                question.texte,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Les options de réponse
              ...List.generate(question.options.length, (index) {
                final isSelected = _selectedAnswers[_currentIndex] == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppConstants.primaryColor
                              : (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          width: isSelected ? 2 : 1,
                        ),
                        backgroundColor: isSelected
                            ? AppConstants.primaryColor.withValues(alpha: 0.1)
                            : (isDark
                                  ? AppConstants.cardColorDark
                                  : Colors.white),
                        elevation: isSelected ? 0 : 2,
                      ),
                      onPressed: () {
                        setState(() => _selectedAnswers[_currentIndex] = index);
                      },
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? AppConstants.primaryColor
                                : Colors.grey,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? AppConstants.primaryColor
                                    : (isDark ? Colors.white : Colors.black87),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentIndex == widget.quiz.questions.length - 1
                      ? 'Terminer l\'examen'
                      : 'Question Suivante',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
