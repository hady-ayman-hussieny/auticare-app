// This is a basic Flutter widget test for AutiCare.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:auticare/main.dart';

void main() {
  testWidgets('App starts and shows Login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AutiCareApp());
    await tester.pumpAndSettle();

    // Verify that the Login screen is displayed by finding the "Sign In" text.
    expect(find.text('Sign In'), findsAtLeast(1));
  });
}
