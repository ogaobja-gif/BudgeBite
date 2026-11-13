<?php
// Remember Me: the app sends its saved token; we return the user if it is still valid.
require __DIR__ . '/../config/database.php';
$in = input();
$parts = explode(':', (string)($in['token'] ?? ''), 2);
if (count($parts) === 2) {
    $st = db()->prepare('SELECT u.*, t.validator_hash FROM auth_tokens t JOIN users u ON u.user_id = t.user_id WHERE t.selector = ? AND t.expires_at > NOW()');
    $st->execute([$parts[0]]);
    $row = $st->fetch();
    if ($row && $row['account_status'] === 'Active' && hash_equals($row['validator_hash'], hash('sha256', $parts[1]))) {
        respond(['success' => true, 'message' => 'OK', 'user' => public_user($row)]);
    }
}
respond(['success' => false, 'status' => 'invalid', 'message' => 'Session expired. Please log in again.'], 401);
