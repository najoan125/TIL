import 'package:flutter_test/flutter_test.dart';
import 'package:dice/dice_3d.dart';
import 'package:dice/main.dart';

void main() {
  testWidgets('Dice App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DiceApp());

    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('Dicee 3D'), findsOneWidget);

    // Verify that the "ROLL" button is present
    expect(find.text('ROLL'), findsOneWidget);

    // Verify that two Dice3D widgets are present
    expect(find.byType(Dice3D), findsNWidgets(2));
  });
}
