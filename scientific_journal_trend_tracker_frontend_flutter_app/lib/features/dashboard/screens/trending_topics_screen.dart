import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/theme.dart';
import '../../../core/services/api.dart';
import '../../../core/widgets/animated_background.dart';

class TrendingTopicsScreen extends StatefulWidget {
  const TrendingTopicsScreen({super.key});

  @override
  State<TrendingTopicsScreen> createState() => _TrendingTopicsScreenState();
}

class _TrendingTopicsScreenState extends State<TrendingTopicsScreen> {
  final TextEditingController _keywordController = TextEditingController();
  String _selectedSource = 'OpenAlex';
  int _startYear = 2018;
  
  bool _loading = false;
  String? _error;
  
  List<dynamic> _topKeywords = [];
  List<dynamic> _trends = [];
  List<dynamic> _extractedPublications = [];
  List<LineBarSpot>? _selectedSpots;

  // 10 distinctive colors for the multiline chart
  final List<Color> _lineColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _analyzeTrend() async {
    final keyword = _keywordController.text.trim();
    if (keyword.isEmpty) {
      _snack('Please enter a keyword', AppColors.error);
      return;
    }

    setState(() { 
      _loading = true; 
      _error = null;
      _topKeywords = [];
      _trends = [];
      _extractedPublications = [];
      _selectedSpots = null;
    });

    try {
      final source = _selectedSource == 'Local DB' ? 'Local' : 'OpenAlex';
      final response = await TrendsApi.analyzeRelated(keyword, source, _startYear);
      
      if (!mounted) return;
      setState(() {
        _topKeywords = response['topKeywords'] ?? [];
        _trends = response['trends'] ?? [];
        _extractedPublications = response['extractedPublications'] ?? [];
        _loading = false;
      });
      
      if (_topKeywords.isEmpty) {
        _snack('No related keywords found', AppColors.warning);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { 
        _error = e.toString(); 
        _loading = false; 
      });
      _snack('Analysis failed: $_error', AppColors.error);
    }
  }

  double _getMaxY() {
    double maxY = 0;
    for (var trend in _trends) {
      for (var kw in _topKeywords) {
        final kwName = kw['keyword'];
        final count = (trend[kwName] as num?)?.toDouble() ?? 0.0;
        if (count > maxY) maxY = count;
      }
    }
    return maxY == 0 ? 10 : maxY * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBackground(
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
                  child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Related Keywords Trend', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                      SizedBox(height: 4),
                      Text('Analyze frequency of related keywords over years', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Search Form
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    labelText: 'Primary Keyword',
                    hintText: 'e.g., machine learning',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _analyzeTrend(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSource,
                        decoration: InputDecoration(
                          labelText: 'Source',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: ['OpenAlex', 'Local DB'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSource = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _startYear,
                        decoration: InputDecoration(
                          labelText: 'Start Year',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: List.generate(20, (index) => 2005 + index).map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _startYear = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _analyzeTrend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Analyze', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error / Empty State
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error)),
              child: Text('Error: $_error', style: const TextStyle(color: AppColors.error)),
            )
          else if (!_loading && _trends.isEmpty && _topKeywords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.query_stats_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('Enter a keyword to analyze related trends', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  ],
                ),
              ),
            )
          // Chart Section
          else if (_trends.isNotEmpty && _topKeywords.isNotEmpty) ...[
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
                    const Text('Related Keywords Growth', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: _getMaxY(),
                          lineBarsData: _topKeywords.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final kwName = entry.value['keyword'];
                            final color = _lineColors[idx % _lineColors.length];
                            
                            return LineChartBarData(
                              spots: _trends.map<FlSpot>((trend) {
                                final year = (trend['year'] as num).toDouble();
                                final count = (trend[kwName] as num?)?.toDouble() ?? 0.0;
                                return FlSpot(year, count);
                              }).toList(),
                              isCurved: true,
                              color: color,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: color.withValues(alpha: 0.1),
                              ),
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toInt().toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12));
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(value.toInt().toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
                              left: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: (_getMaxY() / 5) > 0 ? (_getMaxY() / 5) : 1,
                            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border.withValues(alpha: 0.3), strokeWidth: 1, dashArray: [5, 5]),
                            getDrawingVerticalLine: (value) => FlLine(color: AppColors.border.withValues(alpha: 0.3), strokeWidth: 1, dashArray: [5, 5]),
                          ),
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: false,
                            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                              if (!event.isInterestedForInteractions || response == null || response.lineBarSpots == null) {
                                setState(() { _selectedSpots = null; });
                                return;
                              }
                              setState(() {
                                _selectedSpots = response.lineBarSpots;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Detail view for touched year
                    if (_selectedSpots != null && _selectedSpots!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Year: ${_selectedSpots!.first.x.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              children: _selectedSpots!.map((spot) {
                                final kwName = _topKeywords[spot.barIndex]['keyword'];
                                final color = _lineColors[spot.barIndex % _lineColors.length];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('$kwName: ${spot.y.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _topKeywords.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final kwName = entry.value['keyword'];
                        final color = _lineColors[idx % _lineColors.length];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(kwName, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Extracted Publications Section
            if (_extractedPublications.isNotEmpty) ...[
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
                          const Icon(Icons.library_books, color: AppColors.primary, size: 24),
                          const SizedBox(width: 8),
                          Text('Extracted Publications (${_extractedPublications.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Sample of the top 100 most-cited papers — for reference only. Frequencies and the chart above are computed over the full matched corpus.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _extractedPublications.length,
                        separatorBuilder: (context, index) => Divider(color: AppColors.border.withValues(alpha: 0.5)),
                        itemBuilder: (context, index) {
                          final pub = _extractedPublications[index];
                          final title = pub['title'] ?? 'Unknown Title';
                          final year = pub['publicationYear']?.toString() ?? 'N/A';
                          final citations = pub['citationCount']?.toString() ?? '0';
                          
                          // Handle author formatting carefully depending on API source
                          String authorsStr = 'Unknown Author';
                          final authors = pub['authors'];
                          if (authors != null && authors is List && authors.isNotEmpty) {
                            authorsStr = authors.map((a) => a['fullName'] ?? a['name'] ?? '').where((n) => n.toString().isNotEmpty).join(', ');
                            if (authorsStr.isEmpty) authorsStr = 'Unknown Author';
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primary)),
                                const SizedBox(height: 4),
                                Text(authorsStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text('Year: $year', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.format_quote_rounded, size: 14, color: AppColors.success),
                                          const SizedBox(width: 4),
                                          Text('$citations citations', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
      ),
    );
  }
}
