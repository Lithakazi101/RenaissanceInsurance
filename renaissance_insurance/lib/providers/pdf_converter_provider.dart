import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_converter_service.dart';

enum ConversionStatus {
  idle,
  selectingFile,
  converting,
  compressing,
  completed,
  error
}

class PdfConverterProvider extends ChangeNotifier {
  final PdfConverterService _service = PdfConverterService();
  
  ConversionStatus _status = ConversionStatus.idle;
  String _errorMessage = '';
  double _progress = 0.0;
  File? _selectedPdfFile;
  List<String> _convertedImagePaths = [];
  String? _outputPdfPath;
  int _selectedDpi = 150;
  int _selectedQuality = 75;
  int _currentPage = 0;
  int _totalPages = 0;
  
  // Getters
  ConversionStatus get status => _status;
  String get errorMessage => _errorMessage;
  double get progress => _progress;
  File? get selectedPdfFile => _selectedPdfFile;
  List<String> get convertedImagePaths => _convertedImagePaths;
  String? get outputPdfPath => _outputPdfPath;
  int get selectedDpi => _selectedDpi;
  int get selectedQuality => _selectedQuality;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasSelectedFile => _selectedPdfFile != null;
  bool get hasConvertedImages => _convertedImagePaths.isNotEmpty;
  bool get hasOutputPdf => _outputPdfPath != null;
  bool get isProcessing => _status == ConversionStatus.converting || 
                          _status == ConversionStatus.compressing;
  
  // Set DPI for conversion
  void setDpi(int dpi) {
    _selectedDpi = dpi;
    notifyListeners();
  }
  
  // Set quality for compression
  void setQuality(int quality) {
    _selectedQuality = quality;
    notifyListeners();
  }
  
  // Reset the conversion state
  void reset() {
    _status = ConversionStatus.idle;
    _errorMessage = '';
    _progress = 0.0;
    _selectedPdfFile = null;
    _convertedImagePaths = [];
    _outputPdfPath = null;
    _currentPage = 0;
    _totalPages = 0;
    notifyListeners();
  }
  
  // Select a PDF file
  Future<bool> selectPdfFile() async {
    try {
      _status = ConversionStatus.selectingFile;
      _errorMessage = '';
      notifyListeners();
      
      final file = await _service.pickPdfFile();
      if (file != null) {
        _selectedPdfFile = file;
        _status = ConversionStatus.idle;
        notifyListeners();
        return true;
      } else {
        _status = ConversionStatus.idle;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ConversionStatus.error;
      _errorMessage = 'Failed to select PDF file: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Convert PDF to images
  Future<bool> convertPdfToImages() async {
    if (_selectedPdfFile == null) {
      _errorMessage = 'No PDF file selected';
      return false;
    }
    
    try {
      _status = ConversionStatus.converting;
      _progress = 0.0;
      _convertedImagePaths = [];
      _errorMessage = '';
      notifyListeners();
      
      final imagePaths = await _service.convertPdfToImages(
        _selectedPdfFile!,
        dpi: _selectedDpi,
      );
      
      if (imagePaths.isNotEmpty) {
        _convertedImagePaths = imagePaths;
        _totalPages = imagePaths.length;
        _status = ConversionStatus.completed;
        _progress = 1.0;
        notifyListeners();
        return true;
      } else {
        _status = ConversionStatus.error;
        _errorMessage = 'No images were extracted from the PDF';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ConversionStatus.error;
      _errorMessage = 'Failed to convert PDF to images: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Compress images and combine into a PDF
  Future<bool> compressAndCombineImages() async {
    if (_convertedImagePaths.isEmpty) {
      _errorMessage = 'No images to compress';
      return false;
    }
    
    try {
      _status = ConversionStatus.compressing;
      _progress = 0.0;
      _outputPdfPath = null;
      _errorMessage = '';
      notifyListeners();
      
      final outputPath = await _service.compressAndCombineImages(
        _convertedImagePaths,
        quality: _selectedQuality,
      );
      
      if (outputPath != null) {
        _outputPdfPath = outputPath;
        _status = ConversionStatus.completed;
        _progress = 1.0;
        notifyListeners();
        return true;
      } else {
        _status = ConversionStatus.error;
        _errorMessage = 'Failed to create output PDF';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = ConversionStatus.error;
      _errorMessage = 'Failed to compress and combine images: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Open the output PDF file
  Future<void> openOutputPdf() async {
    if (_outputPdfPath != null) {
      await _service.openFile(_outputPdfPath!);
    }
  }
} 