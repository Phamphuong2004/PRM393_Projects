import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isDesktop),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroSection(context, isDesktop),
                _buildFeaturesSection(context, isDesktop),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDesktop) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      scrolledUnderElevation: 10,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            'Journal Trends',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        if (isDesktop) ...[ 
          TextButton(onPressed: () {}, child: const Text('Features', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          const SizedBox(width: 16),
          TextButton(onPressed: () {}, child: const Text('How it Works', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
          const SizedBox(width: 24),
          TextButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.go('/auth/register'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Up Free'),
          ),
          const SizedBox(width: 40),
        ] else ...[ 
          // Mobile: compact icon button for login + small sign up
          IconButton(
            onPressed: () => context.go('/auth/login'),
            icon: const Icon(Icons.login_rounded, color: AppColors.primary),
            tooltip: 'Log In',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () => context.go('/auth/register'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: isDesktop ? 80 : 40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glows
          Positioned(
            left: isDesktop ? -100 : -50,
            top: 0,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: isDesktop ? -50 : -20,
            bottom: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text('AI-Powered Scientific Tracker 2.0', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Track Scientific Trends\nwith Absolute Precision',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: isDesktop ? 64 : 40,
                  height: 1.1,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                child: Text(
                  'Discover emerging research, monitor key publications, and stay ahead in your field with our real-time trend analysis and intelligent tracking algorithms.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/auth/register'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 32, vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppColors.primary,
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    child: Text('Get Started Free', style: TextStyle(fontSize: isDesktop ? 18 : 16, fontWeight: FontWeight.bold)),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppColors.border, width: 2),
                      ),
                      child: const Text('View Live Demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 80),
              // Dashboard Mockup Image
              Container(
                width: isDesktop ? 900 : double.infinity,
                height: isDesktop ? 500 : 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // Fake Browser/App Header
                      Container(
                        height: 40,
                        color: AppColors.bg,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Row(
                              children: [
                                CircleAvatar(radius: 6, backgroundColor: Colors.redAccent),
                                SizedBox(width: 8),
                                CircleAvatar(radius: 6, backgroundColor: Colors.amber),
                                SizedBox(width: 8),
                                CircleAvatar(radius: 6, backgroundColor: Colors.green),
                              ],
                            ),
                            const Spacer(),
                            Container(width: 200, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
                            const Spacer(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(color: AppColors.bg),
                            // Fake content lines
                            Positioned(top: 40, left: 40, child: Container(width: 200, height: 30, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(8)))),
                            Positioned(top: 100, left: 40, right: 40, child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Container(height: 120, decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(16)))),
                                const SizedBox(width: 20),
                                Expanded(child: Container(height: 120, decoration: BoxDecoration(gradient: AppColors.gradientSecondary, borderRadius: BorderRadius.circular(16)))),
                              ],
                            )),
                            Positioned(top: 250, left: 40, right: 40, child: Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20, vertical: 80),
      color: AppColors.bg,
      child: Column(
        children: [
          Text(
            'Everything you need to stay ahead',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Powerful tools designed specifically for researchers, academics, and data scientists.',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _FeatureCard(
                icon: Icons.auto_graph_rounded,
                title: 'Trend Analysis',
                description: 'Visualize keyword usage over time to spot emerging research topics before they go mainstream.',
                color: AppColors.primaryLight,
              ),
              _FeatureCard(
                icon: Icons.notifications_active_rounded,
                title: 'Real-time Alerts',
                description: 'Get notified instantly when new papers are published matching your exact research interests.',
                color: AppColors.accent,
              ),
              _FeatureCard(
                icon: Icons.library_books_rounded,
                title: 'Smart Bookmarks',
                description: 'Organize your reading list with AI-generated tags, summaries, and citation tracking.',
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: AppColors.primaryDark,
      child: const Column(
        children: [
          Text('© 2026 Scientific Journal Trend Tracker. All rights reserved.', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({required this.icon, required this.title, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}
