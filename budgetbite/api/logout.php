<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_post();

if (!empty($_COOKIE['bb_remember']) && str_contains($_COOKIE['bb_remember'], ':')) {
    db()->prepare('DELETE FROM remember_tokens WHERE selector = ?')->execute([explode(':', $_COOKIE['bb_remember'])[0]]);
}
set_remember_cookie('', time() - 3600);
$_SESSION = [];
session_destroy();
header('Location: ../login.html?logged_out=1');
exit;
