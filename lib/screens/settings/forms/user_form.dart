import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_constants.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/settings_controller.dart';
import '../../../utils/validators.dart';

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  static const List<Map<String, String>> _defaultBranches = [
    {'id': 'br_01', 'name': 'Dubai HQ Office', 'code': 'Dubai'},
    {'id': 'br_02', 'name': 'Ras Al Khaimah Branch', 'code': 'RAK'},
    {'id': 'br_03', 'name': 'Kerala Back Office', 'code': 'Kerala'},
  ];

  String _selectedRole = AppConstants.roleBranchSales;
  final Set<String> _selectedBranchCodes = {'Dubai'};

  List<Map<String, String>> _getAvailableBranches() {
    if (Get.isRegistered<SettingsController>()) {
      final s = Get.find<SettingsController>();
      if (s.branches.isNotEmpty) {
        return s.branches.map((b) => {
          'id': b.id,
          'name': b.name,
          'code': b.code.isNotEmpty ? b.code : b.name,
        }).toList();
      }
    }
    return _defaultBranches;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranchCodes.isEmpty) {
        Get.snackbar('Validation Error', 'Please select at least one assigned branch.');
        return;
      }

      final payload = {
        'username': _usernameController.text.trim().isNotEmpty ? _usernameController.text.trim() : _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : 'Info@1234',
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'branch': _selectedBranchCodes.join(', '),
        'branches': _selectedBranchCodes.toList(),
      };
      Get.find<SettingsController>().createUser(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 640),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Create System User Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Username *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(hintText: 'e.g. Admin or sarah'),
                                  validator: (v) => Validators.required(v, message: 'Username required'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Password *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(hintText: 'Default: Info@1234'),
                                  validator: (v) => Validators.required(v, message: 'Password required'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Full Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        validator: (v) => Validators.required(v, message: 'Name required'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email Address *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _emailController,
                                  validator: Validators.email,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(hintText: '+971 50 000 0000'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Assigned Role *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedRole,
                        items: AppConstants.allRoles.map((r) {
                          return DropdownMenuItem<String>(
                            value: r,
                            child: Text(
                              r.replaceAll('_', ' ').toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedRole = v);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Assigned Branches * (Select Multiple)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          TextButton(
                            onPressed: () {
                              final allCodes = _getAvailableBranches().map((b) => b['code'] ?? b['name']!).toSet();
                              setState(() {
                                if (_selectedBranchCodes.length == allCodes.length) {
                                  _selectedBranchCodes.clear();
                                  _selectedBranchCodes.add(allCodes.first);
                                } else {
                                  _selectedBranchCodes.addAll(allCodes);
                                }
                              });
                            },
                            child: Text(
                              _selectedBranchCodes.length == _getAvailableBranches().length ? 'Deselect Extra' : 'Select All',
                              style: const TextStyle(fontSize: 12, color: AppTheme.primaryTeal),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Builder(builder: (context) {
                        final branchesList = _getAvailableBranches();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.surface,
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: branchesList.map((b) {
                              final code = b['code'] ?? b['name']!;
                              final isSelected = _selectedBranchCodes.contains(code);
                              return FilterChip(
                                label: Text(code, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppTheme.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                                selected: isSelected,
                                selectedColor: AppTheme.primaryTeal,
                                checkmarkColor: Colors.white,
                                backgroundColor: Colors.grey.shade100,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedBranchCodes.add(code);
                                    } else {
                                      if (_selectedBranchCodes.length > 1) {
                                        _selectedBranchCodes.remove(code);
                                      }
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _submit,
                    child: const Text('Create User'),
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
