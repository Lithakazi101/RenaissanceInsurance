import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';

class TaskService {
  final String _tasksKey = 'renaissance_tasks';
  
  // Get all tasks
  Future<List<TaskItem>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString(_tasksKey);
    
    if (tasksString == null) {
      // Return sample data for first-time users
      final sampleTasks = _getSampleTasks();
      await saveTasks(sampleTasks);
      return sampleTasks;
    }
    
    final List<dynamic> tasksList = json.decode(tasksString);
    return tasksList.map((item) => TaskItem.fromJson(item)).toList();
  }
  
  // Save all tasks
  Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, json.encode(tasksJson));
  }
  
  // Add a new task
  Future<void> addTask(TaskItem task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }
  
  // Update a task
  Future<void> updateTask(TaskItem updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == updatedTask.id);
    
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await saveTasks(tasks);
  }
  
  // Update task status (for drag and drop)
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((task) => task.id == taskId);
    
    if (index != -1) {
      final updatedTask = tasks[index].copyWith(status: newStatus);
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }
  
  // Get tasks grouped by status
  Future<Map<String, List<TaskItem>>> getTasksByStatus() async {
    final tasks = await getTasks();
    final Map<String, List<TaskItem>> groupedTasks = {
      'todo': [],
      'in_progress': [],
      'done': [],
    };
    
    for (var task in tasks) {
      if (groupedTasks.containsKey(task.status)) {
        groupedTasks[task.status]!.add(task);
      } else {
        // If status doesn't exist in our map, add to todo as default
        groupedTasks['todo']!.add(task);
      }
    }
    
    return groupedTasks;
  }
  
  // Generate sample tasks for first-time users
  List<TaskItem> _getSampleTasks() {
    return [
      TaskItem(
        id: '1',
        title: 'Review Policy #1234',
        description: 'Conduct annual review of policy details and coverage',
        status: 'todo',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      TaskItem(
        id: '2',
        title: 'Process Claim #5678',
        description: 'Verify documents and process claim for approval',
        status: 'in_progress',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TaskItem(
        id: '3',
        title: 'Client Meeting: Johnson Family',
        description: 'Discuss policy renewal options and potential upgrades',
        status: 'todo',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TaskItem(
        id: '4',
        title: 'Update Risk Assessment Tool',
        description: 'Incorporate new risk factors into assessment model',
        status: 'in_progress',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      TaskItem(
        id: '5',
        title: 'Quarterly Report Review',
        description: 'Analyze Q2 performance metrics and claim ratio',
        status: 'done',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
} 