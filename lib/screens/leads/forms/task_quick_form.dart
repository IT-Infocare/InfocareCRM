import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/task_controller.dart';
import '../../../utils/validators.dart';

class TaskQuickFormDialog extends StatefulWidget {
  final String? leadId;
  final String? relatedTitle;

  const TaskQuickFormDialog({super.key, this.leadId, this.relatedTitle});

  @override
  State<TaskQuickFormDialog> createState() => _TaskQuickFormDialogState();
}

class _TaskQuickFormDialogState extends State<TaskQuickFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _priority = 'medium';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final taskCtrl = Get.put(TaskController());
      taskCtrl.createTask({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'lead_id': widget.leadId,
        'related_to_title': widget.relatedTitle,
        'assigned_user_id': 'usr_1001',
        'assigned_user_name': 'Sarah Connor',
        'due_date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'priority': _priority,
        'status': 'pending',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Follow-Up Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Task Title *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                validator: (v) => Validators.required(v, message: 'Title required'),
                decoration: const InputDecoration(hintText: 'e.g. Call client to follow up on quote'),
              ),
              const SizedBox(height: 16),
              const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['low', 'medium', 'high', 'urgent'].map((p) {
                  return DropdownMenuItem(value: p, child: Text(p.toUpperCase()));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
              ),
              const SizedBox(height: 16),
              const Text('Task Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Optional instructions...'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: _submit, child: const Text('Create Task')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
