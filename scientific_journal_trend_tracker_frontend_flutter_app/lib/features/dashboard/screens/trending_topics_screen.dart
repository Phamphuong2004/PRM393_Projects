import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/theme.dart';
import '../../../core/services/api.dart';

class TrendingTopicsScreen extends StatefulWidget {
  const TrendingTopicsScreen({super.key});

  @override
  State<TrendingTopicsScreen> createState() => _TrendingTopicsScreenState();
}

class _TrendingTopicsScreenState extends State<TrendingTopicsScreen> {
  List<dynamic> _keywords = [];
  List<dynamic> _trends = [];
  bool _loading = true;
  String? _error;
  final Set<String> _followedKeywordIds = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    _loadFollowedKeywords();
  }

  String? _followTargetId(dynamic f) {
    final t = f['targetId'];
    if (t is Map) return t['_id']?.toString();
    return t?.toString();
  }

  Future<void> _loadFollowedKeywords() async {
    try {
      final follows = await FollowsApi.list();
      if (!mounted || follows is! List) return;
      setState(() {
        _followedKeywordIds
          ..clear()
          ..addAll(follows
              .where((f) => f['targetType'] == 'Keyword')
              .map(_followTargetId)
              .whereType<String>());
      });
    } catch (_) {
      // Non-blocking: keep current state if follows can't be loaded.
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _toggleFollowKeyword(dynamic kw) async {
    final id = kw['_id']?.toString();
    if (id == null) return;
    final name = kw['name'] ?? 'keyword';
    final alreadyFollowed = _followedKeywordIds.contains(id);
    try {
      if (alreadyFollowed) {
        await FollowsApi.unfollow(id);
        if (!mounted) return;
        setState(() => _followedKeywordIds.remove(id));
        _snack('Unfollowed "$name"', AppColors.textSecondary);
      } else {
        await FollowsApi.follow('Keyword', id);
        if (!mounted) return;
        setState(() => _followedKeywordIds.add(id));
        _snack('Following "$name"', AppColors.success);
      }
    } catch (e) {
      _snack('Action failed. Please try again.', AppColors.error);
    }
  }

  Future<void> _fetchData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        KeywordsApi.trending(limit: 20),
        TrendsApi.trendingList(),
      ]);
      if (!mounted) return;
      setState(() {
        _keywords = results[0] is List ? results[0] as List : [];
        _trends = results[1] is List ? results[1] as List : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  double _toDouble(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
              boxShadow: AppColors.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.insights_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trending Topics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                      SizedBox(height: 4),
                      Text('Real-time research trends and emerging keywords', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()))
          else if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.error)),
              child: Text(_error!, style: const TextStyle(color: AppColors.error)),
            )
          else ...[
            // Bar Chart
            if (_trends.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                  boxShadow: AppColors.softShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text('Publication Trends by Topic', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary, letterSpacing: -0.3)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (_trends.map((t) => _toDouble(t['paperCount'])).reduce((a, b) => a > b ? a : b)) * 1.2,
                            barGroups: _trends.asMap().entries.take(8).map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [BarChartRodData(toY: _toDouble(e.value['paperCount']), color: AppColors.primaryLight, width: 16, borderRadius: BorderRadius.circular(4))],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    final idx = val.toInt();
                                    if (idx < 0 || idx >= _trends.length) return const SizedBox();
                                    final name = (_trends[idx]['keyword']?['name'] ?? '${_trends[idx]['year'] ?? ''}') as String;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(name.length > 6 ? name.substring(0, 6) : name, style: const TextStyle(fontSize: 9), overflow: TextOverflow.ellipsis),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Emerging Keywords
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                boxShadow: AppColors.softShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text('Emerging Keywords', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary, letterSpacing: -0.3)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_keywords.isEmpty)
                      const Text('No trending keywords found.', style: TextStyle(color: AppColors.textSecondary))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _keywords.map<Widget>((kw) {
                          final score = kw['trendScore'];
                          final id = kw['_id']?.toString();
                          final followed = id != null && _followedKeywordIds.contains(id);
                          return GestureDetector(
                            onTap: id == null ? null : () => _toggleFollowKeyword(kw),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: followed ? AppColors.primary : AppColors.surface,
                                border: Border.all(color: followed ? AppColors.primary : AppColors.border),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: followed ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(kw['name'] ?? '', style: TextStyle(color: followed ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                      if (score != null) Text('Score: $score', style: TextStyle(color: followed ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    followed ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                    color: followed ? Colors.white : AppColors.primaryLight,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

