// task_card.dart
// A reusable widget that shows one task as a card in the list.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + priority badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(_priorityLabel(task.priority), _priorityColor(task.priority)),
                ],
              ),

              // Description
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description!,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Status + due date + avatar
              Row(
                children: [
                  _buildBadge(_statusLabel(task.status), _statusColor(task.status), filled: false),
                  const SizedBox(width: 8),
                  if (task.dueDate != null) ...[
                    Icon(Icons.calendar_today_outlined, size: 13, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d').format(task.dueDate!),
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                  const Spacer(),
                  if (task.assignedUser != null && task.assignedUser!.isNotEmpty)
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        task.assignedUser![0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, {bool filled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
