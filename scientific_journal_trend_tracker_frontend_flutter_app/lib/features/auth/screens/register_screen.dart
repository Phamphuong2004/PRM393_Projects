import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/models/institution.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/institution_repository.dart';
import '../../../core/widgets/animated_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'researcher';
  int _passwordScore = 0;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  List<Institution> _institutions = [];
  String? _selectedInstitution;
  bool _loadingInstitutions = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  Future<void> _loadInstitutions() async {
    try {
      final repo = ref.read(institutionRepositoryProvider);
      final list = await repo.getInstitutions();
      if (mounted) {
        setState(() {
          _institutions = list;
          _loadingInstitutions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingInstitutions = false);
    }
  }

  // Tính độ mạnh mật khẩu: 0..4 dựa trên độ dài và độ đa dạng ký tự.
  int _calcPasswordScore(String password) {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final institution = _selectedInstitution;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    if (_calcPasswordScore(password) < 2) {
      setState(() => _errorMessage =
          'Password is too weak. Use at least 8 characters with letters, numbers or symbols.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().register(
        email,
        password,
        fullName,
        role: _selectedRole,
        institution: institution,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBackground(
        child: Stack(
          children: [
          
          SafeArea(
            child: Center(
              child: isDesktop
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: _buildVisualPanel(isDesktop)),
                        Expanded(child: _buildGlassForm(isDesktop)),
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildVisualPanel(isDesktop),
                            const SizedBox(height: 32),
                            _buildGlassForm(isDesktop),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          
          Positioned(
            top: 40,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildVisualPanel(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: const Icon(Icons.person_add_rounded, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            'Join Us',
            style: TextStyle(
              fontSize: isDesktop ? 56 : 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
              height: 1.1,
            ),
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Create an account to start bookmarking papers, tracking trends, and receiving real-time alerts.',
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassForm(bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 12),
      constraints: const BoxConstraints(maxWidth: 450),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 48 : 28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get started with a free account today.',
                  style: TextStyle(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 36),
                
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name *',
                  hint: 'Dr. Jane Doe',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address *',
                  hint: 'jane@university.edu',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password *',
                  hint: 'Create a strong password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: (value) =>
                      setState(() => _passwordScore = _calcPasswordScore(value)),
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildPasswordStrength(),
                ],
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password *',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_reset_rounded,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (_confirmPasswordController.text.isNotEmpty &&
                    _confirmPasswordController.text != _passwordController.text) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Passwords do not match',
                    style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 24),
                _buildInstitutionSelector(),
                const SizedBox(height: 24),
                _buildRoleSelector(),

                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                  ),
                ),
                
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500)),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.pushReplacement('/auth/login'),
                      child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    const roles = <Map<String, String>>[
      {'value': 'researcher', 'label': 'Researcher'},
      {'value': 'student', 'label': 'Student'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Role *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondary, size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            items: roles
                .map((r) => DropdownMenuItem(value: r['value'], child: Text(r['label']!)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedRole = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstitutionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Institution (Optional)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        // Combobox: pick from the catalog OR type a custom institution.
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue value) {
            final names = _institutions.map((e) => e.name);
            if (value.text.isEmpty) return names;
            return names.where((n) => n.toLowerCase().contains(value.text.toLowerCase()));
          },
          onSelected: (value) => _selectedInstitution = value,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                onChanged: (v) {
                  final t = v.trim();
                  _selectedInstitution = t.isEmpty ? null : t;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.business_outlined, color: AppColors.textSecondary, size: 22),
                  hintText: _loadingInstitutions ? 'Loading...' : 'Select or type your institution',
                  hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240, maxWidth: 440),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Text(option, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStrength() {
    const labels = ['Very Weak', 'Weak', 'Fair', 'Good', 'Strong'];
    const colors = [
      AppColors.error,
      AppColors.error,
      Colors.orange,
      Colors.amber,
      Colors.green,
    ];
    final score = _passwordScore.clamp(0, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final active = i < score;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: active ? colors[score] : AppColors.textLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Strength: ${labels[score]}',
          style: TextStyle(color: colors[score], fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
              suffixIcon: suffixIcon,
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontWeight: FontWeight.w400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
