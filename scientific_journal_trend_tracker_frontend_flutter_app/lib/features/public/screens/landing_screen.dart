import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/animated_background.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light slate background
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 120, // Approximate height minus header
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: _buildMainContent(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isDesktop ? null : _buildModernBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Section
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Text(
                    'Journal Trends',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Actions Section
          Row(
            children: [
              TextButton(
                onPressed: () => context.go('/auth/login'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => context.go('/auth/register'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // Glassmorphism blur
        child: Container(
          width: isDesktop ? 800 : screenWidth * 0.9,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 60.0 : 24.0,
            vertical: isDesktop ? 80.0 : 40.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4), // Glassmorphism tint
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6), 
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI-Powered Scientific Tracker 2.0',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Gradient Text
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF8B5CF6)], // Blue to Purple gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Track Scientific\nTrends\nwith Absolute\nPrecision',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, // Needs to be white for ShaderMask
                    fontSize: isDesktop ? 56 : 42,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Subheading
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                child: const Text(
                  'Discover emerging research, monitor key publications, and stay ahead in your field with our real-time trend analysis and intelligent tracking algorithms.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Get Started Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => context.go('/auth/login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.glassShadow,
      ),
      child: NavigationBar(
        height: 80,
        selectedIndex: 0,
        elevation: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: break;
            case 1: context.go('/app/workspaces'); break;
            case 2: context.go('/app/trending'); break;
            case 3: context.go('/app/bookmarks'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.workspaces_outline), selectedIcon: Icon(Icons.workspaces), label: 'Workspaces'),
          NavigationDestination(icon: Icon(Icons.trending_up_rounded), selectedIcon: Icon(Icons.trending_up_rounded), label: 'Trending'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline_rounded), selectedIcon: Icon(Icons.bookmark_rounded), label: 'Bookmarks'),
        ],
      ),
    );
  }
}
