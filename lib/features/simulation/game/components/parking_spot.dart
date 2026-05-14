/// DriveAuto — parking_spot.dart
/// Rôle : La zone cible de stationnement
library;

import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'car_player.dart';

class ParkingSpot extends PositionComponent {
  final Paint _paintNormal = Paint()
    ..color = Colors.white.withValues(alpha: 0.4)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  final Paint _paintSuccess = Paint()
    ..color = Colors.green.withValues(alpha: 0.6)
    ..style = PaintingStyle.fill;

  bool isOccupied = false;
  final Function() onParked; // Callback quand le joueur réussit

  ParkingSpot({
    required Vector2 position,
    required Vector2 size,
    required this.onParked,
  }) : super(position: position, size: size) {
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = size.toRect();

    // On dessine le marquage au sol
    if (isOccupied) {
      canvas.drawRect(rect, _paintSuccess);
    } else {
      // De simples lignes blanches pour représenter la place
      canvas.drawRect(rect, _paintNormal);

      // Petit test "P" au centre
      final TextPainter textPainter = TextPainter(
        text: const TextSpan(
          text: 'P',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.x - textPainter.width) / 2,
          (size.y - textPainter.height) / 2,
        ),
      );
    }
  }

  // Vérifie si la voiture est bien alignée et arrêtée sur la place
  void checkParking(CarPlayer car) {
    if (isOccupied) return; // Déjà réussi

    // Calcule la distance entre les centres
    final distance = position.distanceTo(car.position);

    // Le joueur est considéré "garé" s'il est proche du centre et s'il est presque à l'arrêt
    // et s'il est à peu près droit (angle). Dans une vraie simu, c'est plus exigeant !
    if (distance < 20.0) {
      isOccupied = true;
      onParked(); // On notifie le jeu (qui va déclencher l'UI Flutter)
    }
  }
}
