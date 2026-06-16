import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as prov;
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/user_repository.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditingProfile = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = prov.Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        setState(() {
          _nameController.text = user['fullName'] ?? '';
          _bioController.text = user['bio'] ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(Map<String, dynamic> userMap) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      final userId = userMap['_id'] ?? userMap['id'];
      await repo.updateProfile(userId, {
        'fullName': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
      });
      
      setState(() {
        _isEditingProfile = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update profile'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _changePassword(String userId) async {
    if (!_passwordFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.changePassword(
        userId, 
        _currentPasswordController.text, 
        _newPasswordController.text
      );
      
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to change password'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = prov.Provider.of<AuthProvider>(context);
    final user = authState.user;

    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    final String fullName = user['fullName'] ?? 'Unknown';
    final String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              Center(
                child: Column(
                  children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientPrimary,
                      boxShadow: AppColors.glowShadow,
                      border: Border.all(color: AppColors.surface, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(fullName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      (user['role'] ?? 'User').toString().toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Personal Information
            _buildSectionHeader('Personal Information', 
              action: TextButton.icon(
                icon: Icon(_isEditingProfile ? Icons.check_rounded : Icons.edit_rounded, size: 16),
                onPressed: () {
                  if (_isEditingProfile) {
                    _updateProfile(user);
                  } else {
                    setState(() => _isEditingProfile = true);
                  }
                },
                label: _isLoading && _isEditingProfile 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEditingProfile ? 'Save' : 'Edit', style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            ),
            
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Email Address', initialValue: user['email'], enabled: false, icon: Icons.email_rounded),
                    const SizedBox(height: 20),
                    _buildTextField('Full Name', controller: _nameController, enabled: _isEditingProfile, icon: Icons.person_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 20),
                    _buildTextField('Bio / Research Interests', controller: _bioController, enabled: _isEditingProfile, icon: Icons.description_rounded, maxLines: 3),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Security
            _buildSectionHeader('Security'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Current Password', controller: _currentPasswordController, isPassword: true, icon: Icons.lock_outline_rounded, validator: (v) => v!.isEmpty ? 'Required' : null),
                    const SizedBox(height: 20),
                    _buildTextField('New Password', controller: _newPasswordController, isPassword: true, icon: Icons.lock_rounded, validator: (v) => v!.length < 6 ? 'Min 6 characters' : null),
                    const SizedBox(height: 20),
                    _buildTextField('Confirm Password', controller: _confirmPasswordController, isPassword: true, icon: Icons.lock_rounded, validator: (v) => v != _newPasswordController.text ? 'Passwords do not match' : null),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _changePassword(user['_id'] ?? user['id']),
                        child: _isLoading && !_isEditingProfile 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Update Password'),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  prov.Provider.of<AuthProvider>(context, listen: false).logout();
                },
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {String? initialValue, TextEditingController? controller, bool enabled = true, bool isPassword = false, int maxLines = 1, IconData? icon, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: enabled ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: enabled ? AppColors.primaryLight : AppColors.textLight, size: 20) : null,
            filled: true,
            fillColor: enabled ? AppColors.bg : AppColors.bg.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
