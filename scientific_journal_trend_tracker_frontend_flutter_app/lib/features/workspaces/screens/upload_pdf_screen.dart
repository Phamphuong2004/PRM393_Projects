import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/workspace_paper_provider.dart';
import '../providers/workspace_detail_provider.dart';

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
  String? _fileName;
  int? _fileSize;
  List<int>? _fileBytes; // for web

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,  // Always get bytes (works on both mobile and web)
    );

    if (result != null && result.files.isNotEmpty) {
      final picked = result.files.single;

      setState(() {
        _fileName = picked.name;
        _fileSize = picked.size;
        _fileBytes = picked.bytes;

        // Mobile: also set File from path if available
        if (picked.path != null) {
          _selectedFile = File(picked.path!);
        } else {
          _selectedFile = null; // web: no path, only bytes
        }
      });

      if (picked.bytes == null && picked.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not read file. Please try again.'),
            backgroundColor: Colors.orange,
          ));
        }
      }
    }
  }

  bool get _hasFile => _fileBytes != null || _selectedFile != null;

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _uploadFile() async {
    if (_fileBytes == null && _selectedFile == null) return;

    await ref.read(uploadPdfStateProvider.notifier).uploadPdf(
      widget.workspaceId,
      widget.paperId,
      file: _selectedFile,
      bytes: _fileBytes,
      fileName: _fileName ?? 'upload.pdf',
    );

    final state = ref.read(uploadPdfStateProvider);
    if (state.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (state.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Pass true to indicate success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadPdfStateProvider);
    final hasFile = _hasFile;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload PDF for Paper'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PDF icon + status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: hasFile
                  ? Column(
                      key: const ValueKey('file_selected'),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.picture_as_pdf, size: 64, color: Colors.green),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _fileName ?? 'File selected',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (_fileSize != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _formatSize(_fileSize),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      key: const ValueKey('no_file'),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.picture_as_pdf, size: 64, color: Colors.redAccent),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No file selected.\nPlease select a PDF file (max 25MB).',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 40),

            // Pick button
            OutlinedButton.icon(
              onPressed: uploadState.isLoading ? null : _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(hasFile ? 'Change File' : 'Pick PDF File'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),

            // Upload button
            ElevatedButton.icon(
              onPressed: (!hasFile || uploadState.isLoading) ? null : _uploadFile,
              icon: uploadState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(uploadState.isLoading ? 'Uploading...' : 'Upload PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
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
