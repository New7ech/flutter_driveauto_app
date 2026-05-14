// DriveAuto — admin_users_screen.dart
// Role : Gestion complète des apprenants (liste, recherche, édition, suppression)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';

// ── Provider Firestore ────────────────────────────────────────────────────────

final _firestoreUsersProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return FirebaseFirestore.instance.collection('users').snapshots().map((snap) {
    final docs = snap.docs
        .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
        .toList();

    docs.sort((a, b) {
      final dateA = _parseDate(a['createdAt']);
      final dateB = _parseDate(b['createdAt']);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    return docs;
  });
});

DateTime? _parseDate(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is String) return DateTime.tryParse(v);
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterRole = 'tous'; // 'tous', 'apprenant', 'admin', 'pending'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> users) {
    final q = _searchQuery.trim().toLowerCase();
    return users.where((u) {
      final name = (u['displayName'] as String? ?? '').toLowerCase();
      final email = (u['email'] as String? ?? '').toLowerCase();
      final role = (u['role'] as String? ?? 'apprenant');
      final approved = u['approved'] as bool? ?? false;

      final matchSearch = q.isEmpty || name.contains(q) || email.contains(q);
      final matchRole = _filterRole == 'tous'
          ? true
          : _filterRole == 'pending'
          ? (role == 'apprenant' && !approved)
          : role == _filterRole;

      return matchSearch && matchRole;
    }).toList();
  }

  Future<void> _approveUser(Map<String, dynamic> user) async {
    final uid = user['id'] as String? ?? user['uid'] as String? ?? '';
    final name =
        user['displayName'] as String? ??
        (user['email'] as String? ?? '').split('@').first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approuver l\'apprenant'),
        content: Text(
          'Voulez-vous approuver "$name" ?\n\n'
          'Il pourra accéder à l\'application immédiatement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approuver'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'approved': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name approuvé avec succès.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppConstants.primaryColor,
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

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_firestoreUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des apprenants'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, ref, e),
        data: (users) {
          final filtered = _filtered(users);
          final admins = users.where((u) => u['role'] == 'admin').length;
          final apprenants = users.length - admins;
          final pending = users.where((u) {
            final role = u['role'] as String? ?? 'apprenant';
            final approved = u['approved'] as bool? ?? false;
            return role == 'apprenant' && !approved;
          }).length;

          return Column(
            children: [
              // ── Stats ──
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatMini(
                      label: 'Total',
                      value: '${users.length}',
                      icon: Icons.people,
                    ),
                    _StatMini(
                      label: 'Apprenants',
                      value: '$apprenants',
                      icon: Icons.school,
                    ),
                    _StatMini(
                      label: 'Admins',
                      value: '$admins',
                      icon: Icons.admin_panel_settings,
                    ),
                    _StatMini(
                      label: 'En attente',
                      value: '$pending',
                      icon: Icons.hourglass_top_rounded,
                      color: const Color(0xFFF9A825),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Barre de recherche ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom ou email…',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(height: 8),

              // ── Filtres par rôle ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        selected: _filterRole == 'tous',
                        onTap: () => setState(() => _filterRole = 'tous'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Apprenants',
                        selected: _filterRole == 'apprenant',
                        onTap: () => setState(() => _filterRole = 'apprenant'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Admins',
                        selected: _filterRole == 'admin',
                        onTap: () => setState(() => _filterRole = 'admin'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'En attente${pending > 0 ? ' ($pending)' : ''}',
                        selected: _filterRole == 'pending',
                        color: const Color(0xFFF9A825),
                        onTap: () => setState(() => _filterRole = 'pending'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Liste ──
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty(users.isEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _UserCard(
                          data: filtered[index],
                          onEdit: () =>
                              _showEditDialog(context, filtered[index]),
                          onDelete: () =>
                              _confirmDelete(context, filtered[index]),
                          onProgress: () =>
                              _showProgressDialog(context, filtered[index]),
                          onApprove: () => _approveUser(filtered[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger les utilisateurs',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              onPressed: () => ref.invalidate(_firestoreUsersProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool noUsers) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            noUsers
                ? 'Aucun utilisateur enregistré.'
                : 'Aucun résultat pour cette recherche.',
          ),
        ],
      ),
    );
  }

  // ── Dialogue : Modifier le nom ────────────────────────────────────────────

  void _showEditDialog(BuildContext context, Map<String, dynamic> user) {
    final uid = user['id'] as String? ?? user['uid'] as String? ?? '';
    final controller = TextEditingController(
      text: user['displayName'] as String? ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom affiché',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                      'displayName': newName,
                      'updatedAt': FieldValue.serverTimestamp(),
                    });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nom mis à jour.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppConstants.primaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : $e'),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ── Dialogue : Confirmer suppression ─────────────────────────────────────

  void _confirmDelete(BuildContext context, Map<String, dynamic> user) {
    final uid = user['id'] as String? ?? user['uid'] as String? ?? '';
    final name =
        user['displayName'] as String? ??
        (user['email'] as String? ?? '').split('@').first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'apprenant'),
        content: Text(
          'Voulez-vous supprimer "$name" ?\n\n'
          'Son profil sera effacé définitivement et il sera '
          'automatiquement déconnecté de l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .delete();
                // Supprime aussi la progression si elle existe
                await FirebaseFirestore.instance
                    .collection('users_progress')
                    .doc(uid)
                    .delete()
                    .catchError((_) {});
                // Nettoie les entrées Hive locales (clés "{uid}_*")
                try {
                  final box = Hive.box(AppConstants.hiveSeriesProgressBox);
                  final orphanKeys = box.keys
                      .whereType<String>()
                      .where((k) => k.startsWith('${uid}_'))
                      .toList();
                  await box.deleteAll(orphanKeys);
                } catch (_) {}
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name supprimé.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : $e'),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ── Dialogue : Progression de l'apprenant ────────────────────────────────

  void _showProgressDialog(BuildContext context, Map<String, dynamic> user) {
    final uid = user['id'] as String? ?? user['uid'] as String? ?? '';
    final name =
        user['displayName'] as String? ??
        (user['email'] as String? ?? '').split('@').first;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progression — $name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users_progress')
                    .doc(uid)
                    .get(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Text('Erreur : ${snap.error}');
                  }
                  if (!snap.hasData || !snap.data!.exists) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Aucune progression enregistrée.'),
                    );
                  }

                  final data = snap.data!.data() as Map<String, dynamic>;
                  return _ProgressView(data: data);
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProgressView extends StatelessWidget {
  const _ProgressView({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final completedLessons = (data['completedLessons'] as List?)?.length ?? 0;
    final quizScores = data['quizScores'] as Map<String, dynamic>? ?? {};
    final avgScore = quizScores.isEmpty
        ? null
        : quizScores.values.whereType<num>().fold<double>(0, (s, v) => s + v) /
              quizScores.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressRow(
          icon: Icons.menu_book,
          label: 'Leçons terminées',
          value: '$completedLessons',
          color: AppConstants.primaryColor,
        ),
        const SizedBox(height: 8),
        _ProgressRow(
          icon: Icons.quiz,
          label: 'Quiz complétés',
          value: '${quizScores.length}',
          color: Colors.orange.shade700,
        ),
        if (avgScore != null) ...[
          const SizedBox(height: 8),
          _ProgressRow(
            icon: Icons.star,
            label: 'Score moyen quiz',
            value: '${avgScore.toStringAsFixed(1)} %',
            color: Colors.amber.shade700,
          ),
        ],
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
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
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onProgress,
    this.onApprove,
  });

  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onProgress;
  final VoidCallback? onApprove;

  String get _uid => data['id'] as String? ?? data['uid'] as String? ?? '';
  String get _email => data['email'] as String? ?? '(inconnu)';
  String get _displayName =>
      data['displayName'] as String? ?? _email.split('@').first;
  String get _role => data['role'] as String? ?? 'apprenant';
  bool get _isAdmin => _role == 'admin';
  bool get _isApproved => data['approved'] as bool? ?? true;
  DateTime? get _createdAt => _parseDate(data['createdAt']);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _isAdmin
                  ? const Color(0xFF7B1FA2).withValues(alpha: 0.15)
                  : Colors.blue.shade50,
              child: Text(
                _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isAdmin
                      ? const Color(0xFF7B1FA2)
                      : Colors.blue.shade700,
                  fontSize: 18,
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
                    _displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _email,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Inscrit le ${_formatDate(_createdAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _RoleBadge(role: _role),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Approuver (apprenant en attente)
                    if (!_isAdmin && !_isApproved && onApprove != null) ...[
                      _ActionIcon(
                        icon: Icons.check_circle_outline,
                        color: Colors.green.shade600,
                        tooltip: 'Approuver',
                        onTap: onApprove!,
                      ),
                      const SizedBox(width: 4),
                    ],
                    // Voir progression
                    _ActionIcon(
                      icon: Icons.bar_chart,
                      color: Colors.teal,
                      tooltip: 'Progression',
                      onTap: onProgress,
                    ),
                    const SizedBox(width: 4),
                    // Modifier nom
                    _ActionIcon(
                      icon: Icons.edit,
                      color: Colors.blue.shade600,
                      tooltip: 'Modifier',
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 4),
                    // Changer rôle
                    _RoleToggleButton(uid: _uid, currentRole: _role),
                    const SizedBox(width: 4),
                    // Supprimer
                    _ActionIcon(
                      icon: Icons.delete_outline,
                      color: Colors.red.shade400,
                      tooltip: 'Supprimer',
                      onTap: onDelete,
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xFF7B1FA2).withValues(alpha: 0.12)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'Apprenant',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isAdmin ? const Color(0xFF7B1FA2) : Colors.blue.shade700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RoleToggleButton extends StatefulWidget {
  const _RoleToggleButton({required this.uid, required this.currentRole});
  final String uid;
  final String currentRole;

  @override
  State<_RoleToggleButton> createState() => _RoleToggleButtonState();
}

class _RoleToggleButtonState extends State<_RoleToggleButton> {
  bool _loading = false;

  Future<void> _toggleRole() async {
    final newRole = widget.currentRole == 'admin' ? 'apprenant' : 'admin';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le rôle'),
        content: Text(
          newRole == 'admin'
              ? 'Promouvoir cet utilisateur en admin ?'
              : 'Rétrograder cet utilisateur en apprenant ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: newRole == 'admin'
                  ? const Color(0xFF7B1FA2)
                  : AppConstants.secondaryColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(newRole == 'admin' ? 'Promouvoir' : 'Rétrograder'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update({'role': newRole, 'updatedAt': FieldValue.serverTimestamp()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rôle mis à jour : $newRole'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppConstants.primaryColor,
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
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return _ActionIcon(
      icon: Icons.swap_horiz,
      color: Colors.grey.shade500,
      tooltip: 'Changer de rôle',
      onTap: _toggleRole,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Colors.blue.shade700;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatMini extends StatelessWidget {
  const _StatMini({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.blue.shade700;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: c),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
