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
  late TextEditingController _institutionController;
  late TextEditingController _interestsController;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPasswordForm = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _institutionController = TextEditingController();
    _interestsController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = prov.Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        setState(() {
          _nameController.text = user['fullName'] ?? '';
          _bioController.text = user['bio'] ?? '';
          _institutionController.text = user['institution'] ?? '';
          _interestsController.text = user['researchInterests'] ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _institutionController.dispose();
    _interestsController.dispose();
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
        'institution': _institutionController.text.trim(),
        'researchInterests': _interestsController.text.trim(),
      });
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _changePassword(String userId) async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.changePassword(userId, _currentPasswordController.text, _newPasswordController.text);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() { _isLoading = false; _showPasswordForm = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to change password'), backgroundColor: AppColors.error),
        );
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
    final String email = user['email'] ?? '';
    final String role = user['role'] ?? 'User';
    final String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
    final String createdAt = user['createdAt'] != null
        ? _formatDate(user['createdAt'].toString())
        : 'N/A';
    final int savedPapers = (user['savedPapers'] as List?)?.length ?? 0;

    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header Banner ──────────────────────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB8B8FF), Color(0xFFB2E8E8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                ),
                // Avatar overlapping the banner
                Positioned(
                  left: 28,
                  bottom: -44,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE8E8F4),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.person_rounded, size: 44, color: Colors.grey.shade500),
                    ),
                  ),
                ),
              ],
            ),

            // ── User Info row ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(136, 16, 24, 20),
              margin: const EdgeInsets.only(top: 44), // space for overlapping avatar
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              email,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _capitalize(role),
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Content ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 260, child: _buildActivityCard(createdAt, savedPapers)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              _buildGeneralInfoCard(user),
                              const SizedBox(height: 20),
                              _buildSecurityCard(user),
                              const SizedBox(height: 20),
                              _buildLogoutButton(context),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildActivityCard(createdAt, savedPapers),
                        const SizedBox(height: 20),
                        _buildGeneralInfoCard(user),
                        const SizedBox(height: 20),
                        _buildSecurityCard(user),
                        const SizedBox(height: 20),
                        _buildLogoutButton(context),
                      ],
                    ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ── Account Activity Card ──────────────────────────────────────────────────
  Widget _buildActivityCard(String createdAt, int savedPapers) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.monitor_heart_outlined, 'Account Activity'),
          const SizedBox(height: 16),
          _activityRow('Status', badge: _buildBadge('Active', Colors.green)),
          _divider(),
          _activityRow('Member Since', value: createdAt),
          _divider(),
          _activityRow(
            'Saved Papers',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(savedPapers.toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── General Information Card ───────────────────────────────────────────────
  Widget _buildGeneralInfoCard(Map<String, dynamic> user) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(Icons.settings_outlined, 'General Information'),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 500;
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _profileField('Full Name', controller: _nameController, validator: (v) => v!.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: _profileField('Email Address', initialValue: user['email'], enabled: false, note: 'Email cannot be changed.')),
                      ],
                    )
                  : Column(children: [
                      _profileField('Full Name', controller: _nameController, validator: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      _profileField('Email Address', initialValue: user['email'], enabled: false, note: 'Email cannot be changed.'),
                    ]);
            }),
            const SizedBox(height: 16),
            _profileField('Institution', controller: _institutionController, hint: 'e.g. FPT University'),
            const SizedBox(height: 16),
            _profileField('Bio', controller: _bioController, hint: 'Tell us a bit about yourself and your research focus...', maxLines: 4),
            const SizedBox(height: 16),
            _profileField('Research Interests', controller: _interestsController, hint: 'e.g. Artificial Intelligence, Quantum Physics', note: 'Separate multiple topics with commas.'),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _updateProfile(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Security Card ──────────────────────────────────────────────────────────
  Widget _buildSecurityCard(Map<String, dynamic> user) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.key_outlined, 'Security Settings'),
          const SizedBox(height: 20),

          // Change Password row
          if (!_showPasswordForm)
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      SizedBox(height: 4),
                      Text('Update your password to keep your account secure.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _showPasswordForm = true),
                  child: const Text('Update Password', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            )
          else
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  _passwordField('Current Password', _currentPasswordController, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 14),
                  _passwordField('New Password', _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew),
                      validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null),
                  const SizedBox(height: 14),
                  _passwordField('Confirm Password', _confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) => v != _newPasswordController.text ? 'Passwords do not match' : null),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() { _showPasswordForm = false; }),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _changePassword(user['_id'] ?? user['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          prov.Provider.of<AuthProvider>(context, listen: false).logout();
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _activityRow(String label, {String? value, Widget? badge, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          badge ?? trailing ?? Text(value ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);

  Widget _profileField(String label, {TextEditingController? controller, String? initialValue, String? hint, String? note, bool enabled = true, int maxLines = 1, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: enabled,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 14, color: enabled ? const Color(0xFF1E293B) : Colors.grey.shade500),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ],
    );
  }

  Widget _passwordField(String label, TextEditingController controller, bool obscure, VoidCallback toggle, {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: Colors.grey),
              onPressed: toggle,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
