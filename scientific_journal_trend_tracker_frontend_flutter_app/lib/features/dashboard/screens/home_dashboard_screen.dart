import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/dashboard_repository.dart';
import '../../../core/repositories/paper_repository.dart';
import '../../../core/models/paper.dart';
import '../../../core/models/keyword.dart';
import '../../../core/repositories/keyword_repository.dart';
import 'package:provider/provider.dart' as prov;
import 'paper_detail_screen.dart';

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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      if (!mounted) return;
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
        keywordRepo.getTrendingKeywords(limit: 8),
      ]);

      if (!mounted) return;
      setState(() {
        _dashboardStats = Map<String, dynamic>.from(results[0] as Map);
        _recentPapers = (results[1] as Map)['papers'] ?? [];
        _trendingKeywords = results[2] as List;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
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
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32.0 : 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreeting(user),
                          const SizedBox(height: 24),
                          if (!_isLoading && _error == null) ...[
                            _buildOngoingCard(),
                            const SizedBox(height: 32),
                            _buildMonthlyPreview(isDesktop, user),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildSectionHeader('Recent Publications'),
                                TextButton(
                                  onPressed: () => context.push('/app/search'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildRecentPapers(),
                          ] else if (_isLoading) ...[
                            const SizedBox(height: 100),
                            const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ] else ...[
                            const SizedBox(height: 100),
                            Center(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(Map<String, dynamic>? user) {
    final firstName = user?['fullName']?.toString().split(' ').first ?? 'User';
    final trendingCount = _trendingKeywords.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi $firstName.',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$trendingCount Keywords are trending',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildOngoingCard() {
    String keywordText = 'Research Trends';
    String trendScoreText = '';
    if (_trendingKeywords.isNotEmpty) {
      final first = _trendingKeywords.first;
      if (first is Keyword) {
        keywordText = first.name;
        trendScoreText = first.trendScore > 0 ? 'Score: ${first.trendScore.toStringAsFixed(1)}' : '';
      } else if (first is Map) {
        keywordText = (first['keyword'] ?? first['name'] ?? 'Trend').toString();
      } else {
        keywordText = first.toString();
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Top Trending Keyword',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            keywordText,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                    if (trendScoreText.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        trendScoreText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Text(
                'Updated Now',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyPreview(bool isDesktop, Map<String, dynamic>? user) {
    int totalPapers = _dashboardStats?['totalPapers'] ?? _recentPapers.length;
    int totalCitations = 0;
    for (var p in _recentPapers) {
      if (p is Paper) {
        totalCitations += p.citationCount;
      } else if (p is Map) {
        final cit = p['citationCount'];
        totalCitations += ((cit is num) ? cit.toInt() : 0);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Dashboard Metrics'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: isDesktop ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: [
            _buildMetricSquareCard(
              title: 'Total Papers',
              value: totalPapers.toString(),
              icon: Icons.article_outlined,
            ),
            _buildMetricSquareCard(
              title: 'Total Citations',
              value: totalCitations.toString(),
              icon: Icons.format_quote_rounded,
            ),
            _buildMetricSquareCard(
              title: 'Hot Topics',
              value: _trendingKeywords.length.toString(),
              icon: Icons.local_fire_department_outlined,
            ),
            _buildMetricSquareCard(
              title: 'Your Role',
              value: _normalizeRole(user?['role'] ?? 'User'),
              icon: Icons.person_outline,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricSquareCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildRecentPapers() {
    if (_recentPapers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: const Center(
          child: Text(
            'No papers found.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }
    
    return Column(
      children: _recentPapers.map((paper) => _buildPaperCard(paper)).toList(),
    );
  }

  Widget _buildPaperCard(dynamic paperObj) {
    final paper = paperObj as Paper;
    final title = paper.title;
    final venue = paper.source ?? 'Unknown Venue';
    final year = paper.publicationYear?.toString() ?? '';
    final citations = paper.citationCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaperDetailScreen(paper: paper),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.article_rounded, color: AppColors.primaryLight),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              venue,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (year.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                year,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.format_quote_rounded, color: AppColors.primaryLight, size: 16),
                    const SizedBox(height: 4),
                    Text(
                      citations.toString(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _normalizeRole(String role) {
    if (role.isEmpty) return 'User';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }
}
