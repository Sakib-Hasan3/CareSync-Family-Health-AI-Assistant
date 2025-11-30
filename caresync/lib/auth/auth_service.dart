import 'package:firebase_auth/firebase_auth.dart';
import 'otp_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final OTPService _otpService = OTPService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up with OTP Verification
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Send OTP via email
      final otp = await _otpService.sendOTPEmail(email);
      
      // For testing: print OTP to console
      print('DEBUG: OTP for $email: $otp');

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send OTP for email verification
  Future<String> sendOTPForVerification(String email) async {
    try {
      return await _otpService.sendOTPEmail(email);
    } catch (e) {
      throw 'Failed to send OTP: ${e.toString()}';
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      return await _otpService.verifyOTP(email: email, otp: otp);
    } catch (e) {
      throw e.toString();
    }
  }

  // Resend OTP
  Future<String> resendOTP(String email) async {
    try {
      return await _otpService.resendOTP(email);
    } catch (e) {
      throw 'Failed to resend OTP: ${e.toString()}';
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Create Google Auth Provider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      // Add scopes
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      // Sign in with popup for web, redirect for mobile
      try {
        return await _auth.signInWithPopup(googleProvider);
      } catch (e) {
        // Fallback to redirect if popup is blocked
        await _auth.signInWithRedirect(googleProvider);
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-blocked') {
        throw 'Pop-up was blocked. Please allow pop-ups for this site.';
      } else if (e.code == 'popup-closed-by-user') {
        return null; // User closed the popup
      } else if (e.code == 'unauthorized-domain' || 
                 e.code == 'auth/unauthorized-domain') {
        throw 'Google Sign-In is not configured for this domain.\n\nPlease configure Google Sign-In in Firebase Console:\n1. Go to Authentication → Sign-in method\n2. Enable Google provider\n3. Add your domain to authorized domains\n\nFor now, please use Email/Password sign-in.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Google sign-in failed: ${e.toString()}\n\nPlease use email/password sign-in instead.';
    }
  }

  // Send Email Verification OTP
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw 'No user is currently signed in.';
      } else {
        throw 'Email is already verified.';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Resend Verification Email
  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw 'No user is currently signed in.';
      } else {
        throw 'Email is already verified.';
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Handle Firebase Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
