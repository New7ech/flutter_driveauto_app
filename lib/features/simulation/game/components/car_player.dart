/// DriveAuto — car_player.dart
/// Rôle : Le véhicule contrôlable par le joueur (Simulation Flame)
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class CarPlayer extends PositionComponent {
  final JoystickComponent joystick;

  // Paramètres physiques basiques
  double maxSpeed = 150.0;
  double acceleration = 200.0;
  double _currentSpeed = 0.0;

  // On crée un paint pour dessiner la voiture (Vue de haut)
  late Paint _carPaint;
  late Paint _windowPaint;
  late Paint _lightsPaint;

  CarPlayer({required this.joystick}) : super(size: Vector2(30, 60)) {
    anchor = Anchor.center;
    _carPaint = Paint()..color = Colors.blue.shade700;
    _windowPaint = Paint()..color = Colors.lightBlueAccent.withOpacity(0.8);
    _lightsPaint = Paint()..color = Colors.yellow;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (joystick.direction != JoystickDirection.idle) {
      // Accélération classique
      _currentSpeed += acceleration * dt;
      if (_currentSpeed > maxSpeed) {
        _currentSpeed = maxSpeed;
      }

      // On tourne la voiture
      // La direction du joystick est lue (radians). Mais l'orientation d'une voiture dépend de son axe.
      // Pour une simulation d'arcade simple, la voiture regarde directement où pointe le joystick.
      angle = joystick.relativeDelta.screenAngle();

      // On avance dans la direction
      position.add(joystick.relativeDelta * _currentSpeed * dt);
    } else {
      // Décélération progressive (frein moteur)
      _currentSpeed -= acceleration * dt * 2;
      if (_currentSpeed < 0) _currentSpeed = 0;

      // On continue un peu sur l'élan dans l'angle actuel
      if (_currentSpeed > 0) {
        position.x += sin(angle) * _currentSpeed * dt;
        position.y +=
            -cos(angle) *
            _currentSpeed *
            dt; // Le -cos() car repère orienté vers le bas
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final r = size.toRect();

    // Le corps de la voiture
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(5)),
      _carPaint,
    );

    // Pare-brise avant
    final frontWindow = Rect.fromLTWH(5, 12, size.x - 10, 10);
    canvas.drawRect(frontWindow, _windowPaint);

    // Pare-brise arrière
    final backWindow = Rect.fromLTWH(5, size.y - 18, size.x - 10, 8);
    canvas.drawRect(backWindow, _windowPaint);

    // Phares avant (vu de haut)
    canvas.drawCircle(const Offset(6, 4), 3, _lightsPaint);
    canvas.drawCircle(Offset(size.x - 6, 4), 3, _lightsPaint);

    // Feux stop (arrière en rouge)
    final stopLightsPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(6, size.y - 4), 3, stopLightsPaint);
    canvas.drawCircle(Offset(size.x - 6, size.y - 4), 3, stopLightsPaint);
  }
}
