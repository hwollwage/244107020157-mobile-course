import 'package:flutter/material.dart';

import 'is_valid_task_title.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _controller = TextEditingController();
  final List<String> _tasks = [];
  String? _errorText;

  void _saveTask() {
    final title = _controller.text;
    if (!isValidTaskTitle(title)) {
      setState(() => _errorText = 'Title cannot be empty');
      return;
    }
    setState(() {
      _tasks.add(title.trim());
      _controller.clear();
      _errorText = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Task list'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('task-title-field'),
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Task title',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('save-task-button'),
              onPressed: _saveTask,
              child: const Text('Save task'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      key: Key('empty-message'),
                      child: Text('No tasks yet.'),
                    )
                  : ListView.builder(
                      key: const Key('task-list'),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) => ListTile(
                        key: Key('task-item-$index'),
                        title: Text(_tasks[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
