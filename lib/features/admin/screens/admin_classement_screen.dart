// DriveAuto — admin_classement_screen.dart
// Role : Classement des apprenants par score d'examen

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

const _kAdminPrimary = Color(0xFF7B1FA2);

// ── Données fusionnées users + progress ──────────────────────────────────────

class _ApprenantRank {
  final String uid;
  final String nom;
  final String email;
  final int lessonsCompleted;
  final double avgScore;
  final int quizCount;

  const _ApprenantRank({
    required this.uid,
    required this.nom,
    required this.email,
    required this.lessonsCompleted,
    required this.avgScore,
    required this.quizCount,
  });
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminClassementScreen extends StatefulWidget {
  const AdminClassementScreen({super.key});

  @override
  State<AdminClassementScreen> createState() => _AdminClassementScreenState();
}

class _AdminClassementScreenState extends State<AdminClassementScreen> {
  List<_ApprenantRank> _classement = [];
  bool _loading = true;
  String? _error;
  String _sortBy = 'score'; // 'score' | 'lessons'

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'apprenant')
          .get();

      final progressSnap = await FirebaseFirestore.instance
          .collection('users_progress')
          .get();

      final progressMap = {
        for (final d in progressSnap.docs) d.id: d.data()
      };

      final ranks = <_ApprenantRank>[];
      for (final u in usersSnap.docs) {
        final data = u.data();
        final prog = progressMap[u.id] ?? {};
        final quizScores =
            prog['quizScores'] as Map<String, dynamic>? ?? {};
        final avgScore = quizScores.isEmpty
            ? 0.0
            : quizScores.values
                    .whereType<num>()
                    .fold<double>(0, (s, v) => s + v) /
                quizScores.length;
        final lessons =
            (prog['completedLessons'] as List?)?.length ?? 0;

        ranks.add(_ApprenantRank(
          uid: u.id,
          nom: data['displayName'] as String? ??
              (data['email'] as String? ?? '').split('@').first,
          email: data['email'] as String? ?? '',
          lessonsCompleted: lessons,
          avgScore: avgScore,
          quizCount: quizScores.length,
        ));
      }

      _sortRanks(ranks);
      setState(() {
        _classement = ranks;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _sortRanks(List<_ApprenantRank> list) {
    if (_sortBy == 'score') {
      list.sort((a, b) => b.avgScore.compareTo(a.avgScore));
    } else {
      list.sort(
          (a, b) => b.lessonsCompleted.compareTo(a.lessonsCompleted));
    }
  }

  void _changeSort(String key) {
    setState(() => _sortBy = key);
    _sortRanks(_classement);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_error != null)
            SliverToBoxAdapter(child: _buildError())
          else if (_classement.isEmpty)
            SliverToBoxAdapter(child: _buildEmpty())
          else ...[
            SliverToBoxAdapter(child: _buildSortBar()),
            if (_classement.length >= 3)
              SliverToBoxAdapter(
                child: _buildPodium(_classement.take(3).toList()),
              ),
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final rank = i + (_classement.length >= 3 ? 3 : 0);
                    if (rank >= _classement.length) return null;
                    return _RankRow(
                      rank: rank + 1,
                      apprenant: _classement[rank],
                      isDark: isDark,
                      sortBy: _sortBy,
                    );
                  },
                  childCount: _classement.length >= 3
                      ? _classement.length - 3
                      : _classement.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFCD116), Color(0xFFB89800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Classement',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.black54),
                    onPressed: _charger,
                    tooltip: 'Actualiser',
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '${_classement.length} apprenant(s) — trié par '
                  '${_sortBy == "score" ? "score moyen" : "leçons complétées"}',
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          const Text('Trier par :',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 12),
          _SortChip(
            label: 'Score moyen',
            selected: _sortBy == 'score',
            onTap: () => _changeSort('score'),
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'Leçons',
            selected: _sortBy == 'lessons',
            onTap: () => _changeSort('lessons'),
            color: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<_ApprenantRank> top3) {
    final medals = ['🥇', '🥈', '🥉'];
    final heights = [110.0, 85.0, 70.0];
    // Order: 2nd, 1st, 3rd (podium arrangement)
    final order = top3.length >= 3
        ? [top3[1], top3[0], top3[2]]
        : top3;
    final orderIdx = top3.length >= 3 ? [1, 0, 2] : [0, 1, 2];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kAdminPrimary, Color(0xFF4A148C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kAdminPrimary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Podium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < order.length; i++)
                _PodiumItem(
                  apprenant: order[i],
                  rank: orderIdx[i] + 1,
                  medal: medals[orderIdx[i]],
                  height: heights[orderIdx[i]],
                  isFirst: orderIdx[i] == 0,
                  sortBy: _sortBy,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.emoji_events_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun apprenant trouvé.',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Erreur : $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            onPressed: _charger,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PODIUM ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.apprenant,
    required this.rank,
    required this.medal,
    required this.height,
    required this.isFirst,
    required this.sortBy,
  });

  final _ApprenantRank apprenant;
  final int rank;
  final String medal;
  final double height;
  final bool isFirst;
  final String sortBy;

  @override
  Widget build(BuildContext context) {
    final value = sortBy == 'score'
        ? '${apprenant.avgScore.toStringAsFixed(0)}%'
        : '${apprenant.lessonsCompleted} leç.';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(medal, style: TextStyle(fontSize: isFirst ? 32 : 24)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: isFirst ? 2 : 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: isFirst ? 26 : 20,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            child: Text(
              apprenant.nom.isNotEmpty ? apprenant.nom[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 20 : 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            apprenant.nom.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isFirst ? 13 : 11,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: isFirst ? 13 : 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        // Colonne du podium
        Container(
          width: isFirst ? 64 : 52,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isFirst ? 0.25 : 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RANK ROW (hors podium)
// ─────────────────────────────────────────────────────────────────────────────

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.rank,
    required this.apprenant,
    required this.isDark,
    required this.sortBy,
  });

  final int rank;
  final _ApprenantRank apprenant;
  final bool isDark;
  final String sortBy;

  @override
  Widget build(BuildContext context) {
    final score = apprenant.avgScore;
    final value = sortBy == 'score'
        ? '${score.toStringAsFixed(1)} %'
        : '${apprenant.lessonsCompleted} leçons';
    final color = score >= 87.5
        ? AppConstants.primaryColor
        : score >= 60
            ? AppConstants.yellowBF
            : AppConstants.secondaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: _kAdminPrimary.withValues(alpha: 0.12),
            child: Text(
              apprenant.nom.isNotEmpty ? apprenant.nom[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _kAdminPrimary,
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          // Nom + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apprenant.nom,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  apprenant.email,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Score / leçons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
              if (sortBy == 'score')
                Text(
                  '${apprenant.quizCount} quiz',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
