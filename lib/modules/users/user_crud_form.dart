import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_app_bar.dart';

/// CRUD form for creating and editing users
class UserCrudForm extends StatefulWidget {
  final User? initialUser;
  final Function(User) onSave;
  final VoidCallback? onCancel;

  const UserCrudForm({
    Key? key,
    this.initialUser,
    required this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  State<UserCrudForm> createState() => _UserCrudFormState();
}

class _UserCrudFormState extends State<UserCrudForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _departmentController;
  late final TextEditingController _studentIdController;
  late UserRole _selectedRole;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser?.name ?? '');
    _emailController = TextEditingController(text: widget.initialUser?.email ?? '');
    _departmentController =
        TextEditingController(text: widget.initialUser?.department ?? '');
    _studentIdController =
        TextEditingController(text: widget.initialUser?.studentId ?? '');
    _selectedRole = widget.initialUser?.role ?? UserRole.student;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final user = User(
      id: widget.initialUser?.id ??
          'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      email: _emailController.text,
      role: _selectedRole,
      department: _departmentController.text.isNotEmpty
          ? _departmentController.text
          : null,
      studentId: _studentIdController.text.isNotEmpty
          ? _studentIdController.text
          : null,
      createdAt: widget.initialUser?.createdAt ?? DateTime.now(),
      isActive: true,
    );

    widget.onSave(user);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.initialUser == null;

    return Scaffold(
      appBar: CustomAppBar(
        title: isNew ? 'Create User' : 'Edit User',
        showBackButton: true,
        onBackPressed: widget.onCancel ?? () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              Text(
                'Full Name',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter full name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Name is required';
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Email field
              Text(
                'Email Address',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Role selection
              Text(
                'Role',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: UserRole.values
                    .map((role) => FilterChip(
                          label: Text(role.name.toUpperCase()),
                          selected: _selectedRole == role,
                          onSelected: (_) =>
                              setState(() => _selectedRole = role),
                          backgroundColor:
                              AppColors.secondaryBackground,
                          selectedColor:
                              AppColors.buttonPrimary.withOpacity(0.3),
                        ))
                    .toList(),
              ),
              SizedBox(height: 20),

              // Department field
              Text(
                'Department',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Department name (optional)',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              SizedBox(height: 20),

              // Student ID field (visible only for students)
              if (_selectedRole == UserRole.student) ...[
                Text(
                  'Student ID',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: 'Student ID (required for students)',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (_selectedRole == UserRole.student &&
                        (value?.isEmpty ?? true)) {
                      return 'Student ID is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: Icon(Icons.save),
                      label: Text(isNew ? 'Create' : 'Update'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          widget.onCancel ?? () => Navigator.pop(context),
                      icon: Icon(Icons.cancel),
                      label: Text('Cancel'),
                    ),
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
