import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../utils/constants.dart';

class PdfViewerWidget extends StatefulWidget {
  final String filePath;
  final String? title;
  final VoidCallback? onShare;
  
  const PdfViewerWidget({
    super.key,
    required this.filePath,
    this.title,
    this.onShare,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Validate file path
    _validateFile();
  }

  Future<void> _validateFile() async {
    try {
      final file = File(widget.filePath);
      final exists = await file.exists();
      
      if (!exists) {
        setState(() {
          _errorMessage = 'File does not exist';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDF: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'PDF Viewer'),
        actions: [
          if (widget.onShare != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: widget.onShare,
              tooltip: 'Share',
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _pdfViewerController.searchText('');
            },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
            tooltip: 'Bookmarks',
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            File(widget.filePath),
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
              setState(() {
                _errorMessage = 'Failed to load PDF: ${details.error}';
                _isLoading = false;
              });
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withAlpha(179),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.zoom_in),
        onPressed: () {
          _showZoomOptions(context);
        },
      ),
    );
  }

  void _showZoomOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.zoom_in),
                title: const Text('Zoom In'),
                onTap: () {
                  _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel + 0.25).clamp(0.25, 3.0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.zoom_out),
                title: const Text('Zoom Out'),
                onTap: () {
                  _pdfViewerController.zoomLevel = (_pdfViewerController.zoomLevel - 0.25).clamp(0.25, 3.0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.fit_screen),
                title: const Text('Fit to Width'),
                onTap: () {
                  _pdfViewerController.zoomLevel = 1.0;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 