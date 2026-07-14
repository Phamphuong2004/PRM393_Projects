import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme.dart';
import '../../../core/repositories/analysis_run_repository.dart';
import '../../../core/repositories/keyword_repository.dart';
import '../../../core/models/keyword.dart';

class AnalyticsReportScreen extends ConsumerStatefulWidget {
  const AnalyticsReportScreen({super.key});

  @override
  ConsumerState<AnalyticsReportScreen> createState() => _AnalyticsReportScreenState();
}

class _AnalyticsReportScreenState extends ConsumerState<AnalyticsReportScreen> {
  List<dynamic> _runs = [];
  int _page = 1;
  int _totalPages = 1;
  int _totalRuns = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRuns();
  }

  Future<void> _fetchRuns() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(analysisRunRepositoryProvider);
      final res = await repo.getAnalysisRuns(page: _page, limit: 10);
      
      if (!mounted) return;

      final runsList = res['runs'] as List? ?? [];
      final pagination = res['pagination'];

      setState(() {
        _runs = runsList;
        _totalPages = pagination?['pages'] ?? 1;
        _totalRuns = pagination?['total'] ?? runsList.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteRun(String id) async {
    try {
      final repo = ref.read(analysisRunRepositoryProvider);
      await repo.deleteAnalysisRun(id);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis run deleted successfully.'), backgroundColor: AppColors.success),
      );
      _fetchRuns();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showCreateRunDialog() async {
    // Fetch keywords first
    List<Keyword> keywords = [];
    try {
      final kwRepo = ref.read(keywordRepositoryProvider);
      final res = await kwRepo.getKeywords(page: 1, limit: 100);
      keywords = res['keywords'] as List<Keyword>? ?? [];
    } catch (e) {
      debugPrint('Error loading keywords: $e');
    }

    if (!mounted) return;

    Keyword? selectedKeyword = keywords.isNotEmpty ? keywords.first : null;
    final seedController = TextEditingController(text: selectedKeyword?.name ?? '');
    final sourceController = TextEditingController(text: 'Semantic Scholar');
    final startYearController = TextEditingController(text: '2015');
    final endYearController = TextEditingController(text: DateTime.now().year.toString());

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Run Trend Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (keywords.isEmpty)
                      TextField(
                        decoration: const InputDecoration(labelText: 'Keyword ID (Manual)'),
                        onChanged: (val) {
                          seedController.text = val;
                        },
                      )
                    else
                      DropdownButtonFormField<Keyword>(
                        initialValue: selectedKeyword,
                        decoration: const InputDecoration(labelText: 'Select Keyword'),
                        items: keywords.map((k) {
                          return DropdownMenuItem(
                            value: k,
                            child: Text(k.name),
                          );
                        }).toList(),
                        onChanged: (k) {
                          setDialogState(() {
                            selectedKeyword = k;
                            seedController.text = k?.name ?? '';
                          });
                        },
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: seedController,
                      decoration: const InputDecoration(labelText: 'Seed Keyword Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sourceController,
                      decoration: const InputDecoration(labelText: 'Source Database'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Start Year'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: endYearController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'End Year'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: () async {
                    if (selectedKeyword == null && keywords.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select or specify a keyword'), backgroundColor: AppColors.error),
                      );
                      return;
                    }

                    final data = {
                      'keywordId': selectedKeyword?.id ?? seedController.text,
                      'seedKeyword': seedController.text.trim(),
                      'source': sourceController.text.trim(),
                      'startYear': int.tryParse(startYearController.text) ?? 2015,
                      'endYear': int.tryParse(endYearController.text) ?? DateTime.now().year,
                    };

                    try {
                      final repo = ref.read(analysisRunRepositoryProvider);
                      await repo.createAnalysisRun(data);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _fetchRuns();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to trigger analysis: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  },
                  child: const Text('Run'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPremiumDark,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Analytics Reports',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Trigger and analyze publication trend statistics for research topics ($_totalRuns runs)',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.primaryLight),
                  onPressed: _showCreateRunDialog,
                  icon: const Icon(Icons.play_arrow_rounded),
                  tooltip: 'New Analysis Run',
                ),
              ],
            ),
          ),

          // Main content list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.error)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _fetchRuns, child: const Text('Try Again')),
                          ],
                        ),
                      )
                    : _runs.isEmpty
                        ? const Center(
                            child: Text(
                              'No trend analysis runs logged yet. Click the play button to start one.',
                              style: TextStyle(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _runs.length + (_totalPages > 1 ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _runs.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_page > 1)
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left),
                                          onPressed: () {
                                            setState(() => _page--);
                                            _fetchRuns();
                                          },
                                        ),
                                      Text('$_page / $_totalPages'),
                                      if (_page < _totalPages)
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed: () {
                                            setState(() => _page++);
                                            _fetchRuns();
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              }

                              final run = _runs[index];
                              return _buildRunCard(run);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunCard(Map<String, dynamic> run) {
    String seedKeyword = 'Unknown Keyword';
    if (run['seedKeyword'] != null && run['seedKeyword'].toString().isNotEmpty) {
      seedKeyword = run['seedKeyword'].toString();
    } else if (run['keywordId'] != null) {
      if (run['keywordId'] is Map) {
        seedKeyword = (run['keywordId']['name'] ?? run['keywordId']['keyword'] ?? '').toString();
      } else {
        seedKeyword = run['keywordId'].toString();
      }
    }
    if (seedKeyword.isEmpty) {
      seedKeyword = 'Unknown Keyword';
    }

    final source = run['source'] ?? 'Unknown Source';
    final startYear = run['startYear'] ?? 2015;
    final endYear = run['endYear'] ?? 2026;
    final status = run['status'] ?? 'pending';
    final id = run['_id'] ?? '';

    // Status colors
    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = AppColors.success;
        break;
      case 'failed':
        statusColor = AppColors.error;
        break;
      case 'running':
        statusColor = AppColors.accent;
        break;
      default:
        statusColor = AppColors.textLight;
    }

    // Yearly Data mapping
    final Map<String, dynamic> yearlyDataMap = run['yearlyData'] != null 
        ? Map<String, dynamic>.from(run['yearlyData']) 
        : {};
    
    final hasData = yearlyDataMap.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(
          seedKeyword,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          'Range: $startYear - $endYear • Source: $source',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toString().toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Analysis Run', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    content: const Text('Are you sure you want to delete this historical analysis run?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteRun(id);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const Text(
                  'Yearly Publication Counts:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                if (!hasData)
                  const Text('No yearly data generated yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                else
                  ...yearlyDataMap.entries.map((entry) {
                    final year = entry.key;
                    final count = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 60, child: Text(year, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (count as num).toDouble() / 100.0, // Scale for demo visualization
                              backgroundColor: AppColors.border,
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('$count papers'),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
