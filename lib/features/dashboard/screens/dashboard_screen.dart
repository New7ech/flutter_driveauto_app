// DriveAuto - dashboard_screen.dart
// Role: Ecran d'accueil pour l'apprenant — design premium avec gradient BF

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/user_progress.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../providers/repository_providers.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/app_auth_user.dart';
import '../widgets/progress_card.dart';

final userProgressProvider = FutureProvider<UserProgress?>((ref) async {
  final user = ref.watch(currentAuthUserProvider);
  if (user == null) return null;
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserProgress(user.id);
});

// Annonces actives depuis Firestore (filtre côté Dart pour éviter l'index composite)
final annoncesActiveProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  if (firestore == null) return const Stream.empty();
  return firestore
      .collection('annonces')
      .orderBy('dateCreation', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
            .where((d) => d['active'] as bool? ?? true)
            .toList(),
      );
});

// Examens officiels proposés et actifs (filtre Dart pour éviter l'index composite)
final examensProposesActiveProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final firestore = ref.watch(firebaseFirestoreProvider);
      if (firestore == null) return const Stream.empty();
      return firestore
          .collection('examens_proposes')
          .orderBy('dateCreation', descending: true)
          .snapshots()
          .map((snap) {
            final now = DateTime.now();
            return snap.docs
                .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
                .where((d) {
                  if (!(d['actif'] as bool? ?? true)) return false;
                  final dl = d['dateLimite'];
                  if (dl == null) return true;
                  final date = dl is Timestamp ? dl.toDate() : null;
                  return date == null || date.isAfter(now);
                })
                .toList();
          });
    });

// Séances pratiques de l'apprenant connecté (filtre Dart pour éviter l'index composite)
final seancesApprenantProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final uid = ref.watch(currentAuthUserProvider)?.id;
  if (firestore == null || uid == null) return const Stream.empty();
  return firestore
      .collection('seances_pratiques')
      .where('apprenantId', isEqualTo: uid)
      .snapshots()
      .map((snap) {
        final now = DateTime.now();
        return snap.docs
            .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
            .where((d) {
              final ts = d['dateSeance'];
              if (ts == null) return false;
              final date = ts is Timestamp ? ts.toDate() : null;
              if (date == null) return false;
              final statut = d['statut'] as String? ?? 'planifiee';
              return statut == 'planifiee' && date.isAfter(now);
            })
            .toList()
          ..sort((a, b) {
            final ta = (a['dateSeance'] as Timestamp).toDate();
            final tb = (b['dateSeance'] as Timestamp).toDate();
            return ta.compareTo(tb);
          });
      });
});

Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
  final connectivity = ref.read(connectivityProvider).valueOrNull;
  final offline =
      connectivity != null &&
      (connectivity.isEmpty ||
          connectivity.every((result) => result == ConnectivityResult.none));

  if (offline) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connexion requise'),
        content: const Text(
          'Vous etes hors ligne. Gardez la session ouverte pour consulter les cours hors connexion. '
          'La reconnexion necessite Internet.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
    return;
  }

  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Se deconnecter ?'),
          content: const Text(
            'Apres deconnexion, il faudra une connexion Internet pour vous reconnecter '
            'ou reinitialiser le mot de passe.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Se deconnecter'),
            ),
          ],
        ),
      ) ??
      false;

  if (!confirmed || !context.mounted) return;
  await ref.read(authControllerProvider.notifier).logout();
  if (context.mounted) context.go(AppConstants.routeLogin);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(userProgressProvider);
    final user = ref.watch(currentAuthUserProvider);
    final authControllerState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: progressState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Erreur lors du chargement : $error')),
        data: (progress) {
          if (progress == null) {
            return _buildEmptyState(context, ref, user, authControllerState);
          }
          return _buildDashboardContent(
            context,
            ref,
            progress,
            user,
            authControllerState,
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────

  String _greet(int hour) {
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _firstName(AppAuthUser? user) {
    if (user == null) return 'Apprenant';
    final name = user.displayName.isNotEmpty
        ? user.displayName
        : user.email.isNotEmpty
        ? user.email.split('@').first
        : 'Apprenant';
    return name.trim().split(' ').first;
  }

  String _initials(AppAuthUser? user) {
    if (user == null) return 'A';
    final name = user.displayName.isNotEmpty
        ? user.displayName
        : user.email.isNotEmpty
        ? user.email.split('@').first
        : 'Apprenant';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  // ────────────────────────────────────────────────────────
  // GRADIENT HEADER
  // ────────────────────────────────────────────────────────

  Widget _buildGradientHeader(
    BuildContext context,
    WidgetRef ref,
    AppAuthUser? user,
  ) {
    final hour = DateTime.now().hour;
    return Container(
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
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar : logo + profil + logout
              Row(
                children: [
                  const Icon(
                    Icons.directions_car_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'DriveAuto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.manage_accounts_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    tooltip: 'Mon profil',
                    onPressed: () => _showProfileSheet(context, ref, user),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    tooltip: 'Se déconnecter',
                    onPressed: () => _confirmAndLogout(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Avatar cliquable + prénom
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showProfileSheet(context, ref, user),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _initials(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greet(hour)} 👋',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _firstName(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bannière motivationnelle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Text('🏁', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Chaque cours vous rapproche du permis !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(
    BuildContext context,
    WidgetRef ref,
    AppAuthUser? user,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(user: user),
    );
  }

  // ────────────────────────────────────────────────────────
  // EMPTY STATE
  // ────────────────────────────────────────────────────────

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    AppAuthUser? user,
    AsyncValue<void> authControllerState,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(authControllerProvider.notifier).refreshSession();
        ref.invalidate(userProgressProvider);
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildGradientHeader(context, ref, user),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user != null) ...[
                  _buildEmailVerificationCard(
                    context,
                    ref,
                    user,
                    authControllerState,
                  ),
                  const SizedBox(height: 20),
                ],
                _buildAnnoncesSection(context, ref),
                _buildExamensProposeSection(context, ref),
                _buildSectionTitle(context, 'Rendez-vous Pratique'),
                const SizedBox(height: 12),
                _buildAppointmentCard(context, ref),
                const SizedBox(height: 28),
                Text(
                  'Commencer l\'apprentissage',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choisissez une activité pour démarrer',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                _buildNavigationGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // DASHBOARD CONTENT
  // ────────────────────────────────────────────────────────

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    UserProgress progress,
    AppAuthUser? user,
    AsyncValue<void> authControllerState,
  ) {
    final lessonPercent = (progress.totalLessonsCompleted / 40.0).clamp(
      0.0,
      1.0,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(authControllerProvider.notifier).refreshSession();
        ref.invalidate(userProgressProvider);
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildGradientHeader(context, ref, user),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user != null) ...[
                  _buildEmailVerificationCard(
                    context,
                    ref,
                    user,
                    authControllerState,
                  ),
                  const SizedBox(height: 20),
                ],
                // Annonces
                _buildAnnoncesSection(context, ref),
                // Examens proposés
                _buildExamensProposeSection(context, ref),
                // Progression
                _buildSectionTitle(context, 'Ma Progression'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ProgressCard(
                        title: 'Leçons',
                        progressPercent: lessonPercent,
                        subtitle:
                            '${progress.totalLessonsCompleted} / 40 cours',
                        icon: Icons.menu_book_rounded,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ProgressCard(
                        title: 'Note',
                        progressPercent: progress.globalScore / 100.0,
                        subtitle: 'Moyenne des quizz',
                        icon: Icons.quiz_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _buildSectionTitle(context, 'Mes Activités'),
                const SizedBox(height: 4),
                Text(
                  'Sélectionnez une activité pour continuer',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 16),
                _buildNavigationGrid(context),
                const SizedBox(height: 28),
                _buildSectionTitle(context, 'Rendez-vous Pratique'),
                const SizedBox(height: 12),
                _buildAppointmentCard(context, ref),
                const SizedBox(height: 28),
                _buildSectionTitle(context, 'Historique des Quiz'),
                const SizedBox(height: 12),
                _buildBarChart(context, isDark, progress),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // ANNONCES
  // ────────────────────────────────────────────────────────

  Widget _buildAnnoncesSection(BuildContext context, WidgetRef ref) {
    final annoncesAsync = ref.watch(annoncesActiveProvider);
    return annoncesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          'Erreur annonces : $e',
          style: TextStyle(fontSize: 11, color: Colors.red.shade400),
        ),
      ),
      data: (annonces) {
        if (annonces.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Annonces'),
            const SizedBox(height: 12),
            ...annonces.map((a) => _AnnonceCard(data: a)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // EXAMENS PROPOSÉS (vue apprenant)
  // ────────────────────────────────────────────────────────

  Widget _buildExamensProposeSection(BuildContext context, WidgetRef ref) {
    final examensAsync = ref.watch(examensProposesActiveProvider);
    return examensAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (examens) {
        if (examens.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Examens proposés'),
            const SizedBox(height: 12),
            ...examens.map((e) => _ExamenProposeApprenant(data: e)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // APPOINTMENT CARD
  // ────────────────────────────────────────────────────────

  Widget _buildAppointmentCard(BuildContext context, WidgetRef ref) {
    final seancesAsync = ref.watch(seancesApprenantProvider);

    return seancesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _SeanceVide(message: 'Erreur : $e'),
      data: (seances) {
        if (seances.isEmpty) {
          return const _SeanceVide(
            message: 'Contactez l\'auto-école pour planifier une séance',
          );
        }
        return Column(
          children: seances.map((s) => _SeanceCard(data: s)).toList(),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────
  // BAR CHART
  // ────────────────────────────────────────────────────────

  Widget _buildBarChart(
    BuildContext context,
    bool isDark,
    UserProgress progress,
  ) {
    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppConstants.cardColorDark
            : AppConstants.cardColorLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBarChartItem(context, 0.4, 'Sem 1'),
          _buildBarChartItem(context, 0.7, 'Sem 2'),
          _buildBarChartItem(context, 0.5, 'Sem 3'),
          _buildBarChartItem(
            context,
            progress.globalScore / 100.0,
            'Global',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartItem(
    BuildContext context,
    double heightRatio,
    String label, {
    bool isHighlighted = false,
  }) {
    final clampedRatio = heightRatio.clamp(0.04, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${(clampedRatio * 100).toInt()}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? AppConstants.secondaryColor
                : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 38,
          height: 80 * clampedRatio,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHighlighted
                  ? [
                      AppConstants.secondaryColor,
                      AppConstants.secondaryColor.withValues(alpha: 0.5),
                    ]
                  : [
                      AppConstants.primaryColor,
                      AppConstants.primaryColor.withValues(alpha: 0.5),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? AppConstants.secondaryColor : null,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // NAVIGATION GRID
  // ────────────────────────────────────────────────────────

  Widget _buildNavigationGrid(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.menu_book_rounded,
        label: 'Cours',
        subtitle: 'Séries & slides',
        colors: [const Color(0xFF00A86B), const Color(0xFF005C38)],
        onTap: () => context.push(AppConstants.routeSeries),
      ),
      _NavItem(
        icon: Icons.school_rounded,
        label: 'Examen',
        subtitle: '40 questions',
        colors: [const Color(0xFFEF0107), const Color(0xFF8B0000)],
        onTap: () => context.push(AppConstants.routeExamen),
      ),
      _NavItem(
        icon: Icons.checklist_rounded,
        label: 'Pratique',
        subtitle: 'Checklists',
        colors: [const Color(0xFFFCD116), const Color(0xFFB89800)],
        onTap: () => context.push(AppConstants.routePractice),
      ),
      _NavItem(
        icon: Icons.directions_car_rounded,
        label: 'Simulation',
        subtitle: 'Jeu de conduite',
        colors: [const Color(0xFF2196F3), const Color(0xFF0D47A1)],
        onTap: () => context.push(AppConstants.routeSimulation),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 114,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildNavCard(context, items[i]),
    );
  }

  Widget _buildNavCard(BuildContext context, _NavItem item) {
    final luminance = item.colors[0].computeLuminance();
    final textColor = luminance > 0.3 ? Colors.black87 : Colors.white;
    final subtitleColor = luminance > 0.3
        ? Colors.black54
        : Colors.white.withValues(alpha: 0.8);
    final iconBg = luminance > 0.3
        ? Colors.black.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.22);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: item.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: item.colors[0].withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.onTap,
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: textColor, size: 20),
                ),
                const Spacer(),
                Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(fontSize: 11, color: subtitleColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // EMAIL VERIFICATION CARD
  // ────────────────────────────────────────────────────────

  Widget _buildEmailVerificationCard(
    BuildContext context,
    WidgetRef ref,
    AppAuthUser user,
    AsyncValue<void> authControllerState,
  ) {
    if (user.emailVerified) {
      return Container(
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: const Text(
            'Compte vérifié',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            '${user.displayName} • ${user.email}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Vérification de l\'email recommandée',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Adresse connectée : ${user.email}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: authControllerState.isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(authControllerProvider.notifier)
                              .resendEmailVerification();
                          if (!context.mounted || !success) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Vérification envoyée !',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppConstants.primaryColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  child: const Text('Vérifier mon email'),
                ),
                TextButton(
                  onPressed: authControllerState.isLoading
                      ? null
                      : () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .refreshSession();
                        },
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SÉANCE PRATIQUE (vue apprenant)
// ─────────────────────────────────────────────────────────────────────────────

class _SeanceVide extends StatelessWidget {
  const _SeanceVide({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.primaryColor, Color(0xFF007A4D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeanceCard extends StatelessWidget {
  const _SeanceCard({required this.data});
  final Map<String, dynamic> data;

  DateTime get _date => (data['dateSeance'] as Timestamp).toDate();
  String get _moniteur => data['moniteur'] as String? ?? 'À définir';
  String get _lieu => data['lieu'] as String? ?? '';
  String get _notes => data['notes'] as String? ?? '';

  String _fmt(DateTime d) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final j = jours[(d.weekday - 1).clamp(0, 6)];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$j ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} à ${hh}h$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConstants.primaryColor, Color(0xFF007A4D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fmt(_date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Moniteur : $_moniteur',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Planifiée',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (_lieu.isNotEmpty || _notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (_lieu.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _lieu,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            if (_notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _notes,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTE ANNONCE (vue apprenant)
// ─────────────────────────────────────────────────────────────────────────────

class _AnnonceCard extends StatelessWidget {
  const _AnnonceCard({required this.data});
  final Map<String, dynamic> data;

  String get _titre => data['titre'] as String? ?? 'Annonce';
  String get _contenu => data['contenu'] as String? ?? '';
  String get _priorite => data['priorite'] as String? ?? 'normal';

  Color get _color {
    switch (_priorite) {
      case 'urgent':
        return Colors.red.shade600;
      case 'info':
        return Colors.blue.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  IconData get _icon {
    switch (_priorite) {
      case 'urgent':
        return Icons.warning_amber_rounded;
      case 'info':
        return Icons.info_outline_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(_icon, color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _color,
                  ),
                ),
                if (_contenu.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _contenu,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FICHE PROFIL — changement de mot de passe
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSheet extends ConsumerStatefulWidget {
  const _ProfileSheet({required this.user});
  final AppAuthUser? user;

  @override
  ConsumerState<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<_ProfileSheet> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      _currentPwCtrl.text.isNotEmpty &&
      _newPwCtrl.text.length >= 6 &&
      _newPwCtrl.text == _confirmPwCtrl.text;

  Future<void> _submit() async {
    if (!_valid) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await ref
        .read(authControllerProvider.notifier)
        .changePassword(
          currentPassword: _currentPwCtrl.text,
          newPassword: _newPwCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe modifié avec succès !'),
          backgroundColor: AppConstants.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final err = ref.read(authControllerProvider).error;
      setState(() {
        _loading = false;
        _error = err?.toString() ?? 'Erreur inconnue.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // En-tête profil
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppConstants.primaryColor, Color(0xFF005C38)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user != null && user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Apprenant',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            // Titre section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppConstants.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Changer le mot de passe',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Mot de passe actuel
            _buildPwField(
              controller: _currentPwCtrl,
              label: 'Mot de passe actuel',
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 12),
            // Nouveau mot de passe
            _buildPwField(
              controller: _newPwCtrl,
              label: 'Nouveau mot de passe (min. 6 caractères)',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            // Confirmation
            _buildPwField(
              controller: _confirmPwCtrl,
              label: 'Confirmer le nouveau mot de passe',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              onChanged: (_) => setState(() {}),
              hasError:
                  _confirmPwCtrl.text.isNotEmpty &&
                  _confirmPwCtrl.text != _newPwCtrl.text,
            ),
            if (_confirmPwCtrl.text.isNotEmpty &&
                _confirmPwCtrl.text != _newPwCtrl.text) ...[
              const SizedBox(height: 4),
              Text(
                'Les mots de passe ne correspondent pas.',
                style: TextStyle(fontSize: 11, color: Colors.red.shade600),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(fontSize: 13, color: Colors.red.shade700),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_loading ? 'Enregistrement…' : 'Enregistrer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: (_valid && !_loading) ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPwField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
    bool hasError = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Icons.lock_rounded,
          size: 18,
          color: AppConstants.primaryColor,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 18,
            color: Colors.grey.shade500,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade400 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade400 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade400 : AppConstants.primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTE EXAMEN PROPOSÉ (vue apprenant)
// ─────────────────────────────────────────────────────────────────────────────

class _ExamenProposeApprenant extends StatelessWidget {
  const _ExamenProposeApprenant({required this.data});
  final Map<String, dynamic> data;

  String get _titre => data['titre'] as String? ?? 'Examen';
  String get _description => data['description'] as String? ?? '';
  int get _nbQuestions => data['nombreQuestions'] as int? ?? 40;
  int get _duree => data['dureeMinutes'] as int? ?? 30;
  String get _message => data['message'] as String? ?? '';
  DateTime? get _dateLimite {
    final v = data['dateLimite'];
    if (v is Timestamp) return v.toDate();
    return null;
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final dl = _dateLimite;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.secondaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.secondaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF0107), Color(0xFF8B0000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$_nbQuestions questions • $_duree min',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Officiel',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (_description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              _description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"$_message"',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppConstants.secondaryColor.withValues(alpha: 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (dl != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  'Limite : ${_fmtDate(dl)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
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
