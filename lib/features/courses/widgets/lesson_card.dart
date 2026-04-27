/// DriveAuto — lesson_card.dart
/// Rôle : Carte affichant le résumé d'une leçon théorique dans la liste
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/lecon.dart';

class LessonCard extends StatelessWidget {
  final Lecon lecon;
  final VoidCallback onTap;

  const LessonCard({super.key, required this.lecon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icone ou Miniature
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: lecon.imageUrl != null && lecon.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          lecon.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.menu_book,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.menu_book,
                        color: AppConstants.primaryColor,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 16),
              // Titre et Catégorie
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecon.categorie.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppConstants.secondaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lecon.titre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Status d'accomplissement (Checkmark)
              if (lecon.isCompleted)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.check_circle,
                    color: AppConstants.primaryColor,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.chevron_right, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
