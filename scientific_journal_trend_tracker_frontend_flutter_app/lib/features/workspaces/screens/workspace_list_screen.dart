import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/animated_background.dart';
import '../providers/workspace_list_provider.dart';

class WorkspaceListScreen extends ConsumerWidget {
  const WorkspaceListScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedVisibility = 'team';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Workspace Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedVisibility,
                    decoration: const InputDecoration(
                      labelText: 'Visibility',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'private', child: Text('Private')),
                      DropdownMenuItem(value: 'team', child: Text('Team')),
                      DropdownMenuItem(value: 'public', child: Text('Public')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedVisibility = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(context);
                      await ref.read(createWorkspaceStateProvider.notifier).createWorkspace(
                        name, 
                        descController.text.trim(), 
                        selectedVisibility
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildWorkspaceCard(BuildContext context, dynamic workspace) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/app/workspaces/${workspace.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.workspaces_filled, color: Theme.of(context).primaryColor, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workspace.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      workspace.description.isEmpty ? 'No description' : workspace.description,
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            workspace.visibility.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspacesAsync = ref.watch(workspacesProvider);
    final invitationsAsync = ref.watch(pendingInvitationsProvider);
    final createState = ref.watch(createWorkspaceStateProvider);
    final inviteState = ref.watch(workspaceInviteStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspaces', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => _showCreateDialog(context, ref),
            ),
          ),
        ],
      ),
      body: AnimatedBackground(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(workspacesProvider);
                ref.invalidate(pendingInvitationsProvider);
              },
              child: CustomScrollView(
                slivers: [
                  // INVITATIONS SECTION
                  invitationsAsync.when(
                    data: (invitations) {
                      if (invitations.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
                            child: Text(
                              'Pending Invitations',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor),
                            ),
                          ),
                          ...invitations.map((workspace) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  color: Colors.orange.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(Icons.mail_outline, color: Colors.orange.shade700, size: 32),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(workspace.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(height: 4),
                                              Text('You have been invited to join this workspace.', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check_circle, color: Colors.green),
                                              onPressed: () => ref.read(workspaceInviteStateProvider.notifier).respondToInvite(workspace.id, 'accept'),
                                              tooltip: 'Accept',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.cancel, color: Colors.red),
                                              onPressed: () => ref.read(workspaceInviteStateProvider.notifier).respondToInvite(workspace.id, 'reject'),
                                              tooltip: 'Decline',
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                        ]),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (e, s) => SliverToBoxAdapter(child: Text('Error loading invites: $e')),
                  ),
                  
                  // WORKSPACES SECTION
                  workspacesAsync.when(
                    data: (workspaces) {
                      if (workspaces.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.workspaces_outline, size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text('No workspaces yet', style: TextStyle(fontSize: 20, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Create one to collaborate with your team', style: TextStyle(color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == 0 && (invitationsAsync.value?.isNotEmpty ?? false)) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                      child: Text(
                                        'Your Workspaces',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                                    _buildWorkspaceCard(context, workspaces[0]),
                                  ],
                                );
                              }
                              return _buildWorkspaceCard(context, workspaces[index]);
                            },
                            childCount: workspaces.length,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                    error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
                  ),
                ],
              ),
            ),
            
            if (createState.isLoading || inviteState.isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.7),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
