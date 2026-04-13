// api_service.dart
// This file handles ALL communication with the REST API.
// Every method here is one API call: getTasks, createTask, etc.
// It automatically attaches the Bearer token to every request.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService authService;

  ApiService(this.authService);

  // Build the Authorization header using the stored token
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.token}',
      };

  // Helper: throw a readable error if the response is not successful
  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message;
      try {
        final body = jsonDecode(response.body);
        message = body['message'] ?? 'Request failed (${response.statusCode})';
      } catch (_) {
        message = 'Request failed (${response.statusCode})';
      }
      throw Exception(message);
    }
  }

  // GET /tasks — fetch all tasks, with optional filters
  Future<List<Task>> getTasks({
    String? status,
    String? priority,
    String? search,
  }) async {
    // Build query parameters only if they are not null
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty) queryParams['priority'] = priority;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/tasks').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await http.get(uri, headers: _headers);
    _checkResponse(response);

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Task.fromJson(json)).toList();
  }

  // GET /tasks/:id — fetch a single task by ID
  Future<Task> getTask(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: _headers,
    );
    _checkResponse(response);
    return Task.fromJson(jsonDecode(response.body));
  }

  // POST /tasks — create a new task
  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    _checkResponse(response);
    return Task.fromJson(jsonDecode(response.body));
  }

  // PUT /tasks/:id — update an existing task
  Future<Task> updateTask(String id, Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    _checkResponse(response);
    return Task.fromJson(jsonDecode(response.body));
  }

  // DELETE /tasks/:id — delete a task
  Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: _headers,
    );
    _checkResponse(response);
  }
}
