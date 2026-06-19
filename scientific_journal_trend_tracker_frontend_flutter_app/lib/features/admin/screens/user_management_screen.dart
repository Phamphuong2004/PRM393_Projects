import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme.dart';
import '../../../core/models/user.dart';
import '../../../core/repositories/user_repository.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  List<User> _users = [];
  int _page = 1;
  int _totalPages = 1;
  int _totalUsers = 0;
  bool _loading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userRepo = ref.read(userRepositoryProvider);
      final res = await userRepo.getAllUsers(page: _page, limit: 20);
      
      if (!mounted) return;
      
      final usersList = res['users'] as List<User>;
      final pagination = res['pagination'];
      
      setState(() {
        _users = usersList;
        _totalPages = pagination?['pages'] ?? 1;
        _totalUsers = pagination?['total'] ?? usersList.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(User user, bool isActive) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.updateUserStatus(user.id, isActive);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account status updated for ${user.fullName}'),
          backgroundColor: AppColors.success,
        ),
      );
      _fetchUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateRole(User user, String newRole) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.updateUserRole(user.id, newRole);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role updated to ${newRole.toUpperCase()} for ${user.fullName}'),
          backgroundColor: AppColors.success,
        ),
      );
      _fetchUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update role: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteUser(User user) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.deleteUser(user.id);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${user.fullName} deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      _fetchUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showRoleDialog(User user) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Change Role for ${user.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Select Role'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'researcher', child: Text('Researcher')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (val) => setDialogState(() => selectedRole = val!),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _updateRole(user, selectedRole);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${user.fullName}\'s account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((user) {
      final q = _searchQuery.toLowerCase();
      return user.fullName.toLowerCase().contains(q) || user.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPremiumDark,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'User Management',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage account permissions, roles, and administrative statuses ($_totalUsers users)',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ],
            ),
          ),

          // Main list section
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.error)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _fetchUsers, child: const Text('Try Again')),
                          ],
                        ),
                      )
                    : filteredUsers.isEmpty
                        ? const Center(child: Text('No users found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length + (_totalPages > 1 ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredUsers.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_page > 1)
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left),
                                          onPressed: () {
                                            setState(() => _page--);
                                            _fetchUsers();
                                          },
                                        ),
                                      Text('$_page / $_totalPages'),
                                      if (_page < _totalPages)
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed: () {
                                            setState(() => _page++);
                                            _fetchUsers();
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              }

                              final user = filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final initial = user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U';
    
    // Choose role color
    Color roleColor;
    switch (user.role) {
      case 'admin':
        roleColor = AppColors.error;
        break;
      case 'researcher':
        roleColor = AppColors.secondary;
        break;
      default:
        roleColor = AppColors.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: roleColor.withValues(alpha: 0.1),
              child: Text(
                initial,
                style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.isActive 
                              ? AppColors.success.withValues(alpha: 0.1) 
                              : AppColors.textLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isActive ? 'ACTIVE' : 'SUSPENDED',
                          style: TextStyle(
                            color: user.isActive ? AppColors.success : AppColors.textSecondary, 
                            fontSize: 11, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit Role Action
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                      tooltip: 'Change User Role',
                      onPressed: () => _showRoleDialog(user),
                    ),
                    // Ban/Unban toggle switch
                    Switch(
                      value: user.isActive,
                      activeThumbColor: AppColors.success,
                      inactiveThumbColor: AppColors.error,
                      inactiveTrackColor: AppColors.error.withValues(alpha: 0.2),
                      onChanged: (val) => _updateStatus(user, val),
                    ),
                  ],
                ),
                // Delete user
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete User Account',
                  onPressed: () => _confirmDelete(user),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
