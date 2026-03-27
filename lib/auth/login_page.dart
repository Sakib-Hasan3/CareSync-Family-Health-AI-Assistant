import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

const String _baseUrl = "https://www.flicksize.com/caresync/";

bool _isSupportedRobiAirtelNumber(String phone) {
  return RegExp(r'^01(?:6|8)\d{8}$').hasMatch(phone);
}

// Retry with exponential backoff
Future<http.Response> _makeRequestWithRetry(
  Future<http.Response> Function() request, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int attempts = 0;
  Duration delay = initialDelay;
  dynamic lastError;

  while (attempts < maxRetries) {
    try {
      debugPrint('🔄 Request attempt ${attempts + 1}/$maxRetries');
      final response = await request().timeout(const Duration(seconds: 25));
      debugPrint('✅ Request succeeded on attempt ${attempts + 1}');
      return response;
    } catch (e) {
      lastError = e;
      attempts++;
      final errorType = _getErrorType(e);
      debugPrint('❌ Request failed (attempt $attempts): [$errorType] $e');

      if (attempts >= maxRetries) {
        debugPrint('⛔ Max retries ($maxRetries) reached. Error: $e');
        rethrow;
      }

      // Wait before retrying with exponential backoff
      debugPrint('⏳ Waiting ${delay.inSeconds}s before retry...');
      await Future.delayed(delay);
      delay *= 2; // Double the delay for next retry
    }
  }

  throw Exception('Request failed after $maxRetries retries: $lastError');
}

String _getErrorType(dynamic error) {
  final errorStr = error.toString().toLowerCase();
  if (errorStr.contains('timeout')) return 'TIMEOUT';
  if (errorStr.contains('connection')) return 'CONNECTION_ERROR';
  if (errorStr.contains('dns')) return 'DNS_ERROR';
  if (errorStr.contains('certificate')) return 'SSL_CERTIFICATE_ERROR';
  if (errorStr.contains('refused')) return 'CONNECTION_REFUSED';
  if (errorStr.contains('network')) return 'NETWORK_ERROR';
  return 'UNKNOWN_ERROR';
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _checkAlreadySubscribed(String phone) async {
    try {
      debugPrint('Checking subscription for: $phone');

      final response = await _makeRequestWithRetry(
        () => http.post(
          Uri.parse('${_baseUrl}check_subscription.php'),
          body: {'user_mobile': phone},
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        maxRetries: 2,
      );

      if (response.statusCode != 200) {
        debugPrint('Subscription check failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        debugPrint('Invalid subscription response format');
        return false;
      }

      final status =
          decoded['subscriptionStatus']?.toString().trim().toUpperCase() ?? '';
      final isSubscribed = status == 'REGISTERED';

      debugPrint('Subscription status: $status, isSubscribed: $isSubscribed');
      return isSubscribed;
    } catch (e) {
      debugPrint('Subscription check error: $e');
      return false;
    }
  }

  Future<void> _onContinue() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showError('Please enter a mobile number');
      return;
    }
    if (!_isSupportedRobiAirtelNumber(phone)) {
      _showError('Please enter a valid Robi/Airtel number (016/018)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if already subscribed
      final isSubscribed = await _checkAlreadySubscribed(phone);

      if (isSubscribed) {
        _showSuccess('Welcome! Logging in...');
        await Future.delayed(const Duration(milliseconds: 800));

        try {
          await _saveAndGoHome(phone);
        } catch (e) {
          if (mounted) {
            _showError('Login failed. Please try again.');
            setState(() => _isLoading = false);
          }
        }
        return;
      }

      // Send OTP request with retry logic
      _showSuccess('Sending OTP...');

      try {
        final otpResponse = await _makeRequestWithRetry(
          () => http.post(
            Uri.parse('${_baseUrl}send_otp.php'),
            body: {'user_mobile': phone},
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
          maxRetries: 3,
          initialDelay: const Duration(seconds: 2),
        );

        debugPrint('OTP Response Status: ${otpResponse.statusCode}');
        debugPrint('OTP Response Body: ${otpResponse.body}');

        if (otpResponse.statusCode != 200) {
          _showError('Server connection failed. Please try again later.');
          setState(() => _isLoading = false);
          return;
        }

        dynamic otpData;
        try {
          otpData = jsonDecode(otpResponse.body);
        } catch (e) {
          debugPrint('JSON Parse Error: $e');
          _showError('Invalid response from server');
          setState(() => _isLoading = false);
          return;
        }

        if (otpData is! Map<String, dynamic>) {
          _showError('Unexpected server response');
          setState(() => _isLoading = false);
          return;
        }

        final success = otpData['success'] == true;
        final referenceNo = otpData['referenceNo']?.toString().trim() ?? '';
        final message = otpData['message']?.toString() ?? '';
        final statusDetail = otpData['statusDetail']?.toString() ?? '';
        final statusCode = otpData['statusCode']?.toString().trim() ?? '';

        debugPrint(
          'Success: $success, RefNo: $referenceNo, StatusCode: $statusCode',
        );

        if (success && referenceNo.isNotEmpty) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OtpVerifyPage(phone: phone, referenceNo: referenceNo),
            ),
          );
        } else if (statusCode == 'E1351' ||
            message.toLowerCase().contains('already registered')) {
          _showSuccess('Already registered! Logging in...');
          await Future.delayed(const Duration(milliseconds: 800));

          try {
            await _saveAndGoHome(phone);
          } catch (e) {
            if (mounted) {
              _showError('Login failed. Please try again later.');
              setState(() => _isLoading = false);
            }
          }
        } else {
          final errorMsg = message.isNotEmpty
              ? message
              : (statusDetail.isNotEmpty
                    ? statusDetail
                    : 'Failed to send OTP. Please check your internet connection.');
          debugPrint('Error: $errorMsg');
          _showError(errorMsg);
          setState(() => _isLoading = false);
        }
      } catch (e) {
        debugPrint('❌ OTP send exception: $e');
        if (!mounted) return;
        setState(() => _isLoading = false);

        final errorMsg = _getDetailedErrorMessage(e);
        _showError(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      final errorMsg = _getDetailedErrorMessage(e);
      _showError(errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndGoHome(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', phone);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Error messages
  String _getDetailedErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    debugPrint('🔍 Error analysis: $error');

    if (errorStr.contains('timeout')) {
      return 'Server is not responding. Please check your internet connection and try again.';
    }
    if (errorStr.contains('connection refused')) {
      return 'Server connection refused. The server might be offline.';
    }
    if (errorStr.contains('dns') || errorStr.contains('host')) {
      return 'Server not found. Domain name may be incorrect or network issue exists.';
    }
    if (errorStr.contains('certificate') || errorStr.contains('ssl')) {
      return 'Server security certificate issue. Please check your device date/time.';
    }
    if (errorStr.contains('network')) {
      return 'No network connection. Please check your internet.';
    }
    if (errorStr.contains('refused') || errorStr.contains('connect')) {
      return 'Cannot connect to server. Please check if the server is online.';
    }

    return 'Server error occurred. Please try again later.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Logo/Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Welcome Text
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your family health care in one app',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Phone Number Input
                Text(
                  'Mobile Number',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '+8801812345678',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 16),

                // Supported Networks Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFF2563EB),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Use Robi/Airtel number with 016 or 018 prefix',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Continue Button
                _isLoading
                    ? Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : FilledButton(
                        onPressed: _onContinue,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Next',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                const SizedBox(height: 24),

                // Footer / Terms
                Center(
                  child: Text(
                    'By using the app, you agree to our terms and privacy policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpVerifyPage extends StatefulWidget {
  final String phone;
  final String referenceNo;

  const OtpVerifyPage({
    super.key,
    required this.phone,
    required this.referenceNo,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 4) {
      _showError('Please enter a valid OTP (4-6 digits)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _makeRequestWithRetry(
        () => http.post(
          Uri.parse('${_baseUrl}verify_otp.php'),
          body: {
            'Otp': otp,
            'referenceNo': widget.referenceNo,
            'user_mobile': widget.phone,
          },
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        maxRetries: 2,
      );

      debugPrint('OTP Verify Response Status: ${response.statusCode}');
      debugPrint('OTP Verify Response: ${response.body}');

      if (response.statusCode != 200) {
        _showError('Server connection failed');
        setState(() => _isLoading = false);
        return;
      }

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        debugPrint('JSON Parse Error: $e');
        _showError('সার্ভার থেকে ভুল তথ্য এসেছে');
        setState(() => _isLoading = false);
        return;
      }

      if (data is! Map<String, dynamic>) {
        _showError('অপ্রত্যাশিত সার্ভার প্রতিক্রিয়া');
        setState(() => _isLoading = false);
        return;
      }

      final statusCode =
          data['statusCode']?.toString().trim().toUpperCase() ?? '';

      debugPrint('OTP Status Code: $statusCode');

      if (statusCode == 'S1000') {
        // OTP verified successfully - save credentials immediately
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userPhone', widget.phone);

        // Wait briefly for subscription sync, then continue to login.
        final subscribed = await _waitForSubscriptionSync();

        if (!mounted) return;
        if (!subscribed) {
          _showWarning(
            'Subscription is processing. Please login after a moment.',
          );
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      } else {
        final message = data['message']?.toString() ?? 'Invalid OTP';
        debugPrint('OTP Error Message: $message');
        _showError(message);
      }
    } catch (e) {
      debugPrint('❌ OTP Exception: $e');
      // Use the same detailed error message function
      final errorMsg = (e.toString().toLowerCase().contains('timeout'))
          ? 'OTP যাচাইতে সময় লেগেছে। ফিরে যান এবং পুনরায় চেষ্টা করুন।'
          : (e.toString().toLowerCase().contains('connection'))
          ? 'সার্ভারে সংযোগ করতে পারছি না। ইন্টারনেট চেক করুন।'
          : 'সার্ভার সমস্যা হয়েছে। ফিরে যান এবং পুনরায় চেষ্টা করুন।';
      _showError(errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Wait for subscription to sync - reduced to 5 checks for faster UX
  Future<bool> _waitForSubscriptionSync() async {
    for (var i = 0; i < 5; i++) {
      await Future.delayed(const Duration(seconds: 1));

      try {
        debugPrint('Subscription sync check ${i + 1}/5');
        final response = await _makeRequestWithRetry(
          () => http.post(
            Uri.parse('${_baseUrl}check_subscription.php'),
            body: {'user_mobile': widget.phone},
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
          maxRetries: 1,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            final status =
                data['subscriptionStatus']?.toString().trim().toUpperCase() ??
                '';
            debugPrint('Subscription sync status: $status');
            // Only accept REGISTERED (means charging succeeded)
            if (status == 'REGISTERED') {
              return true;
            }
          }
        }
      } catch (e) {
        debugPrint('Subscription sync check error: $e');
        // Continue checking
      }
    }

    return false;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Verify OTP'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Enter OTP',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Phone Number
                Text(
                  widget.phone,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),

                // Message
                Text(
                  'An OTP code has been sent to ${widget.phone}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // OTP Input
                Text(
                  'OTP Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontSize: 32,
                    letterSpacing: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 32,
                      letterSpacing: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF10B981),
                        width: 2.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Verify Button
                _isLoading
                    ? Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : FilledButton(
                        onPressed: _verifyOtp,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Verify',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Back Button
                TextButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Wrong number?'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Reference Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Reference No: ${widget.referenceNo}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
