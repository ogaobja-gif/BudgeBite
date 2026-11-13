<?php
require __DIR__ . '/../config/database.php';
$in = input();
$sel = explode(':', (string)($in['token'] ?? ''))[0];
if ($sel !== '') db()->prepare('DELETE FROM auth_tokens WHERE selector = ?')->execute([$sel]);
respond(['success' => true, 'message' => 'Logged out.']);
