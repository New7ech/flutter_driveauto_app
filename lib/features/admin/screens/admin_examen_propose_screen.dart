// DriveAuto — admin_examen_propose_screen.dart
// Role : Proposer un examen officiel aux apprenants (stocké Firestore)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../providers/serie_provider.dart';

const _kAdminPrimary = Color(0xFF7B1FA2);
const _kAdminDark = Color(0xFF4A148C);

// ── Provider : liste des examens proposés ────────────────────────────────────

final _examensProposesProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('examens_proposes')
      .orderBy('dateCreation', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((d) => <String, dynamic>{'id': d.id, ...d.data()})
            .toList(),
      );
});

// ─────────────────────────────────────────────────────────────────────────────

class AdminExamenProposeScreen extends ConsumerStatefulWidget {
  const AdminExamenProposeScreen({super.key});

  @override
  ConsumerState<AdminExamenProposeScreen> createState() =>
      _AdminExamenProposeScreenState();
}

class _AdminExamenProposeScreenState
    extends ConsumerState<AdminExamenProposeScreen> {
  @override
  Widget build(BuildContext context) {
    final examensAsync = ref.watch(_examensProposesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar gradient ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kAdminPrimary, _kAdminDark],
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
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Text(
                            'Examens officiels',
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
                          'Proposez un examen blanc officiel à vos apprenants.\nIl apparaîtra sur leur tableau de bord.',
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
            ),
          ),

          // ── Liste des examens ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: examensAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Erreur : $e'))),
              data: (examens) {
                if (examens.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmpty(context));
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ExamenProposeCard(
                      data: examens[i],
                      isDark: isDark,
                      onDelete: () => _supprimerExamen(examens[i]['id']),
                      onToggle: () => _toggleActif(
                        examens[i]['id'],
                        examens[i]['actif'] as bool? ?? true,
                      ),
                    ),
                    childCount: examens.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ── FAB ────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _kAdminPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Proposer un examen'),
        onPressed: () => _showCreateForm(context),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kAdminPrimary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 48,
              color: _kAdminPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun examen proposé',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier examen officiel\npour vos apprenants.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // FORMULAIRE DE CRÉATION
  // ────────────────────────────────────────────────────────────────────

  void _showCreateForm(BuildContext context) {
    final series = ref.read(seriesProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateExamenForm(
        series: series,
        onSubmit: (data) async {
          Navigator.of(ctx).pop();
          await _creerExamen(data);
        },
      ),
    );
  }

  Future<void> _creerExamen(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('examens_proposes').add({
        ...data,
        'dateCreation': FieldValue.serverTimestamp(),
        'actif': true,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Examen proposé avec succès !'),
            backgroundColor: _kAdminPrimary,
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

  Future<void> _supprimerExamen(String id) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Supprimer cet examen ?'),
            content: const Text('Il ne sera plus visible par les apprenants.'),
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
    await FirebaseFirestore.instance
        .collection('examens_proposes')
        .doc(id)
        .delete();
  }

  Future<void> _toggleActif(String id, bool currentActif) async {
    await FirebaseFirestore.instance
        .collection('examens_proposes')
        .doc(id)
        .update({'actif': !currentActif});
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTE EXAMEN PROPOSÉ
// ─────────────────────────────────────────────────────────────────────────────

class _ExamenProposeCard extends StatelessWidget {
  const _ExamenProposeCard({
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
  String get _description => data['description'] as String? ?? '';
  int get _nbQuestions => data['nombreQuestions'] as int? ?? 40;
  int get _duree => data['dureeMinutes'] as int? ?? 30;
  bool get _actif => data['actif'] as bool? ?? true;
  String get _message => data['message'] as String? ?? '';
  DateTime? get _dateLimite {
    final v = data['dateLimite'];
    if (v is Timestamp) return v.toDate();
    return null;
  }

  DateTime? get _dateCreation {
    final v = data['dateCreation'];
    if (v is Timestamp) return v.toDate();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dl = _dateLimite;
    final dc = _dateCreation;
    final isExpired = dl != null && dl.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _actif
              ? _kAdminPrimary.withValues(alpha: 0.25)
              : Colors.grey.shade300,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _actif
                        ? _kAdminPrimary.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: _actif ? _kAdminPrimary : Colors.grey.shade400,
                    size: 20,
                  ),
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
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dc != null)
                        Text(
                          'Créé le ${_fmt(dc)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _actif
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _actif ? (isExpired ? 'Expiré' : 'Actif') : 'Inactif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _actif
                          ? (isExpired
                                ? Colors.orange.shade700
                                : Colors.green.shade700)
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
            if (_description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // Infos chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _InfoChip(
                  icon: Icons.quiz_rounded,
                  label: '$_nbQuestions questions',
                  color: _kAdminPrimary,
                ),
                _InfoChip(
                  icon: Icons.timer_rounded,
                  label: '$_duree min',
                  color: Colors.blue.shade700,
                ),
                if (dl != null)
                  _InfoChip(
                    icon: Icons.event_rounded,
                    label: 'Limite : ${_fmt(dl)}',
                    color: isExpired
                        ? Colors.orange.shade700
                        : Colors.teal.shade700,
                  ),
              ],
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kAdminPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: _kAdminPrimary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _message,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: _kAdminPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(
                    _actif
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 15,
                  ),
                  label: Text(_actif ? 'Désactiver' : 'Activer'),
                  style: TextButton.styleFrom(
                    foregroundColor: _actif
                        ? Colors.orange.shade700
                        : Colors.green,
                  ),
                  onPressed: onToggle,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline_rounded, size: 15),
                  label: const Text('Supprimer'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ─────────────────────────────────────────────────────────────────────────────
// FORMULAIRE DE CRÉATION (Bottom Sheet)
// ─────────────────────────────────────────────────────────────────────────────

class _CreateExamenForm extends ConsumerStatefulWidget {
  const _CreateExamenForm({required this.series, required this.onSubmit});
  final List<dynamic> series;
  final ValueChanged<Map<String, dynamic>> onSubmit;

  @override
  ConsumerState<_CreateExamenForm> createState() => _CreateExamenFormState();
}

class _CreateExamenFormState extends ConsumerState<_CreateExamenForm> {
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  int _nbQuestions = 40;
  int _dureeMinutes = 30;
  DateTime? _dateLimite;
  bool _loading = false;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    _messageCtrl.dispose();
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
      child: Padding(
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
              // Titre du formulaire
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kAdminPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: _kAdminPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Nouvel examen officiel',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Titre
              _buildField(
                controller: _titreCtrl,
                label: 'Titre de l\'examen *',
                hint: 'Ex : Examen blanc Mai 2026',
                icon: Icons.title_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              // Description
              _buildField(
                controller: _descCtrl,
                label: 'Description',
                hint: 'Ex : Examen de préparation au permis B',
                icon: Icons.description_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              // Nombre de questions + durée
              Row(
                children: [
                  Expanded(
                    child: _buildSliderField(
                      label: 'Questions',
                      value: _nbQuestions,
                      min: 10,
                      max: 40,
                      divisions: 6,
                      onChanged: (v) =>
                          setState(() => _nbQuestions = v.round()),
                      color: _kAdminPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSliderField(
                      label: 'Durée (min)',
                      value: _dureeMinutes,
                      min: 10,
                      max: 60,
                      divisions: 10,
                      onChanged: (v) =>
                          setState(() => _dureeMinutes = v.round()),
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Date limite
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _dateLimite = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 18,
                        color: _dateLimite != null
                            ? _kAdminPrimary
                            : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _dateLimite != null
                            ? 'Limite : ${_dateLimite!.day.toString().padLeft(2, '0')}/${_dateLimite!.month.toString().padLeft(2, '0')}/${_dateLimite!.year}'
                            : 'Date limite (facultatif)',
                        style: TextStyle(
                          color: _dateLimite != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_dateLimite != null)
                        GestureDetector(
                          onTap: () => setState(() => _dateLimite = null),
                          child: Icon(
                            Icons.clear_rounded,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Message
              _buildField(
                controller: _messageCtrl,
                label: 'Message d\'accompagnement',
                hint: 'Ex : Bonne chance à tous ! Révisez bien les séries.',
                icon: Icons.message_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              // Bouton publier
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kAdminPrimary, _kAdminDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kAdminPrimary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: (_valid && !_loading) ? _publier : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_loading)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else ...[
                            const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _loading ? 'Publication…' : 'Publier l\'examen',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: _kAdminPrimary),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSliderField({
    required String label,
    required int value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _publier() async {
    setState(() => _loading = true);
    final data = {
      'titre': _titreCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'message': _messageCtrl.text.trim(),
      'nombreQuestions': _nbQuestions,
      'dureeMinutes': _dureeMinutes,
      if (_dateLimite != null) 'dateLimite': Timestamp.fromDate(_dateLimite!),
    };
    widget.onSubmit(data);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
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
