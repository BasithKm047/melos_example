import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/notifications/notification_service.dart';
import 'core/storage/hive_boxes.dart';

Future<void> bootstrap() async {
  await Hive.initFlutter();
  await Hive.openBox<Map>(HiveBoxes.users);
  await Hive.openBox<Map>(HiveBoxes.todos);
  tz.initializeTimeZones();
  await NotificationService.instance.initialize();
}
