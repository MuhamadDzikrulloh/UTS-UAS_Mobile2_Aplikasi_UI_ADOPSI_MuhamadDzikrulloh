<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(204);
  exit;
}

$uploadDir = __DIR__ . DIRECTORY_SEPARATOR . 'uploads';
if (!is_dir($uploadDir)) {
  mkdir($uploadDir, 0777, true);
}

if (!isset($_FILES['image'])) {
  http_response_code(400);
  echo json_encode(['success' => false, 'message' => 'File image tidak ditemukan']);
  exit;
}

$file = $_FILES['image'];
if ($file['error'] !== UPLOAD_ERR_OK) {
  http_response_code(400);
  echo json_encode(['success' => false, 'message' => 'Gagal upload gambar']);
  exit;
}

$allowedMime = [
  'image/jpeg' => 'jpg',
  'image/jpg'  => 'jpg',
  'image/pjpeg' => 'jpg',
  'image/jpe' => 'jpg',
  'image/jfif' => 'jpg',
  'image/pipeg' => 'jpg',
  'image/vnd.swiftview-jpeg' => 'jpg',
  'image/x-citrix-jpeg' => 'jpg',
  'image/x-jpeg' => 'jpg',
  'image/png'  => 'png',
  'image/x-png' => 'png',
  'image/webp' => 'webp',
  'image/heic' => 'heic',
  'image/heif' => 'heic',
  'image/heic-sequence' => 'heic',
  'application/octet-stream' => null,
];

$ext = null;

if (isset($file['type']) && array_key_exists($file['type'], $allowedMime)) {
  $ext = $allowedMime[$file['type']];
}

if ($ext === null && isset($file['tmp_name'])) {
  $finfo = finfo_open(FILEINFO_MIME_TYPE);
  if ($finfo) {
    $mimeDetected = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);
    if ($mimeDetected && array_key_exists($mimeDetected, $allowedMime)) {
      $ext = $allowedMime[$mimeDetected];
    }
  }
}

if ($ext === null) {
  $name = isset($file['name']) ? $file['name'] : '';
  $extFromName = strtolower(pathinfo($name, PATHINFO_EXTENSION));
  $allowedExt = ['jpg', 'jpeg', 'jpe', 'jfif', 'png', 'webp', 'heic', 'heif'];
  if (in_array($extFromName, $allowedExt, true)) {
    if ($extFromName === 'jpeg' || $extFromName === 'jfif' || $extFromName === 'jpe') {
      $ext = 'jpg';
    } elseif ($extFromName === 'heif') {
      $ext = 'heic';
    } else {
      $ext = $extFromName;
    }
  }
}

if ($ext === null) {
  http_response_code(415);
  echo json_encode(['success' => false, 'message' => 'Tipe file tidak didukung. Gunakan JPG/PNG/WebP.']);
  exit;
}
$basename = bin2hex(random_bytes(8)) . '.' . $ext;
$target = $uploadDir . DIRECTORY_SEPARATOR . $basename;

if (!move_uploaded_file($file['tmp_name'], $target)) {
  http_response_code(500);
  echo json_encode(['success' => false, 'message' => 'Tidak bisa menyimpan file']);
  exit;
}

$publicPath = '/backend_api/uploads/' . $basename;

echo json_encode(['success' => true, 'url' => $publicPath]);
