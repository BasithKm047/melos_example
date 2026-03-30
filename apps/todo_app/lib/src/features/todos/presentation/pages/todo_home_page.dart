import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/controllers/theme_controller.dart';
import '../../../users/domain/app_user.dart';
import '../../../users/presentation/controllers/users_controller.dart';
import '../../../users/presentation/pages/add_user_page.dart';
import '../../domain/todo_task.dart';
import '../controllers/todo_controller.dart';
import '../controllers/todo_day_filter_controller.dart';
import '../widgets/todo_tile.dart';
import 'add_todo_page.dart';

class TodoHomePage extends ConsumerWidget {
  const TodoHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoListProvider);
    final usersState = ref.watch(userListProvider);
    final filter = ref.watch(todoDayFilterProvider);

    final users = usersState.valueOrNull ?? <AppUser>[];
    final namesById = {for (final user in users) user.id: user.name};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Scheduler'),
        actions: [
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: const Icon(Icons.brightness_6_rounded),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddUserPage()));
            },
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add User',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<TodoDayFilter>(
              segments: const [
                ButtonSegment(value: TodoDayFilter.today, label: Text('Today')),
                ButtonSegment(value: TodoDayFilter.tomorrow, label: Text('Tomorrow')),
              ],
              selected: {filter},
              onSelectionChanged: (value) {
                ref.read(todoDayFilterProvider.notifier).state = value.first;
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: todoState.when(
                data: (items) {
                  final visible = _filterByDay(items, filter);
                  if (visible.isEmpty) {
                    return const Center(
                      child: Text('No tasks in this bucket. Add one to get started.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final task = visible[index];
                      final assigneeName = namesById[task.assignedUserId] ?? 'Unknown user';

                      return TodoTile(
                        task: task,
                        assigneeName: assigneeName,
                        onToggle: () async {
                          await ref.read(todoActionControllerProvider.notifier).toggleStatus(task);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTodoPage()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  List<TodoTask> _filterByDay(List<TodoTask> tasks, TodoDayFilter filter) {
    if (filter == TodoDayFilter.today) {
      return tasks.where((task) => task.isToday).toList();
    }
    return tasks.where((task) => task.isTomorrow).toList();
  }
}
