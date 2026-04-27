/// DriveAuto — offline_banner.dart
/// Rôle : Bandeau visuel avertissant l'utilisateur du mode hors-ligne
/// Auteur : DriveAuto Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../providers/connectivity_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    return connectivityState.when(
      data: (results) {
        // results est un List<ConnectivityResult> avec les dernières versions
        final isOffline =
            results.contains(ConnectivityResult.none) || results.isEmpty;

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: isOffline ? 0 : -50,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent, // Sera sur la stack
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 40,
                color: Colors.redAccent,
                alignment: Alignment.center,
                child: const Text(
                  'Mode hors-ligne actif. Synchronisation en attente.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
