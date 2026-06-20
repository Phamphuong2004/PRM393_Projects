import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/workspace_repository.dart';

class UploadPdfState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  UploadPdfState({this.isLoading = false, this.error, this.isSuccess = false});
}

class UploadPdfNotifier extends Notifier<UploadPdfState> {
  @override
  UploadPdfState build() {
    return UploadPdfState();
  }

  Future<void> uploadPdf(String workspaceId, String paperId, File pdfFile) async {
    state = UploadPdfState(isLoading: true);

    try {
      final repository = ref.read(workspaceRepositoryProvider);
      await repository.uploadPaperPdf(
        workspaceId: workspaceId,
        paperId: paperId,
        pdfFile: pdfFile,
      );
      state = UploadPdfState(isLoading: false, isSuccess: true);
    } catch (e) {
      state = UploadPdfState(isLoading: false, error: e.toString());
    }
  }
}

final uploadPdfStateProvider = NotifierProvider<UploadPdfNotifier, UploadPdfState>(() {
  return UploadPdfNotifier();
});
