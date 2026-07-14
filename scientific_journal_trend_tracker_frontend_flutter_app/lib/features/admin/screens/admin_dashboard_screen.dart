import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/repositories/system_repository.dart';
import '../../../core/repositories/analysis_run_repository.dart';
import '../../../core/services/api.dart';
import '../../../core/models/sync_log.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _totalSources = 0;
  int _totalAnalysisRuns = 0;
  SyncLog? _latestSyncLog;
  List<SyncLog> _recentSyncLogs = [];
  List<dynamic> _recentAnalysisRuns = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAdminStats();
  }

  Future<void> _fetchAdminStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userRepo = ref.read(userRepositoryProvider);
      final systemRepo = ref.read(systemRepositoryProvider);
      final analysisRepo = ref.read(analysisRunRepositoryProvider);

      // Fetch users count (retrieve page 1 with limit 1)
      final usersRes = await userRepo.getAllUsers(page: 1, limit: 1);
      final paginationUsers = usersRes['pagination'];
      _totalUsers = paginationUsers?['total'] ?? 0;

      // Fetch API sources list
      final sources = await systemRepo.getApiSources();
      _totalSources = sources.length;

      // Fetch Analysis runs (retrieve page 1 with limit 3 for overview)
      final analysisRes = await analysisRepo.getAnalysisRuns(page: 1, limit: 3);
      final paginationRuns = analysisRes['pagination'];
      _totalAnalysisRuns = paginationRuns?['total'] ?? 0;
      _recentAnalysisRuns = analysisRes['runs'] ?? [];

      // Fetch Sync logs (retrieve page 1 with limit 3)
      final syncLogsRes = await SyncLogsApi.list(page: 1, limit: 3);
      final List<dynamic> logsList = syncLogsRes['logs'] ?? [];
      _recentSyncLogs = logsList.map((item) => SyncLog.fromJson(item)).toList();
      
      if (_recentSyncLogs.isNotEmpty) {
        _latestSyncLog = _recentSyncLogs.first;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load system administrative metrics: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      final repo = ref.read(systemRepositoryProvider);
      await repo.triggerSync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual background sync process triggered successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
      // Wait a moment then refresh statistics
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _fetchAdminStats();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to trigger sync: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(dateStr).toLocal();
      final year = parsed.year;
      final month = parsed.month.toString().padLeft(2, '0');
      final day = parsed.day.toString().padLeft(2, '0');
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _fetchAdminStats,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32.0 : 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(isDesktop),
                      const SizedBox(height: 32),
                      if (_isLoading) ...[
                        const SizedBox(height: 100),
                        const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      ] else if (_error != null) ...[
                        _buildErrorCard(),
                      ] else ...[
                        _buildMetricsGrid(isDesktop),
                        const SizedBox(height: 32),
                        _buildQuickActions(isDesktop),
                        const SizedBox(height: 32),
                        _buildRecentOperations(isDesktop),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.gradientPremiumDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.glowShadow,
      ),
      padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'ADMIN SECURITY LEVEL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'System Control Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor external database crawlers, execute Trend Analytics engines, manage access roles, and audit background processes.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 24),
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : _triggerSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              icon: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(_isSyncing ? 'Syncing...' : 'Sync Database'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAdminStats,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(bool isDesktop) {
    String syncStatusStr = 'No logs';
    Color syncColor = AppColors.textSecondary;
    IconData syncIcon = Icons.help_outline_rounded;

    if (_latestSyncLog != null) {
      syncStatusStr = _latestSyncLog!.status.toUpperCase();
      if (_latestSyncLog!.status == 'success') {
        syncColor = AppColors.success;
        syncIcon = Icons.check_circle_outline_rounded;
      } else if (_latestSyncLog!.status == 'failed') {
        syncColor = AppColors.error;
        syncIcon = Icons.error_outline_rounded;
      } else if (_latestSyncLog!.status == 'running') {
        syncColor = AppColors.primaryLight;
        syncIcon = Icons.sync;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int columns = width > 900 ? 4 : (width > 550 ? 2 : 1);
        final double itemWidth = (width - (columns - 1) * 16) / columns;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildMetricCard(
              width: itemWidth,
              title: 'Registered Users',
              value: _totalUsers.toString(),
              subtitle: 'Active system accounts',
              icon: Icons.people_alt_rounded,
              color: AppColors.primary,
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildMetricCard(
              width: itemWidth,
              title: 'Data Sources',
              value: _totalSources.toString(),
              subtitle: 'Indexed databases',
              icon: Icons.source_rounded,
              color: AppColors.secondary,
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildMetricCard(
              width: itemWidth,
              title: 'Trend Analysis Runs',
              value: _totalAnalysisRuns.toString(),
              subtitle: 'Executed model tasks',
              icon: Icons.query_stats_rounded,
              color: AppColors.accent,
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildMetricCard(
              width: itemWidth,
              title: 'System Scheduler',
              value: syncStatusStr,
              subtitle: _latestSyncLog != null 
                  ? 'Last: ${_formatDateTime(_latestSyncLog!.startedAt.toIso8601String())}'
                  : 'No execution records',
              icon: syncIcon,
              color: syncColor,
              gradient: LinearGradient(
                colors: [syncColor.withValues(alpha: 0.8), syncColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: value.length > 10 ? 18 : 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Administrative Controls',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final int columns = width > 900 ? 4 : (width > 550 ? 2 : 1);
            final double itemWidth = (width - (columns - 1) * 16) / columns;
            
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionCard(
                  width: itemWidth,
                  title: 'User Management',
                  description: 'Roles, registration validation & status controls',
                  icon: Icons.manage_accounts_rounded,
                  color: AppColors.primary,
                  route: '/app/admin/users',
                ),
                _buildActionCard(
                  width: itemWidth,
                  title: 'API Sources Settings',
                  description: 'Configure journal web crawlers & thresholds',
                  icon: Icons.settings_input_component_rounded,
                  color: AppColors.secondary,
                  route: '/app/admin/settings',
                ),
                _buildActionCard(
                  width: itemWidth,
                  title: 'Trend Analysis Runs',
                  description: 'Schedule, run & analyze keyword trends',
                  icon: Icons.insights_rounded,
                  color: AppColors.accent,
                  route: '/app/admin/analytics',
                ),
                _buildActionCard(
                  width: itemWidth,
                  title: 'Background Sync Logs',
                  description: 'View full scheduler sync history & diagnostics',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.error,
                  route: '/app/admin/sync-logs',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required double width,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(20),
        hoverColor: color.withValues(alpha: 0.03),
        splashColor: color.withValues(alpha: 0.05),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOperations(bool isDesktop) {
    final bodyWidgets = [
      Expanded(
        flex: isDesktop ? 1 : 0,
        child: _buildRecentSyncSection(),
      ),
      if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
      Expanded(
        flex: isDesktop ? 1 : 0,
        child: _buildRecentAnalysisSection(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activities',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: bodyWidgets,
          )
        else
          Column(
            children: bodyWidgets.map((e) => e is Expanded ? e.child : e).toList(),
          ),
      ],
    );
  }

  Widget _buildRecentSyncSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Background Sync History',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () => context.push('/app/admin/sync-logs'),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.border),
          if (_recentSyncLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No background sync activities found', style: TextStyle(color: AppColors.textLight)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSyncLogs.length,
              separatorBuilder: (context, index) => const Divider(height: 12, color: AppColors.border),
              itemBuilder: (context, index) {
                final log = _recentSyncLogs[index];
                
                Color statusColor = AppColors.textLight;
                if (log.status == 'success') statusColor = AppColors.success;
                if (log.status == 'failed') statusColor = AppColors.error;
                if (log.status == 'running') statusColor = AppColors.primaryLight;

                final duration = log.finishedAt?.difference(log.startedAt);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log.status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (log.sourceName == 'Source ID: null' || log.sourceName.isEmpty)
                                  ? 'System Scheduler'
                                  : log.sourceName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Start: ${_formatDateTime(log.startedAt.toIso8601String())}',
                              style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (duration != null)
                        Text(
                          '${duration.inSeconds}s',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentAnalysisSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Trend Runs',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () => context.push('/app/admin/analytics'),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(height: 16, color: AppColors.border),
          if (_recentAnalysisRuns.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No trend analysis runs found', style: TextStyle(color: AppColors.textLight)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentAnalysisRuns.length,
              separatorBuilder: (context, index) => const Divider(height: 12, color: AppColors.border),
              itemBuilder: (context, index) {
                final run = _recentAnalysisRuns[index];
                
                String keyword = 'Unknown Keyword';
                if (run['seedKeyword'] != null) {
                  keyword = run['seedKeyword'].toString();
                } else if (run['keywordId'] != null) {
                  if (run['keywordId'] is Map) {
                    keyword = (run['keywordId']['name'] ?? run['keywordId']['keyword'] ?? '').toString();
                  } else {
                    keyword = run['keywordId'].toString();
                  }
                }
                if (keyword.isEmpty) {
                  keyword = 'Unknown Keyword';
                }

                final source = run['source'] ?? 'All Databases';
                final status = (run['status'] ?? 'pending').toString().toLowerCase();

                Color statusColor = AppColors.textLight;
                if (status == 'completed' || status == 'success') statusColor = AppColors.success;
                if (status == 'failed') statusColor = AppColors.error;
                if (status == 'running' || status == 'processing') statusColor = AppColors.primaryLight;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              keyword,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'DB: $source | Range: ${run['startYear']}-${run['endYear']}',
                              style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
