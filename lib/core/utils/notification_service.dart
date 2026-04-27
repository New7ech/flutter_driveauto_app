// DriveAuto - notification_service.dart
// Role: Gestion des notifications Push foreground/background avec Firebase Messaging
// Auteur : DriveAuto Team

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Cle globale pour afficher des SnackBars ou naviguer sans BuildContext local.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundMessage);
  }

  Future<void> requestPermission() async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    await _fcm.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> subscribeToTopic(String topic) async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    await _fcm.subscribeToTopic(topic);
  }

  void handleForegroundMessage(RemoteMessage msg) {
    if (msg.notification == null) {
      return;
    }

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${msg.notification!.title} : ${msg.notification!.body}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void handleBackgroundMessage(RemoteMessage msg) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final route = msg.data['route'];
    if (route is String && route.isNotEmpty) {
      context.go(route);
      return;
    }

    context.go('/dashboard');
  }
}
