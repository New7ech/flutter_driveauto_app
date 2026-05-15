// DriveAuto — admin_slide_form_screen.dart
// Role : Formulaire de creation / edition d'une diapositive avec question integree

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/media_upload_service.dart';
import '../../../data/repositories/serie_repository.dart';
import '../../../domain/models/serie.dart';
import '../../../providers/serie_provider.dart';

class AdminSlideFormScreen extends ConsumerStatefulWidget {
  const AdminSlideFormScreen({
    super.key,
    required this.serieId,
    required this.ordreDefaut,
    this.diapoExistante,
  });

  final String serieId;
  final int ordreDefaut;
  final Diapositive? diapoExistante;

  @override
  ConsumerState<AdminSlideFormScreen> createState() =>
      _AdminSlideFormScreenState();
}

class _AdminSlideFormScreenState extends ConsumerState<AdminSlideFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titreCtrl;
  late TextEditingController _contenuCtrl;
  late TextEditingController _ordreCtrl;
  late TextEditingController _questionTexteCtrl;
  late TextEditingController _explicationCtrl;
  late TextEditingController _imageUrlCtrl;
  final List<TextEditingController> _optionsCtrls = [];
  final Set<int> _reponsesCorrectes = {};

  // ── Image ──
  String? _imageUrl; // URL existante ou saisie manuellement
  XFile? _imageFile; // Image fraîchement choisie depuis la galerie
  bool _isPickingImage = false;
  bool _isUploadingImage = false;

  bool _avecQuestion = false;
  TypeQuestion _typeQuestion = TypeQuestion.qcm;

  bool _saving = false;
  bool get _isEdit => widget.diapoExistante != null;

  @override
  void initState() {
    super.initState();
    final d = widget.diapoExistante;
    _titreCtrl = TextEditingController(text: d?.titre ?? '');
    _contenuCtrl = TextEditingController(text: d?.contenu ?? '');
    _ordreCtrl = TextEditingController(
      text: '${d?.ordre ?? widget.ordreDefaut}',
    );
    _questionTexteCtrl = TextEditingController(text: d?.question?.texte ?? '');
    _explicationCtrl = TextEditingController(
      text: d?.question?.explication ?? '',
    );
    _imageUrlCtrl = TextEditingController(text: d?.imagePath ?? '');
    _imageUrl = d?.imagePath;

    if (d?.question != null) {
      _avecQuestion = true;
      _typeQuestion = d!.question!.type;
      for (final opt in d.question!.options) {
        _optionsCtrls.add(TextEditingController(text: opt));
      }
      _reponsesCorrectes.addAll(d.question!.reponsesCorrectes);
    }

    if (_optionsCtrls.isEmpty) {
      _optionsCtrls.addAll([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titreCtrl,
      _contenuCtrl,
      _ordreCtrl,
      _questionTexteCtrl,
      _explicationCtrl,
      _imageUrlCtrl,
    ]) {
      c.dispose();
    }
    for (final c in _optionsCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Sélection d'image depuis la galerie
  // ─────────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    if (_isPickingImage || _isUploadingImage || _saving) return;

    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (!mounted) return;
      if (picked != null) {
        setState(() {
          _imageFile = picked;
          _imageUrl = null; // l'ancienne URL est remplacée
          _imageUrlCtrl.clear();
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'already_active') {
        _showImagePickerError(
          "Le sélecteur d'image est déjà ouvert. Fermez la galerie puis réessayez.",
        );
        return;
      }

      _showImagePickerError(_formatPickerError(e));
    } catch (e) {
      if (!mounted) return;
      _showImagePickerError("Impossible d'ouvrir la galerie : $e");
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _showImagePickerError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatPickerError(PlatformException error) {
    switch (error.code) {
      case 'photo_access_denied':
      case 'camera_access_denied':
      case 'permission_denied':
        return "Accès aux photos refusé. Autorisez l'application dans les paramètres puis réessayez.";
      case 'invalid_image':
        return "Le fichier choisi n'est pas une image valide.";
      default:
        final details = error.message?.trim();
        return details == null || details.isEmpty
            ? "Impossible d'ouvrir la galerie (${error.code})."
            : "Impossible d'ouvrir la galerie : $details";
    }
  }

  Future<String?> _uploadImage(String diapoId) async {
    final existingImage = _imageUrlCtrl.text.trim();
    if (_imageFile == null) {
      if (existingImage.isEmpty) return null;
      return existingImage;
    }

    setState(() => _isUploadingImage = true);
    try {
      return const MediaUploadService().uploadSlideImage(
        file: _imageFile!,
        serieId: widget.serieId,
        diapoId: diapoId,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  bool _isHttpUrl(String source) {
    return source.startsWith('http://') || source.startsWith('https://');
  }

  bool _isLocalFilePath(String source) {
    return source.startsWith('/') || (source.length > 2 && source[1] == ':');
  }

  // ─────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Modifier la diapositive' : 'Nouvelle diapositive',
        ),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Contenu de la diapositive'),
            const SizedBox(height: 12),

            // Ordre
            TextFormField(
              controller: _ordreCtrl,
              decoration: const InputDecoration(
                labelText: "Ordre d'affichage *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sort),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obligatoire';
                if (int.tryParse(v.trim()) == null) return 'Entier requis';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Titre
            TextFormField(
              controller: _titreCtrl,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 12),

            // Contenu
            TextFormField(
              controller: _contenuCtrl,
              decoration: const InputDecoration(
                labelText: 'Contenu (texte de la diapositive) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 16),

            // ── Sélecteur d'image ──────────────────────────────────
            _buildSectionHeader('Image (optionnel)'),
            const SizedBox(height: 12),
            _buildImagePicker(),
            const SizedBox(height: 24),

            // Toggle question
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Ajouter une question / exercice',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('QCM ou checklist avec feedback'),
                value: _avecQuestion,
                onChanged: (v) => setState(() => _avecQuestion = v),
                activeThumbColor: AppConstants.primaryColor,
              ),
            ),

            if (_avecQuestion) ...[
              const SizedBox(height: 16),
              _buildSectionHeader('Question / Exercice'),
              const SizedBox(height: 12),
              _buildQuestionForm(),
            ],

            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7B1FA2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_saving || _isUploadingImage || _isPickingImage)
                  ? null
                  : _sauvegarder,
              child: (_saving || _isUploadingImage || _isPickingImage)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isPickingImage
                              ? 'Ouverture galerie...'
                              : _isUploadingImage
                              ? 'Envoi image...'
                              : 'Enregistrement...',
                        ),
                      ],
                    )
                  : Text(
                      _isEdit
                          ? 'Enregistrer les modifications'
                          : 'Créer la diapositive',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Widget sélecteur d'image
  // ─────────────────────────────────────────────────────────────────

  Widget _buildImagePicker() {
    final hasLocalFile = _imageFile != null;
    final hasUrl = _imageUrl != null && _imageUrl!.isNotEmpty;
    final hasImage = hasLocalFile || hasUrl;
    final isBusy = _saving || _isUploadingImage || _isPickingImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Zone de prévisualisation / bouton de sélection
        GestureDetector(
          onTap: isBusy ? null : _pickImage,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasImage
                    ? const Color(0xFF7B1FA2).withValues(alpha: 0.6)
                    : Colors.grey.shade300,
                width: hasImage ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                hasLocalFile
                    ? _buildLocalPreview()
                    : hasUrl
                    ? _buildNetworkPreview()
                    : _buildPickerPlaceholder(),
                if (_isPickingImage)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.28),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Boutons sous la zone d'image
        if (hasImage) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.red,
                ),
                label: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
                onPressed: isBusy
                    ? null
                    : () => setState(() {
                        _imageFile = null;
                        _imageUrl = null;
                        _imageUrlCtrl.clear();
                      }),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('Changer', style: TextStyle(fontSize: 13)),
                onPressed: isBusy ? null : _pickImage,
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choisir depuis la galerie'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7B1FA2),
              side: const BorderSide(color: Color(0xFF7B1FA2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: isBusy ? null : _pickImage,
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OU', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _imageUrlCtrl,
            decoration: const InputDecoration(
              labelText: "Lien de l'image (Ex: https://...)",
              hintText: "Collez l'URL d'une image hébergée sur internet",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
            onChanged: (val) {
              setState(() {
                _imageUrl = val;
                _imageFile = null;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLocalPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildPickedImagePreview(),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Image sélectionnée',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickedImagePreview() {
    if (!kIsWeb) {
      return Image.file(File(_imageFile!.path), fit: BoxFit.cover);
    }

    return FutureBuilder<Uint8List>(
      future: _imageFile!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }
        if (snapshot.hasError) return _buildPickerPlaceholder();
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildNetworkPreview() {
    final source = _imageUrl!.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildStoredImagePreview(source),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_done, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Image actuelle',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStoredImagePreview(String source) {
    if (source.startsWith('data:image/')) {
      try {
        final b64 = source.substring(source.indexOf(',') + 1);
        return Image.memory(
          base64Decode(b64),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPickerPlaceholder(),
        );
      } catch (_) {
        return _buildPickerPlaceholder();
      }
    }

    if (_isHttpUrl(source)) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => _buildPickerPlaceholder(),
        placeholder: (_, _) {
          return Center(
            child: CircularProgressIndicator(color: AppConstants.primaryColor),
          );
        },
      );
    }

    if (_isLocalFilePath(source)) {
      if (kIsWeb) return _buildPickerPlaceholder();
      return Image.file(
        File(source),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPickerPlaceholder(),
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildPickerPlaceholder(),
    );
  }

  String _formatSaveError(Object error) {
    if (error is MediaUploadException) return error.message;

    if (error is FirebaseException) {
      final message = error.message?.trim();
      final suffix = message == null || message.isEmpty ? '' : ' ($message)';

      if (error.plugin == 'cloud_firestore') {
        switch (error.code) {
          case 'permission-denied':
            return "Firestore refuse la mise à jour du profil admin. Vérifiez que firestore.rules est déployé.";
          case 'unavailable':
            return 'Firestore est indisponible pour le moment. Réessayez.';
          default:
            return 'Erreur Firestore ${error.code}$suffix';
        }
      }

      return 'Erreur Firebase ${error.code}$suffix';
    }

    return error.toString();
  }

  Widget _buildPickerPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Text(
          'Appuyer pour choisir une image',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Formulaire question
  // ─────────────────────────────────────────────────────────────────

  Widget _buildQuestionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type
        Row(
          children: [
            const Text(
              'Type : ',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('QCM'),
              selected: _typeQuestion == TypeQuestion.qcm,
              onSelected: (_) => setState(() {
                _typeQuestion = TypeQuestion.qcm;
                _reponsesCorrectes.clear();
              }),
              selectedColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: _typeQuestion == TypeQuestion.qcm ? Colors.white : null,
              ),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Checklist'),
              selected: _typeQuestion == TypeQuestion.checklist,
              onSelected: (_) => setState(() {
                _typeQuestion = TypeQuestion.checklist;
                _reponsesCorrectes.clear();
              }),
              selectedColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: _typeQuestion == TypeQuestion.checklist
                    ? Colors.white
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Texte de la question
        TextFormField(
          controller: _questionTexteCtrl,
          decoration: const InputDecoration(
            labelText: 'Texte de la question *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.help_outline),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          validator: (v) => _avecQuestion && (v == null || v.trim().isEmpty)
              ? 'Obligatoire'
              : null,
        ),
        const SizedBox(height: 16),

        // Options
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Options de réponse',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              onPressed: () => setState(() {
                _optionsCtrls.add(TextEditingController());
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),

        _buildOptionsListe(),
        const SizedBox(height: 4),

        if (_reponsesCorrectes.isEmpty && _avecQuestion)
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'Sélectionnez au moins une réponse correcte',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        const SizedBox(height: 12),

        // Explication
        TextFormField(
          controller: _explicationCtrl,
          decoration: const InputDecoration(
            labelText: 'Explication (optionnel)',
            hintText: 'Affiché après la validation de la réponse',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.info_outline),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildOptionsListe() {
    Widget buildRow(int i) {
      return Column(
        key: ValueKey(i),
        children: [
          Row(
            children: [
              if (_typeQuestion == TypeQuestion.qcm)
                Radio<int>(value: i)
              else
                Checkbox(
                  value: _reponsesCorrectes.contains(i),
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _reponsesCorrectes.add(i);
                    } else {
                      _reponsesCorrectes.remove(i);
                    }
                  }),
                  activeColor: AppConstants.primaryColor,
                ),
              Expanded(
                child: TextFormField(
                  controller: _optionsCtrls[i],
                  decoration: InputDecoration(
                    labelText: 'Option ${i + 1}',
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) =>
                      (_avecQuestion && (v == null || v.trim().isEmpty))
                      ? 'Obligatoire'
                      : null,
                ),
              ),
              if (_optionsCtrls.length > 2)
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => setState(() {
                    _optionsCtrls.removeAt(i);
                    _reponsesCorrectes.remove(i);
                    final adjusted = _reponsesCorrectes
                        .map((r) => r > i ? r - 1 : r)
                        .toSet();
                    _reponsesCorrectes
                      ..clear()
                      ..addAll(adjusted);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    final rows = [for (var i = 0; i < _optionsCtrls.length; i++) buildRow(i)];

    if (_typeQuestion == TypeQuestion.qcm) {
      return RadioGroup<int>(
        groupValue: _reponsesCorrectes.isEmpty ? -1 : _reponsesCorrectes.first,
        onChanged: (v) {
          if (v != null) {
            setState(
              () => _reponsesCorrectes
                ..clear()
                ..add(v),
            );
          }
        },
        child: Column(children: rows),
      );
    }

    return Column(children: rows);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: const Color(0xFF7B1FA2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Sauvegarde
  // ─────────────────────────────────────────────────────────────────

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_avecQuestion && _reponsesCorrectes.isEmpty) {
      setState(() {});
      return;
    }

    setState(() => _saving = true);

    try {
      // Déterminer l'ID de la diapo avant l'upload média.
      final diapoId =
          widget.diapoExistante?.id ?? SerieRepository.generateId('d');

      // Upload image si une nouvelle a été choisie
      final finalImagePath = await _uploadImage(diapoId);

      DiapositiveQuestion? question;
      if (_avecQuestion) {
        final options = _optionsCtrls
            .map((c) => c.text.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        question = DiapositiveQuestion(
          id:
              widget.diapoExistante?.question?.id ??
              SerieRepository.generateId('q'),
          type: _typeQuestion,
          texte: _questionTexteCtrl.text.trim(),
          options: options,
          reponsesCorrectes: _reponsesCorrectes.toList()..sort(),
          explication: _explicationCtrl.text.trim().isEmpty
              ? null
              : _explicationCtrl.text.trim(),
        );
      }

      final diapo = Diapositive(
        id: diapoId,
        serieId: widget.serieId,
        ordre: int.tryParse(_ordreCtrl.text.trim()) ?? widget.ordreDefaut,
        titre: _titreCtrl.text.trim(),
        contenu: _contenuCtrl.text.trim(),
        imagePath: finalImagePath,
        question: question,
      );

      await ref
          .read(seriesNotifierProvider.notifier)
          .saveDiapositive(widget.serieId, diapo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? '« ${diapo.titre} » modifiée.'
                  : '« ${diapo.titre} » créée.',
            ),
            backgroundColor: AppConstants.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Impossible d'enregistrer la diapositive : ${_formatSaveError(e)}",
            ),
            backgroundColor: AppConstants.secondaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
