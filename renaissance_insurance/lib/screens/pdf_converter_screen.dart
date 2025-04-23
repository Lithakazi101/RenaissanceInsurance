import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pdf_converter_provider.dart';
import '../utils/constants.dart';

class PdfConverterScreen extends StatefulWidget {
  const PdfConverterScreen({super.key});

  @override
  State<PdfConverterScreen> createState() => _PdfConverterScreenState();
}

class _PdfConverterScreenState extends State<PdfConverterScreen> {
  @override
  void initState() {
    super.initState();
    // Reset the converter state when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PdfConverterProvider>(context, listen: false).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF to Image Converter'),
      ),
      body: Consumer<PdfConverterProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                _buildHeaderSection(),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Step 1: Select PDF
                _buildSelectPdfSection(provider),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Step 2: Convert to Images
                if (provider.hasSelectedFile)
                  _buildConvertToImagesSection(provider),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Step 3: Compress and Combine
                if (provider.hasConvertedImages)
                  _buildCompressAndCombineSection(provider),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Step 4: Open Result
                if (provider.hasOutputPdf)
                  _buildResultSection(provider),
                
                // Error message
                if (provider.errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Text(
                      provider.errorMessage,
                      style: AppTextStyles.body.copyWith(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        const Icon(
          Icons.picture_as_pdf,
          size: 64,
          color: AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'PDF to Image Converter',
          style: AppTextStyles.heading1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Convert PDF files to images, compress, and recombine them.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSelectPdfSection(PdfConverterProvider provider) {
    return _buildStepCard(
      step: 1,
      title: 'Select PDF',
      isActive: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (provider.selectedPdfFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildFileInfoCard(provider.selectedPdfFile!),
            ),
          ElevatedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () async {
                    await provider.selectPdfFile();
                  },
            icon: const Icon(Icons.upload_file),
            label: const Text('Select PDF File'),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertToImagesSection(PdfConverterProvider provider) {
    return _buildStepCard(
      step: 2,
      title: 'Convert to Images',
      isActive: provider.hasSelectedFile,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set the DPI (Dots Per Inch) for the conversion:',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: provider.selectedDpi.toDouble(),
                  min: 72,
                  max: 300,
                  divisions: 19,
                  label: '${provider.selectedDpi} DPI',
                  onChanged: provider.isProcessing
                      ? null
                      : (value) {
                          provider.setDpi(value.round());
                        },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '${provider.selectedDpi} DPI',
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (provider.convertedImagePaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Successfully converted ${provider.convertedImagePaths.length} pages',
                style: AppTextStyles.body.copyWith(color: AppColors.success),
              ),
            ),
          ElevatedButton.icon(
            onPressed: (provider.isProcessing || !provider.hasSelectedFile)
                ? null
                : () async {
                    await provider.convertPdfToImages();
                  },
            icon: const Icon(Icons.image),
            label: Text(
              provider.status == ConversionStatus.converting
                  ? 'Converting...'
                  : 'Convert to Images',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompressAndCombineSection(PdfConverterProvider provider) {
    return _buildStepCard(
      step: 3,
      title: 'Compress & Combine',
      isActive: provider.hasConvertedImages,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set the compression quality:',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: provider.selectedQuality.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 18,
                  label: '${provider.selectedQuality}%',
                  onChanged: provider.isProcessing
                      ? null
                      : (value) {
                          provider.setQuality(value.round());
                        },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '${provider.selectedQuality}%',
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (provider.outputPdfPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Successfully created compressed PDF',
                style: AppTextStyles.body.copyWith(color: AppColors.success),
              ),
            ),
          ElevatedButton.icon(
            onPressed: (provider.isProcessing || !provider.hasConvertedImages)
                ? null
                : () async {
                    await provider.compressAndCombineImages();
                  },
            icon: const Icon(Icons.compress),
            label: Text(
              provider.status == ConversionStatus.compressing
                  ? 'Compressing...'
                  : 'Compress & Combine',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(PdfConverterProvider provider) {
    return _buildStepCard(
      step: 4,
      title: 'Open Result',
      isActive: provider.hasOutputPdf,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your compressed PDF is ready!',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: provider.isProcessing
                ? null
                : () async {
                    await provider.openOutputPdf();
                  },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required int step,
    required String title,
    required bool isActive,
    required Widget content,
  }) {
    return Card(
      elevation: isActive ? 2 : 1,
      color: isActive ? Colors.white : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$step',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    color: isActive ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoCard(File file) {
    final fileSize = file.lengthSync();
    final fileSizeString = _formatFileSize(fileSize);
    final fileName = file.path.split('/').last;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected File:',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fileName,
            style: AppTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Size: $fileSizeString',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
} 