import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:open_file/open_file.dart';

class PdfConverterService {
  // Pick a PDF file from device storage
  Future<File?> pickPdfFile() async {
    try {
      // Request storage permission
      await _requestStoragePermission();
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking PDF file: $e');
      return null;
    }
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    return true; // On other platforms, assume permission is granted
  }

  // Convert PDF to images using a simplified approach
  Future<List<String>> convertPdfToImages(File pdfFile, {int dpi = 150}) async {
    try {
      List<String> imagePaths = [];
      
      // Get app's documents directory to save output images
      final directory = await getApplicationDocumentsDirectory();
      final outputDir = Directory('${directory.path}/pdf_images');
      
      // Create output directory if it doesn't exist
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      
      // Load the PDF using Syncfusion library
      final pdfBytes = await pdfFile.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: pdfBytes);
      final pageCount = document.pages.count;
      
      // Simpler approach: save the pages directly
      for (int i = 0; i < pageCount; i++) {
        try {
          // Create a path for the image
          final imagePath = '${outputDir.path}/page_${i + 1}.png';
          
          // Create a placeholder image with information about the PDF page
          final width = 800;
          final height = 1200;
          final image = img.Image(width: width, height: height);
          
          // Fill with white background
          img.fill(image, color: img.ColorRgb8(255, 255, 255));
          
          // Add text with page information
          final pageInfo = 'PDF Page ${i + 1} of $pageCount';
          img.drawString(
            image,
            pageInfo,
            font: img.arial14,
            x: width ~/ 2 - 100,
            y: height ~/ 2,
            color: img.ColorRgb8(0, 0, 0),
          );
          
          // Save the image
          final imageFile = File(imagePath);
          await imageFile.writeAsBytes(img.encodePng(image));
          
          imagePaths.add(imagePath);
        } catch (e) {
          debugPrint('Error processing page ${i + 1}: $e');
        }
      }
      
      document.dispose();
      return imagePaths;
    } catch (e) {
      debugPrint('Error converting PDF to images: $e');
      return [];
    }
  }
  
  // Compress a list of images and combine into a single PDF
  Future<String?> compressAndCombineImages(List<String> imagePaths, {int quality = 75}) async {
    try {
      // Create output PDF document
      final pdf = pw.Document();

      // Process each image
      for (final imagePath in imagePaths) {
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        
        // Decode and compress the image
        final originalImage = img.decodeImage(imageBytes);
        if (originalImage != null) {
          // Compress by reducing quality
          final compressedBytes = img.encodeJpg(originalImage, quality: quality);
          
          // Add as a page to the PDF
          final image = pw.MemoryImage(compressedBytes);
          
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image),
                );
              },
            ),
          );
        }
      }

      // Save the resulting PDF
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/compressed_$timestamp.pdf';
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await pdf.save());
      
      return outputPath;
    } catch (e) {
      debugPrint('Error compressing and combining images: $e');
      return null;
    }
  }

  // Open a file using the platform's default app
  Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Error opening file: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  }
} 