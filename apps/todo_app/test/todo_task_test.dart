import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/src/features/todos/domain/todo_task.dart';

void main() {
  group('TodoTask', () {
    test('dueDateTime combines due date and time correctly', () {
      final task = TodoTask(
        id: '1',
        title: 'Test',
        description: '',
        dueDate: DateTime(2026, 3, 27),
        dueTime: '14:30:00',
        assignedUserId: 'u1',
        status: TodoStatus.pending,
        createdAt: DateTime(2026, 3, 27),
      );

      expect(task.dueDateTime.hour, 14);
      expect(task.dueDateTime.minute, 30);
    });

    test('isToday returns true for today date', () {
      final now = DateTime.now();
      final task = TodoTask(
        id: '2',
        title: 'Today',
        description: '',
        dueDate: DateTime(now.year, now.month, now.day),
        dueTime: '09:00:00',
        assignedUserId: 'u1',
        status: TodoStatus.pending,
        createdAt: now,
      );

      expect(task.isToday, isTrue);
    });

    test('isTomorrow returns true for tomorrow date', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final task = TodoTask(
        id: '3',
        title: 'Tomorrow',
        description: '',
        dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        dueTime: '09:00:00',
        assignedUserId: 'u1',
        status: TodoStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(task.isTomorrow, isTrue);
    });
  });
}
