// This is a basic Flutter widget test for the Routine Tracker application.
// It verifies that the main components of our dashboard load successfully.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ictak/main.dart';

void main() {
  testWidgets('Routine Tracker dashboard smoke test', (WidgetTester tester) async {
    // 1. Setup mock initial values for SharedPreferences to prevent testing blocks
    SharedPreferences.setMockInitialValues({});

    // 2. Build our app and trigger a frame.
    await tester.pumpWidget(const RoutineTrackerApp());

    // 3. Pump twice to let the async FutureBuilder load and rebuild the LoginScreen
    await tester.pump();
    await tester.pump();

    // Verify that our main login header "Today's Track" is present.
    expect(find.text("Today's Track"), findsOneWidget);

    // Verify that the login submit button "Get Started" exists.
    expect(find.text('Get Started'), findsOneWidget);
  });
}
