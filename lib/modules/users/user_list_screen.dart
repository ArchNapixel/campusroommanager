import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/loading_widget.dart';
import 'users_provider.dart';

/// User list screen with role badges
class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late UsersProvider _usersProvider;
  final _searchController = TextEditingController();
  List<User> _filteredUsers = [];
  UserRole? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _usersProvider = UsersProvider();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    await _usersProvider.loadUsers();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _usersProvider.users.where((user) {
        final matchesSearch = user.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            user.email
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesRole =
            _selectedRoleFilter == null || user.role == _selectedRoleFilter;

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.buttonPrimary;
      case UserRole.teacher:
        return AppColors.available;
      case UserRole.admin:
        return AppColors.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Users',
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create user form
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Create new user')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // Role filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text('All'),
                    selected: _selectedRoleFilter == null,
                    onSelected: (_) {
                      setState(() => _selectedRoleFilter = null);
                      _applyFilters();
                    },
                  ),
                  SizedBox(width: 8),
                  ...UserRole.values
                      .map((role) => Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(role.name.toUpperCase()),
                              selected: _selectedRoleFilter == role,
                              onSelected: (_) {
                                setState(
                                    () => _selectedRoleFilter = role);
                                _applyFilters();
                              },
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // User list
          Expanded(
            child: _usersProvider.isLoading
                ? LoadingWidget(message: 'Loading users...')
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: AppColors.bodyText),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _getRoleColor(user.role)
                                      .withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getRoleIcon(user.role),
                                  color: _getRoleColor(user.role),
                                ),
                              ),
                              title: Text(user.name),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(user.email),
                                  SizedBox(height: 4),
                                  if (user.department != null)
                                    Text(user.department!),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(user.roleDisplayName),
                                backgroundColor:
                                    _getRoleColor(user.role)
                                        .withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: _getRoleColor(user.role),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                // TODO: Navigate to edit user
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Edit ${user.name}'),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school;
      case UserRole.teacher:
        return Icons.person;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }
}
