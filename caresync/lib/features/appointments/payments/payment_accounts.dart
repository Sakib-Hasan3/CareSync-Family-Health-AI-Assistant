import 'package:flutter/material.dart';

/// Payment account configuration for clinic — replace placeholders with real values.
/// Enhanced with validation, multiple accounts, and better organization.
class PaymentAccounts {
  // Map method -> list of account details (supporting multiple accounts per method)
  static const Map<String, List<PaymentAccount>> _accounts = {
    'bKash': [
      PaymentAccount(
        number: '017XXXXXXXX',
        receiver: 'CareSync Clinic',
        type: 'Personal',
        uri: 'bkash://payment/?number=017XXXXXXXX',
        instructions: 'Send money to this bKash number and include Appointment ID in reference',
      ),
      PaymentAccount(
        number: '019XXXXXXXX',
        receiver: 'CareSync Emergency',
        type: 'Corporate',
        uri: 'bkash://payment/?number=019XXXXXXXX',
        instructions: 'For emergency payments only',
      ),
    ],
    'Nagad': [
      PaymentAccount(
        number: '018YYYYYYYY',
        receiver: 'CareSync Clinic',
        type: 'Personal',
        uri: 'nagad://payment/?number=018YYYYYYYY',
        instructions: 'Send money to this Nagad number and include Appointment ID in reference',
      ),
    ],
    'Rocket': [
      PaymentAccount(
        number: '015ZZZZZZZZ',
        receiver: 'CareSync Clinic',
        type: 'Bank Account',
        uri: 'rocket://payment/?number=015ZZZZZZZZ',
        instructions: 'Send to Rocket number and mention Appointment ID',
      ),
    ],
    'Cash': [
      PaymentAccount(
        number: 'N/A',
        receiver: 'CareSync Clinic Reception',
        type: 'In-Person',
        uri: '',
        instructions: 'Pay at clinic reception during your visit',
      ),
    ],
  };

  /// Get primary account for a payment method
  static PaymentAccount primaryAccountFor(String method) {
    final accounts = _accounts[method];
    if (accounts == null || accounts.isEmpty) {
      return PaymentAccount(
        number: 'Not Configured',
        receiver: 'CareSync Clinic',
        type: 'Unknown',
        uri: '',
        instructions: 'Please contact clinic for payment information',
      );
    }
    return accounts.first;
  }

  /// Get all accounts for a payment method
  static List<PaymentAccount> allAccountsFor(String method) {
    return _accounts[method] ?? [];
  }

  /// Check if a payment method is supported
  static bool supportsMethod(String method) {
    return _accounts.containsKey(method) && _accounts[method]!.isNotEmpty;
  }

  /// Get all supported payment methods
  static List<String> get supportedMethods => _accounts.keys.toList();

  /// Get account number for a method (primary account)
  static String accountNumberFor(String method) => 
      primaryAccountFor(method).number;

  /// Get receiver name for a method (primary account)
  static String receiverFor(String method) => 
      primaryAccountFor(method).receiver;

  /// Get deep link URI for a method (primary account)
  static String uriFor(String method) => 
      primaryAccountFor(method).uri;

  /// Get payment instructions for a method
  static String instructionsFor(String method) => 
      primaryAccountFor(method).instructions;

  /// Validate if an account number is properly configured (not placeholder)
  static bool isAccountConfigured(String method) {
    final account = primaryAccountFor(method);
    return !account.number.contains('X') && 
           !account.number.contains('Y') && 
           !account.number.contains('Z') &&
           account.number != 'Not Configured';
  }

  /// Get formatted account info for display
  static String formattedAccountInfo(String method) {
    final account = primaryAccountFor(method);
    return '${account.receiver}\n${account.number}';
  }

  /// Get payment methods that are properly configured
  static List<String> get configuredMethods {
    return _accounts.keys.where((method) => isAccountConfigured(method)).toList();
  }

  /// Get payment method display names with icons
  static Map<String, Map<String, dynamic>> get methodDisplayInfo {
    return {
      'bKash': {
        'name': 'bKash',
        'icon': 'assets/payment/bkash.png',
        'color': Color(0xFFE2136E),
        'description': 'Mobile Financial Service',
      },
      'Nagad': {
        'name': 'Nagad',
        'icon': 'assets/payment/nagad.png',
        'color': Color(0xFFE30B17),
        'description': 'Digital Financial Service',
      },
      'Rocket': {
        'name': 'Rocket',
        'icon': 'assets/payment/rocket.png',
        'color': Color(0xFF0B9E28),
        'description': 'DBBL Mobile Banking',
      },
      'Cash': {
        'name': 'Cash',
        'icon': 'assets/payment/cash.png',
        'color': Color(0xFF4CAF50),
        'description': 'Pay at Clinic',
      },
    };
  }
}

/// Data class to hold payment account information
class PaymentAccount {
  final String number;
  final String receiver;
  final String type;
  final String uri;
  final String instructions;

  const PaymentAccount({
    required this.number,
    required this.receiver,
    required this.type,
    required this.uri,
    required this.instructions,
  });

  /// Check if this account supports deep linking
  bool get supportsDeepLink => uri.isNotEmpty;

  /// Get a formatted display string
  String get displayInfo => '$receiver - $number';

  /// Copy with new values
  PaymentAccount copyWith({
    String? number,
    String? receiver,
    String? type,
    String? uri,
    String? instructions,
  }) {
    return PaymentAccount(
      number: number ?? this.number,
      receiver: receiver ?? this.receiver,
      type: type ?? this.type,
      uri: uri ?? this.uri,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  String toString() {
    return 'PaymentAccount(number: $number, receiver: $receiver, type: $type)';
  }
}

/// Utility class for payment-related operations
class PaymentUtils {
  /// Generate a payment reference number with appointment ID
  static String generatePaymentReference(String appointmentId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    final tail = (appointmentId.length >= 4)
        ? appointmentId.substring(appointmentId.length - 4)
        : appointmentId;
    // include a short random suffix to reduce collisions
    final suffix = random.toString().padLeft(4, '0');
    return 'CS${timestamp}_${tail}_$suffix';
  }

  /// Validate phone number format for Bangladesh
  static bool isValidBangladeshiNumber(String number) {
    final regex = RegExp(r'^(?:\+88|01[3-9])[0-9]{8}$');
    return regex.hasMatch(number.replaceAll(RegExp(r'[\s\-]'), ''));
  }

  /// Format payment amount for display
  static String formatAmount(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  /// Get payment method icon based on method name
  static IconData getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'bkash':
        return Icons.phone_android_rounded;
      case 'nagad':
        return Icons.phone_iphone_rounded;
      case 'rocket':
        return Icons.account_balance_wallet_rounded;
      case 'cash':
        return Icons.attach_money_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  /// Get payment method color
  static Color getPaymentColor(String method) {
    switch (method.toLowerCase()) {
      case 'bkash':
        return const Color(0xFFE2136E);
      case 'nagad':
        return const Color(0xFFE30B17);
      case 'rocket':
        return const Color(0xFF0B9E28);
      case 'cash':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2196F3);
    }
  }
}