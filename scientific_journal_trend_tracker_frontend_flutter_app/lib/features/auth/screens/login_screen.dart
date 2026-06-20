import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().login(email, password);
      if (mounted) {
        context.go('/app');
      }
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Dynamic animated background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gradientPrimary,
              ),
            ),
          ),
          // Floating orbs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.3),
                    AppColors.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          
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
          
          Positioned(
            top: 40,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.canPop() ? context.pop() : context.go('/'),
            ),
          ),
        ],
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: AppColors.glowShadow,
            ),
            child: const Icon(Icons.analytics_rounded, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(
            'Journal Trends',
            style: TextStyle(
              fontSize: isDesktop ? 56 : 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
              height: 1.1,
            ),
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'Your gateway to tracking scientific discoveries and emerging research trends in real-time.',
            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassForm(bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 24),
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppColors.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 48 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sign in to continue your research journey.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              
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
                controller: _emailController,
                label: 'Email Address',
                hint: 'name@example.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
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
              ),
              
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500)),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => context.pushReplacement('/auth/register'),
                    child: const Text('Sign Up Free', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            suffixIcon: suffixIcon,
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8)),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
