import 'todo_task.dart';

abstract interface class TodoRepository {
  Stream<List<TodoTask>> watchTodos();

  Future<TodoTask> addTodo({
    required String title,
    required String description,
    required DateTime dueDate,
    required String dueTime,
    required String assignedUserId,
  });

  Future<void> updateStatus({required String todoId, required TodoStatus status});
}
