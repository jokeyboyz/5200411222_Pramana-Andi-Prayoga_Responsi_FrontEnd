import 'package:flutter/material.dart';
import 'package:frontend_vania/service/auth.dart';

class TaskAdd extends StatelessWidget {
  final Function(String, String, String, String) onAdd;

  TaskAdd({required this.onAdd});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _task_timeController = TextEditingController();
  final TextEditingController _task_dateController = TextEditingController();

  void saveTask(BuildContext context) async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final task_time = _task_timeController.text;
    final task_date = _task_dateController.text;

    try {
      await addTask(name, description, task_time, task_date);
      onAdd(name, description, task_time, task_date);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _task_timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: _task_dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
              onPressed: () => saveTask(context),
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
