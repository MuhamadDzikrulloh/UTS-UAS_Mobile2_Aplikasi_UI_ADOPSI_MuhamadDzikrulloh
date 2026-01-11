<?php


$DB_HOST = 'localhost';
$DB_USER = 'root';
$DB_PASS = '';
$DB_NAME = 'adoptive_pet_hero';

function getConnection() {
    global $DB_HOST, $DB_USER, $DB_PASS, $DB_NAME;
    $mysqli = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);
    if ($mysqli->connect_errno) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'DB connection failed: ' . $mysqli->connect_error]);
        exit;
    }
    $mysqli->set_charset('utf8mb4');
    return $mysqli;
}

function sendJson($status, $payload) {
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($payload);
    exit;
}

function requireRole($role) {
    if (!isset($_SESSION['role']) || $_SESSION['role'] !== $role) {
        sendJson(403, ['success' => false, 'message' => 'Forbidden']);
    }
}
?>
