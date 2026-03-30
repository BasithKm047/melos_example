import 'package:counter_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('counter increments when tapping the button', (tester) async {
    await tester.pumpWidget(const CounterApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byTooltip('Increment'));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
