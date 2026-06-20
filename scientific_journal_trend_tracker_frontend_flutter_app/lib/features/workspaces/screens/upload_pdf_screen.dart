import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/workspace_paper_provider.dart';

class UploadPdfScreen extends ConsumerStatefulWidget {
  final String workspaceId;
  final String paperId;

  const UploadPdfScreen({
    Key? key,
    required this.workspaceId,
    required this.paperId,
  }) : super(key: key);

  @override
  ConsumerState<UploadPdfScreen> createState() => _UploadPdfScreenState();
}

class _UploadPdfScreenState extends ConsumerState<UploadPdfScreen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _uploadFile() async {
    if (_selectedFile == null) return;

    await ref.read(uploadPdfStateProvider.notifier).uploadPdf(
          widget.workspaceId,
          widget.paperId,
          _selectedFile!,
        );
        
    final state = ref.read(uploadPdfStateProvider);
    if (state.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${state.error}')),
        );
      }
    } else if (state.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
        Navigator.pop(context); // Trở về màn hình trước sau khi upload thành công
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadPdfStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload PDF for Paper')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            if (_selectedFile != null)
              Text(
                'Selected File: ${_selectedFile!.path.split('/').last}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )
            else
              const Text(
                'No file selected. Please select a PDF file (max 25MB).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: uploadState.isLoading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Pick PDF File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (_selectedFile == null || uploadState.isLoading)
                  ? null
                  : _uploadFile,
              icon: uploadState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.upload),
              label: Text(uploadState.isLoading ? 'Uploading...' : 'Upload PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
