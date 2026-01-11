<?php
session_start();
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once 'db.php';
$mysqli = getConnection();

$input = json_decode(file_get_contents('php://input'), true);
$email = isset($input['email']) ? trim($input['email']) : '';
$password = isset($input['password']) ? $input['password'] : '';

if ($email === '' || $password === '') {
    sendJson(400, ['success' => false, 'message' => 'Email dan password wajib diisi']);
}

$stmt = $mysqli->prepare('SELECT id, email, password, role FROM users WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if (!$user || !password_verify($password, $user['password'])) {
    sendJson(401, ['success' => false, 'message' => 'Email atau password salah']);
}

$_SESSION['user_id'] = $user['id'];
$_SESSION['role'] = $user['role'];

sendJson(200, [
    'success' => true,
    'message' => 'Login berhasil',
    'user' => [
        'id' => $user['id'],
        'email' => $user['email'],
        'role' => $user['role'],
    ],
]);
?>
