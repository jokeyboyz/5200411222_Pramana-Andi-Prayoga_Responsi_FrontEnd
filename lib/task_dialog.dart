import 'package:flutter/material.dart';
import 'package:frontend_vania/service/auth.dart';

class TaskDialog extends StatelessWidget {
  final Map<String, dynamic> task;
  final Function(String, String, String, String) onSave;
  final VoidCallback onDelete;

  const TaskDialog({
    super.key,
    required this.task,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: task['name']);
    final TextEditingController descriptionController = TextEditingController(text: task['description']);
    final TextEditingController timeController = TextEditingController(text: task['time']);
    final TextEditingController dateController = TextEditingController(text: task['date']);

    return AlertDialog(
      title: Text('Edit or Delete "${task['name']}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          TextFormField(
            controller: timeController,
            decoration: const InputDecoration(labelText: 'Time'),
          ),
          TextFormField(
            controller: dateController,
            decoration: const InputDecoration(labelText: 'Date'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _deleteTask(context); // Panggil fungsi delete dari auth.dart
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
        ElevatedButton(
          onPressed: () {
            _updateTask(
              context,
              nameController.text,
              descriptionController.text,
              timeController.text,
              dateController.text,
            ); // Panggil fungsi update dari auth.dart
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _updateTask(BuildContext context, String name, String description, String time, String date) async {
    try {
      await updateTask(
        task['id']??'', // Ambil task id dari map
        name,
        description,
        time,
        date,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  Future<void> _deleteTask(BuildContext context) async {
    try {
      await deleteTask(task['id']??''); // Hapus task berdasarkan task id
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
      onDelete(); // Panggil onDelete untuk update UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }
}
