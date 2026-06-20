import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: isDesktop 
          ? null 
          : AppBar(
              title: Text('Journal Trends', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                    onPressed: () => context.push('/app/notifications'),
                  ),
                ),
              ],
            ),
      drawer: isDesktop ? null : _buildPremiumDrawer(context, authProvider),
      body: isDesktop
          ? Row(
              children: [
                _buildDesktopSideMenu(context, authProvider),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), bottomLeft: Radius.circular(32)),
                    child: Container(
                      color: AppColors.bg,
                      child: child,
                    ),
                  ),
                ),
              ],
            )
          : child,
      bottomNavigationBar: isDesktop ? null : _buildModernBottomNav(context),
    );
  }

  Widget _buildDesktopSideMenu(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    final fullName = user?['fullName'] ?? 'User';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
    
    final String location = GoRouterState.of(context).matchedLocation;
    
    return Container(
      width: 280,
      color: AppColors.surface,
      child: Column(
        children: [
          // Branding & User Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.glowShadow),
                  alignment: Alignment.center,
                  child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text((user?['role'] ?? 'User').toString().toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildSideMenuItem(context, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded, '/app', location),
                _buildSideMenuItem(context, 'Workspaces', Icons.workspaces_outline, Icons.workspaces, '/app/workspaces', location),
                _buildSideMenuItem(context, 'Search Papers', Icons.search_outlined, Icons.search_rounded, '/app/search', location),
                _buildSideMenuItem(context, 'Trending', Icons.trending_up_rounded, Icons.trending_up_rounded, '/app/trending', location),
                _buildSideMenuItem(context, 'Bookmarks', Icons.bookmark_outline_rounded, Icons.bookmark_rounded, '/app/bookmarks', location),
                _buildSideMenuItem(context, 'Authors', Icons.people_outline_rounded, Icons.people_rounded, '/app/authors', location),
                
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: AppColors.border)),
                
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                  child: Text('PERSONAL', style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ),
                _buildSideMenuItem(context, 'Notifications', Icons.notifications_none_rounded, Icons.notifications_active_rounded, '/app/notifications', location),
                _buildSideMenuItem(context, 'Following', Icons.people_outline_rounded, Icons.people_rounded, '/app/following', location),
                _buildSideMenuItem(context, 'Profile Settings', Icons.person_outline_rounded, Icons.person_rounded, '/app/profile', location),
                
                if (authProvider.isAdmin) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: AppColors.border)),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text('ADMINISTRATION', style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  _buildSideMenuItem(context, 'User Management', Icons.manage_accounts_outlined, Icons.manage_accounts_rounded, '/app/admin/users', location),
                  _buildSideMenuItem(context, 'Analytics Reports', Icons.analytics_outlined, Icons.analytics_rounded, '/app/admin/analytics', location),
                  _buildSideMenuItem(context, 'Sync Logs', Icons.history_rounded, Icons.history_rounded, '/app/admin/sync-logs', location),
                  _buildSideMenuItem(context, 'System Settings', Icons.settings_outlined, Icons.settings_rounded, '/app/admin/settings', location),
                ],
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              ),
              title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              hoverColor: AppColors.error.withValues(alpha: 0.05),
              onTap: () {
                authProvider.logout();
                context.go('/');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenuItem(BuildContext context, String title, IconData icon, IconData activeIcon, String path, String currentLocation) {
    final isSelected = path == '/app' ? currentLocation == '/app' : currentLocation.startsWith(path);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.transparent,
        hoverColor: isSelected ? null : AppColors.bg,
        onTap: () => context.go(path),
      ),
    );
  }

  Widget _buildPremiumDrawer(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    final fullName = user?['fullName'] ?? 'User';
    final email = user?['email'] ?? '';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppColors.glowShadow),
                  alignment: Alignment.center,
                  child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _buildDrawerItem(context, icon: Icons.workspaces_outline, activeIcon: Icons.workspaces, title: 'Workspaces', path: '/app/workspaces'),
                _buildDrawerItem(context, icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, title: 'Following', path: '/app/following'),
                _buildDrawerItem(context, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, title: 'Profile Settings', path: '/app/profile'),
                _buildDrawerItem(context, icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, title: 'Authors', path: '/app/authors'),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.border)),
                
                if (authProvider.isAdmin) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                    child: Text('ADMINISTRATION', style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  _buildDrawerItem(context, icon: Icons.manage_accounts_outlined, activeIcon: Icons.manage_accounts_rounded, title: 'User Management', path: '/app/admin/users'),
                  _buildDrawerItem(context, icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, title: 'Analytics Reports', path: '/app/admin/analytics'),
                  _buildDrawerItem(context, icon: Icons.history_rounded, activeIcon: Icons.history_rounded, title: 'Sync Logs', path: '/app/admin/sync-logs'),
                  _buildDrawerItem(context, icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, title: 'System Settings', path: '/app/admin/settings'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.border)),
                ],
                
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  ),
                  title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () {
                    authProvider.logout();
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required IconData activeIcon, required String title, required String path}) {
    final location = GoRouterState.of(context).matchedLocation;
    final isSelected = location.startsWith(path);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.transparent,
        onTap: () {
          context.pop();
          context.go(path);
        },
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/app/workspaces')) {
      currentIndex = 1;
    } else if (location.startsWith('/app/search')) {
      currentIndex = 2;
    } else if (location.startsWith('/app/trending')) {
      currentIndex = 3;
    } else if (location.startsWith('/app/bookmarks')) {
      currentIndex = 4;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppColors.glassShadow,
      ),
      child: NavigationBar(
        height: 80,
        selectedIndex: currentIndex,
        elevation: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/app'); break;
            case 1: context.go('/app/workspaces'); break;
            case 2: context.go('/app/search'); break;
            case 3: context.go('/app/trending'); break;
            case 4: context.go('/app/bookmarks'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.workspaces_outline), selectedIcon: Icon(Icons.workspaces), label: 'Workspaces'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search_rounded), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.trending_up_rounded), selectedIcon: Icon(Icons.trending_up_rounded), label: 'Trending'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline_rounded), selectedIcon: Icon(Icons.bookmark_rounded), label: 'Bookmarks'),
        ],
      ),
    );
  }
}
