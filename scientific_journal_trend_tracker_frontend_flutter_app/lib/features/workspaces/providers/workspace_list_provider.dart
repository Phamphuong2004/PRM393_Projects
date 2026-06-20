import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/workspace.dart';
import '../../../core/repositories/workspace_repository.dart';

final workspacesProvider = FutureProvider.autoDispose<List<Workspace>>((ref) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  return repository.getWorkspaces();
});

class WorkspaceListState {
  final bool isLoading;
  final String? error;
  
  WorkspaceListState({this.isLoading = false, this.error});
}

class CreateWorkspaceNotifier extends Notifier<WorkspaceListState> {
  @override
  WorkspaceListState build() {
    return WorkspaceListState();
  }

  Future<void> createWorkspace(String name, String description, String visibility) async {
    state = WorkspaceListState(isLoading: true);
    try {
      final repository = ref.read(workspaceRepositoryProvider);
      await repository.createWorkspace(name, description, visibility);
      ref.invalidate(workspacesProvider); // Refresh list
      state = WorkspaceListState(isLoading: false);
    } catch (e) {
      state = WorkspaceListState(isLoading: false, error: e.toString());
    }
  }
}

final createWorkspaceStateProvider = NotifierProvider<CreateWorkspaceNotifier, WorkspaceListState>(() {
  return CreateWorkspaceNotifier();
});
