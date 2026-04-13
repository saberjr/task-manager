// task_detail_screen.dart
// Shows all the details of one task. Users can edit or delete from here.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _editTask() async {
    final updatedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: _task)),
    );
    if (!mounted) return;
    if (updatedTask != null) {
      setState(() => _task = updatedTask);
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await context.read<ApiService>().deleteTask(_task.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _isDeleting ? null : _editTask,
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline),
            onPressed: _isDeleting ? null : _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _badge(_statusLabel(_task.status), _statusColor(_task.status)),
                const SizedBox(width: 8),
                _badge(_priorityLabel(_task.priority), _priorityColor(_task.priority)),
              ],
            ),
            const SizedBox(height: 24),

            if (_task.description != null && _task.description!.isNotEmpty) ...[
              const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(_task.description!, style: const TextStyle(fontSize: 15, height: 1.5)),
              const SizedBox(height: 24),
            ],

            _detailRow(Icons.person_outline, 'Assigned To', _task.assignedUser ?? 'Unassigned'),
            const SizedBox(height: 12),
            _detailRow(
              Icons.calendar_today_outlined,
              'Due Date',
              _task.dueDate != null ? DateFormat('MMMM d, yyyy').format(_task.dueDate!) : 'No due date',
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress': return Colors.orange.shade700;
      case 'done': return Colors.green.shade700;
      default: return Colors.blue.shade700;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress': return 'In Progress';
      case 'done': return 'Done';
      default: return 'To Do';
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red.shade700;
      case 'medium': return Colors.amber.shade800;
      default: return Colors.green.shade700;
    }
  }

  String _priorityLabel(String priority) {
    if (priority.isEmpty) return 'Low';
    return priority[0].toUpperCase() + priority.substring(1);
  }
}
