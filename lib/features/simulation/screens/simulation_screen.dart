/// DriveAuto — simulation_screen.dart
/// Rôle : Interface Flutter qui intègre le jeu Flame (Parking 2D)
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../game/parking_game.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  late ParkingGame _game;
  bool _isWon = false;

  void _goBackToDashboard() {
    context.go(AppConstants.routeDashboard);
  }

  @override
  void initState() {
    super.initState();
    // On initialise notre monde Flame
    _game = ParkingGame(
      onGameWon: () {
        if (!_isWon) {
          setState(() {
            _isWon = true;
          });
          _showWinDialog();
        }
      },
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer en cliquant à côté
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 36),
              SizedBox(width: 8),
              Text('Parfaitement Garé !'),
            ],
          ),
          content: const Text(
            'Félicitations, vous avez réussi la manœuvre du créneau ! Votre véhicule est parfaitement positionné dans la zone cible sans déborder.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la modale
                _goBackToDashboard(); // Revenir au menu principal
              },
              child: const Text(
                'Quitter',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // On réinitialise et on redémarre
                setState(() {
                  _isWon = false;
                  _game = ParkingGame(
                    onGameWon: () {
                      if (!_isWon) {
                        setState(() {
                          _isWon = true;
                        });
                        _showWinDialog();
                      }
                    },
                  );
                });
              },
              child: const Text('Rejouer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBackToDashboard();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goBackToDashboard,
          ),
          title: const Text('Simulateur de Manœuvre'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Aide',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Utilisez le Joystick en bas à gauche pour vous garer dans la zone P !',
                    ),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: GameWidget(
            game: _game, // Le pont entre Flutter et Flame
            loadingBuilder: (context) =>
                const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
