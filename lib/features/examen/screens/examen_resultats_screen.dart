// DriveAuto — examen_resultats_screen.dart
// Role : Score, verdict et correction détaillée — design premium

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/serie_provider.dart';

class ExamenResultatsScreen extends ConsumerStatefulWidget {
  const ExamenResultatsScreen({super.key, required this.examenState});

  final ExamenState examenState;

  @override
  ConsumerState<ExamenResultatsScreen> createState() =>
      _ExamenResultatsScreenState();
}

class _ExamenResultatsScreenState
    extends ConsumerState<ExamenResultatsScreen> {
  bool _afficherCorrection = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.examenState;
    final score = state.nombreReponsesCorrectes;
    final total = state.total;
    final recu = state.estRecu;
    final pct = total == 0 ? 0.0 : score / total;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Résultats',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            recu ? AppConstants.primaryColor : AppConstants.secondaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildScoreHero(context, score, total, pct, recu),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildStatRow(context, state),
                  const SizedBox(height: 16),
                  _buildActionsRow(context, state, recu),
                  const SizedBox(height: 12),
                  _buildCorrectionToggle(context),
                  _buildCorrectionSection(context, state),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HERO SCORE
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildScoreHero(
    BuildContext context,
    int score,
    int total,
    double pct,
    bool recu,
  ) {
    final couleur =
        recu ? AppConstants.primaryColor : AppConstants.secondaryColor;
    final lightColor =
        recu ? const Color(0xFF007A4D) : const Color(0xFF8B0000);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [couleur, lightColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      child: Column(
        children: [
          // Verdict + emoji
          Text(
            recu ? '🎉' : '😔',
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 10),
          Text(
            recu ? 'ADMIS(E)' : 'RECALÉ(E)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),
          // Cercle de score
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: couleur,
                    height: 1,
                  ),
                ),
                Text(
                  '/ $total',
                  style: TextStyle(
                    fontSize: 13,
                    color: couleur.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Barre de progression
          SizedBox(
            width: 260,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.28),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(pct * 100).toStringAsFixed(1)} %',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Seuil : 87,5 %',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              recu
                  ? 'Félicitations ! Vous avez obtenu la note de passage.'
                  : 'Continuez à vous entraîner, vous pouvez y arriver !',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // STAT ROW
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildStatRow(BuildContext context, ExamenState state) {
    final incorrect =
        state.reponsesUtilisateur.length - state.nombreReponsesCorrectes;
    final nonRepondu =
        state.total - state.reponsesUtilisateur.length;

    return Row(
      children: [
        _StatCard(
          label: 'Correctes',
          value: '${state.nombreReponsesCorrectes}',
          color: const Color(0xFF1B8A4E),
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Incorrectes',
          value: '$incorrect',
          color: AppConstants.secondaryColor,
          icon: Icons.cancel_rounded,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Sans réponse',
          value: '$nonRepondu',
          color: Colors.grey.shade500,
          icon: Icons.help_rounded,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildActionsRow(
      BuildContext context, ExamenState state, bool recu) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.home_rounded),
            label: const Text('Accueil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              side: const BorderSide(color: AppConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              ref
                  .read(examenProvider.notifier)
                  .reinitialiser(ref.read(seriesProvider));
              context.go('/dashboard');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.primaryColor, Color(0xFF005C38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  ref
                      .read(examenProvider.notifier)
                      .reinitialiser(ref.read(seriesProvider));
                  context.go('/examen');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Réessayer',
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
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // CORRECTION TOGGLE
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildCorrectionToggle(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          setState(() => _afficherCorrection = !_afficherCorrection),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppConstants.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.fact_check_rounded,
                color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _afficherCorrection
                    ? 'Masquer la correction'
                    : 'Voir la correction détaillée',
                style: const TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              _afficherCorrection
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // CORRECTION DÉTAILLÉE
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildCorrectionSection(BuildContext context, ExamenState state) {
    if (!_afficherCorrection) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Correction détaillée',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < state.questions.length; i++)
          _buildCorrectionItem(context, state, i),
      ],
    );
  }

  Widget _buildCorrectionItem(
    BuildContext context,
    ExamenState state,
    int index,
  ) {
    final question = state.questions[index];
    final q = question.question;
    final userAnswer = state.reponsesUtilisateur[index];
    final isCorrect = userAnswer != null && q.estCorrecte(userAnswer);
    final isUnanswered = userAnswer == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeColor;
    IconData badgeIcon;
    String badgeLabel;

    if (isUnanswered) {
      badgeColor = Colors.grey;
      badgeIcon = Icons.help_rounded;
      badgeLabel = 'Non répondu';
    } else if (isCorrect) {
      badgeColor = const Color(0xFF1B8A4E);
      badgeIcon = Icons.check_circle_rounded;
      badgeLabel = 'Correct';
    } else {
      badgeColor = AppConstants.secondaryColor;
      badgeIcon = Icons.cancel_rounded;
      badgeLabel = 'Incorrect';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête — FIXE OVERFLOW avec Flexible sur le titre de série
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Q${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 12, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: badgeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Flexible évite l'overflow du titre de série
                Flexible(
                  child: Text(
                    '${question.serieEmoji} ${question.serieTitre}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Texte question
            Text(
              q.texte,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            // Options avec indicateurs
            for (var i = 0; i < q.options.length; i++)
              _buildCorrectionOption(
                context,
                label: q.options[i],
                optionIndex: i,
                isCorrect: q.estCorrecte(i),
                isUserAnswer: userAnswer == i,
              ),
            // Explication
            if (q.explication != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        q.explication!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectionOption(
    BuildContext context, {
    required String label,
    required int optionIndex,
    required bool isCorrect,
    required bool isUserAnswer,
  }) {
    if (!isCorrect && !isUserAnswer) return const SizedBox.shrink();

    Color bg;
    Color textColor;
    IconData icon;

    if (isCorrect && isUserAnswer) {
      bg = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green.shade800;
      icon = Icons.check_circle_rounded;
    } else if (isCorrect) {
      bg = Colors.green.withValues(alpha: 0.06);
      textColor = Colors.green.shade700;
      icon = Icons.check_rounded;
    } else {
      bg = Colors.red.withValues(alpha: 0.07);
      textColor = Colors.red.shade800;
      icon = Icons.close_rounded;
    }

    final letter = optionIndex < _kLettersCorrestion.length
        ? _kLettersCorrestion[optionIndex]
        : '${optionIndex + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 6),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _kLettersCorrestion = ['A', 'B', 'C', 'D', 'E', 'F'];

// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
