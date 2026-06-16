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

  @override
  void initState() {
    super.initState();
    _fetchData();
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📊 Trending Topics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 4),
                Text('Real-time research trends and emerging keywords', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📈 Publication Trends by Topic', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF4FACFE))),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (_trends.map((t) => _toDouble(t['paperCount'])).reduce((a, b) => a > b ? a : b)) * 1.2,
                            barGroups: _trends.asMap().entries.take(8).map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [BarChartRodData(toY: _toDouble(e.value['paperCount']), color: AppColors.secondary, width: 16, borderRadius: BorderRadius.circular(4))],
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
              const SizedBox(height: 16),
            ],

            // Emerging Keywords
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚡ Emerging Keywords', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF43E97B))),
                    const SizedBox(height: 12),
                    if (_keywords.isEmpty)
                      const Text('No trending keywords found.', style: TextStyle(color: AppColors.textSecondary))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _keywords.map<Widget>((kw) {
                          final score = kw['trendScore'];
                          return GestureDetector(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF43E97B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(kw['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  if (score != null) Text('Score: $score', style: const TextStyle(color: Colors.white70, fontSize: 10)),
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

