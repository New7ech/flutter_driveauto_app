// DriveAuto — admin_annonces_screen.dart
// Role : Gérer les annonces de l'auto-école (CRUD Firestore)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

const _kAdminPrimary = Color(0xFF7B1FA2);

// ── Provider Firestore ────────────────────────────────────────────────────────

final _annoncesColl = FirebaseFirestore.instance.collection('annonces');

Stream<List<Map<String, dynamic>>> _annoncesStream() {
  return _annoncesColl
      .orderBy('dateCreation', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
            .toList(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminAnnoncesScreen extends StatefulWidget {
  const AdminAnnoncesScreen({super.key});

  @override
  State<AdminAnnoncesScreen> createState() => _AdminAnnoncesScreenState();
}

class _AdminAnnoncesScreenState extends State<AdminAnnoncesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _annoncesStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Erreur : ${snap.error}')),
                  );
                }
                final annonces = snap.data ?? [];
                if (annonces.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmpty());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _AnnonceCard(
                      data: annonces[i],
                      isDark: isDark,
                      onDelete: () => _supprimer(annonces[i]['id']),
                      onToggle: () => _toggleActive(
                        annonces[i]['id'],
                        annonces[i]['active'] as bool? ?? true,
                      ),
                    ),
                    childCount: annonces.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle annonce'),
        onPressed: () => _showForm(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
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
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Annonces',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Rédigez et publiez des annonces visibles\npar tous vos apprenants.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 48,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune annonce',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première annonce\npour informer vos apprenants.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, [Map<String, dynamic>? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AnnonceForm(
        existing: existing,
        onSubmit: (data) async {
          Navigator.of(ctx).pop();
          await _sauvegarder(data, existing?['id']);
        },
      ),
    );
  }

  Future<void> _sauvegarder(Map<String, dynamic> data, String? id) async {
    try {
      if (id != null) {
        await _annoncesColl.doc(id).update(data);
      } else {
        await _annoncesColl.add({
          ...data,
          'dateCreation': FieldValue.serverTimestamp(),
          'active': true,
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              id != null ? 'Annonce modifiée.' : 'Annonce publiée !',
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _supprimer(String id) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Supprimer cette annonce ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await _annoncesColl.doc(id).delete();
  }

  Future<void> _toggleActive(String id, bool current) async {
    await _annoncesColl.doc(id).update({'active': !current});
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTE ANNONCE
// ─────────────────────────────────────────────────────────────────────────────

class _AnnonceCard extends StatelessWidget {
  const _AnnonceCard({
    required this.data,
    required this.isDark,
    required this.onDelete,
    required this.onToggle,
  });

  final Map<String, dynamic> data;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  String get _titre => data['titre'] as String? ?? 'Sans titre';
  String get _contenu => data['contenu'] as String? ?? '';
  String get _priorite => data['priorite'] as String? ?? 'normal';
  bool get _active => data['active'] as bool? ?? true;

  DateTime? get _dateCreation {
    final v = data['dateCreation'];
    if (v is Timestamp) return v.toDate();
    return null;
  }

  Color get _prioriteColor {
    switch (_priorite) {
      case 'urgent':
        return Colors.red.shade600;
      case 'info':
        return Colors.blue.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  IconData get _prioriteIcon {
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
    final dc = _dateCreation;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _active
              ? _prioriteColor.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _prioriteColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(_prioriteIcon, color: _prioriteColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dc != null)
                        Text(
                          'Publié le ${dc.day.toString().padLeft(2, '0')}/${dc.month.toString().padLeft(2, '0')}/${dc.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Badge priorité
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _prioriteColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _priorite.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _prioriteColor,
                    ),
                  ),
                ),
              ],
            ),
            if (_contenu.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _contenu,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Statut
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _active ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _active ? 'Visible' : 'Masquée',
                      style: TextStyle(
                        fontSize: 11,
                        color: _active
                            ? Colors.green.shade700
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: _active
                            ? Colors.orange.shade700
                            : Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: onToggle,
                      child: Text(_active ? 'Masquer' : 'Afficher'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: onDelete,
                      child: const Text('Supprimer'),
                    ),
                  ],
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
// FORMULAIRE ANNONCE (Bottom Sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _AnnonceForm extends StatefulWidget {
  const _AnnonceForm({this.existing, required this.onSubmit});
  final Map<String, dynamic>? existing;
  final ValueChanged<Map<String, dynamic>> onSubmit;

  @override
  State<_AnnonceForm> createState() => _AnnonceFormState();
}

class _AnnonceFormState extends State<_AnnonceForm> {
  late TextEditingController _titreCtrl;
  late TextEditingController _contenuCtrl;
  String _priorite = 'normal';

  @override
  void initState() {
    super.initState();
    _titreCtrl = TextEditingController(
      text: widget.existing?['titre'] as String? ?? '',
    );
    _contenuCtrl = TextEditingController(
      text: widget.existing?['contenu'] as String? ?? '',
    );
    _priorite = widget.existing?['priorite'] as String? ?? 'normal';
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _contenuCtrl.dispose();
    super.dispose();
  }

  bool get _valid => _titreCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.existing != null
                      ? 'Modifier l\'annonce'
                      : 'Nouvelle annonce',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Priorité
            const Text(
              'Priorité',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final p in [
                  ('normal', 'Normal', Colors.orange.shade600),
                  ('urgent', 'Urgent', Colors.red.shade600),
                  ('info', 'Info', Colors.blue.shade600),
                ])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priorite = p.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _priorite == p.$1
                              ? p.$3.withValues(alpha: 0.15)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _priorite == p.$1
                                ? p.$3
                                : Colors.grey.shade300,
                            width: _priorite == p.$1 ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            p.$2,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _priorite == p.$1
                                  ? p.$3
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Titre
            TextField(
              controller: _titreCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Titre *',
                hintText: 'Ex : Fermeture exceptionnelle',
                prefixIcon: const Icon(
                  Icons.title_rounded,
                  size: 18,
                  color: _kAdminPrimary,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kAdminPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Contenu
            TextField(
              controller: _contenuCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Contenu',
                hintText: 'Ex : L\'auto-école sera fermée le samedi 3 mai...',
                prefixIcon: const Icon(
                  Icons.description_rounded,
                  size: 18,
                  color: _kAdminPrimary,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kAdminPrimary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                widget.existing != null ? 'Enregistrer' : 'Publier l\'annonce',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _valid
                  ? () => widget.onSubmit({
                      'titre': _titreCtrl.text.trim(),
                      'contenu': _contenuCtrl.text.trim(),
                      'priorite': _priorite,
                    })
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
