import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../data/todo_repository_impl.dart';
import '../../domain/todo_repository.dart';
import '../../domain/todo_task.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return HiveTodoRepository.fromHive();
});

final todoListProvider = StreamProvider<List<TodoTask>>((ref) {
  return ref.watch(todoRepositoryProvider).watchTodos();
});

final todoActionControllerProvider = StateNotifierProvider<TodoActionController, AsyncValue<void>>((ref) {
  return TodoActionController(ref.watch(todoRepositoryProvider));
});

class TodoActionController extends StateNotifier<AsyncValue<void>> {
  TodoActionController(this._repository) : super(const AsyncData(null));

  final TodoRepository _repository;

  Future<void> addTodo({
    required String title,
    required String description,
    required DateTime dueDate,
    required String dueTime,
    required String assignedUserId,
  }) async {
    if (!_isTodayOrTomorrow(dueDate)) {
      state = AsyncValue.error(
        ArgumentError('Only today or tomorrow tasks are allowed'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final task = await _repository.addTodo(
        title: title,
        description: description,
        dueDate: dueDate,
        dueTime: dueTime,
        assignedUserId: assignedUserId,
      );
      await NotificationService.instance.schedule(
        id: task.id.hashCode,
        title: 'Todo Reminder',
        body: task.title,
        dateTime: task.dueDateTime,
      );
      await NotificationService.instance.showInstant(
        id: task.title.hashCode,
        title: 'Task Scheduled',
        body: '${task.title} added successfully',
      );
    });
  }

  Future<void> toggleStatus(TodoTask task) async {
    state = const AsyncLoading();
    final nextStatus = task.status == TodoStatus.pending ? TodoStatus.done : TodoStatus.pending;
    state = await AsyncValue.guard(
      () => _repository.updateStatus(todoId: task.id, status: nextStatus),
    );
  }

  bool _isTodayOrTomorrow(DateTime date) {
    final stripped = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final todayStripped = DateTime(today.year, today.month, today.day);
    final tomorrow = todayStripped.add(const Duration(days: 1));
    return stripped == todayStripped || stripped == tomorrow;
  }
}
