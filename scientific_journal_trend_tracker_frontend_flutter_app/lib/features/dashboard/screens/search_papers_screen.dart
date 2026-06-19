import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/paper.dart';
import '../../../core/repositories/paper_repository.dart';

class SearchPapersScreen extends ConsumerStatefulWidget {
  const SearchPapersScreen({super.key});

  @override
  ConsumerState<SearchPapersScreen> createState() => _SearchPapersScreenState();
}

class _SearchPapersScreenState extends ConsumerState<SearchPapersScreen> {
  final _searchController = TextEditingController();
  final _yearController = TextEditingController();
  List<Paper> _results = [];
  int _page = 1;
  int _totalPages = 1;
  int _totalResults = 0;
  bool _loading = false;
  String? _error;
  String _sort = '-publicationYear';
  Paper? _selectedPaper;
  bool _isExternal = false;

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
  }

  Future<void> _fetchPapers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final q = _searchController.text.trim();
      final yearStr = _yearController.text.trim();
      final year = yearStr.isNotEmpty ? int.tryParse(yearStr) : null;

      final paperRepo = ref.read(paperRepositoryProvider);
      Map<String, dynamic> res;
      
      if (_isExternal) {
        if (q.isEmpty) {
          setState(() {
            _results = [];
            _totalPages = 1;
            _totalResults = 0;
            _loading = false;
          });
          return;
        }
        res = await paperRepo.searchExternalPapers(q, limit: 15);
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
    _yearController.clear();
    setState(() { _sort = '-publicationYear'; _page = 1; _isExternal = false; });
    _fetchPapers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Discovery Engine', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Search by title, abstract, author, or journal', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              
              // Search Mode Toggle
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExternal = false;
                            _page = 1;
                          });
                          _fetchPapers();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isExternal ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Local Database',
                              style: TextStyle(
                                color: !_isExternal ? AppColors.primary : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExternal = true;
                            _page = 1;
                          });
                          _fetchPapers();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isExternal ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Semantic Scholar',
                              style: TextStyle(
                                color: _isExternal ? AppColors.primary : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: _isExternal ? 'Search Semantic Scholar...' : 'Search papers, authors, journals...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) { setState(() => _page = 1); _fetchPapers(); },
              ),
              if (!_isExternal) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Year',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _sort,
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: _sortOptions.map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) => setState(() => _sort = v!),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { setState(() => _page = 1); _fetchPapers(); },
                      icon: const Icon(Icons.search, size: 16),
                      label: const Text('Search'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.filter_alt_off, size: 16, color: Colors.white),
                    label: const Text('Reset', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${_searchController.text.isNotEmpty ? "Search results" : "Recent papers"} • Page $_page of $_totalPages • $_totalResults results',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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

        // Paper Detail Sheet
        if (_selectedPaper != null)
          _PaperDetailSheet(paper: _selectedPaper!, onClose: () => setState(() => _selectedPaper = null)),
      ],
    );
  }

  Widget _buildPaperCard(Paper paper) {
    final authorsList = paper.authors ?? [];
    final authors = authorsList.isNotEmpty 
        ? authorsList.map((a) => a.fullName).join(', ') 
        : 'Unknown';
    final journal = paper.journalId != null 
        ? (paper.journalId is Map ? paper.journalId['name'] : paper.journalId.toString()) 
        : 'Unknown journal';
    final year = paper.publicationYear?.toString() ?? '';
    final citations = paper.citationCount;
    final keywordsList = paper.keywords ?? [];
    final keywords = keywordsList.map((k) => k is Map ? k['name'].toString() : k.toString()).where((k) => k.isNotEmpty).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0x1A4F46E5))),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedPaper = paper),
              child: Text(paper.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 14)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _InfoChip(icon: Icons.person_outline, label: authors.isNotEmpty ? authors : 'Unknown', color: const Color(0xFF667EEA)),
                if (journal.isNotEmpty) _InfoChip(icon: Icons.book_outlined, label: journal, color: const Color(0xFFF5576C)),
                if (year != '') _InfoChip(icon: Icons.calendar_today, label: year, color: const Color(0xFF4FACFE)),
                _InfoChip(icon: Icons.format_quote_outlined, label: '$citations citations', color: const Color(0xFF43E97B)),
              ],
            ),
            if (keywords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: keywords.take(4).map((k) => Chip(label: Text(k, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList(),
              ),
            ],
            if (paper.abstract != null) ...[
              const SizedBox(height: 8),
              Text(paper.abstract!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => setState(() => _selectedPaper = paper),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              child: const Text('View Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: TextStyle(fontSize: 12, color: color), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _PaperDetailSheet extends StatelessWidget {
  final Paper paper;
  final VoidCallback onClose;
  const _PaperDetailSheet({required this.paper, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  Row(children: [
                    const Expanded(child: Text('Paper Detail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                  ]),
                  const Divider(),
                  Text(paper.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  if (paper.abstract != null) ...[
                    const Text('Abstract', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(paper.abstract!, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
                  ],
                  if (paper.doi != null) ...[
                    const SizedBox(height: 12),
                    Text('DOI: ${paper.doi}', style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

