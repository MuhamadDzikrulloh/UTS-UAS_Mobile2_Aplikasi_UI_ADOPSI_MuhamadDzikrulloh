<?php
header('Content-Type: text/plain');
$pwd = isset($_GET['pwd']) ? $_GET['pwd'] : 'password';
echo password_hash($pwd, PASSWORD_DEFAULT);
?>
