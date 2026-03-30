enum TodoStatus { pending, done }

class TodoTask {
  const TodoTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.assignedUserId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String dueTime;
  final String assignedUserId;
  final TodoStatus status;
  final DateTime createdAt;

  DateTime get dueDateTime {
    final chunks = dueTime.split(':');
    final hour = chunks.isNotEmpty ? int.tryParse(chunks[0]) ?? 9 : 9;
    final minute = chunks.length > 1 ? int.tryParse(chunks[1]) ?? 0 : 0;

    return DateTime(dueDate.year, dueDate.month, dueDate.day, hour, minute);
  }

  bool get isToday {
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    return TodoTask(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      dueTime: (map['due_time'] as String?) ?? '09:00:00',
      assignedUserId: map['assigned_user_id'] as String,
      status: (map['status'] as String?) == 'done' ? TodoStatus.done : TodoStatus.pending,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T').first,
      'due_time': dueTime,
      'assigned_user_id': assignedUserId,
      'status': status == TodoStatus.done ? 'done' : 'pending',
      'created_at': createdAt.toIso8601String(),
    };
  }
}
