// DriveAuto — admin_slides_screen.dart
// Role : Gestion des diapositives d'une serie (liste + reordonnement + CRUD)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/serie.dart';
import '../../../providers/serie_provider.dart';
import 'admin_slide_form_screen.dart';

class AdminSlidesScreen extends ConsumerWidget {
  const AdminSlidesScreen({super.key, required this.serie});

  final Serie serie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Relit la serie depuis le provider pour avoir les mises a jour en temps reel
    final serieActuelle =
        ref.watch(serieByIdProvider(serie.id)) ?? serie;
    final slides = serieActuelle.diapositives;
    final couleur = Color(serieActuelle.couleurHex);

    return Scaffold(
      appBar: AppBar(
        title: Text('${serieActuelle.emoji}  ${serieActuelle.titre}'),
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une diapositive',
            onPressed: () => _ajouterSlide(context, serieActuelle),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: couleur,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle diapositive'),
        onPressed: () => _ajouterSlide(context, serieActuelle),
      ),
      body: slides.isEmpty
          ? _buildEmpty(context, serieActuelle)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: slides.length,
              itemBuilder: (context, index) {
                final diapo = slides[index];
                return _SlideAdminCard(
                  diapo: diapo,
                  serieId: serieActuelle.id,
                  couleur: couleur,
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, Serie s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          const Text('Aucune diapositive dans cette série.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter la première diapositive'),
            onPressed: () => _ajouterSlide(context, s),
          ),
        ],
      ),
    );
  }

  void _ajouterSlide(BuildContext context, Serie s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSlideFormScreen(
          serieId: s.id,
          ordreDefaut: s.diapositives.length + 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SlideAdminCard extends ConsumerWidget {
  const _SlideAdminCard({
    required this.diapo,
    required this.serieId,
    required this.couleur,
  });

  final Diapositive diapo;
  final String serieId;
  final Color couleur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Numéro d'ordre
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${diapo.ordre}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: couleur,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    diapo.titre,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                // Badge question
                if (diapo.aUneQuestion)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz_outlined,
                            size: 11, color: AppConstants.primaryColor),
                        const SizedBox(width: 3),
                        Text(
                          diapo.question!.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (diapo.contenu.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                diapo.contenu,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (diapo.imagePath != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.image_outlined,
                      size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      diapo.imagePath!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Modifier'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminSlideFormScreen(
                        serieId: serieId,
                        diapoExistante: diapo,
                        ordreDefaut: diapo.ordre,
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                      foregroundColor: AppConstants.secondaryColor),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Supprimer'),
                  onPressed: () =>
                      _confirmerSuppression(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerSuppression(
      BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Supprimer « ${diapo.titre} » ?'),
            content: const Text(
                'Cette diapositive et sa question seront supprimées.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok || !context.mounted) return;
    await ref
        .read(seriesNotifierProvider.notifier)
        .deleteDiapositive(serieId, diapo.id);
  }
}
