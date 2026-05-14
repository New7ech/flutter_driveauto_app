// DriveAuto — slide_viewer_screen.dart
// Role : Visionneuse de diapositives avec exercices intégrés — design premium

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/serie.dart';
import '../../../providers/serie_provider.dart';
import '../../../providers/series_progress_provider.dart';

class SlideViewerScreen extends ConsumerStatefulWidget {
  const SlideViewerScreen({super.key, required this.serieId});

  final String serieId;

  @override
  ConsumerState<SlideViewerScreen> createState() => _SlideViewerScreenState();
}

class _SlideViewerScreenState extends ConsumerState<SlideViewerScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _progressInitialized = false;

  final Map<String, int> _selectedAnswers = {};
  final Map<String, bool> _validated = {};
  final Map<String, Set<int>> _checklistSelections = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _initProgress() {
    if (_progressInitialized) return;
    _progressInitialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(seriesProgressProvider.notifier).marquerSlide(widget.serieId, 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Priorité : données Firestore (temps réel). Fallback : Hive local.
    final remoteAsync = ref.watch(seriesRemoteProvider);
    final localSerie = ref.watch(serieByIdProvider(widget.serieId));

    if (remoteAsync.isLoading && localSerie == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final remoteSerie = remoteAsync.valueOrNull
        ?.where((s) => s.id == widget.serieId)
        .firstOrNull;
    final serie = remoteSerie ?? localSerie;

    if (serie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cours')),
        body: const Center(child: Text('Série introuvable.')),
      );
    }

    final total = serie.diapositives.length;
    if (total == 0) {
      return Scaffold(
        appBar: AppBar(title: Text(serie.titre)),
        body: const Center(child: Text('Aucune diapositive disponible.')),
      );
    }

    _initProgress();

    final progress = total == 0 ? 0.0 : (_currentPage + 1) / total;
    final couleur = Color(serie.couleurHex);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serie.titre,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${serie.emoji}  ${serie.categorie}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          // Indicateur numéroté
          _buildSlideCounter(total, couleur),
          // PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: total,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                ref
                    .read(seriesProgressProvider.notifier)
                    .marquerSlide(widget.serieId, i);
              },
              itemBuilder: (context, index) {
                final diapo = serie.diapositives[index];
                return _buildSlidePage(context, diapo, couleur);
              },
            ),
          ),
          // Barre de navigation
          _buildNavigationBar(total, couleur),
        ],
      ),
    );
  }

  Widget _buildSlideCounter(int total, Color couleur) {
    return Container(
      color: couleur.withValues(alpha: 0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < total && total <= 10; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: i == _currentPage ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? couleur
                        : couleur.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              if (total > 10)
                Text(
                  'Slide ${_currentPage + 1}',
                  style: TextStyle(
                    color: couleur,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1} / $total',
              style: TextStyle(
                fontSize: 12,
                color: couleur,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidePage(
    BuildContext context,
    Diapositive diapo,
    Color couleur,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSection(diapo, couleur),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diapo.titre,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                _buildRichContent(context, diapo.contenu),
              ],
            ),
          ),
          if (diapo.aUneQuestion) ...[
            const SizedBox(height: 24),
            _buildExerciceSection(context, diapo, couleur),
          ],
        ],
      ),
    );
  }

  Widget _buildImageSection(Diapositive diapo, Color couleur) {
    final source = diapo.imagePath?.trim();
    if (source == null || source.isEmpty) {
      return _buildImagePlaceholder(diapo, couleur);
    }

    if (_isHttpUrl(source)) {
      return _wrapSlideImage(_buildNetworkImage(source, diapo, couleur));
    }

    if (_isFirebaseStorageReference(source)) {
      return FutureBuilder<String>(
        future: _resolveFirebaseStorageUrl(source),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _wrapSlideImage(
              _buildNetworkImage(snapshot.data!, diapo, couleur),
            );
          }

          if (snapshot.hasError) {
            return _buildImagePlaceholder(diapo, couleur);
          }

          return _buildImageLoading(couleur);
        },
      );
    }

    if (_isLocalFilePath(source)) {
      return _wrapSlideImage(
        Image.file(
          File(source),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => _buildImagePlaceholder(diapo, couleur),
        ),
      );
    }

    return _wrapSlideImage(
      Image.asset(
        source,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _buildImagePlaceholder(diapo, couleur),
      ),
    );
  }

  bool _isHttpUrl(String source) {
    return source.startsWith('http://') || source.startsWith('https://');
  }

  bool _isLocalFilePath(String source) {
    return source.startsWith('/') || (source.length > 2 && source[1] == ':');
  }

  bool _isFirebaseStorageReference(String source) {
    return source.startsWith('gs://') || source.startsWith('series/');
  }

  Future<String> _resolveFirebaseStorageUrl(String source) {
    final ref = source.startsWith('gs://')
        ? FirebaseStorage.instance.refFromURL(source)
        : FirebaseStorage.instance.ref(source);
    return ref.getDownloadURL();
  }

  Widget _buildNetworkImage(String url, Diapositive diapo, Color couleur) {
    return Image.network(
      url,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) => _buildImagePlaceholder(diapo, couleur),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _buildImageLoading(couleur);
      },
    );
  }

  Widget _wrapSlideImage(Widget child) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: child,
    );
  }

  Widget _buildImageLoading(Color couleur) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Center(child: CircularProgressIndicator(color: couleur)),
    );
  }

  Widget _buildImagePlaceholder(Diapositive diapo, Color couleur) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [couleur, couleur.withValues(alpha: 0.45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Cercles décoratifs
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Contenu centré
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    diapo.titre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichContent(BuildContext context, String contenu) {
    return Text(
      contenu,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(height: 1.7, fontSize: 15),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // SECTION EXERCICE
  // ────────────────────────────────────────────────────────────────────

  Widget _buildExerciceSection(
    BuildContext context,
    Diapositive diapo,
    Color couleur,
  ) {
    final question = diapo.question!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isValidated = _validated[diapo.id] ?? false;
    final isQcm = question.type == TypeQuestion.qcm;

    Color borderColor;
    if (isValidated) {
      borderColor = _isExerciceCorrect(diapo)
          ? Colors.green.shade300
          : Colors.red.shade300;
    } else {
      borderColor = AppConstants.primaryColor.withValues(alpha: 0.3);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF182018) : const Color(0xFFF2FAF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête exercice
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isQcm
                          ? Icons.radio_button_checked_rounded
                          : Icons.checklist_rounded,
                      color: AppConstants.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isQcm ? 'Exercice' : 'Checklist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        isQcm
                            ? 'Une seule bonne réponse'
                            : 'Sélectionnez toutes les bonnes réponses',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppConstants.primaryColor.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Texte de la question
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  question.texte,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Options
              if (isQcm)
                _buildQcmOptions(diapo, question, isValidated)
              else
                _buildChecklistOptions(diapo, question, isValidated),
              const SizedBox(height: 14),
              // Bouton valider / feedback
              if (!isValidated)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Valider ma réponse'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _canValidate(diapo, question)
                        ? () => setState(() => _validated[diapo.id] = true)
                        : null,
                  ),
                )
              else
                _buildFeedback(context, diapo, question),
            ],
          ),
        ),
      ),
    );
  }

  bool _canValidate(Diapositive diapo, DiapositiveQuestion question) {
    if (question.type == TypeQuestion.qcm) {
      return _selectedAnswers.containsKey(diapo.id);
    }
    return (_checklistSelections[diapo.id] ?? <int>{}).isNotEmpty;
  }

  bool _isExerciceCorrect(Diapositive diapo) {
    final question = diapo.question!;
    if (question.type == TypeQuestion.qcm) {
      final selected = _selectedAnswers[diapo.id];
      return selected != null && question.estCorrecte(selected);
    }
    final sel = _checklistSelections[diapo.id] ?? <int>{};
    return question.estSelectionCorrecte(sel);
  }

  Widget _buildQcmOptions(
    Diapositive diapo,
    DiapositiveQuestion question,
    bool isValidated,
  ) {
    return Column(
      children: [
        for (var i = 0; i < question.options.length; i++)
          _QcmOption(
            label: question.options[i],
            index: i,
            isSelected: _selectedAnswers[diapo.id] == i,
            isValidated: isValidated,
            isCorrect: question.estCorrecte(i),
            isUserAnswer: _selectedAnswers[diapo.id] == i,
            onTap: isValidated
                ? null
                : () => setState(() => _selectedAnswers[diapo.id] = i),
          ),
      ],
    );
  }

  Widget _buildChecklistOptions(
    Diapositive diapo,
    DiapositiveQuestion question,
    bool isValidated,
  ) {
    final selections = _checklistSelections[diapo.id] ?? <int>{};
    return Column(
      children: [
        for (var i = 0; i < question.options.length; i++)
          _ChecklistOption(
            label: question.options[i],
            index: i,
            isChecked: selections.contains(i),
            isValidated: isValidated,
            isCorrect: question.estCorrecte(i),
            onChanged: isValidated
                ? null
                : (checked) => setState(() {
                    final newSet = Set<int>.from(selections);
                    if (checked) {
                      newSet.add(i);
                    } else {
                      newSet.remove(i);
                    }
                    _checklistSelections[diapo.id] = newSet;
                  }),
          ),
      ],
    );
  }

  Widget _buildFeedback(
    BuildContext context,
    Diapositive diapo,
    DiapositiveQuestion question,
  ) {
    final correct = _isExerciceCorrect(diapo);
    final couleurFeedback = correct ? const Color(0xFF1B8A4E) : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: couleurFeedback.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: couleurFeedback.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: couleurFeedback.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: couleurFeedback,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correct ? '✅ Bonne réponse !' : '❌ Mauvaise réponse',
                      style: TextStyle(
                        color: couleurFeedback,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (question.explication != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        question.explication!,
                        style: TextStyle(
                          color: couleurFeedback.withValues(alpha: 0.85),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Réessayer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
            side: const BorderSide(color: AppConstants.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => setState(() {
            _validated.remove(diapo.id);
            _selectedAnswers.remove(diapo.id);
            _checklistSelections.remove(diapo.id);
          }),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // BARRE DE NAVIGATION
  // ────────────────────────────────────────────────────────────────────

  Widget _buildNavigationBar(int total, Color couleur) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == total - 1;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 15),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: couleur,
                  side: BorderSide(color: couleur),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isFirst ? null : () => _goToPage(_currentPage - 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isLast
                  ? FilledButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Terminer'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : FilledButton.icon(
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                      ),
                      label: const Text('Suivant'),
                      style: FilledButton.styleFrom(
                        backgroundColor: couleur,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _goToPage(_currentPage + 1),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS D'OPTIONS
// ─────────────────────────────────────────────────────────────────────────────

const _kLetters = ['A', 'B', 'C', 'D', 'E', 'F'];

class _QcmOption extends StatelessWidget {
  const _QcmOption({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isValidated,
    required this.isCorrect,
    required this.isUserAnswer,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool isSelected;
  final bool isValidated;
  final bool isCorrect;
  final bool isUserAnswer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.transparent;
    Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    Color letterBg = Colors.grey.shade200;
    Color letterColor = Colors.grey.shade600;
    Widget? trailingIcon;

    if (isValidated) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.07);
        textColor = Colors.green.shade800;
        letterBg = Colors.green;
        letterColor = Colors.white;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 20,
        );
      } else if (isUserAnswer && !isCorrect) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.07);
        textColor = Colors.red.shade800;
        letterBg = Colors.red;
        letterColor = Colors.white;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: Colors.red,
          size: 20,
        );
      }
    } else if (isSelected) {
      borderColor = AppConstants.primaryColor;
      bgColor = AppConstants.primaryColor.withValues(alpha: 0.07);
      textColor = AppConstants.primaryColor;
      letterBg = AppConstants.primaryColor;
      letterColor = Colors.white;
    }

    final letter = index < _kLetters.length ? _kLetters[index] : '${index + 1}';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Badge lettre
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: letterBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: letterColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.3),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}

class _ChecklistOption extends StatelessWidget {
  const _ChecklistOption({
    required this.label,
    required this.index,
    required this.isChecked,
    required this.isValidated,
    required this.isCorrect,
    required this.onChanged,
  });

  final String label;
  final int index;
  final bool isChecked;
  final bool isValidated;
  final bool isCorrect;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.transparent;
    Color textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    if (isValidated) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.07);
        textColor = Colors.green.shade800;
      } else if (isChecked && !isCorrect) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.07);
        textColor = Colors.red.shade800;
      }
    } else if (isChecked) {
      borderColor = AppConstants.primaryColor;
      bgColor = AppConstants.primaryColor.withValues(alpha: 0.07);
      textColor = AppConstants.primaryColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: isValidated ? null : (v) => onChanged?.call(v ?? false),
        title: Text(
          label,
          style: TextStyle(color: textColor, fontSize: 14, height: 1.3),
        ),
        activeColor: AppConstants.primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
