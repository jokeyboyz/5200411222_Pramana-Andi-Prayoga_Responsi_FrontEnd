import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_vania/loginScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();

const String baseUrl =
    'http://192.168.1.2:3306/api'; // ganti ip dengan ip host laptop punya temen temen

// Future<Map<String, String>> getDefaultHeaders() async {
//   final accessToken = await secureStorage.read(key: 'access_token');
//   return {
//     'Content-Type': 'application/json',
//     if (accessToken != null) 'Authorization': 'Bearer $accessToken',
//   };
// }

Future<void> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/auth/login');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final accessToken = data['token']['access_token'];

      await secureStorage.write(key: 'access_token', value: accessToken);
      print('Access token successfully stored!');
    } else {
      final error = json.decode(response.body);
      throw Exception('Login failed: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

Future <void> fetchProtectedData() async {
  final url = Uri.parse('$baseUrl/user/me');
  final accessToken = await secureStorage.read(key: 'access_token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      print('Data retrieved successfully: ${response.body}');
    } else if (response.statusCode == 401) {
      print('Invalid or expired access token. Please log in again.');
    } else {
      final error = json.decode(response.body);
      print('Error: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

Future<void> logout() async {
  await secureStorage.delete(key: 'access_token');
  print('Access token successfully deleted.');
}

Future<Map<String, dynamic>> getUserProfile() async {
  final url = Uri.parse('$baseUrl/user/profile');
  final accessToken = await secureStorage.read(key: 'access_token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(
          'Failed to get profile: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('Failed to get profile: $e');
  }
}

Future<void> addTask(String name, String description, String task_time, String task_date) async {
  final url = Uri.parse('$baseUrl/auth/addTask');
  final accessToken = await secureStorage.read(key: 'access_token'); // Get token

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Add token here
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'task_time': task_time,
        'task_date': task_date,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Task added successfully');
    } else {
      final error = json.decode(response.body);
      throw Exception('Failed to add task: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('Error adding task: $e');
  } 
}

Future<List<Map<String, dynamic>>> fetchTasks() async {
  final url = Uri.parse('$baseUrl/auth/getTask'); // Endpoint baru
  final accessToken = await secureStorage.read(key: 'access_token'); // Ambil token

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Kirim token
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please log in again.');
    } else {
      final error = json.decode(response.body);
      throw Exception('Error: ${error['message']}');
    }
  } catch (e) {
    throw Exception('Failed to fetch tasks: $e');
  }
}

Future<void> updateTask(int id, String name, String description, String task_time, String task_date) async {
  final url = Uri.parse('$baseUrl/auth/editTask'); // Endpoint untuk edit task
  final accessToken = await secureStorage.read(key: 'access_token');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Kirim token
      },
      body: jsonEncode({
        'id': id.toString(),
        'name': name,
        'description': description,
        'task_time': task_time,
        'task_date': task_date,
      }),
    );

    if (response.statusCode == 200) {
      print('Task updated successfully');
    } else {
      final error = json.decode(response.body);
      throw Exception('Failed to update task: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('Error updating task: $e');
  }
}

Future<void> deleteTask(int id) async {
  final url = Uri.parse('$baseUrl/auth/deleteTask/$id'); // Endpoint untuk delete task
  final accessToken = await secureStorage.read(key: 'access_token');

  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Kirim token
      },
    );

    if (response.statusCode == 200) {
      print('Task deleted successfully');
    } else {
      final error = json.decode(response.body);
      throw Exception('Failed to delete task: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('Error deleting task: $e');
  }
}










