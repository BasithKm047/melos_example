import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TodoDayFilter { today, tomorrow }

final todoDayFilterProvider = StateProvider<TodoDayFilter>((ref) => TodoDayFilter.today);
