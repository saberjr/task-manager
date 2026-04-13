// task.dart
// Blueprint for a Task object.
// API JSON → Task (fromJson)
// Task → API JSON (toJson)

class Task {
  final String id;
  final String title;
  final String? description;   // optional
  final String status;         // 'todo' | 'in_progress' | 'done'
  final String priority;       // 'low' | 'medium' | 'high'
  final DateTime? dueDate;     // optional
  final String? assignedUser;  // optional

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    this.assignedUser,
  });

  // Build a Task from the JSON the API sends us
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      assignedUser: json['assignedTo']?.toString(),
    );
  }

  // Convert Task to JSON to send to the API
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String().split('T').first, // "YYYY-MM-DD"
      'assignedTo': assignedUser,
    };
  }

  // Returns a copy of this task with specific fields changed (used when editing)
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    String? assignedUser,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      assignedUser: assignedUser ?? this.assignedUser,
    );
  }
}
