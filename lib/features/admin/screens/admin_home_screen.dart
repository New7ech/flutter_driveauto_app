// DriveAuto — admin_home_screen.dart
// Role : Tableau de bord Super-Administrateur — design premium

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../providers/serie_provider.dart';
import 'admin_annonces_screen.dart';
import 'admin_classement_screen.dart';
import 'admin_examen_propose_screen.dart';
import 'admin_planning_screen.dart';
import 'admin_series_screen.dart';
import 'admin_stats_screen.dart';
import 'admin_users_screen.dart';

const _kAdminPrimary = Color(0xFF7B1FA2);
const _kAdminDark = Color(0xFF4A148C);

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider);
    final totalSlides =
        series.fold(0, (sum, s) => sum + s.nombreDiapositives);
    final totalQuestions =
        series.fold(0, (sum, s) => sum + s.nombreQuestions);
    final user = ref.watch(currentAuthUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header gradient ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: _buildGradientHeader(
                context, ref, user?.displayName ?? 'Admin', series.length,
                totalSlides, totalQuestions),
          ),
          // ── Contenu ───────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionLabel(context, '📚  Contenu pédagogique'),
                _buildMenuGrid(context, [
                  _MenuItem(
                    icon: Icons.library_books_rounded,
                    label: 'Séries & Cours',
                    subtitle: '${series.length} séries • $totalSlides slides',
                    colors: [AppConstants.primaryColor, const Color(0xFF005C38)],
                    onTap: () => _push(context, const AdminSeriesScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.school_rounded,
                    label: 'Proposer un Examen',
                    subtitle: 'Créer un examen officiel',
                    colors: [const Color(0xFFEF0107), const Color(0xFF8B0000)],
                    onTap: () =>
                        _push(context, const AdminExamenProposeScreen()),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionLabel(context, '👥  Apprenants'),
                _buildMenuGrid(context, [
                  _MenuItem(
                    icon: Icons.people_rounded,
                    label: 'Gestion',
                    subtitle: 'Profils, rôles, progression',
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade900
                    ],
                    onTap: () => _push(context, const AdminUsersScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.emoji_events_rounded,
                    label: 'Classement',
                    subtitle: 'Top apprenants par score',
                    colors: [
                      const Color(0xFFFCD116),
                      const Color(0xFFB89800)
                    ],
                    onTap: () => _push(context, const AdminClassementScreen()),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionLabel(context, '📢  Communication'),
                _buildMenuGrid(context, [
                  _MenuItem(
                    icon: Icons.campaign_rounded,
                    label: 'Annonces',
                    subtitle: 'Alertes & informations',
                    colors: [Colors.orange.shade700, Colors.orange.shade900],
                    onTap: () => _push(context, const AdminAnnoncesScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.event_available_rounded,
                    label: 'Planning',
                    subtitle: 'Séances pratiques',
                    colors: [Colors.teal.shade600, Colors.teal.shade900],
                    onTap: () => _push(context, const AdminPlanningScreen()),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionLabel(context, '📊  Analytiques & Maintenance'),
                _buildMenuGrid(context, [
                  _MenuItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistiques',
                    subtitle: 'Contenu & progression',
                    colors: [Colors.indigo.shade600, Colors.indigo.shade900],
                    onTap: () => _push(
                      context,
                      AdminStatsScreen(
                        series: series,
                        totalSlides: totalSlides,
                        totalQuestions: totalQuestions,
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.restore_rounded,
                    label: 'Maintenance',
                    subtitle: 'Réinitialiser les données',
                    colors: [Colors.red.shade600, Colors.red.shade900],
                    onTap: () => _confirmerReset(context, ref),
                  ),
                ]),
                const SizedBox(height: 24),
                // ── Raccourcis apprenant ────────────────────────────────
                _buildSectionLabel(context, '🔗  Raccourcis vue apprenant'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickChip(
                      icon: Icons.home_rounded,
                      label: 'Dashboard',
                      onTap: () => context.go(AppConstants.routeDashboard),
                    ),
                    _QuickChip(
                      icon: Icons.menu_book_rounded,
                      label: 'Cours',
                      onTap: () => context.go(AppConstants.routeSeries),
                    ),
                    _QuickChip(
                      icon: Icons.school_rounded,
                      label: 'Examen',
                      onTap: () => context.go(AppConstants.routeExamen),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // GRADIENT HEADER
  // ────────────────────────────────────────────────────────────────────

  Widget _buildGradientHeader(
    BuildContext context,
    WidgetRef ref,
    String adminName,
    int nbSeries,
    int nbSlides,
    int nbQuestions,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kAdminPrimary, _kAdminDark],
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
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Super Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.white70, size: 22),
                    tooltip: 'Se déconnecter',
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).logout();
                      context.go(AppConstants.routeLogin);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Admin info
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: Center(
                      child: Text(
                        adminName.isNotEmpty
                            ? adminName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Super-Administrateur',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          adminName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Stats rapides
              Row(
                children: [
                  _HeaderStat(
                      label: 'Séries', value: '$nbSeries', icon: Icons.folder_rounded),
                  const SizedBox(width: 10),
                  _HeaderStat(
                      label: 'Slides', value: '$nbSlides', icon: Icons.slideshow_rounded),
                  const SizedBox(width: 10),
                  _HeaderStat(
                      label: 'Questions',
                      value: '$nbQuestions',
                      icon: Icons.quiz_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // SECTION LABEL
  // ────────────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _kAdminPrimary,
              letterSpacing: 0.3,
            ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // MENU GRID 2×N
  // ────────────────────────────────────────────────────────────────────

  Widget _buildMenuGrid(BuildContext context, List<_MenuItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 106,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildMenuCard(context, items[i]),
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuItem item) {
    final luminance = item.colors[0].computeLuminance();
    final textColor = luminance > 0.3 ? Colors.black87 : Colors.white;
    final subtitleColor =
        luminance > 0.3 ? Colors.black54 : Colors.white.withValues(alpha: 0.8);
    final iconBg = luminance > 0.3
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.22);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: item.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: item.colors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.onTap,
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(item.icon, color: textColor, size: 18),
                ),
                const Spacer(),
                Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 10, color: subtitleColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────

  void _push(BuildContext context, Widget screen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _confirmerReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Réinitialiser les données ?',
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
              'Toutes les séries et diapositives seront remplacées par les données par défaut. '
              'Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok || !context.mounted) return;
    await ref.read(seriesNotifierProvider.notifier).resetToDefaults();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données réinitialisées avec succès.'),
          backgroundColor: _kAdminPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS INTERNES
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderStat extends StatelessWidget {
  const _HeaderStat(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _kAdminPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _kAdminPrimary.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: _kAdminPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: _kAdminPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;
}
