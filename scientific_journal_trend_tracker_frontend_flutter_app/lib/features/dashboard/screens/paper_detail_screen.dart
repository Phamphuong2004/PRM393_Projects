import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/paper.dart';

class PaperDetailScreen extends StatelessWidget {
  final Paper paper;

  const PaperDetailScreen({super.key, required this.paper});

  @override
  Widget build(BuildContext context) {
    final authorsList = paper.authors ?? [];
    final authors = authorsList.isNotEmpty 
        ? authorsList.map((a) => a.fullName).join(', ') 
        : 'Unknown';
    final journal = paper.journalId != null 
        ? (paper.journalId is Map ? paper.journalId['name'] : paper.journalId.toString()) 
        : 'Unknown journal';
    final year = paper.publicationYear?.toString() ?? 'N/A';
    final citations = paper.citationCount;
    final hasOpenAlex = paper.externalIdOpenalexId != null && paper.externalIdOpenalexId!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Paper Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4F46E5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (hasOpenAlex || paper.source != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasOpenAlex ? 'OpenAlex' : (paper.source ?? ''),
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$citations Citations',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              paper.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                height: 1.3,
              ),
            ),
            if (paper.doi != null && paper.doi!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://doi.org/${paper.doi}');
                  if (await canLaunchUrl(url)) await launchUrl(url);
                },
                child: Text(
                  'DOI: ${paper.doi}',
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaRow(Icons.person_outline, 'Authors', authors),
                  const SizedBox(height: 12),
                  _buildMetaRow(Icons.calendar_today_outlined, 'Published', year),
                  const SizedBox(height: 12),
                  _buildMetaRow(Icons.book_outlined, 'Journal/Venue', journal),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Abstract',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              paper.abstract?.isNotEmpty == true ? paper.abstract! : 'No abstract available for this paper.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Save Paper'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (paper.url != null && paper.url!.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(paper.url!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View Source'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
