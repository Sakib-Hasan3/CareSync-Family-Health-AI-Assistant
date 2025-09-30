import 'dart:io';
import '../config/app_config.dart';

/// API service for handling HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConfig.baseApiUrl;
  final Duration _timeout = AppConfig.apiTimeout;

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _headersWithAuth(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };

  /// Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final uriWithParams = queryParams != null
          ? uri.replace(queryParameters: queryParams)
          : uri;

      // Simulate HTTP request (replace with actual HTTP client)
      await Future.delayed(const Duration(seconds: 1));

      // Mock response
      return _mockResponse(endpoint);
    } catch (e) {
      throw ApiException('GET request failed: ${e.toString()}');
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = authToken != null
          ? _headersWithAuth(authToken)
          : _headers;

      // Simulate HTTP request (replace with actual HTTP client)
      await Future.delayed(const Duration(seconds: 1));

      // Mock response
      return _mockResponse(endpoint, body: body);
    } catch (e) {
      throw ApiException('POST request failed: ${e.toString()}');
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = authToken != null
          ? _headersWithAuth(authToken)
          : _headers;

      // Simulate HTTP request
      await Future.delayed(const Duration(seconds: 1));

      return _mockResponse(endpoint, body: body);
    } catch (e) {
      throw ApiException('PUT request failed: ${e.toString()}');
    }
  }

  /// Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = authToken != null
          ? _headersWithAuth(authToken)
          : _headers;

      // Simulate HTTP request
      await Future.delayed(const Duration(seconds: 1));

      return {'success': true, 'message': 'Resource deleted successfully'};
    } catch (e) {
      throw ApiException('DELETE request failed: ${e.toString()}');
    }
  }

  /// Upload file
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String? authToken,
    Map<String, String>? additionalFields,
  }) async {
    try {
      // Simulate file upload
      await Future.delayed(const Duration(seconds: 3));

      return {
        'success': true,
        'fileUrl': 'https://example.com/uploads/${file.path.split('/').last}',
        'fileId': 'file_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      throw ApiException('File upload failed: ${e.toString()}');
    }
  }

  /// Mock response generator for development
  Map<String, dynamic> _mockResponse(
    String endpoint, {
    Map<String, dynamic>? body,
  }) {
    // This would be replaced with actual API responses
    if (endpoint.contains('/users')) {
      return {
        'id': 'user_123',
        'name': 'John Doe',
        'email': 'john@example.com',
      };
    } else if (endpoint.contains('/medications')) {
      return {
        'id': 'med_123',
        'name': 'Aspirin',
        'dosage': '100mg',
        'frequency': 'Daily',
      };
    } else if (endpoint.contains('/appointments')) {
      return {
        'id': 'apt_123',
        'doctorName': 'Dr. Smith',
        'date': DateTime.now().toIso8601String(),
        'location': 'Health Center',
      };
    }

    return {
      'success': true,
      'data': body ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Check network connectivity
  Future<bool> isConnected() async {
    try {
      // Simple connectivity check (replace with actual implementation)
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}
