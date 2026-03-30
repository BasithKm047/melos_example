import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/todo_task.dart';

class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.task,
    required this.assigneeName,
    required this.onToggle,
  });

  final TodoTask task;
  final String assigneeName;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(task.dueDateTime);
    final isDone = task.status == TodoStatus.done;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Checkbox(value: isDone, onChanged: (_) => onToggle()),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(task.description),
            ],
            const SizedBox(height: 6),
            Text('Assigned to: $assigneeName'),
            Text('Reminder: $time'),
          ],
        ),
      ),
    );
  }
}
