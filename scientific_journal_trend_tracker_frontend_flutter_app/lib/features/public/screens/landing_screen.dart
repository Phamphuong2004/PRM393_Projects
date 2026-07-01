import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(context),
                const SizedBox(height: 48),
                _buildMainContent(context),
              ],
            ),
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

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Decorative background circle
        Positioned(
          top: 0,
          child: Container(
            width: isDesktop ? 600 : screenWidth * 0.9,
            height: isDesktop ? 600 : screenWidth * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEFF6FF), // Light blue circle background
            ),
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 60.0 : 24.0,
            vertical: isDesktop ? 80.0 : 40.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
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
              // Main Headline
              Text(
                'Track Scientific\nTrends\nwith Absolute\nPrecision',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: isDesktop ? 56 : 42,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Search Bar
              Container(
                width: isDesktop ? 600 : double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ]
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search papers, authors, journals...',
                    hintStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        final value = _searchController.text;
                        if (value.trim().isNotEmpty) {
                          context.go('/search?q=${Uri.encodeComponent(value.trim())}');
                        } else {
                          context.go('/search');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      context.go('/search?q=${Uri.encodeComponent(value.trim())}');
                    } else {
                      context.go('/search');
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/auth/register'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
            ],
          ),
        ),
      ],
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
            case 0: break; // Stay on home page
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
