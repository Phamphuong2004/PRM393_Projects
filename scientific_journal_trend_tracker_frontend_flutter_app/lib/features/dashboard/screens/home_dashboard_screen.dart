import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/dashboard_repository.dart';
import '../../../core/repositories/paper_repository.dart';
import '../../../core/models/paper.dart';
import '../../../core/repositories/keyword_repository.dart';
import 'package:provider/provider.dart' as prov;

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _dashboardStats;
  List<dynamic> _recentPapers = [];
  List<dynamic> _trendingKeywords = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final dashboardRepo = ref.read(dashboardRepositoryProvider);
      final paperRepo = ref.read(paperRepositoryProvider);
      final keywordRepo = ref.read(keywordRepositoryProvider);

      final results = await Future.wait([
        dashboardRepo.getDashboardStats(),
        paperRepo.getPapers(page: 1, limit: 5),
        keywordRepo.getTrendingKeywords(limit: 5),
      ]);

      setState(() {
        _dashboardStats = Map<String, dynamic>.from(results[0] as Map);
        _recentPapers = (results[1] as Map)['papers'] ?? [];
        _trendingKeywords = results[2] as List;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = 'Failed to load dashboard data. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = prov.Provider.of<AuthProvider>(context).user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: AppColors.primary,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildSliverHeader(user, isDesktop),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 24.0,
                      ),
                      child: _buildDashboardContent(user, isDesktop),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(Map<String, dynamic>? user, bool isDesktop) {
    final firstName =
        user?['fullName']?.toString().split(' ').first ?? 'Researcher';

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          'Welcome back,\n$firstName.',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            height: 1.2,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gradientPrimary,
              ),
            ),
            // Decorative geometric shapes for scientific feel
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(int totalPapers, int totalCitations, bool isDesktop, Map<String, dynamic>? user) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _AnimatedMetricCard(
          title: 'Total Papers',
          value: totalPapers,
          icon: Icons.article_rounded,
          gradient: AppColors.gradientPrimary,
        ),
        _AnimatedMetricCard(
          title: 'Total Citations',
          value: totalCitations,
          icon: Icons.format_quote_rounded,
          gradient: AppColors.gradientSecondary,
        ),
        _AnimatedMetricCard(
          title: 'Trending Topics',
          value: _trendingKeywords.length,
          icon: Icons.local_fire_department_rounded,
          gradient: AppColors.gradientTrend,
        ),
        _AnimatedMetricCard(
          title: 'Account Role',
          value: 0,
          stringValue: _normalizeRole(user?['role'] ?? 'User'),
          icon: Icons.shield_rounded,
          gradient: AppColors.gradientPremiumDark,
        ),
      ],
    );
  }

  Widget _buildDashboardContent(Map<String, dynamic>? user, bool isDesktop) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
          ],
        ),
      );
    }

    final totalPapers = _dashboardStats?['totalPapers'] ?? _recentPapers.length;
    final totalCitations = _recentPapers.fold<int>(
      0,
      (sum, p) {
        if (sum == null) return 0; // fallback just in case
        if (p is Paper) {
          return sum + p.citationCount;
        } else if (p is Map) {
          final cit = p['citationCount'];
          return sum + ((cit is num) ? cit.toInt() : 0);
        }
        return sum;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsGrid(totalPapers, totalCitations, isDesktop, user),
        const SizedBox(height: 32),

        // Chart Section
        if (_dashboardStats?['timelineData'] != null &&
            (_dashboardStats!['timelineData'] as List).isNotEmpty) ...[
          _SectionHeader(
            title: 'Publication Timeline',
            icon: Icons.insights_rounded,
          ),
          const SizedBox(height: 16),
          _buildChartCard(),
          const SizedBox(height: 32),
        ],

        // Recent Papers Section
        _SectionHeader(
          title: 'Recent Publications',
          icon: Icons.history_edu_rounded,
          onSeeAll: () {},
        ),
        const SizedBox(height: 16),
        if (_recentPapers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No papers found.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ..._recentPapers.map((paper) => _buildPaperCard(paper)),
      ],
    );
  }

  Widget _buildChartCard() {
    final timelineData = _dashboardStats!['timelineData'] as List;

    // Convert data to FlSpot list
    List<FlSpot> spots = [];
    double maxY = 0;

    for (int i = 0; i < timelineData.length; i++) {
      final item = timelineData[i];
      final paperCountVal = item['paperCount'];
      final countVal = item['count'];
      double count = 0.0;
      if (paperCountVal is num) {
        count = paperCountVal.toDouble();
      } else if (paperCountVal is String) {
        count = double.tryParse(paperCountVal) ?? 0.0;
      } else if (countVal is num) {
        count = countVal.toDouble();
      } else if (countVal is String) {
        count = double.tryParse(countVal) ?? 0.0;
      }
      if (count > maxY) maxY = count;
      spots.add(FlSpot(i.toDouble(), count));
    }

    if (maxY == 0) maxY = 10;

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4).ceilToDouble() > 0
                ? (maxY / 4).ceilToDouble()
                : 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 &&
                      index < timelineData.length &&
                      index % 2 == 0) {
                    final yearInfo =
                        (timelineData[index]['year'] ?? timelineData[index]['_id'] ?? '').toString();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        yearInfo,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (timelineData.length - 1).toDouble(),
          minY: 0,
          maxY: maxY * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primaryLight,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.3),
                    AppColors.primaryLight.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaperCard(dynamic paperObj) {
    final paper = paperObj as Paper;
    final title = paper.title;
    final venue = paper.source ?? 'Unknown Venue';
    final year = paper.publicationYear?.toString() ?? '';
    final citations = paper.citationCount.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.article_rounded,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildTag(venue, AppColors.secondary),
                    if (year.isNotEmpty)
                      _buildTag(year, AppColors.textSecondary, isOutline: true),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    citations,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withValues(alpha: 0.1),
        border: isOutline ? Border.all(color: AppColors.border) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.length > 20 ? '${text.substring(0, 20)}...' : text,
        style: TextStyle(
          color: isOutline ? color : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _normalizeRole(String role) {
    if (role.isEmpty) return 'User';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }
}

class _AnimatedMetricCard extends StatelessWidget {
  final String title;
  final int value;
  final String? stringValue;
  final IconData icon;
  final LinearGradient gradient;

  const _AnimatedMetricCard({
    required this.title,
    required this.value,
    this.stringValue,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stringValue != null)
                Text(
                  stringValue!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value.toDouble()),
                  duration: const Duration(seconds: 1),
                  builder: (context, val, child) {
                    return Text(
                      val.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.icon,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
            ),
            child: const Text(
              'See all',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
      ],
    );
  }
}
