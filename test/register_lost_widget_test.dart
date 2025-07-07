import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found_app/main.dart';

void main() {
  testWidgets('Register Lost Item button and form appear', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LostAndFoundApp());

    // Check for the button on the Home screen
    expect(find.text('Register Lost Item'), findsOneWidget);

    // Tap the button
    await tester.tap(find.text('Register Lost Item'));
    await tester.pumpAndSettle();

    // Check for the registration form fields
    expect(find.text('Register Lost Item'), findsWidgets); // AppBar and Button
    expect(find.text('Name of Item'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Identity Number (if applicable)'), findsOneWidget);
    expect(find.text('Location (where lost)'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });
}
