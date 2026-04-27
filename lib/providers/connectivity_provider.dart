/// DriveAuto — connectivity_provider.dart
/// Rôle : Fournir l'état de la connexion réseau (Offline/Online)
/// Auteur : DriveAuto Team
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});
