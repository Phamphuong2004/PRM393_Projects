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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/app/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go('/');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider),
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(authProvider.user?['fullName'] ?? 'User'),
            accountEmail: Text(authProvider.user?['email'] ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (authProvider.user?['fullName'] ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 24, color: AppColors.primary),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Following'),
            onTap: () {
              context.pop();
              context.go('/app/following');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile Settings'),
            onTap: () {
              context.pop();
              context.go('/app/profile');
            },
          ),
          const Divider(),
          if (authProvider.isAdmin) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text('Admin', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: const Text('User Management'),
              onTap: () {
                context.pop();
                context.go('/app/admin/users');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Analytics Reports'),
              onTap: () {
                context.pop();
                context.go('/app/admin/analytics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('System Settings'),
              onTap: () {
                context.pop();
                context.go('/app/admin/settings');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    // Determine selected index based on current location
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/app/search')) {
      currentIndex = 1;
    } else if (location.startsWith('/app/trending')) {
      currentIndex = 2;
    } else if (location.startsWith('/app/bookmarks')) {
      currentIndex = 3;
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/app');
            break;
          case 1:
            context.go('/app/search');
            break;
          case 2:
            context.go('/app/trending');
            break;
          case 3:
            context.go('/app/bookmarks');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_outlined),
          activeIcon: Icon(Icons.trending_up),
          label: 'Trending',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          activeIcon: Icon(Icons.bookmark),
          label: 'Bookmarks',
        ),
      ],
    );
  }
}
