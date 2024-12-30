// File utama (task_screen.dart)
import 'package:flutter/material.dart';
import 'package:frontend_vania/loginScreen.dart';
import 'package:frontend_vania/service/auth.dart';
import 'task_dialog.dart';
import 'task_add.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> tasks = []; // Daftar task/user
  List<Map<String, dynamic>> filteredTasks = []; // Hasil pencarian
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    fetchTasksFromBackend(); // Simulasi load task
  }

  Future<void> loadUserProfile() async {
    try {
      final data = await getUserProfile();
      setState(() {
        userData = data['data'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // void loadTasks() {
  //   tasks = [
  //     {'name': 'Task 1', 'description': 'Complete the design', 'time': '14:00', 'date': '2024-12-29'},
  //     {'name': 'Meeting', 'description': 'Discuss project updates', 'time': '16:00', 'date': '2024-12-30'},
  //   ];
  //   filteredTasks = List.from(tasks);
  // }

  void filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTasks = List.from(tasks);
      } else {
        // Pastikan task memiliki key yang benar
        filteredTasks = tasks.where((task) {
          final name = task['name']?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }


  void showEditDeleteModal(BuildContext context, Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSave: (name, description, time, date) async {
          try {
            await updateTask(task['id'], name, description, time, date); // Kirim ID ke backend
            setState(() {
              task['name'] = name;
              task['description'] = description;
              task['time'] = time;
              task['date'] = date;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Task "${task['name']}" updated successfully.')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update task: $e')),
            );
          }
        },
        onDelete: () async {
          try {
            await deleteTask(task['id']); // Hapus berdasarkan ID
            setState(() {
              tasks.remove(task);
              filteredTasks.remove(task);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Task "${task['name']}" deleted successfully.')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete task: $e')),
            );
          }
        },
      ),
    );
  }


  void showAddTaskModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskAdd(
          onAdd: (name, description, time, date) {
            setState(() {
              final newTask = {
                'name': name,
                'description': description,
                'time': time,
                'date': date,
              };
              tasks.add(newTask);
              filteredTasks.add(newTask);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Task "$name" added.')),
            );
          },
        ),
      ),
    );
  }

  Future<void> fetchTasksFromBackend() async {
    try {
      final tasksFromBackend = await fetchTasks(); // Fungsi dari auth.dart
      setState(() {
        tasks = List<Map<String, dynamic>>.from(tasksFromBackend.map((task) => {
              'id': task['id'],
              'name': task['name'],
              'description': task['description'],
              'time': task['task_time'],
              'date': task['task_date'],
            }));
        filteredTasks = List.from(tasks);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tasks: $e')),
      );
    }
  }

  void logoutButton() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userData == null
              ? 'Welcome, Guest'
              : 'Welcome, ${userData?['name'] ?? 'User'}',
          style: const TextStyle(fontSize: 16.0),
        ),
        actions: [
          IconButton(
          onPressed: () {
            logoutButton();
          },
          icon: const Icon(Icons.logout))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: filterTasks,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Task List', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 20),
                  // List of Filtered Tasks with Cards
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? const Center(child: Text('No results found'))
                        : ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 120,
                                  child: Card(
                                    elevation: 5,
                                    color: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ListTile(
                                        title: Text(
                                          task['name']!,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          task['description']!,
                                          style: const TextStyle(fontSize: 14.0, color: Colors.white),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              task['time']!,
                                              style: const TextStyle(fontSize: 12.0, color: Colors.white),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              task['date']!,
                                              style: const TextStyle(fontSize: 12.0, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        onTap: () => showEditDeleteModal(context, task),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  ElevatedButton(
                    onPressed: () => showAddTaskModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Add Task',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
