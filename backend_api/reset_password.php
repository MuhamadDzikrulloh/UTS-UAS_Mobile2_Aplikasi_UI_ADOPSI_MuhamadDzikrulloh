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
$newPassword = isset($input['password']) ? $input['password'] : '';

if ($email === '' || $newPassword === '') {
    sendJson(400, ['success' => false, 'message' => 'Email dan password baru wajib diisi']);
}

$stmt = $mysqli->prepare('SELECT id FROM users WHERE email = ? LIMIT 1');
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if (!$user) {
    sendJson(404, ['success' => false, 'message' => 'Email tidak ditemukan']);
}

$hashed = password_hash($newPassword, PASSWORD_BCRYPT);
$upd = $mysqli->prepare('UPDATE users SET password = ? WHERE id = ?');
$upd->bind_param('si', $hashed, $user['id']);
$ok = $upd->execute();

if ($ok) {
    sendJson(200, ['success' => true, 'message' => 'Password berhasil direset']);
}

sendJson(500, ['success' => false, 'message' => 'Gagal reset password']);
?>
