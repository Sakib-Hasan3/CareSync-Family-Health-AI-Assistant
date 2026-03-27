<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$date_ = date("Y-m-d h:i:sa");

$user_otp = isset($_POST['Otp']) ? $_POST['Otp'] : '';
$referenceNo = isset($_POST['referenceNo']) ? $_POST['referenceNo'] : '';

if (empty($user_otp) || empty($referenceNo)) {
    echo json_encode(array('statusCode' => 'FAILED', 'message' => 'Missing OTP or referenceNo'));
    exit;
}

try {
    $myfile = fopen("OTP+RefNo.txt", "a+") or die("Unable to open file!");
    fwrite($myfile, "OTP:" . $user_otp . " RefNo:" . $referenceNo . " Date" . $date_ . "\n");
    fclose($myfile);
} catch (Exception $e) {
}

$requestData = array(
    "applicationId" => "APP_136048",
    "password" => "fd272dde31dac4116adf5c1e6d62f3db",
    "referenceNo" => $referenceNo,
    "otp" => $user_otp
);

$requestJson = json_encode($requestData);

$url = "https://developer.bdapps.com/subscription/otp/verify";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $requestJson);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, array(
    "Content-Type: application/json",
    "Content-Length: " . strlen($requestJson)
));
curl_setopt($ch, CURLOPT_TIMEOUT, 15);

$responseJson = curl_exec($ch);

if ($responseJson === false) {
    echo json_encode(array('statusCode' => 'FAILED', 'message' => 'cURL error'));
    curl_close($ch);
    exit;
}

curl_close($ch);

$response = json_decode($responseJson, true);

if ($response === null) {
    echo json_encode(array('statusCode' => 'FAILED', 'message' => 'Invalid API response'));
    exit;
}

echo json_encode(array(
    'statusCode' => isset($response['statusCode']) ? $response['statusCode'] : 'FAILED',
    'subscriptionStatus' => isset($response['subscriptionStatus']) ? $response['subscriptionStatus'] : '',
    'subscriberId' => isset($response['subscriberId']) ? $response['subscriberId'] : ''
));

?>