import 'package:flutter_test/flutter_test.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('renders primary button label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Tap me',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Tap me'), findsOneWidget);
  });
}
