import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class TaskForm extends StatefulWidget {
  final TaskItem? task;
  final Function(TaskItem) onSave;
  
  const TaskForm({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'todo';
  
  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'todo', 'label': AppStrings.todo, 'color': AppColors.todo},
    {'value': 'in_progress', 'label': AppStrings.inProgress, 'color': AppColors.inProgress},
    {'value': 'done', 'label': AppStrings.done, 'color': AppColors.done},
  ];

  @override
  void initState() {
    super.initState();
    
    // If editing an existing task, populate the form
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      final task = widget.task != null
          ? widget.task!.copyWith(
              title: title,
              description: description,
              status: _status,
            )
          : TaskItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              description: description,
              status: _status,
              createdAt: DateTime.now(),
            );
      
      widget.onSave(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: AppStrings.taskTitle,
            ),
            textInputAction: TextInputAction.next,
            validator: Validators.validateRequired,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: AppStrings.taskDescription,
            ),
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            validator: Validators.validateRequired,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Status
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: AppStrings.taskStatus,
            ),
            items: _statusOptions.map((option) {
              return DropdownMenuItem<String>(
                value: option['value'],
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: option['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(option['label']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _status = value;
                });
              }
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel Button
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.cancel),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Save Button
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(
                  widget.task != null ? AppStrings.save : AppStrings.addTask,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 