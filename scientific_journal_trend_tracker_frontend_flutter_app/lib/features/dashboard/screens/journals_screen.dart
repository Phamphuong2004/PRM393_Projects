import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api.dart';

class JournalsScreen extends StatefulWidget {
  const JournalsScreen({super.key});

  @override
  State<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends State<JournalsScreen> {
  List<dynamic> _journals = [];
  bool _isLoading = true;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalJournals = 0;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchJournals();
  }

  Future<void> _fetchJournals({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await JournalsApi.list(page: page, limit: _limit);
      final List<dynamic> list = response['data'] ?? response['journals'] ?? [];
      final pagination = response['pagination'] ?? {};

      if (mounted) {
        setState(() {
          _journals = list;
          _currentPage = pagination['page'] as int? ?? page;
          _totalPages = pagination['pages'] as int? ?? 1;
          _totalJournals = pagination['total'] as int? ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteJournal(String id) async {
    try {
      await JournalsApi.delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal deleted successfully'), backgroundColor: AppColors.success),
        );
      }
      _fetchJournals(page: _currentPage);
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
        title: const Text('Delete Journal'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteJournal(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showJournalFormDialog([Map<String, dynamic>? journal]) {
    final isEditing = journal != null;
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController(text: journal?['name'] ?? '');
    final publisherCtrl = TextEditingController(text: journal?['publisher'] ?? '');
    final issnCtrl = TextEditingController(text: journal?['issn'] ?? '');
    final ifCtrl = TextEditingController(text: journal?['impactFactor']?.toString() ?? '');
    final hIndexCtrl = TextEditingController(text: journal?['hIndex']?.toString() ?? '');
    final domainCtrl = TextEditingController(text: journal?['fieldDomain'] ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(isEditing ? 'Edit Journal' : 'Add New Journal', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Journal Name *', prefixIcon: Icon(Icons.book_rounded)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: publisherCtrl,
                    decoration: const InputDecoration(labelText: 'Publisher', prefixIcon: Icon(Icons.business_rounded)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: issnCtrl,
                    decoration: const InputDecoration(labelText: 'ISSN', prefixIcon: Icon(Icons.confirmation_number_rounded)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ifCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Impact Factor', prefixIcon: Icon(Icons.trending_up_rounded)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: hIndexCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'H-Index', prefixIcon: Icon(Icons.assessment_rounded)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: domainCtrl,
                    decoration: const InputDecoration(labelText: 'Field Domain', prefixIcon: Icon(Icons.category_rounded)),
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
                
                final data = {
                  'name': nameCtrl.text.trim(),
                  'publisher': publisherCtrl.text.trim().isEmpty ? null : publisherCtrl.text.trim(),
                  'issn': issnCtrl.text.trim().isEmpty ? null : issnCtrl.text.trim(),
                  'impactFactor': double.tryParse(ifCtrl.text),
                  'hIndex': int.tryParse(hIndexCtrl.text),
                  'fieldDomain': domainCtrl.text.trim().isEmpty ? null : domainCtrl.text.trim(),
                };

                // Clean up nulls
                data.removeWhere((key, value) => value == null);

                try {
                  if (isEditing) {
                    await JournalsApi.update(journal['_id'], data);
                  } else {
                    await JournalsApi.create(data);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Journal updated' : 'Journal created'), backgroundColor: AppColors.success),
                    );
                    _fetchJournals(page: isEditing ? _currentPage : 1);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canEdit = authProvider.isAdmin || authProvider.isResearcher;
    final isAdmin = authProvider.isAdmin;
    
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
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
                        Text('Scientific Journals', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -1)),
                        const SizedBox(height: 4),
                        const Text('Manage academic venues, impact factors, and publications.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  if (canEdit)
                    ElevatedButton.icon(
                      onPressed: () => _showJournalFormDialog(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Journal'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                                const SizedBox(height: 16),
                                Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: () => _fetchJournals(page: _currentPage), child: const Text('Retry')),
                              ],
                            ),
                          )
                        : _journals.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.library_books_outlined, color: AppColors.textLight, size: 64),
                                    const SizedBox(height: 16),
                                    const Text('No journals found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isDesktop ? 2 : 1,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: 180,
                                      ),
                                      itemCount: _journals.length,
                                      itemBuilder: (context, index) {
                                        final journal = _journals[index];
                                        return _buildJournalCard(journal, canEdit, isAdmin);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPagination(),
                                ],
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalCard(Map<String, dynamic> journal, bool canEdit, bool isAdmin) {
    final name = journal['name'] ?? 'Unknown Journal';
    final publisher = journal['publisher'] ?? 'Unknown Publisher';
    final impactFactor = journal['impactFactor']?.toString() ?? 'N/A';
    final domain = journal['fieldDomain'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.book_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(publisher, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: AppColors.secondary, size: 14),
                    const SizedBox(width: 4),
                    Text('IF: $impactFactor', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
              if (domain.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(domain, style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
              const Spacer(),
              if (canEdit) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  onPressed: () => _showJournalFormDialog(journal),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: () => _showDeleteConfirmation(journal['_id'], name),
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
        Text('Total $_totalJournals journals', style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 1 ? () => _fetchJournals(page: _currentPage - 1) : null,
              style: IconButton.styleFrom(backgroundColor: AppColors.surface, disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5), elevation: 0),
            ),
            const SizedBox(width: 8),
            Text('$_currentPage of $_totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < _totalPages ? () => _fetchJournals(page: _currentPage + 1) : null,
              style: IconButton.styleFrom(backgroundColor: AppColors.surface, disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5), elevation: 0),
            ),
          ],
        ),
      ],
    );
  }
}
