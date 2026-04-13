// task_list_screen.dart
// Main screen after login. Shows all tasks with search and filter chips.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String? _error;

  String _selectedStatus = '';
  String _selectedPriority = '';
  String _searchQuery = '';

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tasks = await context.read<ApiService>().getTasks();
      if (!mounted) return;
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        final matchesStatus = _selectedStatus.isEmpty || task.status == _selectedStatus;
        final matchesPriority = _selectedPriority.isEmpty || task.priority == _selectedPriority;
        final matchesSearch = _searchQuery.isEmpty ||
            task.title.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesStatus && matchesPriority && matchesSearch;
      }).toList();
    });
  }

  Future<void> _openCreateTask() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (!mounted) return;
    if (created == true) _loadTasks();
  }

  Future<void> _openTaskDetail(Task task) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    if (!mounted) return;
    if (changed == true) _loadTasks();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthService>().logout();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTask,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _applyFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip('All', '', isStatus: true),
                _filterChip('To Do', 'todo', isStatus: true),
                _filterChip('In Progress', 'in_progress', isStatus: true),
                _filterChip('Done', 'done', isStatus: true),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                const SizedBox(width: 8),
                _filterChip('All Priority', '', isStatus: false),
                _filterChip('Low', 'low', isStatus: false),
                _filterChip('Medium', 'medium', isStatus: false),
                _filterChip('High', 'high', isStatus: false),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, {required bool isStatus}) {
    final isSelected = isStatus ? _selectedStatus == value : _selectedPriority == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            if (isStatus) {
              _selectedStatus = value;
            } else {
              _selectedPriority = value;
            }
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton.icon(onPressed: _loadTasks, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    if (_filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 52, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _allTasks.isEmpty ? 'No tasks yet.\nTap + to create one!' : 'No tasks match your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) => TaskCard(
          task: _filteredTasks[index],
          onTap: () => _openTaskDetail(_filteredTasks[index]),
        ),
      ),
    );
  }
}
