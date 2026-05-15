<div align="center">
  <h1>🚗 DriveAuto</h1>
  
  [![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.22-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
  [![Android](https://img.shields.io/badge/Android-Arm64-3DDC84?logo=android&logoColor=white)](https://android.com)

  *Votre auto-école de poche au Burkina Faso*
</div>

---

## 📖 Description
DriveAuto est une application mobile complète conçue pour révolutionner l'apprentissage de la conduite au Burkina Faso. Elle permet aux apprenants de réviser leurs leçons de code, de s'entraîner via des examens blancs interactifs, et de suivre leur progression pédagogique en temps réel. Dotée d'un mode "Offline-first", DriveAuto garantit l'accès aux cours même sans connexion internet stable.

## ⚙️ Prérequis
- **Flutter** ≥ 3.22
- **Dart** ≥ 3.4
- Un compte **Firebase** pour l'authentification, Firestore, Analytics, Crashlytics et les notifications Push.
- Un compte **Cloudinary** avec un upload preset unsigned pour les images des diapositives.

## 🚀 Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/ton-user/flutter_driveauto_app
cd flutter_driveauto_app

# 2. Installer les dépendances
flutter pub get

# 3. Générer les fichiers (Riverpod, Freezed, Hive, Mockito)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Configurer l'environnement
cp .env.example .env
# Remplir .env avec les valeurs Firebase/Cloudinary
```

## 🔥 Configuration Firebase
1. Créez un projet sur la console Firebase.
2. Ajoutez une application Android et téléchargez le fichier `google-services.json`.
3. Placez `google-services.json` dans le dossier `android/app/`.
4. (Recommandé) Exécutez la commande `flutterfire configure` à la racine pour synchroniser toutes les plateformes.

## 🖼️ Configuration Cloudinary
1. Créez un upload preset en mode **Unsigned**.
2. Limitez le preset aux formats `jpg`, `jpeg`, `png`, `webp`.
3. Utilisez `driveauto/slides` comme dossier de ressources.
4. Ajoutez les valeurs dans `.env` :

```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=your-unsigned-upload-preset
CLOUDINARY_SLIDES_FOLDER=driveauto/slides
```

Ne mettez jamais `CLOUDINARY_API_SECRET` dans l'application Flutter.

## 📱 Lancer l'app

```bash
# Lancement en mode debug
flutter run

# Lancement en mode release (Performances OPTIMALES)
flutter run --release

# Compiler un APK pour le distribuer
flutter build apk --release --target-platform android-arm64
```

## 🏗️ Architecture
L'application respecte la **Clean Architecture** couplée à **Riverpod** pour la gestion d'état. L'arborescence est "Feature-First".

```text
lib/
├── core/                   # Cœur de l'application (thème, constantes, utils, validateurs)
├── data/                   # Couche Data : Implémentations des repositories (Hive, Firestore)
├── domain/                 # Couche Domaine : Modèles de données (Lecon, Quiz, Practice) avec Freezed
├── features/               # Fonctionnalités cloisonnées (Auth, Courses, Quizzes, Simulation, Dashboard...)
│   ├── [feature]/
│   │   ├── controllers/    # Logique métier et états Riverpod
│   │   ├── widgets/        # Composants UI spécifiques
│   │   └── screens/        # Écrans principaux associés
├── presentation/           # Composants UI globaux (ex: OfflineBanner)
├── providers/              # Injection de dépendance Data -> Business via Riverpod
└── main.dart               # Point d'entrée, initialisation (Hive, GoRouter, Firebase)
```

## 🗺️ Roadmap
- Intégration de paiements locaux via mobile money (Orange Money, Moov, Carte BF).
- Mode **Instructeur** dédié pour suivre les élèves assignés.
- Simulation 3D avancée avec des scénarios interactifs plus nombreux.
