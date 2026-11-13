<?php
require __DIR__ . '/../config/database.php';
$in = input();
$email = strtolower(trim((string)($in['email'] ?? '')));
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) respond(['success' => false, 'message' => 'Enter a valid email address.'], 422);

$st = db()->prepare('SELECT user_id FROM users WHERE email = ?');
$st->execute([$email]);
$u = $st->fetch();
if (!$u) respond(['success' => false, 'message' => 'No account is registered with this email.'], 404);

// 10-character one-time code, stored hashed, valid for 15 minutes
$chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
$code = '';
for ($i = 0; $i < 10; $i++) $code .= $chars[random_int(0, strlen($chars) - 1)];

db()->prepare('DELETE FROM password_resets WHERE user_id = ?')->execute([$u['user_id']]);
db()->prepare('INSERT INTO password_resets (user_id, code_hash, expires_at) VALUES (?,?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))')
    ->execute([$u['user_id'], hash('sha256', $code)]);

// TODO (production): email $code with PHPMailer/SMTP and set APP_DEBUG to false.
$out = ['success' => true, 'message' => 'A reset code has been sent. It expires in 15 minutes.'];
if (APP_DEBUG) $out['dev_code'] = $code;
respond($out);
