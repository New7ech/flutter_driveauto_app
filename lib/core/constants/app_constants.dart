// DriveAuto - app_constants.dart
// Role: Constantes globales (couleurs, routes, cles)
// Auteur : DriveAuto Team

import 'package:flutter/material.dart';

class AppConstants {
  // Cles d'environnement
  static const String envFirebaseProjectId = 'FIREBASE_PROJECT_ID';

  // Couleurs (Design System - Drapeau BF)
  static const Color primaryColor = Color(0xFF00A86B);
  static const Color secondaryColor = Color(0xFFEF0107);
  static const Color yellowBF = Color(0xFFFCD116);

  static const Color backgroundColorLight = Color(0xFFF8F9FA);
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color cardColorLight = Colors.white;
  static const Color cardColorDark = Color(0xFF1E1E1E);

  // Noms de routes
  static const String routeAuthLoading = '/auth-loading';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeDashboard = '/dashboard';
  static const String routeCourses = '/courses';
  static const String routeCourseDetail = 'detail';
  static const String routeQuiz = '/quiz';
  static const String routeQuizResults = 'results';
  static const String routePractice = '/practice';
  static const String routeSimulation = '/simulation';
  static const String routeAdmin = '/admin';

  // Nouvelles routes — Series / Slides / Examen
  static const String routeSeries = '/series';
  static const String routeExamen = '/examen';
  static const String routeExamenResultats = '/examen/resultats';

  // Noms de boites Hive (cache)
  static const String hiveLeconsBox = 'lecons_box';
  static const String hiveQuizzesBox = 'quizzes_box';
  static const String hiveAuthUsersBox = 'auth_users_box';
  static const String hiveAuthSessionBox = 'auth_session_box';
  static const String hiveSeriesBox = 'series_box'; // Séries admin
}
