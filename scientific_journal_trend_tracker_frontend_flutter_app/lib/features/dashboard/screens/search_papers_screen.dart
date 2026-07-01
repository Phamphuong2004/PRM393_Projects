import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/paper.dart';
import '../../../core/repositories/bookmark_repository.dart';
import '../../../core/repositories/paper_repository.dart';
import '../../../core/repositories/workspace_repository.dart';
import 'paper_detail_screen.dart';

class SearchPapersScreen extends ConsumerStatefulWidget {
  final String? workspaceId;
  const SearchPapersScreen({super.key, this.workspaceId});

  @override
  ConsumerState<SearchPapersScreen> createState() => _SearchPapersScreenState();
}

class _SearchPapersScreenState extends ConsumerState<SearchPapersScreen> {
  final _searchController = TextEditingController();
  List<Paper> _results = [];
  int _page = 1;
  bool _isImporting = false;
  int _totalPages = 1;
  int _totalResults = 0;
  bool _loading = false;
  String? _error;
  String _sort = '-publicationYear';
  String _selectedSource = 'Local Database';
  String _selectedYear = 'All Years';

  // Bookmark UI state
  final Set<String> _savedIds = {};
  final Set<String> _savingIds = {};
  final Set<String> _addingToWorkspaceIds = {};
  final Set<String> _addedToWorkspaceIds = {};
  
  // MongoDB ObjectId = 24 hex chars. External results (OpenAlex/Crossref/...)
  // carry a non-ObjectId id and are NOT in the local library, so they can't be bookmarked.
  static final _objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');

  static const _sortOptions = [
    ('-publicationYear', 'Newest first'),
    ('publicationYear', 'Oldest first'),
    ('-citationCount', 'Most cited'),
    ('citationCount', 'Least cited'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPapers();
    _syncSavedIds();
    _syncWorkspacePapers();
  }

  Future<void> _syncWorkspacePapers() async {
    if (widget.workspaceId == null) return;
    try {
      final res = await ref.read(workspaceRepositoryProvider).getWorkspacePapers(widget.workspaceId!, limit: 100);
      if (!mounted) return;
      final papers = res['data'] as List<dynamic>? ?? [];
      setState(() {
        for (var p in papers) {
          if (p['paper'] != null) {
             final paperId = p['paper']['_id'] ?? p['paper'];
             if (paperId is String) {
               _addedToWorkspaceIds.add(paperId);
             }
          }
        }
      });
    } catch (_) {}
  }

  // Rebuild the "Saved" state from the server so it survives leaving/reopening
  // the screen (in-memory state alone is lost when the screen is recreated).
  Future<void> _syncSavedIds() async {
    try {
      final papers = await ref.read(bookmarkRepositoryProvider).getBookmarks();
      if (!mounted) return;
      setState(() {
        _savedIds.clear();
        for (var p in papers) {
          _savedIds.add(p.id);
          if (p.externalIdOpenalexId != null) _savedIds.add(p.externalIdOpenalexId!);
          if (p.externalIdSemanticScholarId != null) _savedIds.add(p.externalIdSemanticScholarId!);
          if (p.externalIdCrossref != null) _savedIds.add(p.externalIdCrossref!);
        }
      });
    } catch (_) {
      // Non-blocking: keep current state if bookmarks can't be loaded.
    }
  }

  Future<void> _fetchPapers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final q = _searchController.text.trim();
      final year = _selectedYear != 'All Years' ? int.tryParse(_selectedYear) : null;

      final paperRepo = ref.read(paperRepositoryProvider);
      Map<String, dynamic> res;

      if (_selectedSource != 'Local Database') {
        if (q.isEmpty) {
          setState(() {
            _results = [];
            _totalPages = 1;
            _totalResults = 0;
            _loading = false;
          });
          return;
        }
        res = await paperRepo.searchExternalPapers(q, limit: 15, source: _selectedSource);
      } else {
        if (q.isNotEmpty) {
          res = await paperRepo.searchPapers(q, year: year);
        } else {
          res = await paperRepo.getPapers(page: _page, limit: 10);
        }
      }

      if (!mounted) return;
      final papers = res['papers'] as List<Paper>? ?? [];
      final pagination = res['pagination'];
      setState(() {
        _results = papers;
        _totalPages = pagination?['pages'] ?? 1;
        _totalResults = pagination?['total'] ?? papers.length;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _reset() {
    _searchController.clear();
    setState(() {
      _sort = '-publicationYear';
      _page = 1;
      _selectedSource = 'Local Database';
      _selectedYear = 'All Years';
    });
    _fetchPapers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showPaperDetail(Paper paper) async {
    final isLocalPaper =
        _selectedSource == 'Local Database' && _objectIdRegex.hasMatch(paper.id);

    Paper displayPaper = paper;

    if (!isLocalPaper) {
      setState(() { _isImporting = true; });

      try {
        final importedPaper = await ref.read(bookmarkRepositoryProvider).importBookmark(paper.toJson());
        displayPaper = importedPaper;
        
        if (mounted) {
          setState(() {
            _isImporting = false;
            _savedIds.add(paper.id);
            _savedIds.add(importedPaper.id);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() { _isImporting = false; });
          String errorMessage = 'Failed to import and open paper details.';
          if (e is DioException && e.response?.data != null) {
            final data = e.response!.data;
            if (data is Map && data['details'] != null) {
              errorMessage = 'Backend Error: ${data['details']}';
            }
          }
          _showSnack(errorMessage, AppColors.error);
        }
        return;
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaperDetailScreen(paper: displayPaper),
      ),
    );
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleAddToWorkspace(Paper paper) async {
    if (widget.workspaceId == null) return;
    if (_addingToWorkspaceIds.contains(paper.id)) return;

    setState(() => _addingToWorkspaceIds.add(paper.id));
    try {
      await ref.read(workspaceRepositoryProvider).addPaperToWorkspace(widget.workspaceId!, paper);
      if (!mounted) return;
      setState(() => _addedToWorkspaceIds.add(paper.id));
      _showSnack('Added to workspace!', AppColors.success);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showSnack(msg, Colors.red.shade700);
    } finally {
      if (mounted) setState(() => _addingToWorkspaceIds.remove(paper.id));
    }
  }

  Future<void> _handleSave(Paper paper) async {
    if (_savedIds.contains(paper.id) || _savingIds.contains(paper.id)) return;

    final isLocalPaper =
        _selectedSource == 'Local Database' && _objectIdRegex.hasMatch(paper.id);

    setState(() => _savingIds.add(paper.id));
    try {
      if (isLocalPaper) {
        await ref.read(bookmarkRepositoryProvider).addBookmark(paper.id);
      } else {
        await ref.read(bookmarkRepositoryProvider).importBookmark(paper.toJson());
      }
      if (!mounted) return;
      setState(() {
        _savingIds.remove(paper.id);
        _savedIds.add(paper.id);
      });
      _showSnack('Saved to bookmarks', AppColors.success);
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingIds.remove(paper.id));
      _showSnack(
        'Failed to save bookmark. Please try again.',
        AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
        // Search Header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          color: AppColors.bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.workspaceId != null) ...[
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      onPressed: () => context.pop(),
                    ),
                    const Text('Back to Workspace', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const Text('Search & Discovery', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              const Text('Search by title, abstract, author, or journal', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 20),

              // Search Bar + Filter Icon
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Search papers, authors, journals...',
                          hintStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w400),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        onSubmitted: (_) { setState(() => _page = 1); _fetchPapers(); },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                      boxShadow: [
                         BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                      ]
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(16),
                      icon: Stack(
                        children: [
                          const Icon(Icons.tune_rounded, color: AppColors.primary),
                          if (_selectedYear != 'All Years')
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Source Dropdown + Reset
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSource,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          items: ['Local Database', 'OpenAlex', 'Semantic Scholar', 'Crossref', 'IEEE Xplore', 'Exa Research']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSource = val;
                                _page = 1;
                              });
                              _fetchPapers();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${_searchController.text.isNotEmpty ? "Search results" : "Recent papers"} • Page $_page of $_totalPages • $_totalResults results',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, style: const TextStyle(color: AppColors.error)),
                    ))
                  : _results.isEmpty
                      ? const Center(child: Text('No papers found. Try another keyword.', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _results.length + (_totalPages > 1 ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i == _results.length) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_page > 1) IconButton(icon: const Icon(Icons.chevron_left), onPressed: () { setState(() => _page--); _fetchPapers(); }),
                                  Text('$_page / $_totalPages'),
                                  if (_page < _totalPages) IconButton(icon: const Icon(Icons.chevron_right), onPressed: () { setState(() => _page++); _fetchPapers(); }),
                                ],
                              );
                            }
                            final paper = _results[i];
                            return _buildPaperCard(paper);
                          },
                        ),
        ),
      ],
    ),
    if (_isImporting)
      Positioned.fill(
        child: Container(
          color: Colors.white.withValues(alpha: 0.7),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildPaperCard(Paper paper) {
    final authorsList = paper.authors ?? [];
    final authors = authorsList.isNotEmpty
        ? authorsList.map((a) => a.fullName).join(', ')
        : 'Unknown';
    final journal = paper.journalId != null
        ? (paper.journalId is Map ? (paper.journalId['name']?.toString() ?? 'Unknown journal') : paper.journalId.toString())
        : 'Unknown journal';
    final year = paper.publicationYear?.toString() ?? '';
    final citations = paper.citationCount;
    final hasOpenAlex = paper.externalIdOpenalexId != null && paper.externalIdOpenalexId!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: AppColors.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showPaperDetail(paper),
                    child: Text(
                      paper.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                if (hasOpenAlex || _selectedSource != 'Local Database') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasOpenAlex ? 'OpenAlex' : _selectedSource,
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (paper.doi != null && paper.doi!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'DOI: ${paper.doi}',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '$authors · ${year.isNotEmpty ? year : "N/A"} · $citations citations · $journal',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              paper.abstract?.isNotEmpty == true ? paper.abstract! : 'No abstract available.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Builder(
                        builder: (_) {
                          if (widget.workspaceId != null) {
                            final isAdding = _addingToWorkspaceIds.contains(paper.id);
                            final isAdded = _addedToWorkspaceIds.contains(paper.id);

                            return TextButton.icon(
                              onPressed: (isAdding || isAdded) ? null : () => _handleAddToWorkspace(paper),
                              icon: isAdding
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Icon(isAdded ? Icons.check : Icons.add, size: 18),
                              label: Text(isAdded ? 'Added' : 'Add to Workspace'),
                              style: TextButton.styleFrom(
                                foregroundColor: isAdded ? Colors.green : const Color(0xFF4F46E5),
                                disabledForegroundColor: isAdded ? Colors.green : Colors.grey,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(60, 36),
                              ),
                            );
                          }

                          final saved = _savedIds.contains(paper.id);
                          final saving = _savingIds.contains(paper.id);
                          return TextButton.icon(
                            onPressed: saving ? null : () => _handleSave(paper),
                            icon: saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 18),
                            label: Text(saved ? 'Saved' : 'Save'),
                            style: TextButton.styleFrom(
                              foregroundColor: saved ? AppColors.primary : Colors.grey.shade700,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(60, 36),
                            ),
                          );
                        },
                      ),
                      if (paper.url != null && paper.url!.isNotEmpty)
                        TextButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(paper.url!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Source'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 36),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showPaperDetail(paper),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 36),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.tune, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedYear = 'All Years';
                            _sort = '-publicationYear';
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Year chips
                  const Text('PUBLICATION YEAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All Years', ...List.generate(10, (i) => (DateTime.now().year - i).toString())].map((y) {
                      final isSelected = _selectedYear == y;
                      return GestureDetector(
                        onTap: () => setModalState(() => _selectedYear = y),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            y,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Or type a year (e.g. 2010)',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            prefixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade500),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                          onChanged: (val) {
                            final trimmed = val.trim();
                            if (trimmed.length == 4 && int.tryParse(trimmed) != null) {
                              setModalState(() => _selectedYear = trimmed);
                            } else if (trimmed.isEmpty) {
                              setModalState(() => _selectedYear = 'All Years');
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  // Sort chips (only for Local Database)
                  if (_selectedSource == 'Local Database') ...[
                    const SizedBox(height: 24),
                    const Text('SORT BY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sortOptions.map((o) {
                        final isSelected = _sort == o.$1;
                        return GestureDetector(
                          onTap: () => setModalState(() => _sort = o.$1),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              o.$2,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() => _page = 1);
                        _fetchPapers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      if (mounted) setState(() {});
    });
  }
}
