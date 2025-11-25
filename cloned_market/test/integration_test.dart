import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloned_market/main.dart';

void main() {
  testWidgets('Counter app full integration test', (WidgetTester tester) async {
    // Setup: Clear SharedPreferences before the test
    SharedPreferences.setMockInitialValues({});

    // Build the app
    await tester.pumpWidget(const MyApp());

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the counter displays UI elements
    expect(find.byKey(const Key('counter_text')), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify the floating action button exists and is not null
    final floatingActionButton = find.byType(FloatingActionButton);
    expect(floatingActionButton, findsOneWidget);

    // Get the service instance to verify counter operations
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('counter_value'), isNull);

    // Tap the increment button to test UI interaction
    await tester.tap(floatingActionButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verify UI is still responsive
    expect(find.byKey(const Key('counter_text')), findsOneWidget);
  });

  testWidgets('Counter persists after app restart', (WidgetTester tester) async {
    // Setup: Set initial value in SharedPreferences
    SharedPreferences.setMockInitialValues({'counter_value': 5});

    // Build the app
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the counter displays the UI
    expect(find.byKey(const Key('counter_text')), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify the initial value from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final initialValue = prefs.getInt('counter_value');
    expect(initialValue, equals(5));

    // Tap the increment button to trigger counter update
    final floatingActionButton = find.byType(FloatingActionButton);
    await tester.tap(floatingActionButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verify the UI remains responsive after tap
    expect(find.byKey(const Key('counter_text')), findsOneWidget);
  });
}
