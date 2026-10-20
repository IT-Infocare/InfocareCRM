import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_constants.dart';
import '../../../config/app_theme.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/user_model.dart';
import '../../../utils/validators.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  const UserFormDialog({super.key, this.user});

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
    {'id': 'br_dxb', 'name': 'InfoCare System Dubai', 'code': 'Dubai'},
    {'id': 'br_irq', 'name': 'InfoCare System Iraq', 'code': 'Iraq'},
    {'id': 'br_shj', 'name': 'InfoCare Systems Sharjah', 'code': 'Sharjah'},
  ];

  late String _selectedRole;
  final Set<String> _selectedBranchCodes = {'Dubai'};

  @override
  void initState() {
    super.initState();
    _selectedRole = AppConstants.roleBranchSales;

    if (widget.user != null) {
      final u = widget.user!;
      _usernameController.text = u.username;
      _nameController.text = u.name;
      _emailController.text = u.email;
      _phoneController.text = u.phone ?? '';

      final matchedRole = AppConstants.allRoles.firstWhere(
        (r) => r.toLowerCase() == u.role.toLowerCase(),
        orElse: () => AppConstants.allRoles.contains(u.role) ? u.role : AppConstants.roleBranchSales,
      );
      _selectedRole = matchedRole;

      final branches = u.branch.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
      if (branches.isNotEmpty) {
        _selectedBranchCodes.clear();
        _selectedBranchCodes.addAll(branches);
      }
    }
  }

  List<Map<String, String>> _getAvailableBranches() {
    if (Get.isRegistered<AuthController>() && AuthController.to.branches.isNotEmpty) {
      return AuthController.to.branches.where((b) => b.isActive).map((b) => {
        'id': b.id,
        'name': b.displayShortName,
        'code': b.displayShortName,
      }).toList();
    }
    if (Get.isRegistered<SettingsController>()) {
      final s = Get.find<SettingsController>();
      if (s.branches.isNotEmpty) {
        return s.branches.where((b) => b.isActive).map((b) => {
          'id': b.id,
          'name': b.displayShortName,
          'code': b.displayShortName,
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

      final payload = <String, dynamic>{
        'username': _usernameController.text.trim().isNotEmpty ? _usernameController.text.trim() : _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'branch': _selectedBranchCodes.join(', '),
        'branches': _selectedBranchCodes.toList(),
      };

      if (_passwordController.text.trim().isNotEmpty) {
        payload['password'] = _passwordController.text.trim();
      } else if (widget.user == null) {
        payload['password'] = 'Info@1234';
      }

      if (widget.user != null) {
        Get.find<SettingsController>().updateUser(widget.user!.id, payload);
      } else {
        Get.find<SettingsController>().createUser(payload);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 560 : MediaQuery.of(context).size.width * 0.94,
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit User Account' : 'Create System User Account',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ),
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
                                Text(
                                  isEditing ? 'New Password' : 'Password *',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: isEditing ? 'Leave blank to keep unchanged' : 'Default: Info@1234',
                                  ),
                                  validator: (v) {
                                    if (!isEditing && (v == null || v.trim().isEmpty)) {
                                      return 'Password required';
                                    }
                                    return null;
                                  },
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
                                label: Text(
                                  code,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
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
                    child: Text(isEditing ? 'Update User' : 'Create User'),
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
