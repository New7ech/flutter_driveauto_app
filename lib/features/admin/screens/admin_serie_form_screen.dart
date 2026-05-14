// DriveAuto — admin_serie_form_screen.dart
// Role : Formulaire de creation / edition d'une serie

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/serie_repository.dart';
import '../../../domain/models/serie.dart';
import '../../../providers/serie_provider.dart';

// Couleurs disponibles pour les series
const List<int> _kCouleurs = [
  0xFF00A86B, // vert BF
  0xFFEF0107, // rouge BF
  0xFFFCD116, // jaune BF
  0xFF2196F3, // bleu
  0xFFFF8C00, // orange
  0xFF7B1FA2, // violet
  0xFF009688, // teal
  0xFFE91E63, // rose
  0xFF607D8B, // gris bleu
  0xFF795548, // marron
];

const List<String> _kEmojis = [
  '🚦',
  '🛑',
  '🚗',
  '🅿️',
  '🚑',
  '📚',
  '🎓',
  '🚧',
  '⚠️',
  '🗺️',
  '🛤️',
  '🚘',
  '✅',
  '📝',
  '🔑',
  '🏁',
  '🛣️',
  '🚙',
  '⛽',
  '🔧',
];

class AdminSerieFormScreen extends ConsumerStatefulWidget {
  const AdminSerieFormScreen({super.key, this.serie});

  final Serie? serie;

  @override
  ConsumerState<AdminSerieFormScreen> createState() =>
      _AdminSerieFormScreenState();
}

class _AdminSerieFormScreenState extends ConsumerState<AdminSerieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titreCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _categorieCtrl;

  late String _emoji;
  late int _couleurHex;
  bool _saving = false;

  bool get _isEdit => widget.serie != null;

  @override
  void initState() {
    super.initState();
    final s = widget.serie;
    _titreCtrl = TextEditingController(text: s?.titre ?? '');
    _descriptionCtrl = TextEditingController(text: s?.description ?? '');
    _categorieCtrl = TextEditingController(text: s?.categorie ?? '');
    _emoji = s?.emoji ?? '📚';
    _couleurHex = s?.couleurHex ?? _kCouleurs.first;
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descriptionCtrl.dispose();
    _categorieCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier la série' : 'Nouvelle série'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Aperçu
            _buildPreview(),
            const SizedBox(height: 24),

            // Titre
            TextFormField(
              controller: _titreCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Catégorie
            TextFormField(
              controller: _categorieCtrl,
              decoration: const InputDecoration(
                labelText: 'Catégorie *',
                hintText: 'ex: Signalisation, Priorités...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
            ),
            const SizedBox(height: 24),

            // Emoji
            _buildLabel('Icône (emoji)'),
            const SizedBox(height: 8),
            _buildEmojiPicker(),
            const SizedBox(height: 24),

            // Couleur
            _buildLabel('Couleur d\'accentuation'),
            const SizedBox(height: 8),
            _buildColorPicker(),
            const SizedBox(height: 32),

            // Bouton sauvegarder
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _saving ? null : _sauvegarder,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEdit
                          ? 'Enregistrer les modifications'
                          : 'Créer la série',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(_couleurHex).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Color(_couleurHex).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Color(_couleurHex).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(_emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titreCtrl.text.isEmpty
                      ? 'Titre de la série'
                      : _titreCtrl.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(_couleurHex),
                    fontSize: 15,
                  ),
                ),
                Text(
                  _categorieCtrl.text.isEmpty
                      ? 'Catégorie'
                      : _categorieCtrl.text,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildEmojiPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kEmojis.map((e) {
        final selected = e == _emoji;
        return GestureDetector(
          onTap: () => setState(() => _emoji = e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected
                  ? Color(_couleurHex).withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: Color(_couleurHex), width: 2)
                  : null,
            ),
            child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _kCouleurs.map((hex) {
        final selected = hex == _couleurHex;
        return GestureDetector(
          onTap: () => setState(() => _couleurHex = hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(hex),
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: Colors.black, width: 2.5)
                  : Border.all(color: Colors.transparent),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Color(hex).withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final serie = Serie(
      id: widget.serie?.id ?? SerieRepository.generateId('s'),
      titre: _titreCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      categorie: _categorieCtrl.text.trim(),
      couleurHex: _couleurHex,
      emoji: _emoji,
      diapositives: widget.serie?.diapositives ?? [],
    );

    await ref.read(seriesNotifierProvider.notifier).saveSerie(serie);

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? '« ${serie.titre} » modifiée.'
                : '« ${serie.titre} » créée.',
          ),
          backgroundColor: AppConstants.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}
