
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

// Public Screens
import '../../features/public/screens/landing_screen.dart';
import '../../features/public/screens/features_screen.dart';
import '../../features/public/screens/how_it_works_screen.dart';
import '../../features/public/screens/reviews_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

// Dashboard Screens
import '../../features/dashboard/screens/dashboard_shell.dart';
import '../../features/dashboard/screens/home_dashboard_screen.dart';
import '../../features/dashboard/screens/search_papers_screen.dart';
import '../../features/dashboard/screens/trending_topics_screen.dart';
import '../../features/dashboard/screens/bookmarks_screen.dart';
import '../../features/dashboard/screens/following_screen.dart';
import '../../features/dashboard/screens/notifications_screen.dart';
import '../../features/dashboard/screens/profile_settings_screen.dart';
import '../../features/dashboard/screens/authors_screen.dart';
import '../../features/dashboard/screens/journals_screen.dart';
import '../../features/dashboard/screens/topics_screen.dart';

// Workspace Screens
import '../../features/workspaces/screens/workspace_list_screen.dart';
import '../../features/workspaces/screens/workspace_detail_screen.dart';
import '../../features/workspaces/screens/upload_pdf_screen.dart';

// Admin Screens
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/analytics_report_screen.dart';
import '../../features/admin/screens/sync_logs_screen.dart';
import '../../features/admin/screens/system_settings_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final location = state.matchedLocation;
        final isAuthRoute = location.startsWith('/auth');
        final isAppRoute = location.startsWith('/app');

        if (authProvider.isLoading) return null;

        // If authenticated, prevent access to auth routes and the root landing page
        if (isAuthenticated && (isAuthRoute || location == '/')) {
          return '/app';
        }

        // If unauthenticated, prevent access to app routes
        if (!isAuthenticated && isAppRoute) {
          return '/auth/login';
        }

        // Admin-only route protection
        if (location.startsWith('/app/admin') && !authProvider.isAdmin) {
          return '/app';
        }

        return null;
      },
      routes: [
        // Public Flow
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) {
            final q = state.uri.queryParameters['q'];
            return SearchPapersScreen(initialQuery: q, isPublic: true);
          },
        ),
        GoRoute(
          path: '/features',
          builder: (context, state) => const FeaturesScreen(),
        ),
        GoRoute(
          path: '/how-it-works',
          builder: (context, state) => const HowItWorksScreen(),
        ),
        GoRoute(
          path: '/reviews',
          builder: (context, state) => const ReviewsScreen(),
        ),

        // Auth Flow
        GoRoute(
          path: '/auth/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Dashboard Flow (Authenticated)
        ShellRoute(
          builder: (context, state, child) {
            return DashboardShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/app',
              builder: (context, state) => const HomeDashboardScreen(),
            ),
            GoRoute(
              path: '/app/search',
              builder: (context, state) {
                final workspaceId = state.uri.queryParameters['workspaceId'];
                return SearchPapersScreen(workspaceId: workspaceId);
              },
            ),
            GoRoute(
              path: '/app/trending',
              builder: (context, state) => const TrendingTopicsScreen(),
            ),
            GoRoute(
              path: '/app/bookmarks',
              builder: (context, state) => const BookmarksScreen(),
            ),
            GoRoute(
              path: '/app/following',
              builder: (context, state) => const FollowingScreen(),
            ),
            GoRoute(
              path: '/app/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
            GoRoute(
              path: '/app/profile',
              builder: (context, state) => const ProfileSettingsScreen(),
            ),
            GoRoute(
              path: '/app/authors',
              builder: (context, state) => const AuthorsScreen(),
            ),
            GoRoute(
              path: '/app/journals',
              builder: (context, state) => const JournalsScreen(),
            ),
            GoRoute(
              path: '/app/topics',
              builder: (context, state) => const TopicsScreen(),
            ),
            // Workspaces Routes
            GoRoute(
              path: '/app/workspaces',
              builder: (context, state) => const WorkspaceListScreen(),
            ),
            GoRoute(
              path: '/app/workspaces/:workspaceId',
              builder: (context, state) {
                final workspaceId = state.pathParameters['workspaceId']!;
                return WorkspaceDetailScreen(workspaceId: workspaceId);
              },
            ),
            GoRoute(
              path: '/app/workspaces/:workspaceId/papers/:paperId/upload-pdf',
              builder: (context, state) {
                final workspaceId = state.pathParameters['workspaceId']!;
                final paperId = state.pathParameters['paperId']!;
                return UploadPdfScreen(
                  workspaceId: workspaceId,
                  paperId: paperId,
                );
              },
            ),
            // Admin Routes
            GoRoute(
              path: '/app/admin/users',
              builder: (context, state) => const UserManagementScreen(),
            ),
            GoRoute(
              path: '/app/admin/analytics',
              builder: (context, state) => const AnalyticsReportScreen(),
            ),
            GoRoute(
              path: '/app/admin/sync-logs',
              builder: (context, state) => const SyncLogsScreen(),
            ),
            GoRoute(
              path: '/app/admin/settings',
              builder: (context, state) => const SystemSettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

