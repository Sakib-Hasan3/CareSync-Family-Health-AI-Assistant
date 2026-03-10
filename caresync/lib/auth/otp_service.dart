import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate 6-digit OTP
  String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Store OTP in Firestore
  Future<void> storeOTP({
    required String email,
    required String otp,
  }) async {
    await _firestore.collection('email_otps').doc(email).set({
      'otp': otp,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add(const Duration(minutes: 10)),
      'verified': false,
    });
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final doc = await _firestore.collection('email_otps').doc(email).get();
      
      if (!doc.exists) {
        throw 'OTP not found. Please request a new one.';
      }

      final data = doc.data()!;
      final storedOTP = data['otp'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool;

      // Check if already verified
      if (verified) {
        throw 'OTP already used. Please request a new one.';
      }

      // Check if expired
      if (DateTime.now().isAfter(expiresAt)) {
        throw 'OTP expired. Please request a new one.';
      }

      // Verify OTP
      if (storedOTP != otp) {
        throw 'Invalid OTP. Please try again.';
      }

      // Mark as verified
      await _firestore.collection('email_otps').doc(email).update({
        'verified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete OTP after use
  Future<void> deleteOTP(String email) async {
    await _firestore.collection('email_otps').doc(email).delete();
  }

  // Send OTP via email (using Firebase Cloud Functions or email service)
  Future<String> sendOTPEmail(String email) async {
    final otp = generateOTP();
    
    // Store OTP in Firestore
    await storeOTP(email: email, otp: otp);

    // Queue email for sending
    await _firestore.collection('email_queue').add({
      'to': email,
      'subject': 'CareSync - Your Verification Code',
      'html': '''
        <div style="font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #2563EB;">CareSync Email Verification</h2>
          <p>Your verification code is:</p>
          <div style="background-color: #F3F4F6; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
            <h1 style="color: #1F2937; font-size: 36px; letter-spacing: 8px; margin: 0;">$otp</h1>
          </div>
          <p>This code will expire in 10 minutes.</p>
          <p style="color: #6B7280; font-size: 14px;">If you didn't request this code, please ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;">
          <p style="color: #9CA3AF; font-size: 12px;">CareSync - Family Health Management</p>
        </div>
      ''',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return otp; // Return for testing purposes (remove in production)
  }

  // Resend OTP
  Future<String> resendOTP(String email) async {
    // Delete old OTP
    await deleteOTP(email);
    // Send new OTP
    return await sendOTPEmail(email);
  }
}
