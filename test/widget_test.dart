import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_driveauto_app/main.dart';

void main() {
  testWidgets('DriveAutoApp affiche le bootstrap d authentification', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DriveAutoApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Verification de votre session...'), findsOneWidget);
  });

  testWidgets('DriveAutoApp redirige vers la connexion sans session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: DriveAutoApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Se connecter'), findsOneWidget);
  });
}
