// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:tubesmoneyair/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    // Verify app starts without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
