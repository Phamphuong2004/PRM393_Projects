import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Trends'),
        actions: [
          TextButton(
            onPressed: () => context.go('/features'),
            child: const Text('Features'),
          ),
          TextButton(
            onPressed: () => context.go('/how-it-works'),
            child: const Text('How it Works'),
          ),
          if (isLoggedIn)
            ElevatedButton(
              onPressed: () => context.go('/app'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Dashboard'),
            )
          else ...[
            TextButton(
              onPressed: () => context.push('/auth/login'),
              child: const Text('Login'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => context.push('/auth/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Up'),
              ),
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientPrimary,
              ),
              child: Column(
                children: [
                  const Text(
                    'Track Scientific Trends\nwith Precision',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Discover emerging research, monitor key publications, and stay ahead in your field with our AI-powered trend analysis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      if (isLoggedIn) {
                        context.go('/app');
                      } else {
                        context.push('/auth/register');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(isLoggedIn ? 'Go to Dashboard' : 'Get Started Free'),
                  ),
                ],
              ),
            ),
            // Add more marketing sections here like web's HomePage
          ],
        ),
      ),
    );
  }
}
