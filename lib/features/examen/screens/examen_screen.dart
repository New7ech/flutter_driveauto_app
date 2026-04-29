// DriveAuto — examen_screen.dart
// Role : Examen blanc 40 questions QCM — design premium avec badges lettres

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/serie_provider.dart';

const int _dureeExamenMinutes = 30;

class ExamenScreen extends ConsumerStatefulWidget {
  const ExamenScreen({super.key});

  @override
  ConsumerState<ExamenScreen> createState() => _ExamenScreenState();
}

class _ExamenScreenState extends ConsumerState<ExamenScreen> {
  Timer? _timer;
  int _secondesRestantes = _dureeExamenMinutes * 60;
  bool _examenDemarre = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _demarrerTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondesRestantes > 0) {
          _secondesRestantes--;
        } else {
          _terminerExamen();
        }
      });
    });
  }

  void _terminerExamen() {
    _timer?.cancel();
    final state = ref.read(examenProvider);
    if (state.questions.isEmpty) return;
    context.push('/examen/resultats', extra: state);
  }

  void _quitterExamen() {
    _timer?.cancel();
    ref.read(examenProvider.notifier).reset();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppConstants.routeDashboard);
    }
  }

  String get _tempsFormate {
    final min = (_secondesRestantes ~/ 60).toString().padLeft(2, '0');
    final sec = (_secondesRestantes % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  Color get _timerColor {
    if (_secondesRestantes > 600) return Colors.white;
    if (_secondesRestantes > 180) return AppConstants.yellowBF;
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    final examenState = ref.watch(examenProvider);

    if (examenState.questions.isEmpty && !_examenDemarre) {
      return _buildStartPage(context);
    }

    if (examenState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = examenState.questions[examenState.indexActuel];
    final total = examenState.questions.length;
    final progress = (examenState.indexActuel + 1) / total;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final quitter = await _confirmerQuitter(context);
        if (quitter && context.mounted) _quitterExamen();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Examen blanc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                '${examenState.reponsesUtilisateur.length} / $total réponses',
                style:
                    const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final quitter = await _confirmerQuitter(context);
              if (quitter && context.mounted) _quitterExamen();
            },
          ),
          actions: [
            // Timer pill
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _secondesRestantes <= 180
                        ? Colors.red.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded, size: 15, color: _timerColor),
                      const SizedBox(width: 5),
                      Text(
                        _tempsFormate,
                        style: TextStyle(
                          color: _timerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            _buildQuestionHeader(
              context,
              examenState.indexActuel + 1,
              total,
              question.serieEmoji,
              question.serieTitre,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildQuestionContent(
                  context,
                  question,
                  examenState.reponseActuelle,
                ),
              ),
            ),
            _buildNavigation(context, examenState, total),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // PAGE DE DÉMARRAGE
  // ────────────────────────────────────────────────────────────────────

  Widget _buildStartPage(BuildContext context) {
    // Données Firestore en priorité, fallback sur le cache local Hive.
    final remoteAsync = ref.watch(seriesRemoteProvider);
    final localSeries = ref.watch(seriesProvider);
    final series = remoteAsync.valueOrNull ?? localSeries;
    final totalQuestions = series
        .expand((s) => s.diapositives)
        .where((d) => d.aUneQuestion)
        .length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header gradient
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppConstants.primaryColor, Color(0xFF005C38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 36),
                  child: Column(
                    children: [
                      // Top bar avec retour
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Icône animée
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child:
                              Text('🎓', style: TextStyle(fontSize: 46)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Examen Blanc',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Testez vos connaissances sur toutes les séries de cours',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenu
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(context, totalQuestions),
                const SizedBox(height: 32),
                // Bouton démarrer
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppConstants.primaryColor,
                        Color(0xFF005C38),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(examenProvider.notifier)
                            .initialiser(series);
                        setState(() {
                          _examenDemarre = true;
                          _secondesRestantes = _dureeExamenMinutes * 60;
                        });
                        _demarrerTimer();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 17),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Commencer l\'examen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Les questions sont mélangées aléatoirement',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, int totalQuestions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infos = [
      _Info(
        icon: Icons.quiz_rounded,
        label: 'Nombre de questions',
        value: '${totalQuestions >= 40 ? 40 : totalQuestions} questions',
        color: AppConstants.primaryColor,
      ),
      _Info(
        icon: Icons.timer_rounded,
        label: 'Durée',
        value: '$_dureeExamenMinutes minutes',
        color: const Color(0xFF2196F3),
      ),
      _Info(
        icon: Icons.emoji_events_rounded,
        label: 'Score minimum',
        value: '35 / 40  (87,5 %)',
        color: AppConstants.yellowBF,
      ),
      _Info(
        icon: Icons.shuffle_rounded,
        label: 'Questions',
        value: 'Mélangées aléatoirement',
        color: const Color(0xFF9C27B0),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            for (var i = 0; i < infos.length; i++) ...[
              _buildInfoRow(context, infos[i]),
              if (i < infos.length - 1)
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, _Info info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(info.icon, color: info.color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(info.label,
                style: const TextStyle(fontSize: 14)),
          ),
          Text(
            info.value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // QUESTION HEADER
  // ────────────────────────────────────────────────────────────────────

  Widget _buildQuestionHeader(
    BuildContext context,
    int numero,
    int total,
    String emoji,
    String serieTitre,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppConstants.primaryColor.withValues(alpha: 0.05),
      child: Row(
        children: [
          // Numéro
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Q$numero',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '/ $total',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    serieTitre,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // CONTENU DE LA QUESTION
  // ────────────────────────────────────────────────────────────────────

  Widget _buildQuestionContent(
    BuildContext context,
    QuestionExamen question,
    int? reponseActuelle,
  ) {
    final diapo = question.diapositive;
    final q = question.question;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image / placeholder
        if (diapo.imagePath != null && diapo.imagePath!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              diapo.imagePath!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) =>
                  _buildImagePlaceholder(question),
            ),
          )
        else
          _buildImagePlaceholder(question),

        const SizedBox(height: 18),

        // Contexte (titre diapo)
        Text(
          diapo.titre,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),

        // Texte de la question dans une card colorée
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor.withValues(alpha: 0.07),
                AppConstants.primaryColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppConstants.primaryColor.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            q.texte,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.4,
                ),
          ),
        ),
        const SizedBox(height: 18),

        // Options avec badges lettres
        for (var i = 0; i < q.options.length; i++)
          _ExamenOption(
            label: q.options[i],
            index: i,
            isSelected: reponseActuelle == i,
            couleur: AppConstants.primaryColor,
            onTap: () =>
                ref.read(examenProvider.notifier).selectionnerReponse(i),
          ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildImagePlaceholder(QuestionExamen question) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withValues(alpha: 0.12),
            AppConstants.primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppConstants.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Center(
        child: Text(question.serieEmoji,
            style: const TextStyle(fontSize: 38)),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // NAVIGATION
  // ────────────────────────────────────────────────────────────────────

  Widget _buildNavigation(
    BuildContext context,
    ExamenState examenState,
    int total,
  ) {
    final nbReponses = examenState.reponsesUtilisateur.length;
    final isDernier = examenState.estDerniereQuestion;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini barre de réponses
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : nbReponses / total,
                      minHeight: 5,
                      backgroundColor:
                          Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppConstants.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$nbReponses / $total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 15),
                    label: const Text('Précédent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                      side: const BorderSide(color: AppConstants.primaryColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: examenState.estPremierQuestion
                        ? null
                        : () => ref
                            .read(examenProvider.notifier)
                            .questionPrecedente(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isDernier
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppConstants.secondaryColor,
                                Color(0xFF8B0000),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.secondaryColor
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () =>
                                  _confirmerSoumission(context),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 13),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.send_rounded,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Soumettre',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15),
                          label: const Text('Suivant'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => ref
                              .read(examenProvider.notifier)
                              .questionSuivante(),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // DIALOGS
  // ────────────────────────────────────────────────────────────────────

  Future<bool> _confirmerQuitter(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Quitter l\'examen ?',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
              'Votre progression sera perdue. Voulez-vous vraiment quitter ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Non, continuer'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Oui, quitter'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _confirmerSoumission(BuildContext context) async {
    final state = ref.read(examenProvider);
    final nonRepondues = state.total - state.reponsesUtilisateur.length;

    final confirmer = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Soumettre l\'examen ?',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(
              nonRepondues > 0
                  ? 'Il vous reste $nonRepondues question(s) sans réponse. Voulez-vous quand même soumettre ?'
                  : 'Êtes-vous prêt(e) à soumettre votre examen ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Revoir les questions'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Soumettre'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmer) _terminerExamen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTION EXAMEN avec badge lettre
// ─────────────────────────────────────────────────────────────────────────────

const _kLettersExamen = ['A', 'B', 'C', 'D', 'E', 'F'];

class _ExamenOption extends StatelessWidget {
  const _ExamenOption({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.couleur,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool isSelected;
  final Color couleur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final letter = index < _kLettersExamen.length
        ? _kLettersExamen[index]
        : '${index + 1}';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? couleur.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? couleur : Colors.grey.shade300,
            width: isSelected ? 2 : 1.2,
          ),
        ),
        child: Row(
          children: [
            // Badge lettre
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? couleur : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? couleur : null,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  height: 1.3,
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle_rounded,
                    color: couleur, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Info {
  const _Info(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}
