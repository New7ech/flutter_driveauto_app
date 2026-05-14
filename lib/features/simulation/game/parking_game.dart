/// DriveAuto — parking_game.dart
/// Rôle : La boucle de jeu Flame
/// Auteur : DriveAuto Team
library;

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'components/car_player.dart';
import 'components/parking_spot.dart';

class ParkingGame extends FlameGame {
  late JoystickComponent joystick;
  late CarPlayer car;
  late ParkingSpot parkingSpot;

  // Callback pour communiquer avec le Widget Flutter
  final VoidCallback onGameWon;

  ParkingGame({required this.onGameWon});

  @override
  Color backgroundColor() => const Color(0xFF3b3b3b); // Couleur asphalte

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Décoration basique de la route
    add(
      RectangleComponent(
        position: Vector2(size.x / 2, size.y / 2),
        size: Vector2(size.x - 40, size.y - 40),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF2e2e2e),
      ),
    );

    // 2. Création du Joystick (en bas à gauche)
    final knobPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 25, paint: knobPaint),
      background: CircleComponent(radius: 60, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 30, bottom: 40),
    );

    // Le joystick est fixe sur l'écran
    add(joystick);

    // 3. Création de la place de parking
    // On la place en haut à droite avec une petite rotation
    parkingSpot = ParkingSpot(
      position: Vector2(size.x * 0.7, size.y * 0.2),
      size: Vector2(50, 90),
      onParked: () {
        // Appelé quand le joueur réussit
        onGameWon();
      },
    );
    parkingSpot.angle = 0.5; // Légèrement en biais
    add(parkingSpot);

    // 4. Création de notre voiture
    car = CarPlayer(joystick: joystick)
      ..position =
          Vector2(size.x * 0.3, size.y * 0.8) // Départ en bas
      ..angle = -0.5;
    add(car);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // On limite la voiture pour qu'elle ne sorte pas de l'écran (basique)
    car.position.clamp(Vector2(0, 0), size);

    // On vérifie constamment si on est garé
    parkingSpot.checkParking(car);
  }
}
