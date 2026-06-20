import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/workspace_repository.dart';

final workspaceDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  return repository.getWorkspaceDetails(id);
});

final workspacePapersProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, id) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  final res = await repository.getWorkspacePapers(id);
  return res['data'] ?? [];
});

final workspaceNotesProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, id) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  final res = await repository.getWorkspaceNotes(id);
  return res['data'] ?? [];
});

final workspaceAlertsProvider = FutureProvider.autoDispose.family<List<dynamic>, String>((ref, id) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  final res = await repository.getWorkspaceAlerts(id);
  return res['data'] ?? [];
});
