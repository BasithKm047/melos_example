import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_validators.dart';
import '../../../users/domain/app_user.dart';
import '../../../users/presentation/controllers/users_controller.dart';
import '../../../users/presentation/pages/add_user_page.dart';
import '../controllers/todo_controller.dart';

enum _TaskDay { today, tomorrow }

class AddTodoPage extends ConsumerStatefulWidget {
  const AddTodoPage({super.key});

  @override
  ConsumerState<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends ConsumerState<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  _TaskDay _selectedDay = _TaskDay.today;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String? _selectedUserId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(todoActionControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task scheduled successfully')),
            );
            Navigator.of(context).pop();
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    final userState = ref.watch(userListProvider);
    final actionState = ref.watch(todoActionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task title'),
                validator: (value) => AppValidators.requiredText(value, field: 'Task title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<_TaskDay>(
                segments: const [
                  ButtonSegment(value: _TaskDay.today, label: Text('Today')),
                  ButtonSegment(value: _TaskDay.tomorrow, label: Text('Tomorrow')),
                ],
                selected: {_selectedDay},
                onSelectionChanged: (value) => setState(() => _selectedDay = value.first),
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: Theme.of(context).cardTheme.color,
                title: const Text('Reminder time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.schedule),
                onTap: _pickTime,
              ),
              const SizedBox(height: 12),
              userState.when(
                data: (users) => _UserSelector(
                  users: users,
                  selectedUserId: _selectedUserId,
                  onChanged: (value) => setState(() => _selectedUserId = value),
                  onAddUser: _openAddUser,
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Failed to load users: $error'),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: actionState.isLoading ? null : _submit,
                child: actionState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Schedule Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(context: context, initialTime: _selectedTime);
    if (result != null) {
      setState(() => _selectedTime = result);
    }
  }

  Future<void> _openAddUser() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddUserPage()));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an assignee')),
      );
      return;
    }

    final now = DateTime.now();
    final selectedDate = _selectedDay == _TaskDay.today
        ? DateTime(now.year, now.month, now.day)
        : DateTime(now.year, now.month, now.day + 1);

    final dueTime = DateFormat('HH:mm:ss').format(
      DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );

    await ref.read(todoActionControllerProvider.notifier).addTodo(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: selectedDate,
          dueTime: dueTime,
          assignedUserId: _selectedUserId!,
        );
  }
}

class _UserSelector extends StatelessWidget {
  const _UserSelector({
    required this.users,
    required this.selectedUserId,
    required this.onChanged,
    required this.onAddUser,
  });

  final List<AppUser> users;
  final String? selectedUserId;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddUser;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('No users found. Add your first user to assign tasks.'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: onAddUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: selectedUserId,
          decoration: const InputDecoration(labelText: 'Assign to user'),
          items: users
              .map(
                (user) => DropdownMenuItem<String>(
                  value: user.id,
                  child: Text('${user.name} (${user.email})'),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Please select a user' : null,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onAddUser,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add New User'),
        ),
      ],
    );
  }
}
