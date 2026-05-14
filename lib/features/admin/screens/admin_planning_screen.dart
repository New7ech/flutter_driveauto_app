// DriveAuto — admin_planning_screen.dart
// Role : Planification des séances pratiques (Firestore)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

const _kTeal = Color(0xFF00695C);

// ── Firestore streams ────────────────────────────────────────────────────────

final _seancesColl = FirebaseFirestore.instance.collection('seances_pratiques');
final _usersColl = FirebaseFirestore.instance.collection('users');

Stream<List<Map<String, dynamic>>> _seancesStream() {
  return _seancesColl
      .orderBy('dateSeance', descending: false)
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
            .toList(),
      );
}

Future<List<Map<String, dynamic>>> _fetchApprenants() async {
  final snap = await _usersColl.where('role', isEqualTo: 'apprenant').get();
  return snap.docs
      .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────

class AdminPlanningScreen extends StatefulWidget {
  const AdminPlanningScreen({super.key});

  @override
  State<AdminPlanningScreen> createState() => _AdminPlanningScreenState();
}

class _AdminPlanningScreenState extends State<AdminPlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          TabBar(
            controller: _tabCtrl,
            indicatorColor: _kTeal,
            labelColor: _kTeal,
            unselectedLabelColor: Colors.grey.shade500,
            tabs: const [
              Tab(text: 'À venir'),
              Tab(text: 'Passées'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _SeancesList(upcoming: true),
                _SeancesList(upcoming: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Planifier une séance'),
        onPressed: () => _showForm(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kTeal, Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Séances de conduite pratique',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SeanceForm(
        onSubmit: (data) async {
          Navigator.of(ctx).pop();
          await _creerSeance(data);
        },
      ),
    );
  }

  Future<void> _creerSeance(Map<String, dynamic> data) async {
    try {
      await _seancesColl.add({
        ...data,
        'dateCreation': FieldValue.serverTimestamp(),
        'statut': 'planifiee',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance planifiée avec succès !'),
            backgroundColor: _kTeal,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// LISTE DES SÉANCES
// ─────────────────────────────────────────────────────────────────────────────

class _SeancesList extends StatelessWidget {
  const _SeancesList({required this.upcoming});
  final bool upcoming;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _seancesStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Erreur : ${snap.error}'));
        }
        final all = snap.data ?? [];
        final filtered = all.where((s) {
          final ts = s['dateSeance'];
          if (ts == null) return false;
          final date = ts is Timestamp ? ts.toDate() : null;
          if (date == null) return false;
          return upcoming ? date.isAfter(now) : date.isBefore(now);
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  upcoming
                      ? Icons.event_available_outlined
                      : Icons.history_rounded,
                  size: 56,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  upcoming ? 'Aucune séance à venir' : 'Aucune séance passée',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: filtered.length,
          itemBuilder: (context, i) =>
              _SeanceCard(data: filtered[i], isDark: isDark, isPast: !upcoming),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTE SÉANCE
// ─────────────────────────────────────────────────────────────────────────────

class _SeanceCard extends StatelessWidget {
  const _SeanceCard({
    required this.data,
    required this.isDark,
    required this.isPast,
  });

  final Map<String, dynamic> data;
  final bool isDark;
  final bool isPast;

  DateTime? get _dateSeance {
    final v = data['dateSeance'];
    if (v is Timestamp) return v.toDate();
    return null;
  }

  String get _apprenant => data['apprenantNom'] as String? ?? 'N/A';
  String get _moniteur => data['moniteur'] as String? ?? 'À définir';
  String get _lieu => data['lieu'] as String? ?? '';
  String get _statut => data['statut'] as String? ?? 'planifiee';
  String get _notes => data['notes'] as String? ?? '';

  Color get _statutColor {
    switch (_statut) {
      case 'terminee':
        return Colors.green;
      case 'annulee':
        return Colors.red;
      default:
        return _kTeal;
    }
  }

  String get _statutLabel {
    switch (_statut) {
      case 'terminee':
        return 'Terminée';
      case 'annulee':
        return 'Annulée';
      default:
        return 'Planifiée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _dateSeance;
    final dateStr = d != null
        ? '${_weekday(d.weekday)} ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} à ${d.hour.toString().padLeft(2, '0')}h${d.minute.toString().padLeft(2, '0')}'
        : 'Date non définie';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast ? Colors.grey.shade200 : _kTeal.withValues(alpha: 0.2),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statutColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: _statutColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _apprenant,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        dateStr,
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
                    color: _statutColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statutLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _statutColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _InfoBadge(
                  icon: Icons.person_rounded,
                  label: 'Moniteur : $_moniteur',
                  color: _kTeal,
                ),
                if (_lieu.isNotEmpty)
                  _InfoBadge(
                    icon: Icons.location_on_rounded,
                    label: _lieu,
                    color: Colors.blue.shade700,
                  ),
              ],
            ),
            if (_notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _notes,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!isPast && _statut == 'planifiee') ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _QuickAction(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Terminée',
                    color: Colors.green,
                    onTap: () => _updateStatut(data['id'], 'terminee'),
                  ),
                  const SizedBox(width: 8),
                  _QuickAction(
                    icon: Icons.cancel_outlined,
                    label: 'Annuler',
                    color: Colors.red.shade400,
                    onTap: () => _updateStatut(data['id'], 'annulee'),
                  ),
                  const SizedBox(width: 8),
                  _QuickAction(
                    icon: Icons.delete_outline_rounded,
                    label: 'Supprimer',
                    color: Colors.red.shade300,
                    onTap: () => _seancesColl.doc(data['id']).delete(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatut(String id, String statut) async {
    await _seancesColl.doc(id).update({'statut': statut});
  }

  String _weekday(int d) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[(d - 1).clamp(0, 6)];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORMULAIRE SÉANCE (Bottom Sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _SeanceForm extends StatefulWidget {
  const _SeanceForm({required this.onSubmit});
  final ValueChanged<Map<String, dynamic>> onSubmit;

  @override
  State<_SeanceForm> createState() => _SeanceFormState();
}

class _SeanceFormState extends State<_SeanceForm> {
  final _moniteurCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _dateSeance;
  TimeOfDay? _heure;
  String? _apprenantId;
  String? _apprenantNom;
  List<Map<String, dynamic>> _apprenants = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _chargerApprenants();
  }

  @override
  void dispose() {
    _moniteurCtrl.dispose();
    _lieuCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _chargerApprenants() async {
    final list = await _fetchApprenants();
    if (mounted) {
      setState(() {
        _apprenants = list;
        _loadingUsers = false;
      });
    }
  }

  bool get _valid =>
      _apprenantId != null && _dateSeance != null && _heure != null;

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
                    color: _kTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: _kTeal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Planifier une séance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Apprenant
            const Text(
              'Apprenant *',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            if (_loadingUsers)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                initialValue: _apprenantId,
                decoration: InputDecoration(
                  hintText: 'Sélectionner un apprenant',
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
                    borderSide: const BorderSide(color: _kTeal, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                items: _apprenants.map((u) {
                  final nom =
                      u['displayName'] as String? ??
                      (u['email'] as String? ?? '').split('@').first;
                  return DropdownMenuItem<String>(
                    value: u['id'] as String,
                    child: Text(nom, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id == null) return;
                  final u = _apprenants.firstWhere(
                    (a) => a['id'] == id,
                    orElse: () => {},
                  );
                  setState(() {
                    _apprenantId = id;
                    _apprenantNom =
                        u['displayName'] as String? ??
                        (u['email'] as String? ?? '').split('@').first;
                  });
                },
              ),
            const SizedBox(height: 14),
            // Date + Heure
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 180)),
                      );
                      if (d != null) setState(() => _dateSeance = d);
                    },
                    child: _DateField(
                      icon: Icons.calendar_month_rounded,
                      label: _dateSeance != null
                          ? '${_dateSeance!.day.toString().padLeft(2, '0')}/${_dateSeance!.month.toString().padLeft(2, '0')}/${_dateSeance!.year}'
                          : 'Date *',
                      hasValue: _dateSeance != null,
                      color: _kTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final h = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (h != null) setState(() => _heure = h);
                    },
                    child: _DateField(
                      icon: Icons.access_time_rounded,
                      label: _heure != null
                          ? '${_heure!.hour.toString().padLeft(2, '0')}h${_heure!.minute.toString().padLeft(2, '0')}'
                          : 'Heure *',
                      hasValue: _heure != null,
                      color: _kTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Moniteur
            _buildTextField(
              controller: _moniteurCtrl,
              label: 'Moniteur',
              hint: 'Nom du moniteur',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 14),
            // Lieu
            _buildTextField(
              controller: _lieuCtrl,
              label: 'Lieu',
              hint: 'Ex : Circuit de Ouagadougou',
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: 14),
            // Notes
            _buildTextField(
              controller: _notesCtrl,
              label: 'Notes',
              hint: 'Instructions, remarques…',
              icon: Icons.notes_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Planifier la séance'),
              style: FilledButton.styleFrom(
                backgroundColor: _kTeal,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _valid ? _soumettre : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: _kTeal),
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
          borderSide: const BorderSide(color: _kTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  void _soumettre() {
    if (!_valid) return;
    final combined = DateTime(
      _dateSeance!.year,
      _dateSeance!.month,
      _dateSeance!.day,
      _heure!.hour,
      _heure!.minute,
    );
    widget.onSubmit({
      'apprenantId': _apprenantId!,
      'apprenantNom': _apprenantNom ?? '',
      'moniteur': _moniteurCtrl.text.trim(),
      'lieu': _lieuCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'dateSeance': Timestamp.fromDate(combined),
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.icon,
    required this.label,
    required this.hasValue,
    required this.color,
  });
  final IconData icon;
  final String label;
  final bool hasValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue ? color : Colors.grey.shade300,
          width: hasValue ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: hasValue ? color : Colors.grey.shade400),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: hasValue ? Colors.black87 : Colors.grey.shade500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
