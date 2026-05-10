import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Use FitTrackApp instead of MyApp as it is the correct root widget name.
    await tester.pumpWidget(const FitTrackApp());

    // Verify that our app starts at the landing page (AuthWrapper).
    expect(find.text('WorkoutPlanner.'), findsOneWidget);
    expect(find.text('ENTER STUDIO'), findsOneWidget);
  });
}
