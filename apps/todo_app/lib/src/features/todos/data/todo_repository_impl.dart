import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_boxes.dart';
import '../domain/todo_repository.dart';
import '../domain/todo_task.dart';

class HiveTodoRepository implements TodoRepository {
  HiveTodoRepository(this._box);

  factory HiveTodoRepository.fromHive() {
    return HiveTodoRepository(Hive.box<Map>(HiveBoxes.todos));
  }

  final Box<Map> _box;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<TodoTask>> watchTodos() async* {
    yield _readTodos();
    yield* _box.watch().map((_) => _readTodos());
  }

  @override
  Future<TodoTask> addTodo({
    required String title,
    required String description,
    required DateTime dueDate,
    required String dueTime,
    required String assignedUserId,
  }) async {
    final task = TodoTask(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
      dueTime: dueTime,
      assignedUserId: assignedUserId,
      status: TodoStatus.pending,
      createdAt: DateTime.now(),
    );

    await _box.put(task.id, task.toMap());
    return task;
  }

  @override
  Future<void> updateStatus({required String todoId, required TodoStatus status}) async {
    final existing = _box.get(todoId);
    if (existing == null) {
      return;
    }

    final map = Map<String, dynamic>.from(existing);
    map['status'] = status == TodoStatus.done ? 'done' : 'pending';
    await _box.put(todoId, map);
  }

  List<TodoTask> _readTodos() {
    final todos = _box.values
        .map((row) => TodoTask.fromMap(Map<String, dynamic>.from(row)))
        .toList(growable: false);

    todos.sort((a, b) => a.dueDateTime.compareTo(b.dueDateTime));
    return todos;
  }
}
