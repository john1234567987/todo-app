<?php
$host = 'todo-app-db.cj2seuige0e8.eu-west-2.rds.amazonaws.com';
$db   = 'todo_app';
$user = 'admin';
$pass = 'Sonship123$';
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
];

try {
     $pdo = new PDO($dsn, $user, $pass, $options);
} catch (\PDOException $e) {
     die('Connection failed: ' . $e->getMessage());
}
?>
