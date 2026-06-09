# CLAUDE.md — DriveAuto (Flutter)

**Projet :** DriveAuto — Auto-école mobile (Burkina Faso)
**Dépôt :** https://github.com/New7ech/flutter_driveauto_app
**Statut :** Offline-first + synchronisation Firebase
**SDK Dart requis :** `^3.11.4` (voir `pubspec.yaml` — *à confirmer*, cf. Notes de maintenance)

> Ce fichier est la source de vérité que Claude doit suivre pour générer du code sur ce
> projet. Il décrit la stack **réellement installée** (`pubspec.yaml`), pas une stack idéale.
> En cas de doute, le `pubspec.yaml` prime sur ce document.

---

## 🎯 Objectif du projet

Application complète pour l'apprentissage de la conduite :

- Leçons de code interactives (diapositives hébergées sur Cloudinary)
- Examens blancs / quiz
- Suivi de progression
- Simulation de conduite (moteur **Flame**)
- Mode offline (Hive) avec synchronisation Firestore
- Authentification, Analytics, Crashlytics, Push Notifications

---

## 🔧 Stack technique réelle (alignée sur `pubspec.yaml`)

### Cœur

| Domaine | Paquet | Version | Remarque |
|---|---|---|---|
| State management | `flutter_riverpod` | `^2.5.1` | **Riverpod 2.x** — voir avertissement ci-dessous |
| Navigation | `go_router` | `^14.2.0` | `ShellRoute` + guards d'auth |
| Modélisation | `freezed_annotation` + `json_annotation` | `any` | Immutabilité + (dé)sérialisation |
| Stockage local | `hive` `^2.2.3`, `hive_flutter` `^1.1.0` | | Offline-first |
| Détection réseau | `connectivity_plus` | `^7.1.1` | Pilote l'UX offline / la sync |

### Firebase (services **réellement** inclus)

| Service | Paquet | Version |
|---|---|---|
| Core | `firebase_core` | `^3.3.0` |
| Auth | `firebase_auth` `^5.3.0` + `google_sign_in` `^6.2.1` | |
| Firestore | `cloud_firestore` | `^5.2.1` |
| Messaging (FCM) | `firebase_messaging` | `^15.1.3` |
| Analytics | `firebase_analytics` | `^11.3.0` |
| Crashlytics | `firebase_crashlytics` | `^4.1.0` |

> ⚠️ **Pas de `firebase_storage`.** Les images/diapositives sont stockées sur **Cloudinary**
> (upload *unsigned preset*) et appelées via `http` + `cached_network_image`. Ne pas générer
> de code qui suppose Firebase Storage.

### Médias, UI & moteur

| Usage | Paquet | Version |
|---|---|---|
| Moteur de jeu / simulation | `flame` | `^1.18.0` |
| Animations | `lottie` | `^3.1.2` |
| Vidéo (leçons) | `youtube_player_flutter` | `^9.1.0` |
| Polices | `google_fonts` | `^6.2.1` |
| Sélection d'images | `image_picker` | `^1.1.2` |
| Cache images | `cached_network_image` `^3.4.1`, `flutter_cache_manager` `^3.4.1` | |
| Icônes | `cupertino_icons` | `^1.0.8` |

### Utilitaires

| Usage | Paquet | Version |
|---|---|---|
| Config / secrets | `flutter_dotenv` | `^5.1.0` |
| Requêtes HTTP (Cloudinary, etc.) | `http` | `^1.6.0` |
| Internationalisation / formats | `intl` | `^0.19.0` |

### Outils de développement

`flutter_lints`, `mockito`, `build_runner`, `freezed`, `json_serializable`, `hive_generator`.

---

## ⚠️ Avertissement Riverpod (important)

Le projet utilise **Riverpod 2.x** (`flutter_riverpod: ^2.5.1`) **sans génération de code**
(ni `riverpod_annotation`, ni `riverpod_generator` ne sont installés).

**Donc, pour tout provider, Claude doit :**

- écrire des providers **manuels** : `Provider`, `StateProvider`, `FutureProvider`,
  `StreamProvider`, `NotifierProvider`, `AsyncNotifierProvider`, `StateNotifierProvider` ;
- définir les classes `Notifier` / `AsyncNotifier` / `StateNotifier` **à la main** ;
- **ne PAS** utiliser l'annotation `@riverpod` ni la génération `*.g.dart` Riverpod
  (cela ne compilerait pas tel quel) ;
- gérer les états asynchrones avec `AsyncValue` (`when` / `guard`).

> Si une migration vers Riverpod 3.x **avec** codegen est souhaitée, voir Notes de maintenance.
> Tant que ce n'est pas fait, **Riverpod 2.x manuel** est la règle.

---

## ⚙️ Code generation (`build_runner`)

`build_runner` est nécessaire **uniquement** pour : **Freezed**, **json_serializable**,
**Hive (hive_generator)** et **Mockito** (mocks de tests).

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

À relancer après toute modification d'un modèle Freezed/JSON, d'un `TypeAdapter` Hive,
ou des annotations de mocks Mockito. **Pas** nécessaire pour les providers Riverpod
(écrits manuellement).

---

## 🏗️ Architecture (Clean Architecture + Feature-First)

> L'arborescence ci-dessous reflète l'organisation documentée dans le `README`. Le détail
> exact de `lib/` n'a pas pu être vérifié automatiquement (accès robots bloqué) : **confirmer
> que la structure réelle correspond** avant de l'imposer « strictement ».

```text
lib/
├── core/            # Thème, constantes, utils, extensions, validateurs
├── data/            # Implémentations des repositories (Hive local, Firestore remote), DTOs, mappers
├── domain/          # Entités Freezed (Lecon, Quiz, Practice...), use cases, repositories abstraits
├── features/        # Chaque fonctionnalité isolée (auth, courses, quizzes, simulation, dashboard...)
│   └── [feature]/
│       ├── controllers/   # Providers / Notifiers Riverpod (état + logique de présentation)
│       ├── screens/       # Écrans (pages)
│       └── widgets/       # Composants UI propres à la feature
├── presentation/    # Composants UI globaux (OfflineBanner, ErrorWidget, etc.)
├── providers/       # Injection de dépendances (Data -> Domain -> UI) via Riverpod
├── routing/         # Configuration GoRouter + guards
└── main.dart        # Point d'entrée : init Firebase, Hive, dotenv, GoRouter
```

**Règles obligatoires :**

- **Freezed** pour tous les modèles et états (immutabilité, `copyWith`, unions d'états).
- **Riverpod 2.x manuel** uniquement (pas de Provider package, Bloc, GetX, etc.).
- **GoRouter** pour la navigation, avec `ShellRoute` et guards d'authentification.
- Tout asynchrone passe par `AsyncValue` / `AsyncNotifier` / `FutureProvider`.
- Les repositories sont **abstraits dans `domain/`** et **implémentés dans `data/`**
  (une implémentation Hive locale, une implémentation Firestore distante).

---

## 🔐 Configuration & secrets (`.env`)

La config sensible est chargée via `flutter_dotenv` depuis un fichier `.env`
(déclaré dans les `assets` du `pubspec.yaml`).

```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=your-unsigned-upload-preset
CLOUDINARY_SLIDES_FOLDER=driveauto/slides
```

**Règles de sécurité :**

- **Ne jamais committer `.env`** (il doit être dans `.gitignore` ; fournir un `.env.example`).
- **Ne jamais mettre `CLOUDINARY_API_SECRET` dans l'app Flutter** — uniquement un
  *upload preset* unsigned, limité aux formats `jpg/jpeg/png/webp`.
- `google-services.json` va dans `android/app/` (et n'est pas versionné).

---

## 🧪 Tests

État réel : `flutter_test` + `mockito` (mocks générés via `build_runner`).

- **Unit / Widget** : toujours proposés pour la logique métier et les composants.
- Mocker les repositories via Mockito ; surcharger les providers Riverpod avec
  `ProviderContainer` / `overrides` dans les tests.
- **Tests d'intégration** : annoncés mais **le paquet `integration_test` n'est pas encore
  installé**. Pour les activer, l'ajouter en `dev_dependencies` (voir Notes de maintenance).

---

## 🧭 Style de code attendu

- Code lisible, commenté là où c'est utile (use cases et providers non triviaux).
- Nommage clair et cohérent : `leconControllerProvider`, `quizRepositoryProvider`, etc.
- Gestion **exhaustive** des erreurs et des états de chargement (jamais d'`AsyncValue`
  non géré dans l'UI).
- Performances : `const` constructors, `dispose` correct, `select` pour limiter les rebuilds.
- Material 3, design responsive, et UX offline soignée (bannière hors-ligne, états vides).

---

## 🚀 Tâches fréquentes (comment Claude doit répondre)

- **Nouvelle feature** → structure complète Feature-First : `controllers/`, `screens/`,
  `widgets/`, + repository abstrait (domain) et son implémentation (data), + provider d'injection.
- **Modification UI** → Material 3, respect du thème global, proposer des variantes responsive.
- **Ajout Firebase** → passer par les repositories abstraits + implémentations (jamais
  d'appel Firestore/Auth direct depuis l'UI).
- **Offline sync** → Hive (source locale) + Firestore (source distante) avec stratégie de
  résolution de conflits explicite ; s'appuyer sur `connectivity_plus`.
- **Images** → Cloudinary via `http` (upload) + `cached_network_image` (affichage/cache).
- **Simulation / jeu** → composants `flame` isolés dans la feature concernée.
- **Refactoring** → préserver la Clean Architecture.
- **Tests** → toujours proposer les tests unitaires/widgets correspondants.

---

## 🛠️ Commandes utiles

```bash
# Dépendances
flutter pub get

# Génération de code (Freezed, JSON, Hive, Mockito)
flutter pub run build_runner build --delete-conflicting-outputs

# Lancement
flutter run
flutter run --release

# Build APK Android (arm64)
flutter build apk --release --target-platform android-arm64

# Tests
flutter test

# (Recommandé) Synchroniser la config Firebase multi-plateformes
flutterfire configure
```

---

## 📝 Notes de maintenance (décisions à trancher par l'équipe)

1. **Contrainte SDK incohérente.** Le `pubspec.yaml` impose `sdk: ^3.11.4`, alors que le
   `README`/ancien CLAUDE.md mentionnaient « Dart ≥ 3.4 / Flutter ≥ 3.22 ». Aligner les deux :
   soit assouplir la contrainte du `pubspec`, soit mettre à jour la documentation. Tant que
   `^3.11.4` est en place, c'est **lui** qui fait foi.

2. **Riverpod : rester en 2.x manuel, ou migrer en 3.x + codegen ?** Aujourd'hui : 2.x sans
   codegen. Pour passer au style `@riverpod` (codegen), ajouter `riverpod_annotation` (deps),
   `riverpod_generator` + `custom_lint` + `riverpod_lint` (dev_deps), puis migrer les providers.
   Mettre à jour ce fichier en conséquence le cas échéant.

3. **Tests d'intégration.** Ajouter `integration_test` (SDK) en `dev_dependencies` si le suivi
   « Integration » du README doit être effectif.

4. **Firebase Storage.** Confirmé absent : ne pas le réintroduire sauf besoin explicite ; sinon
   retirer toute mention de « Storage » dans la documentation produit.
