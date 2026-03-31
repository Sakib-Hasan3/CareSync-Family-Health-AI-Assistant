<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$rawMobile = $_POST['user_mobile'] ?? '';
$digits = preg_replace('/\D+/', '', $rawMobile);

// Accept 018xxxxxxxx, 88018xxxxxxxx, or 8818xxxxxxxx and normalize to 018xxxxxxxx
if (strpos($digits, '880') === 0 && strlen($digits) === 13) {
    $digits = '0' . substr($digits, 3);
} elseif (strpos($digits, '88') === 0 && strlen($digits) === 12) {
    $digits = '0' . substr($digits, 2);
}

// Validate Bangladesh mobile number
if (!preg_match('/^01[3-9][0-9]{8}$/', $digits)) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid mobile number format',
        'referenceNo' => null
    ]);
    exit;
}

// bdapps subscriberId format
$user_mobile = 'tel:88' . $digits;

// TEST MODE: For development/testing - return test OTP
// Set TEST_MODE to false in production
define('TEST_MODE', true);
define('TEST_NUMBERS', ['01869793139', '01812345678']); // Add test numbers here

if (TEST_MODE && in_array($digits, TEST_NUMBERS)) {
    $testRefNo = 'TEST_' . time() . '_' . rand(10000, 99999);
    $testOtp = '123456'; // Fixed test OTP code for testing
    
    // Log test OTP for reference
    file_put_contents('TEST_OTP_LOG.txt', "Phone: $digits | OTP: $testOtp | RefNo: $testRefNo | Time: " . date('Y-m-d H:i:s') . PHP_EOL, FILE_APPEND);
    
    echo json_encode([
        'success' => true,
        'referenceNo' => $testRefNo,
        'statusCode' => 'S1000',
        'statusDetail' => 'Test Mode: OTP sent successfully',
        'version' => '1.0',
        'testOtp' => $testOtp,
        'isTestMode' => true
    ]);
    exit;
}

// Production mode: Log the request
file_put_contents('user_number.txt', $user_mobile . PHP_EOL, FILE_APPEND);

// Request data
$requestData = [
    'applicationId' => 'APP_136048',
    'password' => 'fd272dde31dac4116adf5c1e6d62f3db',
    'subscriberId' => $user_mobile,
    'applicationHash' => 'App Name',
    'applicationMetaData' => [
        'client' => 'MOBILEAPP',
        'device' => 'Samsung S10',
        'os' => 'android 8',
        'appCode' => 'https://play.google.com/store/apps/details?id=lk.dialog.megarunlor'
    ]
];

$requestJson = json_encode($requestData);

$url = 'https://developer.bdapps.com/subscription/otp/request';
$ch = curl_init();

curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $requestJson);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($requestJson)
]);

$responseJson = curl_exec($ch);

if ($responseJson === false) {
    echo json_encode([
        'success' => false,
        'message' => 'cURL error: ' . curl_error($ch),
        'referenceNo' => null
    ]);
    curl_close($ch);
    exit;
}

curl_close($ch);

$response = json_decode($responseJson, true);

if (!is_array($response)) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid JSON in response',
        'raw' => $responseJson,
        'referenceNo' => null
    ]);
    exit;
}

$referenceNo = isset($response['referenceNo']) ? trim((string)$response['referenceNo']) : '';
$statusCode = isset($response['statusCode']) ? (string)$response['statusCode'] : '';
$statusDetail = isset($response['statusDetail']) ? (string)$response['statusDetail'] : '';
$version = isset($response['version']) ? (string)$response['version'] : '';

if ($referenceNo !== '') {
    echo json_encode([
        'success' => true,
        'referenceNo' => $referenceNo,
        'statusCode' => $statusCode,
        'statusDetail' => $statusDetail,
        'version' => $version
    ]);
    exit;
}

echo json_encode([
    'success' => false,
    'message' => $statusDetail !== '' ? $statusDetail : 'OTP reference not returned',
    'referenceNo' => null,
    'statusCode' => $statusCode,
    'statusDetail' => $statusDetail,
    'version' => $version,
    'subscriberId' => $user_mobile
]);