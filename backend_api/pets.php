<?php
session_start();
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once 'db.php';
$mysqli = getConnection();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $id = isset($_GET['id']) ? intval($_GET['id']) : null;
    $q = isset($_GET['q']) ? '%' . $mysqli->real_escape_string($_GET['q']) . '%' : null;

    if ($id) {
        $stmt = $mysqli->prepare('SELECT id, name, age, gender, description, status, breed, image_url FROM pets WHERE id = ? LIMIT 1');
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $res = $stmt->get_result()->fetch_assoc();
        if (!$res) {
            sendJson(404, ['success' => false, 'message' => 'Pet tidak ditemukan']);
        }
        sendJson(200, ['success' => true, 'data' => $res]);
    }

    if ($q) {
        $stmt = $mysqli->prepare('SELECT id, name, age, gender, description, status, breed, image_url FROM pets WHERE name LIKE ? OR description LIKE ? OR gender LIKE ? OR breed LIKE ? ORDER BY id DESC');
        $stmt->bind_param('ssss', $q, $q, $q, $q);
        $stmt->execute();
        $data = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
        sendJson(200, ['success' => true, 'data' => $data]);
    }

    $data = $mysqli->query('SELECT id, name, age, gender, description, status, breed, image_url FROM pets ORDER BY id DESC')->fetch_all(MYSQLI_ASSOC);
    sendJson(200, ['success' => true, 'data' => $data]);
}

if ($method === 'POST') {
    requireRole('admin');
    $input = json_decode(file_get_contents('php://input'), true);
    $name = $input['name'] ?? '';
    $age = isset($input['age']) ? intval($input['age']) : 0;
    $gender = $input['gender'] ?? '';
    $description = $input['description'] ?? '';
    $status = $input['status'] ?? 'available';
    $breed = $input['breed'] ?? null;
    $imageUrl = $input['image_url'] ?? null;

    if ($name === '' || $gender === '' || $age <= 0) {
        sendJson(400, ['success' => false, 'message' => 'Field name, gender, age wajib diisi']);
    }

    $stmt = $mysqli->prepare('INSERT INTO pets (name, age, gender, description, status, breed, image_url) VALUES (?, ?, ?, ?, ?, ?, ?)');
    $stmt->bind_param('sisssss', $name, $age, $gender, $description, $status, $breed, $imageUrl);
    $stmt->execute();

    sendJson(201, ['success' => true, 'message' => 'Pet ditambahkan', 'id' => $stmt->insert_id]);
}

if ($method === 'PUT') {
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    if ($id <= 0) {
        sendJson(400, ['success' => false, 'message' => 'Parameter id wajib']);
    }

    $input = json_decode(file_get_contents('php://input'), true);
    $isAdmin = isset($_SESSION['role']) && $_SESSION['role'] === 'admin';
    $isUser = isset($_SESSION['role']) && $_SESSION['role'] === 'user';

    if (!$isAdmin && !$isUser) {
        sendJson(401, ['success' => false, 'message' => 'Harus login']);
    }


    if ($isUser) {
        $status = $input['status'] ?? '';
        if ($status !== 'adopted') {
            sendJson(403, ['success' => false, 'message' => 'User hanya boleh mengadopsi (status adopted)']);
        }
        $stmt = $mysqli->prepare('UPDATE pets SET status = ? WHERE id = ?');
        $stmt->bind_param('si', $status, $id);
        $stmt->execute();
        sendJson(200, ['success' => true, 'message' => 'Status diubah menjadi adopted']);
    }

 
    $name = $input['name'] ?? null;
    $age = isset($input['age']) ? intval($input['age']) : null;
    $gender = $input['gender'] ?? null;
    $description = $input['description'] ?? null;
    $status = $input['status'] ?? null;
    $breed = $input['breed'] ?? null;
    $imageUrl = $input['image_url'] ?? null;

    $fields = [];
    $params = [];
    $types = '';

    if ($name !== null) { $fields[] = 'name = ?'; $params[] = $name; $types .= 's'; }
    if ($age !== null) { $fields[] = 'age = ?'; $params[] = $age; $types .= 'i'; }
    if ($gender !== null) { $fields[] = 'gender = ?'; $params[] = $gender; $types .= 's'; }
    if ($description !== null) { $fields[] = 'description = ?'; $params[] = $description; $types .= 's'; }
    if ($status !== null) { $fields[] = 'status = ?'; $params[] = $status; $types .= 's'; }
    if ($breed !== null) { $fields[] = 'breed = ?'; $params[] = $breed; $types .= 's'; }
    if ($imageUrl !== null) { $fields[] = 'image_url = ?'; $params[] = $imageUrl; $types .= 's'; }

    if (empty($fields)) {
        sendJson(400, ['success' => false, 'message' => 'Tidak ada field untuk diupdate']);
    }

    $sql = 'UPDATE pets SET ' . implode(', ', $fields) . ' WHERE id = ?';
    $params[] = $id;
    $types .= 'i';

    $stmt = $mysqli->prepare($sql);
    $stmt->bind_param($types, ...$params);
    $stmt->execute();

    sendJson(200, ['success' => true, 'message' => 'Data pet diperbarui']);
}

if ($method === 'DELETE') {
    requireRole('admin');
    $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
    if ($id <= 0) {
        sendJson(400, ['success' => false, 'message' => 'Parameter id wajib']);
    }

    $stmt = $mysqli->prepare('DELETE FROM pets WHERE id = ?');
    $stmt->bind_param('i', $id);
    $stmt->execute();

    sendJson(200, ['success' => true, 'message' => 'Pet dihapus']);
}

sendJson(405, ['success' => false, 'message' => 'Method not allowed']);
?>
