import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  Map<String, List<TaskItem>> _tasksByStatus = {
    'todo': [],
    'in_progress': [],
    'done': [],
  };
  bool _isLoading = false;
  String _errorMessage = '';
  
  Map<String, List<TaskItem>> get tasksByStatus => _tasksByStatus;
  List<TaskItem> get allTasks {
    final List<TaskItem> all = [];
    _tasksByStatus.forEach((_, tasks) => all.addAll(tasks));
    return all;
  }
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  TaskProvider() {
    loadTasks();
  }
  
  // Load all tasks
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _tasksByStatus = await _taskService.getTasksByStatus();
    } catch (e) {
      _errorMessage = 'Failed to load tasks: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add a new task
  Future<void> addTask(TaskItem task) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _taskService.addTask(task);
      await loadTasks(); // Reload tasks after adding
    } catch (e) {
      _errorMessage = 'Failed to add task: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Update a task
  Future<void> updateTask(TaskItem task) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _taskService.updateTask(task);
      await loadTasks(); // Reload tasks after updating
    } catch (e) {
      _errorMessage = 'Failed to update task: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _taskService.deleteTask(taskId);
      await loadTasks(); // Reload tasks after deleting
    } catch (e) {
      _errorMessage = 'Failed to delete task: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Move a task to a different status (for drag and drop)
  Future<void> moveTask(String taskId, String oldStatus, String newStatus) async {
    // Optimistically update UI first for smoother experience
    final taskIndex = _tasksByStatus[oldStatus]!.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasksByStatus[oldStatus]![taskIndex];
      final updatedTask = task.copyWith(status: newStatus);
      
      // Remove from old list
      _tasksByStatus[oldStatus]!.removeAt(taskIndex);
      
      // Add to new list
      _tasksByStatus[newStatus]!.add(updatedTask);
      
      notifyListeners();
      
      // Then update in storage
      try {
        await _taskService.updateTaskStatus(taskId, newStatus);
      } catch (e) {
        _errorMessage = 'Failed to move task: ${e.toString()}';
        // Revert changes if operation fails
        await loadTasks();
      }
    }
  }
  
  // Clear any error messages
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
} 