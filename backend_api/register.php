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
$name = isset($input['name']) ? trim($input['name']) : '';

if ($email === '' || $password === '' || $name === '') {
    sendJson(400, ['success' => false, 'message' => 'Nama, email, dan password wajib diisi']);
}

// Check if email already exists
$stmt = $mysqli->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();
if ($result->num_rows > 0) {
    sendJson(409, ['success' => false, 'message' => 'Email sudah terdaftar']);
}

// Hash password
$hashedPassword = password_hash($password, PASSWORD_BCRYPT);

// Register new user with role 'user' (default)
$stmt = $mysqli->prepare('INSERT INTO users (email, password, role) VALUES (?, ?, ?)');
$role = 'user'; // Always set role as 'user' for new registrations
$stmt->bind_param('sss', $email, $hashedPassword, $role);

if ($stmt->execute()) {
    sendJson(201, [
        'success' => true,
        'message' => 'Registrasi berhasil, silakan login',
        'user' => [
            'id' => $stmt->insert_id,
            'email' => $email,
            'role' => $role,
        ],
    ]);
} else {
    sendJson(500, ['success' => false, 'message' => 'Gagal registrasi: ' . $stmt->error]);
}
?>
