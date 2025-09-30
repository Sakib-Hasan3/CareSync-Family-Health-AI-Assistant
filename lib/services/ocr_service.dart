import 'dart:io';

/// OCR result model
class OcrResult {
  final String text;
  final double confidence;
  final List<String> lines;
  final Map<String, dynamic>? metadata;

  OcrResult({
    required this.text,
    required this.confidence,
    required this.lines,
    this.metadata,
  });
}

/// OCR service for text extraction from images
abstract class OcrService {
  Future<void> initialize();
  Future<OcrResult> extractTextFromImage(File imageFile);
  Future<OcrResult> extractTextFromBytes(List<int> imageBytes);
  Future<bool> isAvailable();
  void dispose();
}

/// Implementation using ML Kit or similar OCR service
class OcrServiceImpl implements OcrService {
  bool _initialized = false;
  bool _available = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Simulate ML Kit initialization
      await Future.delayed(const Duration(seconds: 1));
      _available = true;
      _initialized = true;
    } catch (e) {
      _available = false;
      _initialized = true;
      throw Exception('Failed to initialize OCR service: ${e.toString()}');
    }
  }

  @override
  Future<bool> isAvailable() async {
    return _available;
  }

  @override
  Future<OcrResult> extractTextFromImage(File imageFile) async {
    if (!_initialized) {
      throw Exception('OCR service not initialized');
    }

    if (!_available) {
      throw Exception('OCR service not available');
    }

    try {
      // Simulate OCR processing
      await Future.delayed(const Duration(seconds: 2));

      // Mock OCR result based on file name for demonstration
      final fileName = imageFile.path.toLowerCase();
      String extractedText;
      List<String> lines;

      if (fileName.contains('prescription') || fileName.contains('rx')) {
        extractedText = _getMockPrescriptionText();
        lines = extractedText.split('\n');
      } else if (fileName.contains('report') || fileName.contains('lab')) {
        extractedText = _getMockLabReportText();
        lines = extractedText.split('\n');
      } else if (fileName.contains('card') || fileName.contains('insurance')) {
        extractedText = _getMockInsuranceCardText();
        lines = extractedText.split('\n');
      } else {
        extractedText = _getMockGenericText();
        lines = extractedText.split('\n');
      }

      return OcrResult(
        text: extractedText,
        confidence:
            0.85 + (0.1 * (DateTime.now().millisecondsSinceEpoch % 10) / 10),
        lines: lines,
        metadata: {
          'processingTime': 2.1,
          'imageSize': await imageFile.length(),
          'detectedLanguage': 'en',
        },
      );
    } catch (e) {
      throw Exception('OCR processing failed: ${e.toString()}');
    }
  }

  @override
  Future<OcrResult> extractTextFromBytes(List<int> imageBytes) async {
    if (!_initialized) {
      throw Exception('OCR service not initialized');
    }

    if (!_available) {
      throw Exception('OCR service not available');
    }

    try {
      // Simulate OCR processing from bytes
      await Future.delayed(const Duration(seconds: 2));

      // Mock result for bytes input
      const extractedText = 'Sample text extracted from image bytes';
      final lines = extractedText.split('\n');

      return OcrResult(
        text: extractedText,
        confidence: 0.80,
        lines: lines,
        metadata: {
          'processingTime': 1.8,
          'imageSize': imageBytes.length,
          'detectedLanguage': 'en',
        },
      );
    } catch (e) {
      throw Exception('OCR processing failed: ${e.toString()}');
    }
  }

  /// Extract structured data from prescription
  Future<Map<String, dynamic>> extractPrescriptionData(File imageFile) async {
    final ocrResult = await extractTextFromImage(imageFile);

    // Parse prescription data from OCR text
    final prescriptionData = _parsePrescriptionText(ocrResult.text);

    return {
      'rawText': ocrResult.text,
      'confidence': ocrResult.confidence,
      'prescriptionData': prescriptionData,
    };
  }

  /// Extract structured data from lab report
  Future<Map<String, dynamic>> extractLabReportData(File imageFile) async {
    final ocrResult = await extractTextFromImage(imageFile);

    // Parse lab report data from OCR text
    final labData = _parseLabReportText(ocrResult.text);

    return {
      'rawText': ocrResult.text,
      'confidence': ocrResult.confidence,
      'labData': labData,
    };
  }

  /// Mock prescription text
  String _getMockPrescriptionText() {
    return '''Dr. Sarah Johnson MD
Family Medicine Clinic
123 Health Street, City

Date: ${DateTime.now().toString().substring(0, 10)}

Patient: John Doe
DOB: 01/15/1980

Rx: Lisinopril 10mg
Sig: Take 1 tablet by mouth daily
Qty: 30
Refills: 2

Dr. Sarah Johnson
DEA: BJ1234567''';
  }

  /// Mock lab report text
  String _getMockLabReportText() {
    return '''LABORATORY REPORT

Patient: John Doe
DOB: 01/15/1980
Date Collected: ${DateTime.now().toString().substring(0, 10)}

COMPLETE BLOOD COUNT
WBC: 7.2 (4.0-11.0) K/uL
RBC: 4.5 (4.2-5.4) M/uL
Hemoglobin: 14.2 (12.0-16.0) g/dL
Hematocrit: 42.1 (36.0-46.0) %

CHEMISTRY PANEL
Glucose: 95 (70-100) mg/dL
Cholesterol: 180 (< 200) mg/dL
HDL: 45 (> 40) mg/dL
LDL: 120 (< 100) mg/dL''';
  }

  /// Mock insurance card text
  String _getMockInsuranceCardText() {
    return '''HEALTH INSURANCE CARD

Member: JOHN DOE
ID: ABC123456789
Group: GRP001
Plan: PPO STANDARD

Provider: HealthCare Plus
Phone: 1-800-555-0123
Copay: \$25

Valid: 01/2024 - 12/2024''';
  }

  /// Mock generic text
  String _getMockGenericText() {
    return 'Sample text extracted from document using OCR technology.';
  }

  /// Parse prescription text to extract structured data
  Map<String, dynamic> _parsePrescriptionText(String text) {
    // Simple parsing logic (would be more sophisticated in real implementation)
    final lines = text.split('\n');
    final data = <String, dynamic>{};

    for (final line in lines) {
      if (line.toLowerCase().contains('rx:')) {
        data['medication'] = line.split(':')[1].trim();
      } else if (line.toLowerCase().contains('sig:')) {
        data['instructions'] = line.split(':')[1].trim();
      } else if (line.toLowerCase().contains('qty:')) {
        data['quantity'] = line.split(':')[1].trim();
      } else if (line.toLowerCase().contains('refills:')) {
        data['refills'] = line.split(':')[1].trim();
      }
    }

    return data;
  }

  /// Parse lab report text to extract structured data
  Map<String, dynamic> _parseLabReportText(String text) {
    // Simple parsing logic for lab values
    final lines = text.split('\n');
    final data = <String, dynamic>{};
    final results = <Map<String, dynamic>>[];

    for (final line in lines) {
      if (line.contains(':') && line.contains('(')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final testName = parts[0].trim();
          final valueAndRange = parts[1].trim();
          final valueParts = valueAndRange.split('(');
          if (valueParts.length >= 2) {
            final value = valueParts[0].trim();
            final range = valueParts[1].replaceAll(')', '').trim();

            results.add({'test': testName, 'value': value, 'range': range});
          }
        }
      }
    }

    data['results'] = results;
    return data;
  }

  @override
  void dispose() {
    // Clean up resources
    _initialized = false;
    _available = false;
  }
}
