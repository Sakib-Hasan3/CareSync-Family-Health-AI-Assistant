# Email OTP Setup Guide for CareSync

## Overview
The OTP system stores verification codes in Firestore and queues emails for sending. To actually send emails, you need to set up Firebase Extensions or Cloud Functions.

## Option 1: Firebase Extensions (Easiest - No Code)

### Step 1: Install Trigger Email Extension
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **CareSync-Family-Health-AI-Assistant**
3. Navigate to **Extensions** in the left menu
4. Click **Install Extension**
5. Search for **"Trigger Email"**
6. Install the official **"Trigger Email from Firestore"** extension

### Step 2: Configure the Extension
During installation, configure:
- **Collection path**: `email_queue`
- **Email documents**: Use the following fields
  - `to`: Recipient email
  - `subject`: Email subject
  - `html`: HTML content
- **SMTP Connection URI**: Use one of these options:
  - **Gmail** (for testing): `smtps://username:password@smtp.gmail.com:465`
  - **SendGrid**: `smtps://apikey:YOUR_SENDGRID_API_KEY@smtp.sendgrid.net:465`
  - **Other SMTP**: Follow provider's SMTP settings

### Step 3: Gmail Setup (for testing)
If using Gmail:
1. Enable 2-factor authentication on your Google account
2. Generate an App Password:
   - Go to [Google Account Settings](https://myaccount.google.com/)
   - Security → 2-Step Verification → App passwords
   - Create a new app password for "Mail"
3. Use this format:
   ```
   smtps://your-email@gmail.com:your-app-password@smtp.gmail.com:465
   ```

### Step 4: Test the Setup
1. Run the app and sign up with a new account
2. Check the Firestore `email_queue` collection
3. The extension will automatically process the email
4. Check your inbox for the OTP code

## Option 2: Firebase Cloud Functions (More Control)

### Step 1: Install Dependencies
```bash
cd functions
npm install nodemailer
```

### Step 2: Update functions/index.js
Add this code to send emails when documents are added to `email_queue`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure your email service
const transporter = nodemailer.createTransport({
  service: 'gmail', // or 'SendGrid', etc.
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.password,
  },
});

// Trigger on new document in email_queue
exports.sendEmail = functions.firestore
  .document('email_queue/{emailId}')
  .onCreate(async (snap, context) => {
    const emailData = snap.data();

    const mailOptions = {
      from: functions.config().email.user,
      to: emailData.to,
      subject: emailData.subject,
      html: emailData.html,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log('Email sent to:', emailData.to);
      
      // Delete the email from queue after sending
      await snap.ref.delete();
    } catch (error) {
      console.error('Error sending email:', error);
    }
  });
```

### Step 3: Set Environment Variables
```bash
firebase functions:config:set email.user="your-email@gmail.com"
firebase functions:config:set email.password="your-app-password"
```

### Step 4: Deploy Functions
```bash
firebase deploy --only functions
```

## Firestore Security Rules

Add these rules to secure OTP storage:

```javascript
match /email_otps/{email} {
  // Anyone can create OTP (for signup)
  allow create: if request.auth != null || true;
  
  // Only the user can read their own OTP
  allow read: if request.auth.token.email == email;
  
  // Only authenticated users can verify (update)
  allow update: if request.auth != null;
  
  // Auto-delete after 10 minutes (handled by client)
  allow delete: if request.auth != null;
}

match /email_queue/{emailId} {
  // Only server can read/write
  allow read, write: if false;
}
```

## Testing Without Email Service

For development/testing, the OTP code is printed to the console:
1. Run the app in debug mode
2. Sign up with a new account
3. Check the VS Code terminal for: `DEBUG: OTP for email@example.com: 123456`
4. Enter this code in the OTP verification page

## Security Best Practices

1. **Rate Limiting**: Add Firestore rules to limit OTP requests per email
2. **OTP Expiry**: OTPs expire after 10 minutes (already implemented)
3. **One-time Use**: OTPs are marked as verified after use (already implemented)
4. **Strong Passwords**: Enforce password complexity in signup
5. **HTTPS Only**: Ensure all API calls use HTTPS in production

## Troubleshooting

### Email Not Received
- Check spam/junk folder
- Verify SMTP credentials are correct
- Check Firebase Functions logs: `firebase functions:log`
- Verify email_queue collection has the document

### OTP Expired
- OTPs expire after 10 minutes
- Click "Resend" to get a new code

### Invalid OTP
- Ensure you're entering the correct 6-digit code
- Check if the OTP has expired
- Try resending a new code

## Production Recommendations

1. **Use SendGrid or AWS SES** instead of Gmail for production
2. **Add email templates** with your branding
3. **Implement rate limiting** to prevent abuse
4. **Monitor email delivery** rates and failures
5. **Add email verification** status to user profiles

## Cost Considerations

- **Firestore**: ~$0.06 per 100k writes (OTP storage)
- **Cloud Functions**: Free tier includes 2M invocations/month
- **SendGrid**: Free tier includes 100 emails/day
- **Total**: Essentially free for small-medium apps

## Next Steps

1. Choose Option 1 (Extension) or Option 2 (Functions)
2. Set up your email service credentials
3. Test the OTP flow end-to-end
4. Configure security rules
5. Deploy to production
