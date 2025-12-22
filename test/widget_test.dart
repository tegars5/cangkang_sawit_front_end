// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cangkang_sawit_mobile/main.dart';

void main() {
  testWidgets('App loads login screen when no token exists', (
    WidgetTester tester,
  ) async {
    // Setup mock SharedPreferences with no token
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(prefs: prefs));

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that login screen is shown
    expect(find.text('Cangkang Sawit'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
