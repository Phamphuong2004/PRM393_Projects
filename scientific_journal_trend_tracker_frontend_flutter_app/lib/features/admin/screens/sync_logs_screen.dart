import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/models/sync_log.dart';
import '../../../core/services/api.dart';

class SyncLogsScreen extends StatefulWidget {
  const SyncLogsScreen({super.key});

  @override
  State<SyncLogsScreen> createState() => _SyncLogsScreenState();
}

class _SyncLogsScreenState extends State<SyncLogsScreen> {
  List<SyncLog> _logs = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = ''; // '' (All), 'running', 'success', 'failed'

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalLogs = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchSyncLogs();
  }

  Future<void> _fetchSyncLogs({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await SyncLogsApi.list(
        page: page,
        limit: _limit,
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
      );

      final List<dynamic> list = response['logs'] ?? [];
      final pagination = response['pagination'] ?? {};

      setState(() {
        _logs = list.map((item) => SyncLog.fromJson(item)).toList();
        _currentPage = pagination['page'] as int? ?? page;
        _totalPages = pagination['pages'] as int? ?? 1;
        _totalLogs = pagination['total'] as int? ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLog(String id) async {
    try {
      await SyncLogsApi.delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync log entry deleted'), backgroundColor: AppColors.success),
        );
      }
      _fetchSyncLogs(page: _currentPage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _purgeAllLogs() async {
    try {
      final res = await SyncLogsApi.clearAll();
      final count = res['deletedCount'] ?? 0;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cleared all logs ($count logs removed)'), backgroundColor: AppColors.success),
        );
      }
      _fetchSyncLogs(page: 1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purge failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showPurgeConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purge Sync Logs'),
        content: const Text('Are you sure you want to delete ALL sync logs? This operation is irreversible and will delete historical sync activity traces.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purgeAllLogs();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Purge All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogDetailDialog(SyncLog log) {
    String durationStr = 'N/A';
    if (log.finishedAt != null) {
      final difference = log.finishedAt!.difference(log.startedAt);
      durationStr = '${difference.inSeconds} seconds';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              _getStatusIcon(log.status, size: 24),
              const SizedBox(width: 12),
              const Text('Sync Log Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Source Name', log.sourceName),
                _buildDetailRow('Base URL', log.sourceBaseUrl.isEmpty ? 'N/A' : log.sourceBaseUrl),
                _buildDetailRow('Seed Keyword', log.seedKeyword ?? 'N/A'),
                _buildDetailRow('Status', log.status.toUpperCase(), 
                  color: log.status == 'success' 
                      ? AppColors.success 
                      : log.status == 'failed' 
                          ? AppColors.error 
                          : AppColors.primary
                ),
                const Divider(height: 24),
                _buildDetailRow('Papers Added', '${log.papersAdded}'),
                _buildDetailRow('Papers Skipped', '${log.papersSkipped}'),
                _buildDetailRow('Papers Updated', '${log.papersUpdated}'),
                const Divider(height: 24),
                _buildDetailRow('Started At', log.startedAt.toLocal().toString()),
                _buildDetailRow('Finished At', log.finishedAt?.toLocal().toString() ?? 'N/A'),
                _buildDetailRow('Duration', durationStr),
                if (log.status == 'failed' && log.errorMessage != null) ...[
                  const Divider(height: 24),
                  const Text('Error Message:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      log.errorMessage!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: () {
                Navigator.pop(context);
                _deleteLog(log.id);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(String status, {double size = 20}) {
    switch (status) {
      case 'success':
        return Icon(Icons.check_circle_rounded, color: AppColors.success, size: size);
      case 'failed':
        return Icon(Icons.error_rounded, color: AppColors.error, size: size);
      case 'running':
      default:
        return SizedBox(
          width: size - 4,
          height: size - 4,
          child: const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryLight),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync Execution Logs',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Track background paper harvesting events, errors, and database metrics.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showPurgeConfirmation,
                    icon: const Icon(Icons.cleaning_services_rounded, color: Colors.white),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    label: const Text('Clear Logs'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Logs', ''),
                    _buildFilterChip('Success', 'success'),
                    _buildFilterChip('Failed', 'failed'),
                    _buildFilterChip('Running', 'running'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main logs body
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                                const SizedBox(height: 16),
                                Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: () => _fetchSyncLogs(page: _currentPage), child: const Text('Retry')),
                              ],
                            ),
                          )
                        : _logs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history_rounded, color: AppColors.textLight, size: 64),
                                    const SizedBox(height: 16),
                                    const Text('No sync logs recorded', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    const Text('Historical harvesting logs will appear here once scheduler runs.', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () => _fetchSyncLogs(page: _currentPage),
                                      child: ListView.builder(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: _logs.length,
                                        itemBuilder: (context, index) {
                                          final log = _logs[index];
                                          return _buildLogCard(log);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPagination(),
                                ],
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _selectedStatus == status;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (val) {
          setState(() {
            _selectedStatus = status;
          });
          _fetchSyncLogs(page: 1);
        },
        selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
      ),
    );
  }

  Widget _buildLogCard(SyncLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => _showLogDetailDialog(log),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _getStatusIcon(log.status, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.sourceName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        Text(
                          log.startedAt.toLocal().toString().substring(11, 16), // HH:mm
                          style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.seedKeyword != null ? 'Keyword: "${log.seedKeyword}"' : 'API Schedule Run',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    // Stats Row
                    Row(
                      children: [
                        _buildStatBadge(Icons.add_rounded, AppColors.success, '+${log.papersAdded}'),
                        const SizedBox(width: 8),
                        _buildStatBadge(Icons.skip_next_rounded, AppColors.textSecondary, '${log.papersSkipped}'),
                        const SizedBox(width: 8),
                        _buildStatBadge(Icons.refresh_rounded, AppColors.primary, '${log.papersUpdated}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, Color color, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total $_totalLogs logs',
          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 1 ? () => _fetchSyncLogs(page: _currentPage - 1) : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_currentPage of $_totalPages',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < _totalPages ? () => _fetchSyncLogs(page: _currentPage + 1) : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
