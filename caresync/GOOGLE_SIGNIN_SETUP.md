# Firebase Google Sign-In Setup Guide

Google Sign-In requires additional configuration in Firebase Console.

## Setup Steps:

### 1. Enable Google Sign-In Provider
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **CareSync**
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Toggle **Enable**
6. Add your **Support email** (required)
7. Click **Save**

### 2. Add Authorized Domains (for Web)
1. In the same Authentication settings
2. Scroll down to **Authorized domains**
3. Add your domains:
   - `localhost` (for local development)
   - `127.0.0.1` (alternative local)
   - Your production domain (e.g., `caresync-app.web.app`)

### 3. Web Configuration (if needed)
1. Go to **Project Settings** (gear icon)
2. Scroll to **Your apps** section
3. Select your **Web app**
4. Copy the Firebase configuration
5. Ensure it's properly configured in `lib/firebase_options.dart`

### 4. Test Google Sign-In

**For Local Development:**
```bash
flutter run -d chrome --web-port=5000
# or
flutter run -d edge
```

**Note:** 
- Google Sign-In works best on actual domains (not localhost)
- For production, deploy to Firebase Hosting or your domain
- Popup blockers may interfere - allow popups for your domain

## Alternative: Email/Password Authentication

If Google Sign-In is not configured, users can still:
- ✅ Sign up with email/password
- ✅ Verify email via link
- ✅ Reset password
- ✅ Login with verified email

## Troubleshooting

**Error: "unauthorized-domain"**
- Solution: Add your domain to authorized domains in Firebase Console

**Error: "popup-blocked"**
- Solution: Allow popups in browser settings

**Error: "auth/configuration-not-found"**
- Solution: Enable Google provider in Firebase Console

## Current Status
- ✅ Email/Password authentication with OTP verification
- ⚠️ Google Sign-In (requires Firebase Console setup)
- ❌ Apple Sign-In (not implemented)

For immediate testing, use **Email/Password** authentication!
