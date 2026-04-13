// task_form_screen.dart
// Used for both creating and editing tasks.
// Pass a Task object to edit it; pass nothing to create a new one.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task; // null = create mode, non-null = edit mode

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _assignedUserController;

  late String _status;
  late String _priority;
  DateTime? _dueDate;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _assignedUserController = TextEditingController(text: widget.task?.assignedUser ?? '');
    _status = widget.task?.status ?? 'todo';
    _priority = widget.task?.priority ?? 'medium';
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedUserController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final task = Task(
      id: widget.task?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
      assignedUser: _assignedUserController.text.trim().isEmpty ? null : _assignedUserController.text.trim(),
    );

    try {
      final apiService = context.read<ApiService>();
      if (_isEditing) {
        final saved = await apiService.updateTask(widget.task!.id, task);
        if (!mounted) return;
        Navigator.pop(context, saved); // Return updated Task to detail screen
      } else {
        await apiService.createTask(task);
        if (!mounted) return;
        Navigator.pop(context, true); // Return true so list screen refreshes
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red.shade700),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title (required)
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'What needs to be done?',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Title is required';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description (optional)
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add more details...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Status dropdown
            _dropdown(
              label: 'Status',
              value: _status,
              items: const [
                DropdownMenuItem(value: 'todo', child: Text('To Do')),
                DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'done', child: Text('Done')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),

            // Priority dropdown
            _dropdown(
              label: 'Priority',
              value: _priority,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (v) => setState(() => _priority = v!),
            ),
            const SizedBox(height: 16),

            // Due date picker
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date (optional)',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dueDate != null ? DateFormat('MMMM d, yyyy').format(_dueDate!) : 'Tap to pick a date',
                        style: TextStyle(color: _dueDate != null ? null : Colors.grey),
                      ),
                    ),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assigned user (optional free text)
            TextFormField(
              controller: _assignedUserController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Assigned User (optional)',
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'E.g., Abdullah',
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : Text(
                      _isEditing ? 'Save Changes' : 'Create Task',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
