import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/workspace_repository.dart';

// No autoDispose: providers must survive tab switching + navigation to Search screen
final workspaceDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  return repository.getWorkspaceDetails(id);
});

final workspacePapersProvider = FutureProvider.family<List<dynamic>, String>((ref, id) async {
  // Papers are now included in workspace detail response — reuse that call
  final detail = await ref.watch(workspaceDetailProvider(id).future);
  return detail['papers'] as List<dynamic>? ?? [];
});

final workspaceNotesProvider = FutureProvider.family<List<dynamic>, String>((ref, id) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  final res = await repository.getWorkspaceNotes(id);
  return res['data'] ?? [];
});

final workspaceAlertsProvider = FutureProvider.family<List<dynamic>, String>((ref, id) async {
  final repository = ref.watch(workspaceRepositoryProvider);
  final res = await repository.getWorkspaceAlerts(id);
  return res['data'] ?? [];
});
