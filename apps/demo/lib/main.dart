import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = LocalOrderNotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(DemoApp(notificationService: notificationService));
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key, required this.notificationService});

  final OrderNotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: OrderTrackingPage(notificationService: notificationService),
    );
  }
}

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({
    super.key,
    required this.notificationService,
    this.stageDuration = const Duration(seconds: 3),
  });

  final OrderNotificationService notificationService;
  final Duration stageDuration;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  static const List<PhoneProduct> _phones = <PhoneProduct>[
    PhoneProduct(
      id: 'phone_1',
      name: 'iPhone 15 Pro',
      priceLabel: '\$1,099',
      details: 'A17 Pro chip, titanium body, 256 GB',
    ),
    PhoneProduct(
      id: 'phone_2',
      name: 'Samsung Galaxy S24 Ultra',
      priceLabel: '\$1,299',
      details: 'Snapdragon 8 Gen 3, 200 MP camera, 256 GB',
    ),
    PhoneProduct(
      id: 'phone_3',
      name: 'Google Pixel 9 Pro',
      priceLabel: '\$999',
      details: 'Tensor chip, 50 MP camera, 128 GB',
    ),
  ];

  static const List<OrderStage> _stages = <OrderStage>[
    OrderStage(progress: 0, label: 'Order placed'),
    OrderStage(progress: 25, label: 'Payment confirmed'),
    OrderStage(progress: 50, label: 'Packed'),
    OrderStage(progress: 75, label: 'Out for delivery'),
    OrderStage(progress: 100, label: 'Delivered'),
  ];

  ActiveOrder? _activeOrder;
  Timer? _stageTimer;
  int _nextOrderId = 1001;

  @override
  void initState() {
    super.initState();
    unawaited(widget.notificationService.initialize());
    unawaited(widget.notificationService.requestPermissions());
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    widget.notificationService.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(PhoneProduct phone) async {
    _stageTimer?.cancel();

    final activeOrder = ActiveOrder(
      orderId: _nextOrderId,
      phone: phone,
      stageIndex: 0,
    );

    setState(() {
      _activeOrder = activeOrder;
      _nextOrderId++;
    });

    await _publishProgress(ongoing: true);

    _stageTimer = Timer.periodic(widget.stageDuration, (_) {
      unawaited(_advanceOrderProgress());
    });
  }

  Future<void> _advanceOrderProgress() async {
    final activeOrder = _activeOrder;
    if (activeOrder == null) {
      return;
    }

    final nextStageIndex = activeOrder.stageIndex + 1;
    if (nextStageIndex >= _stages.length) {
      _stageTimer?.cancel();
      return;
    }

    final updatedOrder = activeOrder.copyWith(stageIndex: nextStageIndex);
    final completed = nextStageIndex == _stages.length - 1;

    setState(() {
      _activeOrder = updatedOrder;
    });

    await _publishProgress(ongoing: !completed);

    if (completed) {
      _stageTimer?.cancel();
    }
  }

  Future<void> _publishProgress({required bool ongoing}) async {
    final activeOrder = _activeOrder;
    if (activeOrder == null) {
      return;
    }

    final stage = _stages[activeOrder.stageIndex];
    final update = OrderProgressUpdate(
      orderId: activeOrder.orderId,
      productName: activeOrder.phone.name,
      progress: stage.progress,
      statusLabel: stage.label,
    );

    await widget.notificationService.showOrderProgress(
      update,
      ongoing: ongoing,
    );
  }

  Widget _buildOrderCard(ActiveOrder order) {
    final stage = _stages[order.stageIndex];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Order #${order.orderId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(order.phone.name),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: stage.progress / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 12),
            Text(
              'Status: ${stage.label}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('Progress: ${stage.progress}%'),
            const SizedBox(height: 8),
            const Text(
              'Android shows lock-screen progress notifications. iOS updates a Live Activity on the lock screen.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneCard(PhoneProduct phone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              phone.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(phone.details),
            const SizedBox(height: 8),
            Text(
              phone.priceLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              key: ValueKey<String>('order_button_${phone.id}'),
              label: 'Order Now',
              onPressed: () {
                unawaited(_placeOrder(phone));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOrder = _activeOrder;

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Order Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Pick a Phone to Order',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "Order Now" to place an order and receive progress notifications.',
          ),
          const SizedBox(height: 16),
          if (activeOrder != null) _buildOrderCard(activeOrder),
          ..._phones.map(_buildPhoneCard),
        ],
      ),
    );
  }
}

class PhoneProduct {
  const PhoneProduct({
    required this.id,
    required this.name,
    required this.priceLabel,
    required this.details,
  });

  final String id;
  final String name;
  final String priceLabel;
  final String details;
}

class OrderStage {
  const OrderStage({required this.progress, required this.label});

  final int progress;
  final String label;
}

class ActiveOrder {
  const ActiveOrder({
    required this.orderId,
    required this.phone,
    required this.stageIndex,
  });

  final int orderId;
  final PhoneProduct phone;
  final int stageIndex;

  ActiveOrder copyWith({int? stageIndex}) {
    return ActiveOrder(
      orderId: orderId,
      phone: phone,
      stageIndex: stageIndex ?? this.stageIndex,
    );
  }
}

class OrderProgressUpdate {
  const OrderProgressUpdate({
    required this.orderId,
    required this.productName,
    required this.progress,
    required this.statusLabel,
  });

  final int orderId;
  final String productName;
  final int progress;
  final String statusLabel;
}

abstract class OrderNotificationService {
  Future<void> initialize();
  Future<void> requestPermissions();
  Future<void> showOrderProgress(
    OrderProgressUpdate update, {
    required bool ongoing,
  });
  void dispose();
}

class LocalOrderNotificationService implements OrderNotificationService {
  static const String _channelId = 'order_tracking_channel';
  static const String _channelName = 'Order Tracking';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final IosLiveActivityClient _iosLiveActivityClient = IosLiveActivityClient();
  final AndroidLiveActivityClient _androidLiveActivityClient =
      AndroidLiveActivityClient();

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(initializationSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Tracks order delivery progress',
        importance: Importance.high,
      ),
    );

    _isInitialized = true;
  }

  @override
  Future<void> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> showOrderProgress(
    OrderProgressUpdate update, {
    required bool ongoing,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (isIos) {
      final liveActivitySynced = await _iosLiveActivityClient.sync(
        update,
        ongoing: ongoing,
      );
      if (liveActivitySynced) {
        return;
      }
    }

    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (isAndroid) {
      final liveActivitySynced = await _androidLiveActivityClient.sync(
        update,
        ongoing: ongoing,
      );
      if (liveActivitySynced) {
        return;
      }
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Order progress visible on lock screen',
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      showProgress: true,
      maxProgress: 100,
      progress: update.progress,
      ongoing: ongoing,
      onlyAlertOnce: true,
      category: AndroidNotificationCategory.progress,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      update.orderId,
      'Order #${update.orderId}: ${update.productName}',
      '${update.statusLabel} (${update.progress}%)',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'order_${update.orderId}',
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await _iosLiveActivityClient.sync(update, ongoing: ongoing);
    }
  }

  @override
  void dispose() {}
}

class IosLiveActivityClient {
  static const MethodChannel _channel = MethodChannel('order_live_activity');
  final Set<int> _startedOrders = <int>{};

  Future<bool> sync(OrderProgressUpdate update, {required bool ongoing}) async {
    final arguments = <String, Object>{
      'orderId': update.orderId,
      'productName': update.productName,
      'statusLabel': update.statusLabel,
      'progress': update.progress,
    };

    try {
      if (!_startedOrders.contains(update.orderId)) {
        await _channel.invokeMethod<String>('startLiveActivity', arguments);
        _startedOrders.add(update.orderId);
        if (!ongoing) {
          await _channel.invokeMethod<void>('endLiveActivity', arguments);
          _startedOrders.remove(update.orderId);
        }
        return true;
      }

      if (ongoing) {
        await _channel.invokeMethod<void>('updateLiveActivity', arguments);
      } else {
        await _channel.invokeMethod<void>('endLiveActivity', arguments);
        _startedOrders.remove(update.orderId);
      }
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // Keep notification delivery working even if Live Activities are unavailable.
      return false;
    }
  }
}

class AndroidLiveActivityClient {
  static const MethodChannel _channel = MethodChannel(
    'order_android_live_activity',
  );
  final Set<int> _startedOrders = <int>{};

  Future<bool> sync(OrderProgressUpdate update, {required bool ongoing}) async {
    final arguments = <String, Object>{
      'orderId': update.orderId,
      'productName': update.productName,
      'statusLabel': update.statusLabel,
      'progress': update.progress,
    };

    try {
      if (!_startedOrders.contains(update.orderId)) {
        final started =
            await _channel.invokeMethod<bool>('startLiveActivity', arguments) ??
            false;
        if (!started) {
          return false;
        }
        _startedOrders.add(update.orderId);
        if (!ongoing) {
          await _channel.invokeMethod<bool>('endLiveActivity', arguments);
          _startedOrders.remove(update.orderId);
        }
        return true;
      }

      if (ongoing) {
        final updated =
            await _channel.invokeMethod<bool>('updateLiveActivity', arguments) ??
            false;
        return updated;
      }

      await _channel.invokeMethod<bool>('endLiveActivity', arguments);
      _startedOrders.remove(update.orderId);
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
