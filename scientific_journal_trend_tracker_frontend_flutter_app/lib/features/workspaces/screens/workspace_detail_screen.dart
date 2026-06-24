import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/workspace_detail_provider.dart';
import '../../../core/repositories/workspace_repository.dart';
import '../../../core/constants/api_constants.dart';

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
        actions: [
          detailAsync.when(
            data: (data) {
              if (data['role'] == 'owner') {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditWorkspaceDialog(context, ref, data['workspace']);
                    } else if (value == 'delete') {
                      _showDeleteWorkspaceDialog(context, ref, data['workspace']);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit Workspace')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete Workspace', style: TextStyle(color: Colors.red))])),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, ___) => const SizedBox.shrink(),
          ),
        ],
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
                      WorkspacePapersTab(workspaceId: workspaceId, role: role),
                      WorkspaceNotesTab(workspaceId: workspaceId, role: role),
                      WorkspaceMembersTab(workspaceId: workspaceId, members: members, role: role),
                      WorkspaceAlertsTab(workspaceId: workspaceId, role: role),
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

  void _showEditWorkspaceDialog(BuildContext context, WidgetRef ref, dynamic workspace) {
    final nameCtrl = TextEditingController(text: workspace['name']);
    final descCtrl = TextEditingController(text: workspace['description']);
    String visibility = workspace['visibility'] ?? 'team';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: visibility,
              decoration: const InputDecoration(labelText: 'Visibility', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'team', child: Text('Team')),
                DropdownMenuItem(value: 'private', child: Text('Private')),
              ],
              onChanged: (val) => visibility = val ?? 'team',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                try {
                  await ref.read(workspaceRepositoryProvider).updateWorkspace(workspaceId, name: nameCtrl.text, description: descCtrl.text, visibility: visibility);
                  ref.invalidate(workspaceDetailProvider(workspaceId));
                  if (context.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteWorkspaceDialog(BuildContext context, WidgetRef ref, dynamic workspace) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workspace', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to delete "${workspace['name']}"? This will delete all associated papers, notes, and alerts. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              try {
                await ref.read(workspaceRepositoryProvider).deleteWorkspace(workspaceId);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  context.go('/app/workspaces');
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ======================= PAPERS TAB =======================
class WorkspacePapersTab extends ConsumerWidget {
  final String workspaceId;
  final String role;
  const WorkspacePapersTab({super.key, required this.workspaceId, required this.role});

  void _showAddPaperDialog(BuildContext context, WidgetRef ref) {
    context.push('/app/search?workspaceId=$workspaceId').then((_) {
      // Force a fresh fetch when returning from search
      ref.invalidate(workspacePapersProvider(workspaceId));
    });
  }

  void _removePaper(BuildContext context, WidgetRef ref, String paperId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Paper'),
        content: const Text('Are you sure you want to remove this paper from the workspace?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(workspaceRepositoryProvider).removePaperFromWorkspace(workspaceId, paperId);
        ref.invalidate(workspacePapersProvider(workspaceId));
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paper removed')));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
                                if (role == 'owner' || role == 'editor')
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                    onPressed: () => _removePaper(context, ref, paper['_id']),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                const SizedBox(width: 8),
                                if (hasPdf)
                                  TextButton.icon(
                                    onPressed: () async {
                                      // Cloudinary returns an absolute URL; older
                                      // records may still hold a relative /uploads path.
                                      final fullUrl = pdfUrl.startsWith('http')
                                          ? pdfUrl
                                          : '${ApiConstants.baseUrl}$pdfUrl';
                                      final uri = Uri.parse(fullUrl);
                                      final ok = await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                      if (!ok && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Could not open PDF link'),
                                          ),
                                        );
                                      }
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
  final String role;
  const WorkspaceNotesTab({super.key, required this.workspaceId, required this.role});

  void _showAddNoteDialog(BuildContext context, WidgetRef ref, {dynamic note}) {
    final contentCtrl = TextEditingController(text: note?['content']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(note == null ? 'Create Note' : 'Edit Note'),
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
                  if (note == null) {
                    await ref.read(workspaceRepositoryProvider).createWorkspaceNote(workspaceId, '', contentCtrl.text.trim());
                  } else {
                    await ref.read(workspaceRepositoryProvider).updateWorkspaceNote(workspaceId, note['_id'], contentCtrl.text.trim());
                  }
                  ref.invalidate(workspaceNotesProvider(workspaceId));
                  if (context.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(BuildContext context, WidgetRef ref, String noteId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(workspaceRepositoryProvider).deleteWorkspaceNote(workspaceId, noteId);
        ref.invalidate(workspaceNotesProvider(workspaceId));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
                      trailing: (role == 'owner' || role == 'editor') ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showAddNoteDialog(context, ref, note: note)),
                          IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _deleteNote(context, ref, note['_id'])),
                        ],
                      ) : null,
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
  final String role;
  const WorkspaceMembersTab({super.key, required this.workspaceId, required this.members, required this.role});

  void _removeMember(BuildContext context, WidgetRef ref, String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove $name from the workspace?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(workspaceRepositoryProvider).removeWorkspaceMember(workspaceId, userId);
        ref.invalidate(workspaceDetailProvider(workspaceId));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

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
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added!')));
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    trailing: (role == 'owner' && member['role'] != 'owner')
                      ? IconButton(
                          icon: const Icon(Icons.person_remove, color: Colors.red, size: 20),
                          onPressed: () => _removeMember(
                            context, 
                            ref, 
                            member['user'] is Map ? member['user']['_id'] : member['user'],
                            member['user'] is Map ? member['user']['fullName'] ?? 'User' : 'User'
                          ),
                        )
                      : null,
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
  final String role;
  const WorkspaceAlertsTab({super.key, required this.workspaceId, required this.role});

  void _deleteAlert(BuildContext context, WidgetRef ref, String alertId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(workspaceRepositoryProvider).deleteWorkspaceAlert(workspaceId, alertId);
        ref.invalidate(workspaceAlertsProvider(workspaceId));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

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
                  if (context.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                      trailing: (role == 'owner' || role == 'editor') ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deleteAlert(context, ref, alert['_id']),
                      ) : null,
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
