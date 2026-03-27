<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$user_mobile = trim($_POST['user_mobile'] ?? '');
if ($user_mobile === '') {
    echo json_encode(['error' => 'Mobile number required']);
    exit;
}

$subscriberId = 'tel:88' . $user_mobile;

$requestData = [
    'version' => '1.0',
    'applicationId' => 'APP_136048',
    'password' => "fd272dde31dac4116adf5c1e6d62f3db",
    'subscriberId' => $subscriberId,
];

$requestJson = json_encode($requestData);

// BDApps subscription status API
$url = 'https://developer.bdapps.com/subscription/getStatus';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $requestJson);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Content-Length: ' . strlen($requestJson),
]);

$responseJson = curl_exec($ch);
$curlError = curl_error($ch);
curl_close($ch);

if ($responseJson === false) {
    echo json_encode([
        'error' => 'cURL failed',
        'details' => $curlError,
    ]);
    exit;
}

$response = json_decode($responseJson, true);
if (!is_array($response)) {
    echo json_encode(['error' => 'Invalid response']);
    exit;
}

$status = strtoupper(trim($response['subscriptionStatus'] ?? ''));

// Per getStatus contract, subscription status is REGISTERED or UNREGISTERED.
$isSubscribed = ($status === 'REGISTERED');

echo json_encode([
    'subscriptionStatus' => $status,
    'isSubscribed' => $isSubscribed,
    'statusCode' => $response['statusCode'] ?? null,
    'statusDetail' => $response['statusDetail'] ?? null,
    'version' => $response['version'] ?? null,
]);
?>
