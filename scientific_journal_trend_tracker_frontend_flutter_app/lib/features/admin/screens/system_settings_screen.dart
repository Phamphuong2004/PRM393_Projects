import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/theme.dart';
import '../../../core/repositories/system_repository.dart';

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> {
  List<Map<String, dynamic>> _sources = [];
  bool _loading = false;
  bool _syncing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSources();
  }

  Future<void> _fetchSources() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(systemRepositoryProvider);
      final sources = await repo.getApiSources();
      if (!mounted) return;
      setState(() {
        _sources = sources;
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

  Future<void> _triggerSync() async {
    setState(() => _syncing = true);
    try {
      final repo = ref.read(systemRepositoryProvider);
      await repo.triggerSync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manual background sync process triggered successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to trigger sync: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _deleteSource(String id) async {
    try {
      final repo = ref.read(systemRepositoryProvider);
      await repo.deleteApiSource(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Source deleted.'), backgroundColor: AppColors.success),
      );
      _fetchSources();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showSourceFormDialog([Map<String, dynamic>? source]) {
    final isEdit = source != null;
    final nameController = TextEditingController(text: source?['name'] ?? '');
    final urlController = TextEditingController(text: source?['baseUrl'] ?? '');
    final scopeController = TextEditingController(text: source?['fieldScope'] ?? '');
    final freqController = TextEditingController(text: (source?['syncFrequency'] ?? 24).toString());
    final threshController = TextEditingController(text: (source?['trendingThreshold'] ?? 5).toString());
    final minPaperController = TextEditingController(text: (source?['minPaperCount'] ?? 10).toString());
    bool isActive = source?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit API Source' : 'Add API Source', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name (e.g. CrossRef)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(labelText: 'Base URL'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: scopeController,
                      decoration: const InputDecoration(labelText: 'Field Scope (e.g. Computer Science)'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: freqController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Sync Freq (hours)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: threshController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Trend Threshold'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: minPaperController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min Paper Count'),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Active status'),
                      value: isActive,
                      activeThumbColor: AppColors.success,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setDialogState(() => isActive = val),
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
                    final data = {
                      'name': nameController.text.trim(),
                      'baseUrl': urlController.text.trim(),
                      'fieldScope': scopeController.text.trim(),
                      'syncFrequency': int.tryParse(freqController.text) ?? 24,
                      'trendingThreshold': int.tryParse(threshController.text) ?? 5,
                      'minPaperCount': int.tryParse(minPaperController.text) ?? 10,
                      'isActive': isActive,
                    };

                    try {
                      final repo = ref.read(systemRepositoryProvider);
                      if (isEdit) {
                        await repo.updateApiSource(source['_id'], data);
                      } else {
                        await repo.createApiSource(data);
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _fetchSources();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Operation failed: $e'), backgroundColor: AppColors.error),
                      );
                    }
                  },
                  child: const Text('Save'),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'System Settings',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Manage data synchronization parameters and API collection endpoints',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Sync Control Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Background ETL Sync Control',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Force triggering this sync retrieves scientific articles from Google Scholar and Semantic Scholar based on registered keywords, dedups papers, and re-calculates trend score metrics in real-time.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _syncing ? null : _triggerSync,
                            icon: _syncing 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.sync_rounded),
                            label: Text(_syncing ? 'Syncing...' : 'Trigger Background ETL Sync'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Sources Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'API Data Sources',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => _showSourceFormDialog(),
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Add API Source',
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Sources list
                if (_loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (_error != null)
                  Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, style: const TextStyle(color: AppColors.error))))
                else if (_sources.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
                    child: const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('No API Data sources configured. Add one to enable paper harvesting.', style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  )
                else
                  ..._sources.map((s) => _buildSourceCard(s)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard(Map<String, dynamic> source) {
    final name = source['name'] ?? 'Unknown Source';
    final url = source['baseUrl'] ?? '';
    final scope = source['fieldScope'] ?? 'All Fields';
    final freq = source['syncFrequency'] ?? 24;
    final isActive = source['isActive'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon indicators
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isActive ? AppColors.success : AppColors.textLight).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: isActive ? AppColors.success : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _SourceTag(label: 'Scope: $scope', color: AppColors.primary),
                      _SourceTag(label: 'Sync: every $freq hrs', color: AppColors.secondary),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                  onPressed: () => _showSourceFormDialog(source),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete API Source', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        content: Text('Are you sure you want to delete the source "$name"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteSource(source['_id']);
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
          ],
        ),
      ),
    );
  }
}

class _SourceTag extends StatelessWidget {
  final String label;
  final Color color;
  const _SourceTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
