import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/paper.dart';
import '../../../core/models/keyword.dart';
import '../../../core/repositories/paper_repository.dart';
import '../../../core/repositories/keyword_repository.dart';
import '../../../core/repositories/dashboard_repository.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  List<Paper> _recentPapers = [];
  List<Keyword> _trendingKeywords = [];
  Map<String, dynamic>? _dashboardStats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final paperRepo = ref.read(paperRepositoryProvider);
      final keywordRepo = ref.read(keywordRepositoryProvider);
      final dashboardRepo = ref.read(dashboardRepositoryProvider);

      final results = await Future.wait([
        paperRepo.getPapers(page: 1, limit: 5),
        keywordRepo.getTrendingKeywords(limit: 10),
        dashboardRepo.getDashboardStats().catchError((_) => <String, dynamic>{}),
      ]);
      if (!mounted) return;
      setState(() {
        _recentPapers = (results[0] as Map)['papers'] as List<Paper>? ?? [];
        _trendingKeywords = results[1] as List<Keyword>? ?? [];
        _dashboardStats = results[2] as Map<String, dynamic>?;
        if (_dashboardStats?.isEmpty ?? false) _dashboardStats = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user?['fullName'] ?? 'Researcher'}! 👋',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text('Here\'s your research dashboard overview', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()))
          else if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error),
              ),
              child: Text(_error!, style: const TextStyle(color: AppColors.error)),
            )
          else ...[
            // Metrics Row
            Row(
              children: [
                _MetricCard(label: 'Total Papers', value: '${_recentPapers.length}', gradient: AppColors.gradientPrimary),
                const SizedBox(width: 12),
                _MetricCard(
                  label: 'Total Citations',
                  value: '${_recentPapers.fold<int>(0, (sum, p) => sum + p.citationCount)}',
                  gradient: AppColors.gradientPink,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetricCard(label: 'Trending Keywords', value: '${_trendingKeywords.length}', gradient: AppColors.gradientBlue),
                const SizedBox(width: 12),
                _MetricCard(label: 'Role', value: _normalizeRole(user?['role'] ?? 'User'), gradient: AppColors.gradientGreen),
              ],
            ),
            const SizedBox(height: 16),

            // Publication Timeline Chart
            if (_dashboardStats?['timelineData'] != null && (_dashboardStats!['timelineData'] as List).isNotEmpty) ...[
              _SectionHeader(title: '📈 Publication Timeline'),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: _buildLineChart(_dashboardStats!['timelineData'] as List),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Trending Keywords
            if (_trendingKeywords.isNotEmpty) ...[
              _SectionHeader(title: '🔥 Trending Keywords'),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _trendingKeywords.map<Widget>((kw) {
                      return Chip(
                        label: Text(kw.name),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recent Papers
            _SectionHeader(title: '📄 Recent Publications'),
            const SizedBox(height: 8),
            ..._recentPapers.map<Widget>((paper) => _PaperCard(paper: paper)),
          ],
        ],
      ),
    );
  }

  Widget _buildLineChart(List data) {
    final spots = data.asMap().entries.map((e) {
      final item = e.value;
      return FlSpot(e.key.toDouble(), ((item['paperCount'] ?? 0) as num).toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final idx = val.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Text('${data[idx]['year'] ?? ''}', style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  String _normalizeRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return 'Admin';
      case 'researcher': return 'Researcher';
      default: return 'User';
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final LinearGradient gradient;
  const _MetricCard({required this.label, required this.value, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }
}

class _PaperCard extends StatelessWidget {
  final Paper paper;
  const _PaperCard({required this.paper});

  @override
  Widget build(BuildContext context) {
    final title = paper.title;
    final journal = paper.journalId != null 
        ? (paper.journalId is Map ? paper.journalId['name'] : paper.journalId.toString()) 
        : 'Unknown journal';
    final year = paper.publicationYear?.toString() ?? '';
    final citations = paper.citationCount;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.book_outlined, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text('$journal • $year • $citations citations', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}

