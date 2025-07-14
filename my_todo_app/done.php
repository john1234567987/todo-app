<?php
require_once 'db.php';

if (isset($_POST['id'], $_POST['is_done'])) {
    $id = (int) $_POST['id'];
    $is_done = (int) $_POST['is_done'];
    

    $stmt = $pdo->prepare("UPDATE tasks SET is_done = ? WHERE id = ?");
    $stmt->execute([$is_done, $id]);
}
?>
