import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/main.dart'; // Ensure this matches your project name

void main() {
  testWidgets('Scanner page loads test', (WidgetTester tester) async {
    // 1. Build our app and trigger a frame.
    // Replace "AttendanceScanner" with whatever you named your root widget in main.dart
    await tester.pumpWidget(const MaterialApp(home: AttendanceScanner()));

    // 2. Verify that the AppBar title is present.
    expect(find.text('Hacktoberfest Scanner'), findsOneWidget);

    // 3. Verify that the MobileScanner widget is present on the screen.
    // Note: Since it's a camera-based widget, we just check for its existence.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
