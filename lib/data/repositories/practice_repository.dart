/// DriveAuto — practice_repository.dart
/// Rôle : Dépôt pour récupérer les sessions pratiques et checklists (Mode Simulation)
/// Auteur : DriveAuto Team
library;

import '../../domain/models/practice.dart';

class PracticeRepository {
  /// Récupère la liste des checklists/sessions pratiques
  Future<List<PracticeSession>> getPracticeSessions() async {
    // Mode simulation direct (Sans Firestore pour l'instant)
    await Future.delayed(const Duration(milliseconds: 600)); // Simule le réseau

    return [
      PracticeSession(
        id: 'p1',
        title: 'Installation au poste de conduite',
        description:
            'Les vérifications vitales avant même de démarrer le moteur.',
        category: 'Vérifications Intérieures',
        imageUrl:
            'https://images.unsplash.com/photo-1502877338535-766e1452684a',
        items: [
          const ChecklistItem(
            id: 'i1',
            task: 'Ajuster l\'assise du siège',
            detail:
                'Les jambes doivent être légèrement fléchies en débrayant à fond.',
          ),
          const ChecklistItem(
            id: 'i2',
            task: 'Régler le dossier et le volant',
            detail:
                'Les bras doivent être légèrement pliés quand on tient le haut du volant.',
          ),
          const ChecklistItem(
            id: 'i3',
            task: 'Régler le rétroviseur int. & ext.',
            detail: 'Limiter au maximum les angles morts.',
          ),
          const ChecklistItem(
            id: 'i4',
            task: 'Attacher sa ceinture',
            detail: 'Vérifier également que les passagers ont mis la leur.',
          ),
        ],
      ),
      PracticeSession(
        id: 'p2',
        title: 'Checklist de Manœuvre : Le Créneau',
        description:
            'Checklist étape par étape pour réussir un créneau du premier coup.',
        category: 'Manoeuvres Pratiques',
        imageUrl:
            'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d',
        items: [
          const ChecklistItem(
            id: 'i5',
            task: 'Contrôler et signaler',
            detail:
                'Regarder ses rétros, angle mort et mettre le clignotant à l\'approche.',
          ),
          const ChecklistItem(
            id: 'i6',
            task: 'Positionnement initial',
            detail:
                'Se placer parallèlement au véhicule garé devant la place, à 50 cm de distance.',
          ),
          const ChecklistItem(
            id: 'i7',
            task: 'Reculer en braquant (1er temps)',
            detail:
                'Reculer doucement et braquer à fond vers le trottoir dès que l\'arrière du véhicule repère dépasse la banquette arrière.',
          ),
          const ChecklistItem(
            id: 'i8',
            task: 'Contre-braquer (2ème temps)',
            detail:
                'Une fois à 45 degrés dans la place, contre-braquer pour aligner le véhicule.',
          ),
        ],
      ),
    ];
  }
}
