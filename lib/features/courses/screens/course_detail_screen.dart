/// DriveAuto — course_detail_screen.dart
/// Rôle : Affichage d'une leçon complète (Texte riche, image et embed YouTube)
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/lecon.dart';
import '../../../providers/repository_providers.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String leconId;
  final Lecon? leconData;

  const CourseDetailScreen({super.key, required this.leconId, this.leconData});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  Lecon? _lecon;
  bool _isLoading = false;
  String? _error;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    if (widget.leconData != null) {
      _lecon = widget.leconData;
      _initYoutube();
    } else {
      _fetchLeconData();
    }
  }

  Future<void> _fetchLeconData() async {
    setState(() => _isLoading = true);
    try {
      final lecons = await ref.read(leconRepositoryProvider).getLecons();
      _lecon = lecons.firstWhere((l) => l.id == widget.leconId);
      _initYoutube();
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Leçon introuvable ou problème réseau.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initYoutube() {
    if (_lecon != null &&
        _lecon!.youtubeVideoId != null &&
        _lecon!.youtubeVideoId!.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _lecon!.youtubeVideoId!,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void deactivate() {
    // Requis si la vue est mise en arrière-plan
    _youtubeController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _lecon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(child: Text(_error ?? 'Leçon non disponible')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_lecon!.titre, style: const TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Catégorie
            Chip(
              label: Text(
                _lecon!.categorie.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: AppConstants.secondaryColor,
            ),
            const SizedBox(height: 16),

            // Titre Principal
            Text(
              _lecon!.titre,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Média principal : YouTube OU Image
            if (_youtubeController != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppConstants.primaryColor,
                  progressColors: const ProgressBarColors(
                    playedColor: AppConstants.primaryColor,
                    handleColor: AppConstants.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else if (_lecon!.imageUrl != null &&
                _lecon!.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _lecon!.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Contenu de la leçon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.cardColorDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                _lecon!.texteRiche,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.8),
              ),
            ),

            const SizedBox(height: 40),

            // Bouton Marquer Terminée
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  _lecon!.isCompleted ? Icons.check_circle : Icons.check,
                ),
                label: Text(
                  _lecon!.isCompleted
                      ? 'Leçon terminée'
                      : 'Marquer comme terminée',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _lecon!.isCompleted
                      ? Colors.grey
                      : AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _lecon!.isCompleted
                    ? null
                    : () async {
                        // Avertissement UI (MVP). En réalité, appele UserRepository pour mettre à jour la BDD
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Leçon validée ! Bravo 🎉',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppConstants.primaryColor,
                          ),
                        );
                      },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
