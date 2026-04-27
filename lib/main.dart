// DriveAuto - main.dart
// Role: Point d'entree de l'application, initialisation des services et configuration du routeur.
// Auteur : DriveAuto Team

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/notification_service.dart';
import 'core/utils/sync_manager.dart';
import 'domain/models/lecon.dart';
import 'domain/models/practice.dart';
import 'domain/models/quiz.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/auth_loading_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/courses/screens/course_detail_screen.dart';
import 'features/courses/screens/courses_list_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/practice/screens/checklist_screen.dart';
import 'features/practice/screens/practice_list_screen.dart';
import 'features/quizzes/screens/quiz_active_screen.dart';
import 'features/quizzes/screens/quiz_results_screen.dart';
import 'features/quizzes/screens/quizzes_list_screen.dart';
import 'features/admin/screens/admin_home_screen.dart';
import 'features/cours/screens/series_list_screen.dart';
import 'features/cours/screens/slide_viewer_screen.dart';
import 'features/examen/screens/examen_resultats_screen.dart';
import 'features/examen/screens/examen_screen.dart';
import 'features/simulation/screens/simulation_screen.dart';
import 'presentation/widgets/offline_banner.dart';
import 'providers/serie_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/repository_providers.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Message recu en arriere-plan : ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Fichier .env introuvable ou erreur de lecture: $e');
  }

  await Hive.initFlutter();
  await Hive.openBox(AppConstants.hiveLeconsBox);
  await Hive.openBox(AppConstants.hiveQuizzesBox);
  await Hive.openBox(AppConstants.hiveAuthUsersBox);
  await Hive.openBox(AppConstants.hiveAuthSessionBox);
  await Hive.openBox(AppConstants.hiveSeriesBox);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erreur lors de l initialisation de Firebase: $e');
  }

  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await NotificationService().initialize();
    await NotificationService().requestPermission();
  } catch (e) {
    debugPrint('Erreur lors de l initialisation des notifications: $e');
  }

  runApp(const ProviderScope(child: DriveAutoApp()));
}

class DriveAutoApp extends ConsumerWidget {
  const DriveAutoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(connectivityProvider, (previous, next) {
      if (!next.hasValue) {
        return;
      }

      final results = next.value!;
      final isOffline =
          results.contains(ConnectivityResult.none) || results.isEmpty;

      final prevResults = previous?.value ?? <ConnectivityResult>[];
      final wasOffline =
          prevResults.contains(ConnectivityResult.none) || prevResults.isEmpty;

      if (!isOffline && wasOffline) {
        final firestore = ref.read(firebaseFirestoreProvider);
        if (firestore != null) {
          SyncManager(firestore).syncAll();
        }
      }
    });

    return MaterialApp.router(
      title: 'DriveAuto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              ...?(child == null ? null : <Widget>[child]),
              const OfflineBanner(),
            ],
          ),
        );
      },
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentAuthUserProvider);
  final landingRoute = ref.watch(authLandingRouteProvider);

  const publicRoutes = <String>{
    AppConstants.routeAuthLoading,
    AppConstants.routeLogin,
    AppConstants.routeRegister,
    AppConstants.routeForgotPassword,
  };

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppConstants.routeAuthLoading,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isPublicRoute = publicRoutes.contains(location);
      final isLoadingRoute = location == AppConstants.routeAuthLoading;
      final isAuthenticated = currentUser != null;
      final authenticatedUser = currentUser;
      final isAdminRoute = location == AppConstants.routeAdmin;

      if (authState.isLoading) {
        return isLoadingRoute ? null : AppConstants.routeAuthLoading;
      }

      // Auth résolue : quitter l'écran de chargement dans tous les cas.
      if (isLoadingRoute) {
        return isAuthenticated ? landingRoute : AppConstants.routeLogin;
      }

      if (!isAuthenticated) {
        return isPublicRoute ? null : AppConstants.routeLogin;
      }

      if (isPublicRoute) {
        return landingRoute;
      }

      if (isAdminRoute &&
          authenticatedUser != null &&
          authenticatedUser.role != 'admin') {
        return AppConstants.routeDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeAuthLoading,
        builder: (context, state) => const AuthLoadingScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCourses,
        builder: (context, state) => const CoursesListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'courseDetail',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? 'inconnu';
              final extra = state.extra;
              if (extra is Lecon) {
                return CourseDetailScreen(leconId: id, leconData: extra);
              }
              return CourseDetailScreen(leconId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeQuiz,
        builder: (context, state) => const QuizzesListScreen(),
        routes: [
          GoRoute(
            path: 'results',
            name: 'quizResults',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              return QuizResultsScreen(
                quiz: args?['quiz'],
                score: args?['score'] ?? 0.0,
                userAnswers: args?['userAnswers'] ?? [],
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'quizDetail',
            builder: (context, state) {
              final extra = state.extra;
              if (extra is Quiz) {
                return QuizActiveScreen(quiz: extra);
              }
              return const Scaffold(
                body: Center(child: Text('Erreur: Quiz non trouve')),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routePractice,
        builder: (context, state) => const PracticeListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'checklistScreen',
            builder: (context, state) {
              final session = state.extra;
              if (session is PracticeSession) {
                return ChecklistScreen(session: session);
              }
              return const Scaffold(
                body: Center(child: Text('Erreur: Session introuvable')),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeSimulation,
        builder: (context, state) => const SimulationScreen(),
      ),
      // ── Nouvelles routes : Séries de cours + Examen ──────────────
      GoRoute(
        path: AppConstants.routeSeries,
        builder: (context, state) => const SeriesListScreen(),
        routes: [
          GoRoute(
            path: ':serieId',
            name: 'slideViewer',
            builder: (context, state) {
              final id = state.pathParameters['serieId'] ?? '';
              return SlideViewerScreen(serieId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeExamen,
        builder: (context, state) => const ExamenScreen(),
        routes: [
          GoRoute(
            path: 'resultats',
            name: 'examenResultats',
            builder: (context, state) {
              final examenState = state.extra as ExamenState?;
              if (examenState == null) {
                return const Scaffold(
                  body: Center(child: Text('Erreur : résultats introuvables.')),
                );
              }
              return ExamenResultatsScreen(examenState: examenState);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.routeAdmin,
        builder: (context, state) => const AdminHomeScreen(),
      ),
    ],
  );
});
