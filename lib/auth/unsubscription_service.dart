import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _baseUrl = "https://www.flicksize.com/caresync/";

/// Service for handling user unsubscription from BDApps
class UnsubscriptionService {
  /// Unsubscribe a user from the BDApps service
  /// Returns true if unsubscription was successful or if we should continue logout anyway
  /// Returns false only for critical errors that should block logout
  static Future<bool> unsubscribeUser(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        debugPrint('⚠️ Phone number is empty, skipping unsubscription');
        return true; // Continue logout even if no phone number
      }

      debugPrint('🔄 Starting unsubscription for: $phoneNumber');

      final response = await http
          .post(
            Uri.parse('${_baseUrl}unsubscription.php'),
            body: {'user_mobile': phoneNumber},
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        debugPrint('⏱️ Unsubscription request timed out');
        // Timeout should not block logout
        return http.Response('Timeout', 408);
      });

      debugPrint(
        '📡 Unsubscription Response Status: ${response.statusCode}',
      );
      debugPrint('📡 Unsubscription Response Body: ${response.body}');

      if (response.statusCode != 200) {
        debugPrint(
          '⚠️ Unsubscription failed with status ${response.statusCode}',
        );
        // Don't block logout on HTTP errors
        return true;
      }

      try {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          final success = data['success'] ?? false;
          final message = data['message'] ?? '';

          if (success) {
            debugPrint('✅ Unsubscription successful: $message');
            return true;
          } else {
            debugPrint('⚠️ Unsubscription not successful: $message');
            // Don't block logout even if unsubscription wasn't successful
            return true;
          }
        } else {
          debugPrint('⚠️ Unexpected response format');
          return true; // Continue logout
        }
      } catch (parseError) {
        debugPrint('❌ Failed to parse unsubscription response: $parseError');
        // Don't block logout on parse errors
        return true;
      }
    } catch (e) {
      debugPrint('❌ Unsubscription exception: $e');
      // Never block logout, log the error but continue
      return true;
    }
  }
}
