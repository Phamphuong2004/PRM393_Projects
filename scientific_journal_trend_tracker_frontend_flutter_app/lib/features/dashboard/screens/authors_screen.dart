import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme.dart';
import '../../../core/models/author.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api.dart';
import '../../../core/widgets/animated_background.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Author> _authors = [];
  bool _isLoading = true;
  String? _error;

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalAuthors = 0;
  final int _limit = 9;

  @override
  void initState() {
    super.initState();
    _fetchAuthors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAuthors({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await AuthorsApi.list(
        page: page,
        limit: _limit,
        search: _searchController.text.trim(),
      );

      final List<dynamic> list = response['authors'] ?? [];
      final pagination = response['pagination'] ?? {};

      setState(() {
        _authors = list.map((item) => Author.fromJson(item)).toList();
        _currentPage = pagination['page'] as int? ?? page;
        _totalPages = pagination['pages'] as int? ?? 1;
        _totalAuthors = pagination['total'] as int? ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    _fetchAuthors(page: 1);
  }

  void _onClearSearch() {
    _searchController.clear();
    _fetchAuthors(page: 1);
  }

  Future<void> _deleteAuthor(String id) async {
    try {
      await AuthorsApi.delete(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Author deleted successfully'), backgroundColor: AppColors.success),
        );
      }
      _fetchAuthors(page: _currentPage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showDeleteConfirmation(Author author) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Author'),
        content: Text('Are you sure you want to delete ${author.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAuthor(author.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAuthorFormDialog([Author? author]) {
    final isEditing = author != null;
    final formKey = GlobalKey<FormState>();
    
    final fullNameCtrl = TextEditingController(text: author?.fullName ?? '');
    final affiliationCtrl = TextEditingController(text: author?.affiliation ?? '');
    final orcidCtrl = TextEditingController(text: author?.orcid ?? '');
    final externalIdCtrl = TextEditingController(text: author?.externalAuthorId ?? '');
    final operalIdCtrl = TextEditingController(text: author?.operalId ?? '');
    final workCountCtrl = TextEditingController(text: author?.workCount.toString() ?? '0');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(isEditing ? 'Edit Author Details' : 'Add New Author', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Full name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: affiliationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Affiliation / Institution',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: orcidCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ORCID iD',
                      prefixIcon: Icon(Icons.badge_rounded),
                      hintText: 'e.g. 0000-0002-1825-0097',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: externalIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Semantic Scholar ID',
                      prefixIcon: Icon(Icons.api_rounded),
                      hintText: 'e.g. 21458925',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: operalIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Operal ID',
                      prefixIcon: Icon(Icons.fingerprint_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: workCountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Work Count (Paper count)',
                      prefixIcon: Icon(Icons.article_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (int.tryParse(v) == null) return 'Must be a valid integer';
                      if (int.parse(v) < 0) return 'Cannot be negative';
                      return null;
                    },
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
                  'fullName': fullNameCtrl.text.trim(),
                  'affiliation': affiliationCtrl.text.trim().isEmpty ? null : affiliationCtrl.text.trim(),
                  'orcid': orcidCtrl.text.trim().isEmpty ? null : orcidCtrl.text.trim(),
                  'externalAuthorId': externalIdCtrl.text.trim().isEmpty ? null : externalIdCtrl.text.trim(),
                  'operalId': operalIdCtrl.text.trim().isEmpty ? null : operalIdCtrl.text.trim(),
                  'workCount': int.tryParse(workCountCtrl.text) ?? 0,
                };

                try {
                  if (isEditing) {
                    await AuthorsApi.update(author.id, data);
                  } else {
                    await AuthorsApi.create(data);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Author details updated' : 'New author created'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    _fetchAuthors(page: isEditing ? _currentPage : 1);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving author: $e'), backgroundColor: AppColors.error),
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
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Research Authors',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage scholarly authors, affiliations, and tracking parameters.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  if (canEdit)
                    ElevatedButton.icon(
                      onPressed: () => _showAuthorFormDialog(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Author'),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search authors by name or affiliation...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: _onClearSearch,
                          )
                        : IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                            onPressed: _onSearch,
                          ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main body list
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
                                ElevatedButton(onPressed: () => _fetchAuthors(page: _currentPage), child: const Text('Retry')),
                              ],
                            ),
                          )
                        : _authors.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline_rounded, color: AppColors.textLight, size: 64),
                                    const SizedBox(height: 16),
                                    const Text('No authors found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    const Text('Try modifying your search criteria or add a new author record.', style: TextStyle(color: AppColors.textLight, fontSize: 14)),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: isDesktop ? 3 : 1,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: 220,
                                      ),
                                      itemCount: _authors.length,
                                      itemBuilder: (context, index) {
                                        final author = _authors[index];
                                        return _buildAuthorCard(author, canEdit, isAdmin);
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
      ),
    );
  }

  Widget _buildAuthorCard(Author author, bool canEdit, bool isAdmin) {
    final initials = author.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join('');

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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.softShadow,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.business_rounded, color: AppColors.textLight, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            author.affiliation ?? 'No Affiliation',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.article_outlined, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${author.workCount} Publications',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),

          // Badges / Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Identifiers Row
              Row(
                children: [
                  if (author.orcid != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA6C307).withValues(alpha: 0.1), // ORCID green
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA6C307).withValues(alpha: 0.3)),
                        ),
                        child: const Text('ORCID', style: TextStyle(color: Color(0xFF5F7003), fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  if (author.externalAuthorId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                      ),
                      child: const Text('S. SCHOLAR', style: TextStyle(color: Color(0xFF0891B2), fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
              
              // Edit / Delete Buttons
              if (canEdit)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                      onPressed: () => _showAuthorFormDialog(author),
                      style: IconButton.styleFrom(hoverColor: AppColors.primaryLight.withValues(alpha: 0.05)),
                    ),
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                        onPressed: () => _showDeleteConfirmation(author),
                        style: IconButton.styleFrom(hoverColor: AppColors.error.withValues(alpha: 0.05)),
                      ),
                  ],
                ),
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
        Text(
          'Total $_totalAuthors authors',
          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: _currentPage > 1 ? () => _fetchAuthors(page: _currentPage - 1) : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_currentPage of $_totalPages',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _currentPage < _totalPages ? () => _fetchAuthors(page: _currentPage + 1) : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                disabledBackgroundColor: AppColors.surface.withValues(alpha: 0.5),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
