// DriveAuto — serie.dart
// Rôle : Modèles pour les séries de cours avec diapositives et exercices intégrés

enum TypeQuestion { qcm, checklist }

class DiapositiveQuestion {
  final String id;
  final TypeQuestion type;
  final String texte;
  final List<String> options;

  // Pour QCM : un seul index. Pour checklist : plusieurs index.
  final List<int> reponsesCorrectes;
  final String? explication;

  const DiapositiveQuestion({
    required this.id,
    required this.type,
    required this.texte,
    required this.options,
    required this.reponsesCorrectes,
    this.explication,
  });

  // Vérifie si une réponse (index unique) est correcte
  bool estCorrecte(int index) => reponsesCorrectes.contains(index);

  // Vérifie si une sélection multiple (pour checklist) est complètement correcte
  bool estSelectionCorrecte(Set<int> selection) {
    return selection.length == reponsesCorrectes.length &&
        selection.every((i) => reponsesCorrectes.contains(i));
  }
}

class Diapositive {
  final String id;
  final String serieId;
  final int ordre;
  final String titre;

  // Chemin vers assets/ (ex: 'assets/images/panneau_stop.png')
  // ou URL réseau. Null = affiche un placeholder coloré.
  final String? imagePath;

  final String contenu;
  final DiapositiveQuestion? question;

  const Diapositive({
    required this.id,
    required this.serieId,
    required this.ordre,
    required this.titre,
    this.imagePath,
    required this.contenu,
    this.question,
  });

  bool get aUneQuestion => question != null;
}

class Serie {
  final String id;
  final String titre;
  final String description;

  // Chemin assets/ ou URL. Null = couleur de fond.
  final String? couvertureImage;

  final String categorie;

  // Valeur hex de la couleur d'accentuation (ex: 0xFF00A86B)
  final int couleurHex;

  // Emoji représentant la série
  final String emoji;

  final List<Diapositive> diapositives;

  const Serie({
    required this.id,
    required this.titre,
    required this.description,
    this.couvertureImage,
    required this.categorie,
    required this.couleurHex,
    required this.emoji,
    required this.diapositives,
  });

  int get nombreDiapositives => diapositives.length;

  int get nombreQuestions => diapositives.where((d) => d.aUneQuestion).length;
}
