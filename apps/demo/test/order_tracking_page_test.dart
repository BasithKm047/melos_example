import 'package:demo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderTrackingPage', () {
    testWidgets('renders hardcoded phone catalog', (tester) async {
      final service = _FakeOrderNotificationService();

      await tester.pumpWidget(
        MaterialApp(
          home: OrderTrackingPage(
            notificationService: service,
            stageDuration: const Duration(milliseconds: 20),
          ),
        ),
      );

      expect(find.text('Pick a Phone to Order'), findsOneWidget);
      expect(find.text('iPhone 15 Pro'), findsOneWidget);
      expect(find.text('Samsung Galaxy S24 Ultra'), findsOneWidget);
      expect(find.text('Google Pixel 9 Pro'), findsOneWidget);
    });

    testWidgets('starts an order and sends initial progress notification', (
      tester,
    ) async {
      final service = _FakeOrderNotificationService();

      await tester.pumpWidget(
        MaterialApp(
          home: OrderTrackingPage(
            notificationService: service,
            stageDuration: const Duration(milliseconds: 20),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('order_button_phone_1')));
      await tester.pump();

      expect(find.text('Order #1001'), findsOneWidget);
      expect(find.text('Status: Order placed'), findsOneWidget);

      expect(service.calls.length, 1);
      expect(service.calls.first.update.progress, 0);
      expect(service.calls.first.update.statusLabel, 'Order placed');
      expect(service.calls.first.ongoing, true);
    });

    testWidgets('advances order progress to delivered', (tester) async {
      final service = _FakeOrderNotificationService();

      await tester.pumpWidget(
        MaterialApp(
          home: OrderTrackingPage(
            notificationService: service,
            stageDuration: const Duration(milliseconds: 20),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('order_button_phone_1')));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 90));

      expect(find.text('Status: Delivered'), findsOneWidget);
      expect(find.text('Progress: 100%'), findsOneWidget);

      expect(service.calls.last.update.progress, 100);
      expect(service.calls.last.update.statusLabel, 'Delivered');
      expect(service.calls.last.ongoing, false);
    });
  });
}

class _FakeOrderNotificationService implements OrderNotificationService {
  final List<_NotificationCall> calls = <_NotificationCall>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showOrderProgress(
    OrderProgressUpdate update, {
    required bool ongoing,
  }) async {
    calls.add(_NotificationCall(update: update, ongoing: ongoing));
  }

  @override
  void dispose() {}
}

class _NotificationCall {
  const _NotificationCall({required this.update, required this.ongoing});

  final OrderProgressUpdate update;
  final bool ongoing;
}
