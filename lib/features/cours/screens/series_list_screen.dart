// DriveAuto — series_list_screen.dart
// Role : Liste de toutes les séries de cours — design premium

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/serie.dart';
import '../../../providers/serie_provider.dart';
import '../../../providers/series_progress_provider.dart';

class SeriesListScreen extends ConsumerWidget {
  const SeriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesAsync = ref.watch(seriesRemoteProvider);

    return seriesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Cours — Séries'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) {
        // Fallback sur les données locales en cas d'erreur réseau
        final series = ref.watch(seriesProvider);
        return _buildContent(context, series);
      },
      data: (series) => _buildContent(context, series),
    );
  }

  Widget _buildContent(BuildContext context, List<Serie> series) {
    return Scaffold(
      body: series.isEmpty
          ? _buildEmpty(context)
          : CustomScrollView(
              slivers: [
                _buildSliverHeader(context, series.length),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _SerieCard(
                        serie: series[index],
                        index: index,
                        onTap: () => context.push(
                          '${AppConstants.routeSeries}/${series[index].id}',
                        ),
                      ),
                      childCount: series.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cours — Séries'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text('Aucune série disponible.')),
    );
  }

  Widget _buildSliverHeader(BuildContext context, int total) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.primaryColor, Color(0xFF005C38)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + titre
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Text(
                      'Cours',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    '📚 Vos cours du code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Naviguez dans chaque série, lisez les diapositives\net entraînez-vous avec les exercices intégrés.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Badge stats
                Row(
                  children: [
                    _StatBadge(
                      icon: Icons.library_books_rounded,
                      label: '$total séries',
                    ),
                    const SizedBox(width: 10),
                    const _StatBadge(
                      icon: Icons.slideshow_rounded,
                      label: 'Slides interactifs',
                    ),
                    const SizedBox(width: 10),
                    const _StatBadge(
                      icon: Icons.quiz_rounded,
                      label: 'Exercices QCM',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERIE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SerieCard extends ConsumerWidget {
  const _SerieCard({
    required this.serie,
    required this.index,
    required this.onTap,
  });

  final Serie serie;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(serie.couleurHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final derniereSlideVue = ref.watch(
      seriesProgressProvider.select((state) => state[serie.id] ?? -1),
    );
    final total = serie.nombreDiapositives;
    final pct = total == 0
        ? 0.0
        : ((derniereSlideVue + 1) / total).clamp(0.0, 1.0);
    final terminee = total > 0 && derniereSlideVue >= total - 1;
    final commencee = derniereSlideVue >= 0;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppConstants.cardColorDark
              : AppConstants.cardColorLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bande colorée gauche
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: terminee
                            ? [
                                Colors.green,
                                Colors.green.withValues(alpha: 0.4),
                              ]
                            : [color, color.withValues(alpha: 0.4)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  // Contenu principal
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                      child: Row(
                        children: [
                          // Icône colorée
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: 0.15),
                                  color.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                serie.emoji,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Textes et chips
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Numéro + badge statut
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'S${index + 1}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (terminee)
                                      _StatusBadge(
                                        label: 'Terminé',
                                        icon: Icons.check_circle_rounded,
                                        color: Colors.green,
                                      )
                                    else if (commencee)
                                      _StatusBadge(
                                        label: 'En cours',
                                        icon: Icons.play_circle_rounded,
                                        color: color,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  serie.titre,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  serie.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade500,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                // Barre de progression si commencée
                                if (commencee) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            minHeight: 5,
                                            backgroundColor: color.withValues(
                                              alpha: 0.15,
                                            ),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  terminee
                                                      ? Colors.green
                                                      : color,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(pct * 100).round()}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: terminee
                                              ? Colors.green
                                              : color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                // Chips
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _Chip(
                                      icon: Icons.slideshow_rounded,
                                      label:
                                          '${serie.nombreDiapositives} slides',
                                      color: color,
                                    ),
                                    _Chip(
                                      icon: Icons.quiz_rounded,
                                      label:
                                          '${serie.nombreQuestions} exercices',
                                      color: AppConstants.secondaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Flèche / check
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: terminee
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                terminee
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: terminee ? Colors.green : color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
