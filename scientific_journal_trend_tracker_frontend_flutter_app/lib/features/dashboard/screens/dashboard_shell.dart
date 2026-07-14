import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/notification_provider.dart';

class DashboardShell extends ConsumerWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(notificationProvider, (previous, next) {
      if (previous != null && next.latestNotification != null && next.latestNotification != previous.latestNotification) {
        final newNotif = next.latestNotification;
        final title = newNotif is Map ? newNotif['title'] : (newNotif as dynamic).title;
        final message = newNotif is Map ? newNotif['message'] : (newNotif as dynamic).message;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title?.toString() ?? 'New Notification', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                if (message != null)
                  Text(message.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: Colors.white,
              onPressed: () => context.push('/app/notifications'),
            ),
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: isDesktop 
          ? null 
          : AppBar(
              title: InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Journal Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final unreadCount = ref.watch(notificationProvider).unreadCount;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Badge(
                          isLabelVisible: unreadCount > 0,
                          label: Text(unreadCount.toString()),
                          child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                        ),
                        onPressed: () => context.push('/app/notifications'),
                        tooltip: 'Notifications',
                      ),
                    );
                  },
                ),
              ],
            ),
      drawer: isDesktop ? null : _buildPremiumDrawer(context, authState, ref),
      body: isDesktop
          ? Row(
              children: [
                _buildDesktopSideMenu(context, authState, ref),
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
      bottomNavigationBar: isDesktop ? null : _buildModernBottomNav(context, authState),
      floatingActionButton: (isDesktop || authState.isAdmin) ? null : FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/app/chat'),
        elevation: 4,
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildDesktopSideMenu(BuildContext context, AuthState authState, WidgetRef ref) {
    final user = authState.user;
    final fullName = user?['fullName'] ?? 'User';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
    
    final String location = GoRouterState.of(context).matchedLocation;
    
    return Material(
      color: AppColors.surface,
      child: SizedBox(
        width: 280,
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
            child: Consumer(
              builder: (context, ref, child) {
                final unreadCount = ref.watch(notificationProvider).unreadCount;
                final badge = unreadCount > 0 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
                      child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ) 
                  : null;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  children: authState.isAdmin
                      ? [
                          _buildSideMenuItem(context, 'Overview Dashboard', Icons.dashboard_outlined, Icons.dashboard_rounded, '/app', location),
                          _buildSideMenuItem(context, 'Notifications', Icons.notifications_none_rounded, Icons.notifications_rounded, '/app/notifications', location, trailing: badge),
                          _buildSideMenuItem(context, 'User Management', Icons.manage_accounts_outlined, Icons.manage_accounts_rounded, '/app/admin/users', location),
                          _buildSideMenuItem(context, 'Trend Analysis', Icons.insights_outlined, Icons.insights_rounded, '/app/admin/analytics', location),
                          _buildSideMenuItem(context, 'API Sources Settings', Icons.settings_input_component_outlined, Icons.settings_input_component_rounded, '/app/admin/settings', location),
                          _buildSideMenuItem(context, 'Background Sync Logs', Icons.receipt_long_outlined, Icons.receipt_long_rounded, '/app/admin/sync-logs', location),
                          _buildSideMenuItem(context, 'Profile Settings', Icons.person_outline_rounded, Icons.person_rounded, '/app/profile', location),
                        ]
                      : [
                          _buildSideMenuItem(context, 'Workspaces', Icons.workspaces_outline, Icons.workspaces, '/app/workspaces', location),
                          _buildSideMenuItem(context, 'Notifications', Icons.notifications_none_rounded, Icons.notifications_rounded, '/app/notifications', location, trailing: badge),
                          _buildSideMenuItem(context, 'Profile Settings', Icons.person_outline_rounded, Icons.person_rounded, '/app/profile', location),
                        ],
                );
              },
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
                ref.read(authProvider.notifier).logout();
                context.go('/');
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSideMenuItem(BuildContext context, String title, IconData icon, IconData activeIcon, String path, String currentLocation, {Widget? trailing}) {
    final isSelected = path == '/app' ? currentLocation == '/app' : currentLocation.startsWith(path);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, fontSize: 15)),
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.transparent,
        hoverColor: isSelected ? null : AppColors.bg,
        onTap: () => context.go(path),
      ),
    );
  }

  Widget _buildPremiumDrawer(BuildContext context, AuthState authState, WidgetRef ref) {
    final user = authState.user;
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
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final unreadCount = ref.watch(notificationProvider).unreadCount;
                final badge = unreadCount > 0 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
                      child: Text(unreadCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ) 
                  : null;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  children: [
                    if (authState.isAdmin) ...[
                      _buildDrawerItem(context, icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, title: 'Overview Dashboard', path: '/app'),
                      _buildDrawerItem(context, icon: Icons.notifications_none_rounded, activeIcon: Icons.notifications_rounded, title: 'Notifications', path: '/app/notifications', trailing: badge),
                      _buildDrawerItem(context, icon: Icons.manage_accounts_outlined, activeIcon: Icons.manage_accounts_rounded, title: 'User Management', path: '/app/admin/users'),
                      _buildDrawerItem(context, icon: Icons.insights_rounded, activeIcon: Icons.insights_rounded, title: 'Trend Analysis', path: '/app/admin/analytics'),
                      _buildDrawerItem(context, icon: Icons.settings_input_component_outlined, activeIcon: Icons.settings_input_component_rounded, title: 'API Sources Settings', path: '/app/admin/settings'),
                      _buildDrawerItem(context, icon: Icons.receipt_long_rounded, activeIcon: Icons.receipt_long_rounded, title: 'Background Sync Logs', path: '/app/admin/sync-logs'),
                    ] else ...[
                      _buildDrawerItem(context, icon: Icons.workspaces_outline, activeIcon: Icons.workspaces, title: 'Workspaces', path: '/app/workspaces'),
                      _buildDrawerItem(context, icon: Icons.notifications_none_rounded, activeIcon: Icons.notifications_rounded, title: 'Notifications', path: '/app/notifications', trailing: badge),
                    ],
                    _buildDrawerItem(context, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, title: 'Profile Settings', path: '/app/profile'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.border)),
                
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 15)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                ),
              ],
            );
          },
        ),
      ),
    ],
  ),
);
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required IconData activeIcon, required String title, required String path, Widget? trailing}) {
    final location = GoRouterState.of(context).matchedLocation;
    final isSelected = path == '/app' ? location == '/app' : location.startsWith(path);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: ListTile(
        leading: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
        title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, fontSize: 15)),
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        onTap: () {
          context.pop();
          context.go(path);
        },
      ),
    );
  }

  Widget _buildModernBottomNav(BuildContext context, AuthState authState) {
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

