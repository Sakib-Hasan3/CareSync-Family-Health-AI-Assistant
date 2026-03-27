# BDApps API Setup Summary

## ✅ Completed Fixes

### 1. **CORS Headers Added** (All PHP files)
All three PHP files now support cross-origin requests from Flutter app:
- ✅ `send_otp.php` - Accepts phone number, sends OTP via BDApps
- ✅ `verify_otp.php` - Verifies OTP with referenceNo  
- ✅ `check_subscription.php` - Checks subscription status

**Headers Added:**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

### 2. **OPTIONS Request Handling**
All PHP files now respond to CORS preflight OPTIONS requests with HTTP 200.

### 3. **Phone Number Normalization** (send_otp.php)
Handles multiple phone formats:
- `018xxxxxxxx` → Direct use
- `88018xxxxxxxx` → Converts to `018xxxxxxxx`  
- `8818xxxxxxxx` → Converts to `018xxxxxxxx`

Validates against: `/^01[3-9][0-9]{8}$/`

### 4. **BDApps API Credentials**
All files contain:
- **applicationId:** `APP_136048`
- **password:** `fd272dde31dac4116adf5c1e6d62f3db`

---

## 🚀 API Endpoints Configuration

### send_otp.php → https://developer.bdapps.com/subscription/otp/request
- Input: `user_mobile` (POST)
- Output: `{ "success": true/false, "referenceNo": "xxx" }`
- Format: `tel:88{digits}` sent to BDApps

### verify_otp.php → https://developer.bdapps.com/subscription/otp/verify
- Input: `Otp`, `referenceNo` (POST)
- Output: `{ "statusCode": "S1000" }` (success) or `"S1XXX"` (error)

### check_subscription.php → https://developer.bdapps.com/subscription/getStatus
- Input: `user_mobile` (POST)
- Output: `{ "subscriptionStatus": "REGISTERED" | "UNREGISTERED" }`

---

## 🔍 Current Issue: "Failed to fetch" Error

**Problem:** Flutter app getting `ClientException: Failed to fetch, uri=https://www.flicksize.com/caresync/send_otp.php`

### Possible Causes & Solutions:

#### 1. **Server Down/Unreachable** ❌
```bash
# Test from terminal:
curl -X OPTIONS https://www.flicksize.com/caresync/send_otp.php -v
# Should return HTTP 200

curl -X POST https://www.flicksize.com/caresync/send_otp.php \
  -d "user_mobile=01812345678" \
  -H "Content-Type: application/x-www-form-urlencoded"
```

#### 2. **Network/Firewall Issues** ❌
- Verify flicksize.com server can reach `developer.bdapps.com`
- Check if port 443 (HTTPS) is open from server location

#### 3. **BDApps Credentials Invalid** ❌
- Test credentials directly:
```php
// In test.php:
$testData = [
    "applicationId" => "APP_136048",
    "password" => "fd272dde31dac4116adf5c1e6d62f3db",
    "subscriberId" => "tel:8801812345678"
];
// Make curl request to verify credentials work
```

#### 4. **PHP Error in Execution** ❌
- Check `/var/www/html/caresync/` or server logs for PHP errors
- Add error logging to files

---

## 📋 Verification Checklist

- [ ] Confirm flicksize.com server is running and reachable
- [ ] Test send_otp.php manually in browser with valid phone
- [ ] Verify BDApps API credentials (APP_136048) are valid
- [ ] Check if BDApps API has IP whitelist (add server IP if needed)
- [ ] Confirm server has internet connectivity
- [ ] Check PHP error logs for runtime errors

---

## 🛠️ Flutter App Configuration

**Base URL:** `https://www.flicksize.com/caresync/`

**Endpoints Used in lib/auth/login_page.dart:**
- `POST /send_otp.php` - Send OTP
- `POST /verify_otp.php` - Verify OTP  
- `POST /check_subscription.php` - Check subscription status

**Headers Sent:**
```dart
headers: {'Content-Type: 'application/x-www-form-urlencoded'}
```

**Timeouts:**
- `send_otp`: 20 seconds
- `verify_otp`: 20 seconds
- `check_subscription`: 15 seconds (5 retries with 1-second delays)

---

## 🔧 Next Steps

1. **Test connectivity** - Verify flicksize.com/caresync/ is online and responding
2. **Check server logs** - Review PHP error logs for runtime issues
3. **Validate credentials** - Ensure BDApps APP_136048 is still active
4. **Debug with curl** - Test each endpoint manually from server
5. **Monitor phone numbers** - Check `user_number.txt` and `OTP+RefNo.txt` in server

If server is down, contact your hosting provider or ensure the PHP files are running on active server.
