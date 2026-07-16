import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/theme.dart';
import '../../../core/models/paper.dart';
import '../../../core/repositories/bookmark_repository.dart';
import '../../../core/widgets/animated_background.dart';
import 'paper_detail_screen.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  List<Paper> _bookmarks = [];
  List<Paper> _filteredBookmarks = [];
  bool _isLoading = true;
  String? _error;
  
  String _searchQuery = '';
  String _sortOrder = 'newest';

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  void _applyFiltersAndSort() {
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final repo = ref.read(bookmarkRepositoryProvider);
      final res = await repo.getBookmarks(searchQuery: _searchQuery, sortOrder: _sortOrder);
      setState(() {
        _bookmarks = res;
        _filteredBookmarks = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load bookmarks.';
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(String id) async {
    try {
      final repo = ref.read(bookmarkRepositoryProvider);
      await repo.removeBookmark(id);
      setState(() {
        _bookmarks.removeWhere((b) => b.id == id);
      });
      _applyFiltersAndSort();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark removed'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to remove bookmark'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('My Bookmarks', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: AnimatedBackground(
        child: Center(
          child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: _buildBody(),
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
            const SizedBox(height: 24),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _fetchBookmarks, child: const Text('Retry'))
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilterSortBar(),
        Expanded(
          child: _filteredBookmarks.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchBookmarks,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: _filteredBookmarks.length,
                    itemBuilder: (context, index) {
                      final paper = _filteredBookmarks[index];
                      return _buildBookmarkCard(paper);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Filter by title...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _applyFiltersAndSort();
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortOrder,
                icon: const Icon(Icons.sort_rounded, size: 20, color: AppColors.textSecondary),
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest First', style: TextStyle(fontSize: 14))),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest First', style: TextStyle(fontSize: 14))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _sortOrder = val;
                    _applyFiltersAndSort();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: const Icon(Icons.bookmark_border_rounded, size: 72, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 32),
          Text(_searchQuery.isNotEmpty ? 'No bookmarks match your search' : 'No bookmarks yet', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Text(_searchQuery.isNotEmpty ? 'Try a different filter.' : 'Save interesting papers to read them later.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(Paper paper) {
    final title = paper.title;
    final venue = paper.source ??
        (paper.journalId is Map ? paper.journalId['name']?.toString() : null) ??
        'Unknown Source';
    final year = paper.publicationYear?.toString() ?? '';
    final url = paper.url ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaperDetailScreen(paper: paper),
              ),
            ).then((_) {
              if (mounted) {
                _fetchBookmarks();
              }
            });
          },
          child: Padding(
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
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPill(venue, AppColors.secondary),
                              if (year.isNotEmpty) 
                                _buildPill(year, AppColors.textSecondary, outline: true),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${paper.citationCount} citations',
                      style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        if (url.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.open_in_new_rounded, size: 20, color: AppColors.primaryLight),
                            onPressed: () => _openUrl(url),
                            tooltip: 'Open Link',
                          ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_remove_rounded, size: 22, color: AppColors.error),
                          onPressed: () => _removeBookmark(paper.id),
                          tooltip: 'Remove Bookmark',
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color color, {bool outline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : color.withValues(alpha: 0.1),
        border: outline ? Border.all(color: AppColors.border) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.length > 20 ? '${text.substring(0, 20)}...' : text,
        style: TextStyle(color: outline ? color : color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
