import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme.dart';
import '../../../core/repositories/follow_repository.dart';
import '../../../core/widgets/animated_background.dart';

class FollowingScreen extends ConsumerStatefulWidget {
  const FollowingScreen({super.key});

  @override
  ConsumerState<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends ConsumerState<FollowingScreen> {
  List<dynamic> _follows = [];
  List<dynamic> _trackedRuns = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final repo = ref.read(followRepositoryProvider);
      
      final followsFuture = repo.getFollows();
      final runsFuture = repo.getTrackedRuns();
      
      final results = await Future.wait([followsFuture, runsFuture]);
      
      setState(() {
        _follows = results[0];
        _trackedRuns = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load following data.';
        _isLoading = false;
      });
    }
  }

  Future<void> _unfollow(String id, bool isRun) async {
    try {
      final repo = ref.read(followRepositoryProvider);
      if (isRun) {
        await repo.untrackRun(id);
        setState(() => _trackedRuns.removeWhere((r) => r['analysisRunId'] == id));
      } else {
        await repo.unfollow(id);
        setState(() => _follows.removeWhere((f) => f['targetId'] == id));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unfollowed successfully'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to unfollow'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _toggleRunNotify(String analysisRunId, bool current) async {
    final newValue = !current;

    void apply(bool value) {
      final run = _trackedRuns.firstWhere(
        (r) => r['analysisRunId'] == analysisRunId,
        orElse: () => null,
      );
      if (run != null) run['notifyEnabled'] = value;
    }

    // Optimistic update
    setState(() => apply(newValue));

    try {
      await ref
          .read(followRepositoryProvider)
          .updateTrackedRunNotification(analysisRunId, newValue);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newValue ? 'Alerts turned on' : 'Alerts turned off'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Revert on failure
      setState(() => apply(current));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update alerts'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text('Following', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.bg,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: _fetchData,
              tooltip: 'Refresh',
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: AppColors.gradientPrimary,
                  boxShadow: AppColors.glowShadow,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: const [
                  Tab(text: 'Keywords'),
                  Tab(text: 'Journals'),
                  Tab(text: 'Analysis'),
                ],
              ),
            ),
          ),
        ),
        body: AnimatedBackground(
          child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: _buildBody(),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Retry'))
          ],
        ),
      );
    }

    final keywords = _follows.where((f) => f['targetType'] == 'Keyword').toList();
    final journals = _follows.where((f) => f['targetType'] == 'Journal').toList();

    return TabBarView(
      children: [
        _buildList(keywords, Icons.tag_rounded, 'No keywords followed', false),
        _buildList(journals, Icons.auto_stories_rounded, 'No journals followed', false),
        _buildList(_trackedRuns, Icons.analytics_rounded, 'No analysis runs tracked', true),
      ],
    );
  }

  Widget _buildList(List<dynamic> items, IconData icon, String emptyMessage, bool isRun) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(icon, size: 72, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 24),
            Text('Nothing here yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text(emptyMessage, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = isRun ? item['analysisRunId'] : item['targetId'];
        
        final title = isRun 
            ? 'Analysis Run (ID: ${id.toString().substring(0, 8)}...)'
            : (item['target'] != null ? item['target']['name'] ?? 'Unknown' : 'ID: $id');
            
        final notify = item['notifyEnabled'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.glowShadow,
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(notify ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, 
                                 size: 14, color: notify ? AppColors.success : AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              notify ? 'Alerts ON' : 'Alerts OFF',
                              style: TextStyle(color: notify ? AppColors.success : AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isRun)
                    IconButton(
                      onPressed: () => _toggleRunNotify(id, notify),
                      icon: Icon(
                        notify ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                        color: notify ? AppColors.success : AppColors.textLight,
                      ),
                      tooltip: notify ? 'Turn alerts off' : 'Turn alerts on',
                    ),
                  IconButton(
                    onPressed: () => _unfollow(id, isRun),
                    icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.error),
                    tooltip: 'Unfollow',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
