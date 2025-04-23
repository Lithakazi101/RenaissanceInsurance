import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../utils/constants.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskItem task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const TaskItemWidget({
    super.key,
    required this.task,
    this.onEdit,
    this.onDelete,
  });

  // Get the appropriate color based on task status
  Color _getStatusColor() {
    switch (task.status) {
      case 'todo':
        return AppColors.todo;
      case 'in_progress':
        return AppColors.inProgress;
      case 'done':
        return AppColors.done;
      default:
        return AppColors.todo;
    }
  }

  // Format the status string for display
  String _formatStatus() {
    switch (task.status) {
      case 'todo':
        return AppStrings.todo;
      case 'in_progress':
        return AppStrings.inProgress;
      case 'done':
        return AppStrings.done;
      default:
        return AppStrings.todo;
    }
  }

  // Format the date for display
  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final taskDate = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
    
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Title and Action Buttons
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    splashRadius: 20,
                    color: AppColors.secondary,
                    constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
                    padding: EdgeInsets.zero,
                    tooltip: AppStrings.editTask,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: onDelete,
                    splashRadius: 20,
                    color: AppColors.error,
                    constraints: const BoxConstraints(maxHeight: 32, maxWidth: 32),
                    padding: EdgeInsets.zero,
                    tooltip: AppStrings.deleteTask,
                  ),
              ],
            ),
            
            const Divider(),
            
            // Task Description
            Text(
              task.description,
              style: AppTextStyles.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Task Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Chip
                Chip(
                  label: Text(
                    _formatStatus(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                
                // Created Date
                Text(
                  _formatDate(),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 