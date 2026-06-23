import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
            onPressed: () => _controller.zoomLevel += 0.25,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
            onPressed: () => _controller.zoomLevel -= 0.25,
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            controller: _controller,
            onDocumentLoaded: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
            onDocumentLoadFailed: (details) {
              if (mounted) setState(() {
                _isLoading = false;
                _error = details.description;
              });
            },
          ),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading PDF...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'There was an error opening this document. If this is an older record, the file might be missing - please try re-uploading the PDF.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_error ?? '', textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade300, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
