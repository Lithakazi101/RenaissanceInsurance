import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart' hide ProgrammaticExpansionTile;
import '../models/task_item.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/task_form.dart';
import '../custom_widgets/programmatic_expansion_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<DragAndDropList> _lists;
  
  @override
  void initState() {
    super.initState();
    // Load tasks when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }
  
  // Create drag and drop lists based on task status
  List<DragAndDropList> _buildTaskLists(Map<String, List<TaskItem>> tasksByStatus) {
    final statusColumns = [
      {'key': 'todo', 'title': AppStrings.todo, 'color': AppColors.todo},
      {'key': 'in_progress', 'title': AppStrings.inProgress, 'color': AppColors.inProgress},
      {'key': 'done', 'title': AppStrings.done, 'color': AppColors.done},
    ];
    
    return statusColumns.map((column) {
      final statusKey = column['key'] as String;
      final statusTitle = column['title'] as String;
      final statusColor = column['color'] as Color;
      final tasks = tasksByStatus[statusKey] ?? [];
      
      return DragAndDropList(
        header: _buildListHeader(statusTitle, statusColor, tasks.length),
        children: tasks.map((task) {
          return DragAndDropItem(
            child: _buildTaskItem(task),
          );
        }).toList(),
      );
    }).toList();
  }
  
  // Build header for each list
  Widget _buildListHeader(String title, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build task item widget with edit and delete functionality
  Widget _buildTaskItem(TaskItem task) {
    return TaskItemWidget(
      task: task,
      onEdit: () => _showTaskForm(task),
      onDelete: () => _showDeleteConfirmation(task),
    );
  }
  
  // Show form dialog to add or edit a task
  void _showTaskForm([TaskItem? task]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          task != null ? AppStrings.editTask : AppStrings.addTask,
          style: AppTextStyles.heading2,
        ),
        content: SingleChildScrollView(
          child: TaskForm(
            task: task,
            onSave: (updatedTask) {
              if (task != null) {
                // Update existing task
                Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
              } else {
                // Add new task
                Provider.of<TaskProvider>(context, listen: false).addTask(updatedTask);
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
      ),
    );
  }
  
  // Show confirmation dialog before deleting a task
  void _showDeleteConfirmation(TaskItem task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteTask),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
  
  // Handle when a task is dropped in a different list
  void _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasksByStatus = taskProvider.tasksByStatus;
    
    final statusKeys = ['todo', 'in_progress', 'done'];
    final oldStatus = statusKeys[oldListIndex];
    final newStatus = statusKeys[newListIndex];
    
    // If the task was moved to a different list (status changed)
    if (oldListIndex != newListIndex) {
      final task = tasksByStatus[oldStatus]![oldItemIndex];
      taskProvider.moveTask(task.id, oldStatus, newStatus);
    }
  }
  
  // Handle when an entire list is reordered (we don't actually allow this)
  void _onListReorder(int oldListIndex, int newListIndex) {
    // We don't actually reorder the lists, as they represent fixed statuses
    // This function is required by the DragAndDropLists widget but won't do anything
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.taskBoard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          if (taskProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          _lists = _buildTaskLists(taskProvider.tasksByStatus);
          
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: DragAndDropLists(
              children: _lists,
              onItemReorder: _onItemReorder,
              onListReorder: _onListReorder,
              listPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              listInnerDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppBorderRadius.large),
              ),
              contentsWhenEmpty: Center(
                child: Text(
                  'No tasks found',
                  style: AppTextStyles.body,
                ),
              ),
              lastListTargetSize: 0, // Prevent empty space at the end
              lastItemTargetHeight: 8, // Height for dropping at the end of a list
              addLastItemTargetHeightToTop: true,
              listDraggingWidth: 150,
              itemDivider: const SizedBox(height: 4),
              itemDecorationWhileDragging: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              listDragHandle: const DragHandle(
                verticalAlignment: DragHandleVerticalAlignment.top,
                child: SizedBox(), // Empty drag handle as we don't want to drag lists
              ),
              itemDragHandle: const DragHandle(
                child: Icon(
                  Icons.drag_handle,
                  color: AppColors.disabled,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(),
        backgroundColor: AppColors.primary,
        tooltip: AppStrings.addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
} 