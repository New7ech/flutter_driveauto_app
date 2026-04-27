// DriveAuto — admin_stats_screen.dart
// Role : Statistiques du contenu (séries, slides, questions)

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/serie.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({
    super.key,
    required this.series,
    required this.totalSlides,
    required this.totalQuestions,
  });

  final List<Serie> series;
  final int totalSlides;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGlobalCards(context),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Détail par série'),
          const SizedBox(height: 12),
          ...series.map((s) => _SerieStatCard(serie: s)),
          const SizedBox(height: 24),
          if (series.isNotEmpty) ...[
            _buildSectionTitle(context, 'Distribution des questions'),
            const SizedBox(height: 12),
            _buildQuestionDistribution(context),
          ],
        ],
      ),
    );
  }

  Widget _buildGlobalCards(BuildContext context) {
    final avgSlidesPerSerie =
        series.isEmpty ? 0.0 : totalSlides / series.length;
    final avgQuestionsPerSerie =
        series.isEmpty ? 0.0 : totalQuestions / series.length;
    final coveragePercent =
        totalSlides == 0 ? 0 : (totalQuestions * 100 ~/ totalSlides);

    return Column(
      children: [
        Row(
          children: [
            _GlobalCard(
              label: 'Séries',
              value: '${series.length}',
              icon: Icons.folder_copy,
              color: const Color(0xFF7B1FA2),
            ),
            const SizedBox(width: 12),
            _GlobalCard(
              label: 'Diapositives',
              value: '$totalSlides',
              icon: Icons.photo_library,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 12),
            _GlobalCard(
              label: 'Questions',
              value: '$totalQuestions',
              icon: Icons.quiz,
              color: Colors.orange.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _GlobalCard(
              label: 'Slides / série',
              value: avgSlidesPerSerie.toStringAsFixed(1),
              icon: Icons.analytics,
              color: Colors.teal,
            ),
            const SizedBox(width: 12),
            _GlobalCard(
              label: 'Questions / série',
              value: avgQuestionsPerSerie.toStringAsFixed(1),
              icon: Icons.help_outline,
              color: Colors.indigo,
            ),
            const SizedBox(width: 12),
            _GlobalCard(
              label: 'Couverture',
              value: '$coveragePercent%',
              icon: Icons.check_circle_outline,
              color: Colors.green.shade700,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
    );
  }

  Widget _buildQuestionDistribution(BuildContext context) {
    final qcmCount = series.fold<int>(
      0,
      (sum, s) => sum +
          s.diapositives
              .where((d) =>
                  d.question?.type == TypeQuestion.qcm)
              .length,
    );
    final checklistCount = totalQuestions - qcmCount;
    final total = totalQuestions == 0 ? 1 : totalQuestions;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DistributionRow(
              label: 'QCM',
              count: qcmCount,
              total: total,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 12),
            _DistributionRow(
              label: 'Checklist',
              count: checklistCount,
              total: total,
              color: Colors.orange.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SerieStatCard extends StatelessWidget {
  const _SerieStatCard({required this.serie});
  final Serie serie;

  @override
  Widget build(BuildContext context) {
    final couleur = Color(serie.couleurHex);
    final coverage = serie.nombreDiapositives == 0
        ? 0
        : (serie.nombreQuestions * 100 ~/ serie.nombreDiapositives);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(serie.emoji,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serie.titre,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        serie.categorie,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$coverage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: couleur,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MiniStat(
                  label: 'Slides',
                  value: '${serie.nombreDiapositives}',
                  color: couleur,
                ),
                const SizedBox(width: 10),
                _MiniStat(
                  label: 'Questions',
                  value: '${serie.nombreQuestions}',
                  color: AppConstants.secondaryColor,
                ),
              ],
            ),
            if (serie.nombreDiapositives > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: serie.nombreQuestions / serie.nombreDiapositives,
                  backgroundColor: couleur.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(couleur),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GlobalCard extends StatelessWidget {
  const _GlobalCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color),
            ),
            Text(
              label,
              style:
                  TextStyle(fontSize: 10, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            Text(
              '$count (${(fraction * 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
