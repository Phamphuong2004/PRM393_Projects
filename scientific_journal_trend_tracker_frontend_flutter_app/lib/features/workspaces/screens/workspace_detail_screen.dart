import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/workspace_detail_provider.dart';
import '../../../core/repositories/workspace_repository.dart';
import 'pdf_viewer_screen.dart';

class WorkspaceDetailScreen extends ConsumerWidget {
  final String workspaceId;

  const WorkspaceDetailScreen({super.key, required this.workspaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workspaceDetailProvider(workspaceId));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Workspace Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: detailAsync.when(
        data: (data) {
          final workspace = data['workspace'];
          final role = data['role'];
          final members = workspace['members'] as List<dynamic>? ?? [];

          return DefaultTabController(
            length: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              workspace['visibility']?.toString().toUpperCase() ?? 'TEAM',
                              style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Role: ${role.toString().toUpperCase()}',
                              style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        workspace['name'] ?? 'Untitled Workspace',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      if (workspace['description'] != null && workspace['description'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          workspace['description'],
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 1), // Divider
                Container(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: 'Papers'),
                      Tab(text: 'Notes'),
                      Tab(text: 'Members'),
                      Tab(text: 'Alerts'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      WorkspacePapersTab(workspaceId: workspaceId),
                      WorkspaceNotesTab(workspaceId: workspaceId),
                      WorkspaceMembersTab(workspaceId: workspaceId, members: members),
                      WorkspaceAlertsTab(workspaceId: workspaceId),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading workspace: $err')),
      ),
    );
  }
}

// ======================= PAPERS TAB =======================
class WorkspacePapersTab extends ConsumerWidget {
  final String workspaceId;
  const WorkspacePapersTab({super.key, required this.workspaceId});

  void _showAddPaperDialog(BuildContext context, WidgetRef ref) {
    context.push('/app/search?workspaceId=$workspaceId').then((_) {
      // Force a fresh fetch when returning from search
      ref.invalidate(workspacePapersProvider(workspaceId));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final papersAsync = ref.watch(workspacePapersProvider(workspaceId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddPaperDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Paper'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: papersAsync.when(
            data: (papers) {
              if (papers.isEmpty) {
                return _buildEmptyState(Icons.description_outlined, 'No papers yet', 'Click the button above to add a paper');
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(workspacePapersProvider(workspaceId)),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    final wp = papers[index];
                    final paper = wp['paper'] ?? {};
                    final pdfUrl = paper['pdfUrl']?.toString();
                    final hasPdf = pdfUrl != null && pdfUrl.isNotEmpty;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.description, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    paper['title'] ?? 'Unknown Title',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (hasPdf)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.picture_as_pdf, size: 12, color: Colors.red.shade700),
                                        const SizedBox(width: 4),
                                        Text('PDF', style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Added: ${wp['addedAt']?.toString().substring(0, 10) ?? ''}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                                const Spacer(),
                                if (hasPdf)
                                  TextButton.icon(
                                    onPressed: () {
                                      // Cloudinary returns an absolute URL; older
                                      // records may still hold a relative /uploads path.
                                      final fullUrl = pdfUrl.startsWith('http')
                                          ? pdfUrl
                                          : 'https://prm393-projects-journal-tracking.up.railway.app$pdfUrl';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PdfViewerScreen(
                                            pdfUrl: fullUrl,
                                            title: paper['title'] ?? 'PDF Viewer',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.picture_as_pdf, size: 14),
                                    label: const Text('View PDF'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 32),
                                    ),
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: () {
                                      if (paper['_id'] != null) {
                                        context.push<bool>('/app/workspaces/$workspaceId/papers/${paper['_id']}/upload-pdf').then((success) {
                                          if (success == true) {
                                            // Wait for the navigation animation to fully complete before invalidating, 
                                            // ensuring Riverpod's state tree is stable.
                                            Future.delayed(const Duration(milliseconds: 400), () {
                                              ref.invalidate(workspacePapersProvider(workspaceId));
                                            });
                                          }
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.upload_file, size: 14),
                                    label: const Text('Upload PDF'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 32),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

// ======================= NOTES TAB =======================
class WorkspaceNotesTab extends ConsumerWidget {
  final String workspaceId;
  const WorkspaceNotesTab({super.key, required this.workspaceId});

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final contentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Note'),
        content: TextField(
          controller: contentCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Note content', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (contentCtrl.text.isNotEmpty) {
                try {
                  // Omit paperId for general workspace notes if allowed, or put empty string
                  await ref.read(workspaceRepositoryProvider).createWorkspaceNote(workspaceId, '', contentCtrl.text.trim());
                  ref.invalidate(workspaceNotesProvider(workspaceId));
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(workspaceNotesProvider(workspaceId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddNoteDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create Note'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return _buildEmptyState(Icons.note_alt_outlined, 'No notes', 'Click the button above to create a note');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(Icons.note, color: Colors.orange),
                      title: Text(note['content'] ?? 'Empty Note'),
                      subtitle: Text('By: ${note['user']?['fullName'] ?? 'User'}'),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

// ======================= MEMBERS TAB =======================
class WorkspaceMembersTab extends ConsumerWidget {
  final String workspaceId;
  final List<dynamic> members;
  const WorkspaceMembersTab({super.key, required this.workspaceId, required this.members});

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final emailCtrl = TextEditingController();
    String selectedRole = 'editor';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Team Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'User Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                DropdownMenuItem(value: 'editor', child: Text('Editor')),
              ],
              onChanged: (val) => selectedRole = val ?? 'viewer',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailCtrl.text.isNotEmpty) {
                try {
                  await ref.read(workspaceRepositoryProvider).addWorkspaceMember(workspaceId, emailCtrl.text.trim(), selectedRole);
                  ref.invalidate(workspaceDetailProvider(workspaceId)); // refreshes members
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added!')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddMemberDialog(context, ref),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Member'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: members.isEmpty 
          ? _buildEmptyState(Icons.people_outline, 'Team Members', 'Click the button above to invite members')
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  elevation: 0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    title: Text(
                      member['user'] is Map ? member['user']['fullName'] ?? member['user']['email'] ?? 'Unknown' : 'User ID: ${member['user']}', 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text('Role: ${member['role'].toString().toUpperCase()}'),
                  ),
                );
              },
            ),
        ),
      ],
    );
  }
}

// ======================= ALERTS TAB =======================
class WorkspaceAlertsTab extends ConsumerWidget {
  final String workspaceId;
  const WorkspaceAlertsTab({super.key, required this.workspaceId});

  void _showAddAlertDialog(BuildContext context, WidgetRef ref) {
    final queryCtrl = TextEditingController();
    String frequency = 'daily';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: queryCtrl,
              decoration: const InputDecoration(labelText: 'Keywords / Query', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: frequency,
              decoration: const InputDecoration(labelText: 'Frequency', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
              ],
              onChanged: (val) => frequency = val ?? 'daily',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (queryCtrl.text.isNotEmpty) {
                try {
                  await ref.read(workspaceRepositoryProvider).createWorkspaceAlert(workspaceId, queryCtrl.text.trim(), frequency);
                  ref.invalidate(workspaceAlertsProvider(workspaceId));
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(workspaceAlertsProvider(workspaceId));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddAlertDialog(context, ref),
              icon: const Icon(Icons.add_alert),
              label: const Text('Create Alert'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Expanded(
          child: alertsAsync.when(
            data: (alerts) {
              if (alerts.isEmpty) {
                return _buildEmptyState(Icons.notifications_outlined, 'No alerts setup', 'Click the button above to create an alert');
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.redAccent),
                      title: Text(alert['query'] ?? 'Query', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Frequency: ${alert['frequency']}'),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

// ======================= HELPERS =======================
Widget _buildEmptyState(IconData icon, String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
      ],
    ),
  );
}
