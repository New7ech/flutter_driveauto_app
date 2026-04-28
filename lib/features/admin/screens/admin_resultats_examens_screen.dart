// DriveAuto — admin_resultats_examens_screen.dart
// Role : Consultation des résultats des examens blancs passés par les apprenants

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _kPrimary = Color(0xFF7B1FA2);
const _kDark = Color(0xFF4A148C);

final _resultatsExamensProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('resultats_examens')
      .orderBy('datePassage', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
          .toList());
});

enum _Filtre { tous, recus, recales }

class AdminResultatsExamensScreen extends ConsumerStatefulWidget {
  const AdminResultatsExamensScreen({super.key});

  @override
  ConsumerState<AdminResultatsExamensScreen> createState() =>
      _AdminResultatsExamensScreenState();
}

class _AdminResultatsExamensScreenState
    extends ConsumerState<AdminResultatsExamensScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  _Filtre get _filtreCourant => _Filtre.values[_tabs.index];

  List<Map<String, dynamic>> _filtrer(List<Map<String, dynamic>> all) {
    switch (_filtreCourant) {
      case _Filtre.recus:
        return all.where((r) => r['reussi'] as bool? ?? false).toList();
      case _Filtre.recales:
        return all.where((r) => !(r['reussi'] as bool? ?? false)).toList();
      case _Filtre.tous:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_resultatsExamensProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: async.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Erreur : $e',
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (all) {
                final filtered = _filtrer(all);
                return Column(
                  children: [
                    _buildStatsBar(all),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) =>
                                  _ResultCard(data: filtered[i]),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary, _kDark],
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
          padding: const EdgeInsets.fromLTRB(4, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Résultats des examens',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Historique des passages d\'examens blancs\npar les apprenants.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TabBar ───────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabs,
        labelColor: _kPrimary,
        unselectedLabelColor: Colors.grey.shade500,
        indicatorColor: _kPrimary,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: 'Tous'),
          Tab(text: 'Reçus ✅'),
          Tab(text: 'Recalés ❌'),
        ],
      ),
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────────────────

  Widget _buildStatsBar(List<Map<String, dynamic>> all) {
    final total = all.length;
    final recus = all.where((r) => r['reussi'] as bool? ?? false).length;
    final taux = total == 0 ? 0.0 : (recus / total) * 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: _kPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _kPrimary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.assignment_rounded,
            label: 'Passages',
            value: '$total',
            color: _kPrimary,
          ),
          _StatChip(
            icon: Icons.check_circle_rounded,
            label: 'Reçus',
            value: '$recus',
            color: const Color(0xFF1B8A4E),
          ),
          _StatChip(
            icon: Icons.cancel_rounded,
            label: 'Recalés',
            value: '${total - recus}',
            color: Colors.red.shade700,
          ),
          _StatChip(
            icon: Icons.percent_rounded,
            label: 'Taux',
            value: '${taux.toStringAsFixed(1)} %',
            color: Colors.orange.shade700,
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Aucun résultat',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Les résultats apparaîtront\naprès les premiers examens.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte résultat
// ─────────────────────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final reussi = data['reussi'] as bool? ?? false;
    final nom = data['apprenantNom'] as String? ?? 'Apprenant inconnu';
    final score = data['score'] as int? ?? 0;
    final total = data['total'] as int? ?? 0;
    final pct = data['pourcentage'] as num? ?? 0.0;
    final ts = data['datePassage'];
    final date = ts is Timestamp ? ts.toDate() : null;
    final dateStr = date != null
        ? DateFormat('dd/MM/yyyy • HH:mm', 'fr_FR').format(date)
        : '—';

    final badgeColor =
        reussi ? const Color(0xFF1B8A4E) : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.22),
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
        child: Row(
          children: [
            // Badge reçu/recalé
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  reussi
                      ? Icons.emoji_events_rounded
                      : Icons.close_rounded,
                  color: badgeColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$score',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: badgeColor,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: ' / $total',
                        style: TextStyle(
                          fontSize: 12,
                          color: badgeColor.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pct.toStringAsFixed(1)} %',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    reussi ? 'REÇU' : 'RECALÉ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
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
// Widgets internes
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
