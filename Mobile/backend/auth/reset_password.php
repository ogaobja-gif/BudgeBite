<?php
require __DIR__ . '/../config/database.php';
$in = input();
$email = strtolower(trim((string)($in['email'] ?? '')));
$code = strtoupper(trim((string)($in['code'] ?? '')));
$pw = (string)($in['password'] ?? '');

if ($m = password_error($pw)) respond(['success' => false, 'message' => $m], 422);

$st = db()->prepare('SELECT r.user_id FROM password_resets r JOIN users u ON u.user_id = r.user_id WHERE u.email = ? AND r.code_hash = ? AND r.expires_at > NOW()');
$st->execute([$email, hash('sha256', $code)]);
$r = $st->fetch();
if (!$r) respond(['success' => false, 'message' => 'Invalid or expired reset code.'], 400);

$pdo = db();
$pdo->beginTransaction();
$pdo->prepare('UPDATE users SET password = ? WHERE user_id = ?')->execute([password_hash($pw, PASSWORD_DEFAULT), $r['user_id']]);
$pdo->prepare('DELETE FROM password_resets WHERE user_id = ?')->execute([$r['user_id']]);
$pdo->prepare('DELETE FROM auth_tokens WHERE user_id = ?')->execute([$r['user_id']]);
$pdo->commit();
respond(['success' => true, 'message' => 'Password updated! You can now log in.']);
