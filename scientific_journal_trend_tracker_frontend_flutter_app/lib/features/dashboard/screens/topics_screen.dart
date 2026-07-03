import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api.dart';
import '../../../core/widgets/animated_background.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<dynamic> _allTopics = [];
  List<dynamic> _emergingTopics = [];
  
  bool _isLoadingAll = true;
  bool _isLoadingEmerging = true;
  
  String? _errorAll;
  String? _errorEmerging;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalTopics = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllTopics();
    _fetchEmergingTopics();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllTopics({int page = 1}) async {
    setState(() {
      _isLoadingAll = true;
      _errorAll = null;
    });

    try {
      final response = await TopicsApi.list(page: page, limit: _limit);
      final List<dynamic> list = response['data'] ?? response['topics'] ?? [];
      final pagination = response['pagination'] ?? {};

      if (mounted) {
        setState(() {
          _allTopics = list;
          _currentPage = pagination['page'] as int? ?? page;
          _totalPages = pagination['pages'] as int? ?? 1;
          _totalTopics = pagination['total'] as int? ?? 0;
          _isLoadingAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorAll = e.toString();
          _isLoadingAll = false;
        });
      }
    }
  }

  Future<void> _fetchEmergingTopics() async {
    setState(() {
      _isLoadingEmerging = true;
      _errorEmerging = null;
    });

    try {
      final response = await TopicsApi.emerging(limit: 20);
      final List<dynamic> list = response['data'] ?? response['topics'] ?? [];

      if (mounted) {
        setState(() {
          _emergingTopics = list;
          _isLoadingEmerging = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorEmerging = e.toString();
          _isLoadingEmerging = false;
        });
      }
    }
  }

  Future<void> _deleteTopic(String id) async {
    try {
      await TopicsApi.delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Topic deleted successfully'), backgroundColor: AppColors.success),
        );
      }
      _fetchAllTopics(page: _currentPage);
      _fetchEmergingTopics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text('Are you sure you want to delete the topic "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTopic(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTopicFormDialog([Map<String, dynamic>? topic]) {
    final isEditing = topic != null;
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController(text: topic?['name'] ?? '');
    final seedCtrl = TextEditingController(text: topic?['seedKeyword'] ?? '');
    String status = topic?['trendStatus'] ?? 'stable';
    bool isEmerging = topic?['isEmerging'] ?? false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(isEditing ? 'Edit Topic' : 'Add New Topic', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Topic Name *', prefixIcon: Icon(Icons.topic_rounded)),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: seedCtrl,
                        decoration: const InputDecoration(labelText: 'Seed Keyword', prefixIcon: Icon(Icons.key_rounded)),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: const InputDecoration(labelText: 'Trend Status', prefixIcon: Icon(Icons.trending_up_rounded)),
                        items: ['emerging', 'growing', 'stable', 'declining'].map((s) {
                          return DropdownMenuItem(value: s, child: Text(s.toUpperCase()));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => status = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Mark as Emerging'),
                        value: isEmerging,
                        activeThumbColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setDialogState(() => isEmerging = val),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    // In a real scenario, you also need to pass an analysisRunId 
                    // when creating if the backend strictly requires it.
                    // For now, we will pass the minimum fields.
                    final data = {
                      'name': nameCtrl.text.trim(),
                      'seedKeyword': seedCtrl.text.trim().isEmpty ? null : seedCtrl.text.trim(),
                      'trendStatus': status,
                      'isEmerging': isEmerging,
                    };

                    data.removeWhere((key, value) => value == null);

                    try {
                      if (isEditing) {
                        await TopicsApi.update(topic['_id'], data);
                      } else {
                        // Creating might fail if analysisRunId is required but not provided.
                        await TopicsApi.create(data);
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isEditing ? 'Topic updated' : 'Topic created'), backgroundColor: AppColors.success),
                        );
                        _fetchAllTopics(page: isEditing ? _currentPage : 1);
                        _fetchEmergingTopics();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Create'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canEdit = authProvider.isAdmin || authProvider.isResearcher;
    final isAdmin = authProvider.isAdmin;
    
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Research Topics', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1)),
                        const SizedBox(height: 4),
                        const Text('Discover emerging fields and manage topic classifications.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  if (canEdit)
                    ElevatedButton.icon(
                      onPressed: () => _showTopicFormDialog(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Topic'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'All Topics'),
                  Tab(text: 'Emerging Topics'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllTopicsView(canEdit, isAdmin),
                    _buildEmergingTopicsView(canEdit, isAdmin),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildAllTopicsView(bool canEdit, bool isAdmin) {
    if (_isLoadingAll) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_errorAll != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(_errorAll!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => _fetchAllTopics(page: _currentPage), child: const Text('Retry')),
          ],
        ),
      );
    }
    
    if (_allTopics.isEmpty) {
      return const Center(child: Text('No topics found', style: TextStyle(color: AppColors.textSecondary)));
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 160,
            ),
            itemCount: _allTopics.length,
            itemBuilder: (context, index) {
              return _buildTopicCard(_allTopics[index], canEdit, isAdmin);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPagination(),
      ],
    );
  }

  Widget _buildEmergingTopicsView(bool canEdit, bool isAdmin) {
    if (_isLoadingEmerging) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_errorEmerging != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(_errorEmerging!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchEmergingTopics, child: const Text('Retry')),
          ],
        ),
      );
    }
    
    if (_emergingTopics.isEmpty) {
      return const Center(child: Text('No emerging topics right now', style: TextStyle(color: AppColors.textSecondary)));
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 160,
      ),
      itemCount: _emergingTopics.length,
      itemBuilder: (context, index) {
        return _buildTopicCard(_emergingTopics[index], canEdit, isAdmin);
      },
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, bool canEdit, bool isAdmin) {
    final name = topic['name'] ?? 'Unknown Topic';
    final seed = topic['seedKeyword'] ?? 'N/A';
    final status = topic['trendStatus'] ?? 'stable';
    final isEmerging = topic['isEmerging'] == true;

    Color statusColor = AppColors.textSecondary;
    if (status == 'emerging' || isEmerging) statusColor = AppColors.primary;
    if (status == 'growing') statusColor = AppColors.success;
    if (status == 'declining') statusColor = AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isEmerging)
                const Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.key_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text('Seed: $seed', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
              const Spacer(),
              if (canEdit) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  onPressed: () => _showTopicFormDialog(topic),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: () => _showDeleteConfirmation(topic['_id'], name),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total $_totalTopics topics', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 1 ? () => _fetchAllTopics(page: _currentPage - 1) : null,
            ),
            Text('$_currentPage of $_totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < _totalPages ? () => _fetchAllTopics(page: _currentPage + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}
