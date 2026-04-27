// DriveAuto — cours_data.dart
// Rôle : Source de données locale des séries de cours (modifiable facilement).
//
// COMMENT MODIFIER CE FICHIER :
// 1. Ajouter une série  → ajouter un bloc Serie(...) dans la liste `series`
// 2. Ajouter une diapositive → ajouter un bloc Diapositive(...) dans la série concernée
// 3. Modifier les images → remplacer imagePath par 'assets/images/votre_image.png'
//    (déclarer l'asset dans pubspec.yaml)
// 4. Modifier une question → éditer le bloc DiapositiveQuestion(...)
//
// IDs UNIQUES : chaque serie et diapositive doit avoir un id unique (ex: 's1', 's1_d1').

import '../../domain/models/serie.dart';

class CoursData {
  CoursData._();

  static const List<Serie> series = [
    // ─────────────────────────────────────────────────────────────────
    // SÉRIE 1 — Signalisation routière
    // ─────────────────────────────────────────────────────────────────
    Serie(
      id: 's1',
      titre: 'Signalisation routière',
      description:
          'Apprenez à reconnaître et comprendre tous les panneaux de signalisation : danger, obligation, interdiction et indication.',
      categorie: 'Signalisation',
      couleurHex: 0xFFEF0107, // rouge
      emoji: '🚦',
      diapositives: [
        Diapositive(
          id: 's1_d1',
          serieId: 's1',
          ordre: 1,
          titre: 'Les catégories de panneaux',
          imagePath: null, // TODO: 'assets/images/s1/categories_panneaux.png'
          contenu:
              'Il existe quatre grandes catégories de panneaux de signalisation :\n\n'
              '🔴 **Panneaux de danger** — forme triangulaire, fond blanc, liseré rouge.\n'
              '🔵 **Panneaux d\'obligation** — forme ronde, fond bleu.\n'
              '⭕ **Panneaux d\'interdiction** — forme ronde, fond blanc, liseré rouge.\n'
              '🟦 **Panneaux d\'indication** — forme rectangulaire ou carrée, fond bleu ou vert.\n\n'
              'Chaque catégorie a une forme et une couleur distincte pour être reconnue immédiatement.',
          question: DiapositiveQuestion(
            id: 's1_d1_q',
            type: TypeQuestion.qcm,
            texte: 'Quelle est la forme d\'un panneau de danger ?',
            options: [
              'Ronde avec fond bleu',
              'Triangulaire avec fond blanc et liseré rouge',
              'Rectangulaire avec fond vert',
              'Carrée avec fond jaune',
            ],
            reponsesCorrectes: [1],
            explication:
                'Les panneaux de danger sont triangulaires avec un fond blanc et un liseré rouge. Cette forme se distingue facilement même à distance.',
          ),
        ),
        Diapositive(
          id: 's1_d2',
          serieId: 's1',
          ordre: 2,
          titre: 'Le panneau STOP',
          imagePath: null, // TODO: 'assets/images/s1/panneau_stop.png'
          contenu:
              'Le panneau STOP (panneau octogonal rouge avec l\'inscription "STOP") est le seul panneau de forme octogonale.\n\n'
              '**Ce que vous devez faire :**\n'
              '• Marquer un arrêt COMPLET même si la visibilité est bonne\n'
              '• Vérifier les deux sens de circulation\n'
              '• Ne repartir que lorsque la voie est libre\n\n'
              '⚠️ Ne pas marquer l\'arrêt devant un STOP est une infraction grave pouvant entraîner un retrait de permis.',
          question: DiapositiveQuestion(
            id: 's1_d2_q',
            type: TypeQuestion.qcm,
            texte:
                'Devant un panneau STOP, que devez-vous faire si la route semble libre ?',
            options: [
              'Ralentir et passer si la voie est libre',
              'S\'arrêter complètement, vérifier puis repartir',
              'Klaxonner et passer sans s\'arrêter',
              'Céder la priorité et repartir sans arrêt',
            ],
            reponsesCorrectes: [1],
            explication:
                'Devant un STOP, l\'arrêt complet est OBLIGATOIRE, même si la route est visible et libre. C\'est une règle absolue.',
          ),
        ),
        Diapositive(
          id: 's1_d3',
          serieId: 's1',
          ordre: 3,
          titre: 'Cédez le passage',
          imagePath: null, // TODO: 'assets/images/s1/cedez_passage.png'
          contenu:
              'Le panneau "Cédez le passage" est un triangle inversé (pointe en bas) avec un liseré rouge.\n\n'
              '**Ce que vous devez faire :**\n'
              '• Ralentir suffisamment\n'
              '• Céder la priorité aux véhicules circulant sur la voie principale\n'
              '• L\'arrêt n\'est pas obligatoire si la voie est libre\n\n'
              '**Différence avec STOP :**\n'
              '• STOP → arrêt obligatoire\n'
              '• Cédez le passage → ralentissement + cession de priorité',
          question: DiapositiveQuestion(
            id: 's1_d3_q',
            type: TypeQuestion.qcm,
            texte:
                'Quelle est la différence entre STOP et "Cédez le passage" ?',
            options: [
              'Aucune différence, les deux imposent un arrêt',
              'STOP impose un arrêt complet ; "Cédez" impose seulement de céder la priorité',
              '"Cédez" impose un arrêt ; STOP impose seulement de ralentir',
              'Les deux imposent de klaxonner avant de passer',
            ],
            reponsesCorrectes: [1],
            explication:
                'STOP exige un arrêt complet de la voiture. "Cédez le passage" n\'exige qu\'un ralentissement avec cession de priorité si nécessaire.',
          ),
        ),
        Diapositive(
          id: 's1_d4',
          serieId: 's1',
          ordre: 4,
          titre: 'Panneaux d\'interdiction courants',
          imagePath: null, // TODO: 'assets/images/s1/interdictions.png'
          contenu:
              'Les panneaux d\'interdiction les plus fréquents :\n\n'
              '⛔ **Sens interdit** — cercle rouge plein avec barre blanche. Tout accès est interdit.\n'
              '🚫 **Accès interdit** — cercle rouge avec croix blanche. Aucun véhicule ne peut entrer.\n'
              '🚷 **Interdiction de dépasser** — cercle blanc, deux voitures dont une rouge. Dépassement interdit.\n'
              '📵 **Arrêt et stationnement interdits** — cercle bleu avec croix rouge.\n\n'
              'Ces panneaux sont toujours de forme ronde avec un fond blanc et un liseré rouge.',
          question: DiapositiveQuestion(
            id: 's1_d4_q',
            type: TypeQuestion.qcm,
            texte:
                'Un panneau circulaire blanc avec une barre rouge horizontale signifie :',
            options: [
              'Priorité absolue',
              'Sens interdit',
              'Arrêt obligatoire',
              'Zone de vitesse limitée',
            ],
            reponsesCorrectes: [1],
            explication:
                'Le panneau circulaire blanc avec une barre rouge horizontale est le panneau "Sens interdit" : aucun véhicule ne peut s\'engager dans ce sens.',
          ),
        ),
        Diapositive(
          id: 's1_d5',
          serieId: 's1',
          ordre: 5,
          titre: 'Limitations de vitesse (panneaux)',
          imagePath: null, // TODO: 'assets/images/s1/vitesse.png'
          contenu:
              'Les panneaux de limitation de vitesse sont ronds avec un fond blanc et un liseré rouge.\n\n'
              '**Valeurs fréquentes :**\n'
              '• 30 km/h — zones résidentielles, abords d\'écoles\n'
              '• 50 km/h — agglomération (vitesse par défaut en ville)\n'
              '• 70 km/h — zones périurbaines\n'
              '• 90 km/h — route nationale hors agglomération\n'
              '• 110 / 130 km/h — voie rapide / autoroute\n\n'
              'La fin de limitation est signalée par le même panneau barré d\'une diagonale.',
          question: DiapositiveQuestion(
            id: 's1_d5_q',
            type: TypeQuestion.qcm,
            texte:
                'En agglomération, quelle est la vitesse maximale par défaut en l\'absence d\'autre panneau ?',
            options: ['30 km/h', '50 km/h', '70 km/h', '90 km/h'],
            reponsesCorrectes: [1],
            explication:
                'En agglomération, la vitesse maximale autorisée par défaut est de 50 km/h, sauf panneau contraire (ex: zone 30).',
          ),
        ),
        Diapositive(
          id: 's1_d6',
          serieId: 's1',
          ordre: 6,
          titre: 'Panneaux d\'obligation',
          imagePath: null, // TODO: 'assets/images/s1/obligations.png'
          contenu:
              'Les panneaux d\'obligation sont de forme **ronde** avec un fond **bleu** et un pictogramme blanc.\n\n'
              '**Exemples :**\n'
              '➡️ **Direction obligatoire** — flèche indiquant la direction à suivre.\n'
              '🔵 **Voie réservée aux cyclistes** — pictogramme vélo.\n'
              '🔔 **Usage du klaxon obligatoire** — sur certains virages dangereux en montagne.\n'
              '💡 **Feux de croisement obligatoires** — pictogramme phare.\n\n'
              'Ces panneaux imposent une action précise au conducteur.',
          question: DiapositiveQuestion(
            id: 's1_d6_q',
            type: TypeQuestion.qcm,
            texte:
                'Comment reconnaît-on facilement un panneau d\'obligation ?',
            options: [
              'Forme triangulaire, fond blanc',
              'Forme ronde, fond bleu',
              'Forme rectangulaire, fond vert',
              'Forme octogonale, fond rouge',
            ],
            reponsesCorrectes: [1],
            explication:
                'Les panneaux d\'obligation sont toujours ronds avec un fond bleu et un pictogramme blanc décrivant l\'action à effectuer.',
          ),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────
    // SÉRIE 2 — Règles de priorité
    // ─────────────────────────────────────────────────────────────────
    Serie(
      id: 's2',
      titre: 'Règles de priorité',
      description:
          'Maîtrisez les règles de priorité aux intersections, carrefours et ronds-points pour circuler en toute sécurité.',
      categorie: 'Priorités',
      couleurHex: 0xFFFF8C00, // orange
      emoji: '🛑',
      diapositives: [
        Diapositive(
          id: 's2_d1',
          serieId: 's2',
          ordre: 1,
          titre: 'La priorité à droite',
          imagePath: null, // TODO: 'assets/images/s2/priorite_droite.png'
          contenu:
              'La **priorité à droite** est la règle de base aux intersections sans signalisation.\n\n'
              '**Principe :** Tout conducteur doit céder le passage aux véhicules venant de sa droite.\n\n'
              '**Quand s\'applique-t-elle ?**\n'
              '• À toute intersection sans panneau de priorité\n'
              '• En l\'absence de signalisation au sol\n\n'
              '**Exceptions :**\n'
              '• Les routes à grande circulation (signalées)\n'
              '• Les ronds-points avec signalisation\n'
              '• Les sorties de garages, cours et chemins non prioritaires',
          question: DiapositiveQuestion(
            id: 's2_d1_q',
            type: TypeQuestion.qcm,
            texte:
                'À une intersection sans aucune signalisation, quel véhicule est prioritaire ?',
            options: [
              'Le véhicule le plus grand',
              'Le véhicule arrivé en premier',
              'Le véhicule venant de la droite',
              'Le véhicule allant tout droit',
            ],
            reponsesCorrectes: [2],
            explication:
                'Sans signalisation, la règle de la priorité à droite s\'applique : le véhicule venant de la droite est prioritaire.',
          ),
        ),
        Diapositive(
          id: 's2_d2',
          serieId: 's2',
          ordre: 2,
          titre: 'Le carrefour à sens giratoire (rond-point)',
          imagePath: null, // TODO: 'assets/images/s2/rond_point.png'
          contenu:
              'Dans un **rond-point signalisé**, les véhicules déjà engagés ont la priorité sur ceux qui entrent.\n\n'
              '**Règles à respecter :**\n'
              '• Céder le passage aux véhicules circulant dans le giratoire\n'
              '• S\'insérer dans la circulation au moment opportun\n'
              '• Utiliser le clignotant à droite pour signaler sa sortie\n\n'
              '**Sur un giratoire à deux voies :**\n'
              '• Voie extérieure → pour les premières sorties\n'
              '• Voie intérieure → pour les sorties plus loin\n\n'
              '⚠️ Ne pas oublier d\'indiquer la sortie avec le clignotant droit.',
          question: DiapositiveQuestion(
            id: 's2_d2_q',
            type: TypeQuestion.qcm,
            texte: 'Dans un rond-point, qui est prioritaire ?',
            options: [
              'Le véhicule qui entre dans le giratoire',
              'Le véhicule le plus à droite à l\'extérieur',
              'Le véhicule déjà engagé dans le giratoire',
              'Les deux véhicules ont la même priorité',
            ],
            reponsesCorrectes: [2],
            explication:
                'Dans un giratoire signalisé, les véhicules circulant à l\'intérieur ont la priorité sur ceux qui s\'engagent.',
          ),
        ),
        Diapositive(
          id: 's2_d3',
          serieId: 's2',
          ordre: 3,
          titre: 'Les feux tricolores',
          imagePath: null, // TODO: 'assets/images/s2/feux_tricolores.png'
          contenu:
              'Les **feux de signalisation** réglementent la circulation aux intersections.\n\n'
              '🔴 **Feu rouge** — STOP. Arrêt obligatoire avant la ligne blanche.\n'
              '🟡 **Feu orange (jaune)** — Préparez-vous à l\'arrêt. Interdiction d\'engager sauf si l\'arrêt est dangereux.\n'
              '🟢 **Feu vert** — Vous pouvez passer, mais en cédant la priorité aux piétons et à la circulation croisée.\n\n'
              '**Feu clignotant orange :** Vous devez ralentir et procéder avec prudence (priorité à droite).\n\n'
              '⚠️ Griller un feu rouge est une infraction grave.',
          question: DiapositiveQuestion(
            id: 's2_d3_q',
            type: TypeQuestion.qcm,
            texte:
                'Un feu passe à l\'orange alors que vous roulez. Que faites-vous ?',
            options: [
              'Accélérer pour passer avant le rouge',
              'Continuer normalement',
              'Freiner pour s\'arrêter, sauf si l\'arrêt est dangereux',
              'Klaxonner et passer',
            ],
            reponsesCorrectes: [2],
            explication:
                'Le feu orange signifie d\'anticiper l\'arrêt. Vous ne devez franchir la ligne que si l\'arrêt serait plus dangereux que de continuer.',
          ),
        ),
        Diapositive(
          id: 's2_d4',
          serieId: 's2',
          ordre: 4,
          titre: 'Priorité aux piétons',
          imagePath: null, // TODO: 'assets/images/s2/pietons.png'
          contenu:
              'Les piétons sont des usagers vulnérables qui bénéficient d\'une protection particulière.\n\n'
              '**Règles :**\n'
              '• Sur un passage piéton, le conducteur DOIT céder la voie aux piétons qui traversent ou s\'apprêtent à traverser.\n'
              '• Même hors passage piéton, si un piéton traverse et que la situation le permet, laissez-le passer.\n'
              '• À l\'approche d\'un arrêt de bus, ralentissez.\n\n'
              '**Pénalités :**\n'
              'Ne pas céder la priorité à un piéton sur un passage protégé est une faute grave entraînant une amende et un retrait de points.',
          question: DiapositiveQuestion(
            id: 's2_d4_q',
            type: TypeQuestion.qcm,
            texte:
                'Un piéton s\'engage sur un passage piéton. Que devez-vous faire ?',
            options: [
              'Klaxonner pour qu\'il attende',
              'Accélérer pour passer avant lui',
              'Marquer l\'arrêt et lui laisser la priorité',
              'Continuer si vous roulez à moins de 30 km/h',
            ],
            reponsesCorrectes: [2],
            explication:
                'Sur un passage piéton, le piéton est toujours prioritaire. Vous devez impérativement vous arrêter pour le laisser traverser.',
          ),
        ),
        Diapositive(
          id: 's2_d5',
          serieId: 's2',
          ordre: 5,
          titre: 'Sortie de garage et voie non prioritaire',
          imagePath: null, // TODO: 'assets/images/s2/sortie_garage.png'
          contenu:
              'Certains endroits sont considérés comme des voies non prioritaires :\n\n'
              '• Sorties de garages, cours et immeubles\n'
              '• Chemins de terre et voies sans issue\n'
              '• Stationnements et parkings\n\n'
              '**Règle :** Un véhicule sortant d\'une telle voie doit **toujours** céder la priorité à tous les usagers circulant sur la voie publique, y compris les cyclistes et piétons.\n\n'
              '⚠️ La règle "priorité à droite" ne s\'applique PAS aux sorties de garages.',
          question: DiapositiveQuestion(
            id: 's2_d5_q',
            type: TypeQuestion.qcm,
            texte: 'En sortant d\'un parking, vous devez :',
            options: [
              'Appliquer la priorité à droite',
              'Céder la priorité à tous les usagers de la voie publique',
              'Klaxonner et avancer doucement',
              'Avancer si aucun véhicule n\'est visible',
            ],
            reponsesCorrectes: [1],
            explication:
                'La sortie de parking ou de garage n\'est pas une voie prioritaire. Vous devez céder la priorité à TOUS les usagers de la voie publique.',
          ),
        ),
        Diapositive(
          id: 's2_d6',
          serieId: 's2',
          ordre: 6,
          titre: 'Les voies de tramway et bus',
          imagePath: null, // TODO: 'assets/images/s2/bus_tram.png'
          contenu:
              'Les bus et tramways ont des règles de priorité spéciales.\n\n'
              '**Tramway :**\n'
              '• Le tramway est prioritaire sur les autres véhicules dans tous les cas.\n'
              '• Ne jamais couper la route d\'un tramway.\n\n'
              '**Bus en arrêt :**\n'
              '• Lorsqu\'un bus signale qu\'il quitte un arrêt (clignotant gauche), vous devez lui céder le passage si la vitesse est ≤ 50 km/h.\n'
              '• Au-delà de 50 km/h, il n\'a pas automatiquement la priorité.',
          question: DiapositiveQuestion(
            id: 's2_d6_q',
            type: TypeQuestion.qcm,
            texte:
                'Un bus met son clignotant gauche pour quitter un arrêt en ville. Que faites-vous ?',
            options: [
              'Doubler rapidement avant qu\'il parte',
              'Céder le passage au bus',
              'Klaxonner pour le prévenir',
              'Il n\'a pas la priorité, continuez',
            ],
            reponsesCorrectes: [1],
            explication:
                'En agglomération (≤ 50 km/h), le bus signalant sa sortie d\'arrêt doit être laissé passer. Cédez-lui le passage.',
          ),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────
    // SÉRIE 3 — Vitesse et distances de sécurité
    // ─────────────────────────────────────────────────────────────────
    Serie(
      id: 's3',
      titre: 'Vitesse et distances de sécurité',
      description:
          'Comprenez les règles de vitesse, les distances de sécurité et les facteurs influençant le freinage.',
      categorie: 'Vitesse',
      couleurHex: 0xFF2196F3, // bleu
      emoji: '🚗',
      diapositives: [
        Diapositive(
          id: 's3_d1',
          serieId: 's3',
          ordre: 1,
          titre: 'Les limites de vitesse légales',
          imagePath: null, // TODO: 'assets/images/s3/limites_vitesse.png'
          contenu:
              'Les limites de vitesse varient selon le type de voie :\n\n'
              '🏙️ **En agglomération** — 50 km/h (30 km/h en zone 30)\n'
              '🛣️ **Hors agglomération** (route à 2 voies) — 90 km/h\n'
              '🛤️ **Route à 2 x 2 voies sans séparateur** — 110 km/h\n'
              '🛤️ **Voie rapide / autoroute** — 130 km/h (110 km/h par temps de pluie)\n\n'
              '⚠️ En cas de **chaussée mouillée**, toutes les vitesses sont réduites de 10 à 20 km/h.\n'
              '⚠️ Un **conducteur novice** (moins de 2 ans de permis) est soumis à des limites réduites.',
          question: DiapositiveQuestion(
            id: 's3_d1_q',
            type: TypeQuestion.qcm,
            texte:
                'Sur une route nationale hors agglomération (2 voies), quelle est la vitesse maximale autorisée par temps sec ?',
            options: ['70 km/h', '90 km/h', '110 km/h', '130 km/h'],
            reponsesCorrectes: [1],
            explication:
                'Sur une route à deux voies hors agglomération, la vitesse maximale est de 90 km/h par temps sec.',
          ),
        ),
        Diapositive(
          id: 's3_d2',
          serieId: 's3',
          ordre: 2,
          titre: 'La distance de sécurité',
          imagePath: null, // TODO: 'assets/images/s3/distance_securite.png'
          contenu:
              'La **distance de sécurité** est l\'espace à maintenir avec le véhicule qui vous précède.\n\n'
              '**Règle pratique :** Comptez au moins **2 secondes** entre votre véhicule et celui devant vous (3 secondes par mauvais temps).\n\n'
              '**Méthode des "2 secondes" :**\n'
              '• Choisissez un repère fixe (arbre, panneau)\n'
              '• Lorsque le véhicule devant vous le dépasse, comptez "mille et un, mille et deux"\n'
              '• Si vous arrivez au repère avant la fin du compte → trop proche !\n\n'
              '**En mètres approximatifs :**\n'
              '• À 50 km/h → 28 m\n'
              '• À 90 km/h → 50 m\n'
              '• À 130 km/h → 72 m',
          question: DiapositiveQuestion(
            id: 's3_d2_q',
            type: TypeQuestion.qcm,
            texte:
                'Comment appliquer la règle des "2 secondes" pour la distance de sécurité ?',
            options: [
              'Compter 2 secondes depuis le démarrage du véhicule',
              'Laisser 2 voitures de distance à tout moment',
              'Après que le véhicule devant dépasse un repère, compter 2 secondes avant d\'y arriver',
              'Rouler à 2 km/h de moins que le véhicule devant',
            ],
            reponsesCorrectes: [2],
            explication:
                'La règle des 2 secondes : quand le véhicule devant passe un repère fixe, vous devez mettre au moins 2 secondes pour atteindre ce même repère.',
          ),
        ),
        Diapositive(
          id: 's3_d3',
          serieId: 's3',
          ordre: 3,
          titre: 'Distance de freinage',
          imagePath: null, // TODO: 'assets/images/s3/freinage.png'
          contenu:
              'La **distance de freinage** est la distance parcourue entre le moment où vous freinez et l\'arrêt complet.\n\n'
              '**La distance d\'arrêt totale = Distance de réaction + Distance de freinage**\n\n'
              '**Temps de réaction moyen :** 1 seconde (peut être plus long si fatigué, distrait ou alcoolisé).\n\n'
              '**Exemples à retenir :**\n'
              '• À 50 km/h → ~35 m d\'arrêt total (14 m réaction + 21 m freinage)\n'
              '• À 90 km/h → ~95 m d\'arrêt total\n'
              '• À 130 km/h → ~170 m d\'arrêt total\n\n'
              '⚠️ En doublant la vitesse, la distance de freinage est multipliée par **4**.',
          question: DiapositiveQuestion(
            id: 's3_d3_q',
            type: TypeQuestion.qcm,
            texte:
                'Si vous doublez votre vitesse, votre distance de freinage est multipliée par :',
            options: ['2', '3', '4', '6'],
            reponsesCorrectes: [2],
            explication:
                'La distance de freinage évolue avec le carré de la vitesse : en doublant la vitesse, la distance de freinage est multipliée par 4.',
          ),
        ),
        Diapositive(
          id: 's3_d4',
          serieId: 's3',
          ordre: 4,
          titre: 'Facteurs aggravants de la vitesse',
          imagePath: null, // TODO: 'assets/images/s3/facteurs_aggravants.png'
          contenu:
              'Plusieurs facteurs augmentent le risque lors d\'un excès de vitesse :\n\n'
              '🌧️ **Pluie / chaussée mouillée** — allonge la distance de freinage de 50 %\n'
              '🌫️ **Brouillard** — réduit la visibilité, les vitesses sont limitées\n'
              '🌙 **Nuit** — visibilité réduite, fatigue accrue\n'
              '🍺 **Alcool / médicaments** — allonge le temps de réaction\n'
              '📱 **Téléphone au volant** — multiplie le risque d\'accident par 3\n'
              '😴 **Fatigue** — réflexes diminués, risque de somnolence\n\n'
              'Ces facteurs se cumulent : une nuit pluvieuse après une longue route est un risque très élevé.',
          question: DiapositiveQuestion(
            id: 's3_d4_q',
            type: TypeQuestion.qcm,
            texte:
                'Par temps de pluie, la distance de freinage est modifiée de quelle façon ?',
            options: [
              'Elle est réduite grâce à l\'eau sur la route',
              'Elle reste identique',
              'Elle est allongée d\'environ 50 %',
              'Elle est doublée uniquement sur autoroute',
            ],
            reponsesCorrectes: [2],
            explication:
                'La pluie réduit l\'adhérence des pneus. La distance de freinage est allongée d\'environ 50 % sur chaussée mouillée.',
          ),
        ),
        Diapositive(
          id: 's3_d5',
          serieId: 's3',
          ordre: 5,
          titre: 'Le dépassement',
          imagePath: null, // TODO: 'assets/images/s3/depassement.png'
          contenu:
              'Le **dépassement** est l\'une des manœuvres les plus dangereuses de la conduite.\n\n'
              '**Conditions pour dépasser en sécurité :**\n'
              '✅ Visibilité suffisante (ligne discontinue)\n'
              '✅ La route est suffisamment longue et libre devant\n'
              '✅ Le véhicule derrière n\'est pas en train de dépasser\n'
              '✅ Le véhicule à dépasser ne signale pas un virage à gauche\n\n'
              '❌ **Dépassement INTERDIT :**\n'
              '• En haut d\'une côte / dans un virage (ligne continue)\n'
              '• À un passage à niveau\n'
              '• Aux intersections (sauf en ligne droite avec bonne visibilité)\n'
              '• Quand un panneau l\'interdit',
          question: DiapositiveQuestion(
            id: 's3_d5_q',
            type: TypeQuestion.qcm,
            texte: 'Dans quel cas le dépassement est-il formellement interdit ?',
            options: [
              'Sur une route droite avec bonne visibilité',
              'Dans un virage et en haut d\'une côte',
              'Lorsque le véhicule devant roule à 40 km/h',
              'Sur une route à deux voies',
            ],
            reponsesCorrectes: [1],
            explication:
                'Le dépassement est interdit dans les virages et en haut des côtes car la visibilité est insuffisante pour garantir la sécurité.',
          ),
        ),
        Diapositive(
          id: 's3_d6',
          serieId: 's3',
          ordre: 6,
          titre: 'Alcool et conduite',
          imagePath: null, // TODO: 'assets/images/s3/alcool_conduite.png'
          contenu:
              '**L\'alcool est la première cause de mortalité sur les routes.**\n\n'
              '**Taux légaux :**\n'
              '• Permis B confirmé : taux maximum **0,5 g/L** dans le sang\n'
              '• Conducteur novice / transport en commun : **0,2 g/L**\n\n'
              '**Effets de l\'alcool :**\n'
              '• Allonge le temps de réaction\n'
              '• Rétrécit le champ visuel\n'
              '• Procure un faux sentiment de confiance\n'
              '• Réduit la coordination\n\n'
              '**Sanctions :** Amende, suspension de permis, voire prison selon le taux.',
          question: DiapositiveQuestion(
            id: 's3_d6_q',
            type: TypeQuestion.qcm,
            texte:
                'Quel est le taux d\'alcoolémie maximum autorisé pour un conducteur confirmé ?',
            options: [
              '0,2 g/L',
              '0,5 g/L',
              '0,8 g/L',
              '1,0 g/L',
            ],
            reponsesCorrectes: [1],
            explication:
                'Le taux légal pour un conducteur confirmé est de 0,5 g/L de sang. Pour les conducteurs novices, ce taux est abaissé à 0,2 g/L.',
          ),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────
    // SÉRIE 4 — Stationnement et arrêt
    // ─────────────────────────────────────────────────────────────────
    Serie(
      id: 's4',
      titre: 'Stationnement et arrêt',
      description:
          'Apprenez les règles d\'arrêt et de stationnement : où et comment stationner, et les interdictions à connaître.',
      categorie: 'Stationnement',
      couleurHex: 0xFF4CAF50, // vert
      emoji: '🅿️',
      diapositives: [
        Diapositive(
          id: 's4_d1',
          serieId: 's4',
          ordre: 1,
          titre: 'Arrêt vs Stationnement',
          imagePath: null, // TODO: 'assets/images/s4/arret_stationnement.png'
          contenu:
              '**Deux notions distinctes :**\n\n'
              '🚗 **L\'arrêt** : Immobilisation brève du véhicule (chargement/déchargement, attente…). Le conducteur reste à bord ou à proximité immédiate.\n\n'
              '🅿️ **Le stationnement** : Immobilisation prolongée du véhicule, le conducteur n\'est pas obligatoirement présent.\n\n'
              '**Interdictions :**\n'
              '• Les deux types d\'immobilisation peuvent être interdits dans certaines zones.\n'
              '• Un panneau "Arrêt et stationnement interdit" (cercle bleu + croix rouge) interdit TOUTE immobilisation.',
          question: DiapositiveQuestion(
            id: 's4_d1_q',
            type: TypeQuestion.qcm,
            texte:
                'Quelle est la différence principale entre un arrêt et un stationnement ?',
            options: [
              'L\'arrêt est autorisé partout, le stationnement non',
              'L\'arrêt est une immobilisation brève avec le conducteur présent ; le stationnement est une immobilisation prolongée',
              'L\'arrêt est interdit en ville, le stationnement est autorisé',
              'Il n\'y a aucune différence juridique',
            ],
            reponsesCorrectes: [1],
            explication:
                'L\'arrêt est une immobilisation brève avec le conducteur disponible. Le stationnement est une immobilisation prolongée sans nécessité de présence du conducteur.',
          ),
        ),
        Diapositive(
          id: 's4_d2',
          serieId: 's4',
          ordre: 2,
          titre: 'Les zones d\'interdiction de stationnement',
          imagePath: null, // TODO: 'assets/images/s4/interdictions_stationner.png'
          contenu:
              'Il est INTERDIT de stationner dans les zones suivantes :\n\n'
              '❌ À moins de 5 m d\'une intersection ou d\'un carrefour\n'
              '❌ Sur un passage piéton ou à moins de 5 m avant lui\n'
              '❌ Devant une sortie de véhicules (garages, pompiers…)\n'
              '❌ Sur une voie de tram ou à moins de 5 m d\'un arrêt de bus\n'
              '❌ En double file (sauf brève immobilisation avec conducteur)\n'
              '❌ Sur les voies rapides et autoroutes (sauf aire de repos)\n'
              '❌ Sur les emplacements réservés (handicapés, livraisons…)\n\n'
              'Ces règles garantissent la fluidité et la sécurité du trafic.',
          question: DiapositiveQuestion(
            id: 's4_d2_q',
            type: TypeQuestion.qcm,
            texte:
                'À quelle distance minimum peut-on stationner avant un passage piéton ?',
            options: ['2 m', '5 m', '10 m', '15 m'],
            reponsesCorrectes: [1],
            explication:
                'Il est interdit de stationner à moins de 5 m avant un passage piéton pour ne pas gêner la visibilité des piétons.',
          ),
        ),
        Diapositive(
          id: 's4_d3',
          serieId: 's4',
          ordre: 3,
          titre: 'Le stationnement en créneau',
          imagePath: null, // TODO: 'assets/images/s4/creneau.png'
          contenu:
              'Le **créneau** permet de se garer entre deux véhicules en marche arrière.\n\n'
              '**Étapes :**\n'
              '1. Se placer parallèle au véhicule devant (environ 1 m de distance latérale)\n'
              '2. Engager la marche arrière\n'
              '3. Braquer à fond vers le trottoir jusqu\'à former un angle de 45°\n'
              '4. Braquer en sens inverse pour redresser les roues\n'
              '5. Avancer pour centrer le véhicule dans la place\n\n'
              '**Distance minimale** : laisser au moins **1 m** devant et derrière le véhicule pour permettre la sortie.',
          question: DiapositiveQuestion(
            id: 's4_d3_q',
            type: TypeQuestion.qcm,
            texte: 'Lors d\'un créneau, dans quel sens engage-t-on la manœuvre ?',
            options: [
              'En marche avant uniquement',
              'En marche arrière',
              'En marche avant puis arrière alternativement',
              'N\'importe quel sens',
            ],
            reponsesCorrectes: [1],
            explication:
                'Le créneau commence toujours en marche arrière. On s\'aligne parallèlement au véhicule devant, puis on recule en braquant pour entrer dans la place.',
          ),
        ),
        Diapositive(
          id: 's4_d4',
          serieId: 's4',
          ordre: 4,
          titre: 'Stationnement sur une pente',
          imagePath: null, // TODO: 'assets/images/s4/pente.png'
          contenu:
              'Garer un véhicule sur une pente nécessite des précautions particulières :\n\n'
              '**Sur une pente descendante (nez vers le bas) :**\n'
              '• Braquer les roues vers le trottoir\n'
              '• Si le véhicule bouge, le trottoir le bloque\n\n'
              '**Sur une pente montante (nez vers le haut) :**\n'
              '• Braquer les roues en direction de la route (vers l\'extérieur)\n'
              '• Si le véhicule recule, les roues dirigent vers le trottoir\n\n'
              '**Toujours :**\n'
              '• Serrer le frein à main\n'
              '• Laisser en première (ou marche arrière) si la pente est forte',
          question: DiapositiveQuestion(
            id: 's4_d4_q',
            type: TypeQuestion.qcm,
            texte:
                'Votre nez est vers le bas d\'une pente. Dans quel sens braquez-vous les roues ?',
            options: [
              'Vers la route (extérieur)',
              'Tout droit',
              'Vers le trottoir',
              'Sens inverse de la pente',
            ],
            reponsesCorrectes: [2],
            explication:
                'Nez vers le bas : on braque les roues VERS le trottoir. Si le frein à main lâche, les roues viennent bloquer contre le trottoir.',
          ),
        ),
        Diapositive(
          id: 's4_d5',
          serieId: 's4',
          ordre: 5,
          titre: 'Les marquages au sol',
          imagePath: null, // TODO: 'assets/images/s4/marquages.png'
          contenu:
              'Les **marquages au sol** complètent la signalisation verticale.\n\n'
              '**Lignes longitudinales :**\n'
              '- - - **Ligne discontinue blanche** : dépassement et franchissement autorisés\n'
              '——— **Ligne continue blanche** : franchissement INTERDIT\n'
              '——— **Double ligne continue** : franchissement interdit des deux côtés\n\n'
              '**Marquages transversaux :**\n'
              '• **Ligne de stop** : arrêt obligatoire\n'
              '• **Ligne cédez-le-passage** : ligne discontinue épaisse\n'
              '• **Passages piétons** : lignes blanches parallèles\n\n'
              '**Lignes jaunes continues :** stationnement interdit sur cette portion.',
          question: DiapositiveQuestion(
            id: 's4_d5_q',
            type: TypeQuestion.qcm,
            texte: 'Que signifie une ligne continue blanche au centre de la route ?',
            options: [
              'Dépassement autorisé',
              'Franchissement et dépassement INTERDITS',
              'Voie réservée aux bus',
              'Zone de travaux',
            ],
            reponsesCorrectes: [1],
            explication:
                'Une ligne continue blanche au centre de la chaussée signifie que le franchissement est interdit : pas de dépassement, pas de changement de file.',
          ),
        ),
        Diapositive(
          id: 's4_d6',
          serieId: 's4',
          ordre: 6,
          titre: 'Stationnement gênant et abusif',
          imagePath: null, // TODO: 'assets/images/s4/stationner_abusif.png'
          contenu:
              '**Stationnement gênant :** Immobilisation gênant la circulation mais non dangereuse.\n'
              'Exemples : en double file temporaire, sur un trottoir étroit.\n\n'
              '**Stationnement dangereux :** Immobilisation créant un danger pour les autres usagers.\n'
              'Exemples : dans un virage sans visibilité, sur une voie à grande vitesse.\n\n'
              '**Stationnement abusif :** Immobilisation prolongée au même endroit (souvent > 7 jours).\n\n'
              '**Sanctions :**\n'
              '• Stationnement gênant → amende\n'
              '• Stationnement dangereux → amende + mise en fourrière\n'
              '• Stationnement abusif → mise en fourrière aux frais du propriétaire',
          question: DiapositiveQuestion(
            id: 's4_d6_q',
            type: TypeQuestion.qcm,
            texte: 'Quel type de stationnement entraîne une mise en fourrière ?',
            options: [
              'Stationnement gênant uniquement',
              'Stationnement dangereux et abusif',
              'Tout type de stationnement interdit',
              'Uniquement le stationnement sur autoroute',
            ],
            reponsesCorrectes: [1],
            explication:
                'Le stationnement dangereux (risque pour autrui) et le stationnement abusif (trop longtemps au même endroit) peuvent entraîner la mise en fourrière du véhicule.',
          ),
        ),
      ],
    ),

    // ─────────────────────────────────────────────────────────────────
    // SÉRIE 5 — Premiers secours et comportement en cas d'accident
    // ─────────────────────────────────────────────────────────────────
    Serie(
      id: 's5',
      titre: 'Premiers secours & Accidents',
      description:
          'Sachez comment réagir face à un accident : sécuriser, alerter, secourir — dans le bon ordre.',
      categorie: 'Secours',
      couleurHex: 0xFF9C27B0, // violet
      emoji: '🚑',
      diapositives: [
        Diapositive(
          id: 's5_d1',
          serieId: 's5',
          ordre: 1,
          titre: 'La méthode P.A.S.',
          imagePath: null, // TODO: 'assets/images/s5/methode_pas.png'
          contenu:
              'En cas d\'accident, respectez la méthode **P.A.S.** :\n\n'
              '🔒 **P — Protéger :** Sécuriser la zone. Baliser à 200 m minimum. Couper le moteur des véhicules accidentés. Ne pas fumer.\n\n'
              '📞 **A — Alerter :** Appeler les secours immédiatement :\n'
              '• 15 = SAMU (urgences médicales)\n'
              '• 17 = Police\n'
              '• 18 = Pompiers\n'
              '• 112 = Numéro d\'urgence européen\n\n'
              '🩹 **S — Secourir :** Apporter les premiers secours sans déplacer la victime (sauf danger immédiat).',
          question: DiapositiveQuestion(
            id: 's5_d1_q',
            type: TypeQuestion.qcm,
            texte: 'Quel est le bon ordre d\'action face à un accident (méthode P.A.S.) ?',
            options: [
              'Secourir → Alerter → Protéger',
              'Alerter → Protéger → Secourir',
              'Protéger → Alerter → Secourir',
              'Protéger → Secourir → Alerter',
            ],
            reponsesCorrectes: [2],
            explication:
                'P.A.S. : d\'abord Protéger (sécuriser la zone), puis Alerter (appeler les secours), puis Secourir (aider les victimes).',
          ),
        ),
        Diapositive(
          id: 's5_d2',
          serieId: 's5',
          ordre: 2,
          titre: 'Ne pas déplacer la victime',
          imagePath: null, // TODO: 'assets/images/s5/victime.png'
          contenu:
              '**Règle fondamentale :** Ne jamais déplacer une victime d\'accident sauf danger immédiat (incendie, noyade, etc.).\n\n'
              '**Pourquoi ?**\n'
              'Un traumatisme de la colonne vertébrale non visible peut être aggravé par un déplacement, entraînant une paralysie permanente.\n\n'
              '**Exceptions :** Si la victime est en danger immédiat (ex : véhicule en feu), déplacez-la avec précaution en maintenant sa nuque.\n\n'
              '**Victime consciente :** Parlez-lui doucement, rassurez-la, demandez-lui de ne pas bouger.',
          question: DiapositiveQuestion(
            id: 's5_d2_q',
            type: TypeQuestion.qcm,
            texte:
                'Pourquoi ne faut-il pas déplacer une victime d\'accident ?',
            options: [
              'Pour ne pas salir les vêtements',
              'Cela est interdit par la loi dans tous les cas',
              'Pour éviter d\'aggraver une éventuelle lésion de la colonne vertébrale',
              'Pour garder les preuves de l\'accident',
            ],
            reponsesCorrectes: [2],
            explication:
                'Déplacer une victime peut aggraver un traumatisme de la colonne non visible et entraîner une paralysie permanente. Ne déplacer que si danger immédiat.',
          ),
        ),
        Diapositive(
          id: 's5_d3',
          serieId: 's5',
          ordre: 3,
          titre: 'La position latérale de sécurité (PLS)',
          imagePath: null, // TODO: 'assets/images/s5/pls.png'
          contenu:
              'La **PLS** (Position Latérale de Sécurité) est utilisée pour une victime inconsciente mais qui respire.\n\n'
              '**Objectif :** Éviter que la victime ne s\'étouffe avec sa langue ou en vomissant.\n\n'
              '**Comment faire :**\n'
              '1. Agenouiller à côté de la victime\n'
              '2. Placer le bras proche de vous à angle droit\n'
              '3. Ramener l\'autre main sous sa joue\n'
              '4. Soulever le genou éloigné et faire basculer la victime vers vous\n'
              '5. Stabiliser la tête légèrement en arrière pour dégager les voies aériennes\n\n'
              '✅ Surveiller la respiration en attendant les secours.',
          question: DiapositiveQuestion(
            id: 's5_d3_q',
            type: TypeQuestion.qcm,
            texte:
                'La PLS (Position Latérale de Sécurité) est utilisée pour une victime :',
            options: [
              'Consciente et qui parle normalement',
              'Inconsciente qui ne respire plus',
              'Inconsciente mais qui respire encore',
              'Consciente mais blessée à la jambe',
            ],
            reponsesCorrectes: [2],
            explication:
                'La PLS s\'applique à une victime inconsciente MAIS qui respire. Elle évite l\'étouffement. Si la victime ne respire pas, c\'est la RCP (réanimation) qu\'il faut pratiquer.',
          ),
        ),
        Diapositive(
          id: 's5_d4',
          serieId: 's5',
          ordre: 4,
          titre: 'Le triangle de présignalisation',
          imagePath: null, // TODO: 'assets/images/s5/triangle.png'
          contenu:
              'Le **triangle de présignalisation** est un équipement de sécurité obligatoire dans tout véhicule.\n\n'
              '**Utilisation :**\n'
              '• Poser le triangle à **200 m minimum** du véhicule en panne ou accidenté sur une route normale\n'
              '• À **150 m** en agglomération\n'
              '• Pas sur autoroute (trop dangereux) : allumer les feux de détresse et rester derrière la glissière\n\n'
              '**Autres équipements obligatoires :**\n'
              '• Gilet fluorescent (porter avant de sortir du véhicule !)\n'
              '• Extincteur (recommandé)',
          question: DiapositiveQuestion(
            id: 's5_d4_q',
            type: TypeQuestion.qcm,
            texte:
                'À quelle distance minimum doit-on placer le triangle de présignalisation sur route ?',
            options: ['50 m', '100 m', '200 m', '500 m'],
            reponsesCorrectes: [2],
            explication:
                'Sur une route normale, le triangle doit être placé à au moins 200 m du véhicule en panne pour laisser le temps aux autres conducteurs de ralentir.',
          ),
        ),
        Diapositive(
          id: 's5_d5',
          serieId: 's5',
          ordre: 5,
          titre: 'L\'obligation de secourir',
          imagePath: null, // TODO: 'assets/images/s5/obligation_secourir.png'
          contenu:
              'En France et dans la plupart des pays francophones, **il est légalement obligatoire** de porter secours à toute personne en danger.\n\n'
              '**Non-assistance à personne en danger :**\n'
              '• Infraction pénale grave\n'
              '• Peine allant jusqu\'à 5 ans de prison et 75 000 € d\'amende\n\n'
              '**Comment aider sans risque :**\n'
              '• Appeler le 15 ou 18 (les secours vous guident par téléphone)\n'
              '• Ne pas hésiter à pratiquer les gestes de premier secours\n'
              '• Vous ne pouvez pas être poursuivi si vous avez agi de bonne foi\n\n'
              '⚠️ Ne jamais fuir les lieux d\'un accident que vous avez provoqué.',
          question: DiapositiveQuestion(
            id: 's5_d5_q',
            type: TypeQuestion.qcm,
            texte: 'Que risque-t-on légalement en ne portant pas secours à une victime d\'accident ?',
            options: [
              'Rien, c\'est une question morale, pas légale',
              'Une simple amende administrative',
              'Une peine de prison et une forte amende',
              'Uniquement la suspension du permis de conduire',
            ],
            reponsesCorrectes: [2],
            explication:
                'La non-assistance à personne en danger est un délit pénal. Elle peut entraîner jusqu\'à 5 ans de prison et 75 000 € d\'amende.',
          ),
        ),
        Diapositive(
          id: 's5_d6',
          serieId: 's5',
          ordre: 6,
          titre: 'Constat amiable d\'accident',
          imagePath: null, // TODO: 'assets/images/s5/constat.png'
          contenu:
              'Le **constat amiable** est un document que les conducteurs impliqués dans un accident remplissent ensemble.\n\n'
              '**Contenu du constat :**\n'
              '• Date, lieu, circonstances de l\'accident\n'
              '• Informations sur les conducteurs et véhicules\n'
              '• Schéma de l\'accident\n'
              '• Dommages observés\n\n'
              '**Règles :**\n'
              '• Le remplir calmement et précisément\n'
              '• Chaque conducteur garde un volet\n'
              '• À envoyer à son assurance dans les **5 jours ouvrés**\n'
              '• Si désaccord : écrire ses réserves avant de signer\n\n'
              '⚠️ Une signature engage votre responsabilité.',
          question: DiapositiveQuestion(
            id: 's5_d6_q',
            type: TypeQuestion.qcm,
            texte: 'Dans quel délai doit-on envoyer le constat amiable à son assurance ?',
            options: [
              '24 heures',
              '3 jours ouvrés',
              '5 jours ouvrés',
              '30 jours',
            ],
            reponsesCorrectes: [2],
            explication:
                'Le constat amiable doit être envoyé à votre compagnie d\'assurance dans un délai de 5 jours ouvrés suivant l\'accident.',
          ),
        ),
      ],
    ),
  ];
}
