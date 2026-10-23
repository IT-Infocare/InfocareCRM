import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_constants.dart';
import '../../../controllers/lead_controller.dart';
import '../../../models/activity_model.dart';
import '../../../utils/validators.dart';

class ActivityFormDialog extends StatefulWidget {
  final String leadId;
  final ActivityModel? activity;

  const ActivityFormDialog({super.key, required this.leadId, this.activity});

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.activity?.description ?? '');
    _selectedType = widget.activity?.type ?? 'call';
    if (!AppConstants.activityTypes.contains(_selectedType)) {
      _selectedType = 'note';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.activity != null) {
        Get.find<LeadController>().updateActivity(
          widget.leadId,
          widget.activity!.id,
          _selectedType,
          _descriptionController.text.trim(),
        );
      } else {
        Get.find<LeadController>().addActivity(
          widget.leadId,
          _selectedType,
          _descriptionController.text.trim(),
        );
      }
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  Text(
                    isEditing ? 'Edit Activity' : 'Log Lead Activity',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Activity Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: AppConstants.activityTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ').toUpperCase()));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),
              const Text('Activity Summary / Notes *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                validator: (v) => Validators.required(v, message: 'Notes required'),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter details of call, site survey findings, or meeting discussion...',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(isEditing ? 'Update Activity' : 'Save Log'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
