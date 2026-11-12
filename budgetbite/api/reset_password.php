<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_post();

$token = clean('token');
$pw = $_POST['password'] ?? '';
$cpw = $_POST['confirm_password'] ?? '';
$e = [];
if ($m = password_error($pw)) $e['password'] = $m;
if ($pw !== $cpw) $e['confirm_password'] = 'Passwords do not match.';
if ($e) json_out(['success' => false, 'message' => 'Please fix the highlighted fields.', 'errors' => $e], 422);

$st = db()->prepare('SELECT id, user_id FROM password_resets WHERE token_hash = ? AND expires_at > NOW()');
$st->execute([hash('sha256', $token)]);
$r = $st->fetch();
if (!$r) json_out(['success' => false, 'message' => 'This reset link is invalid or has expired. Please request a new one.'], 400);

$pdo = db();
$pdo->beginTransaction();
$pdo->prepare('UPDATE users SET password_hash = ? WHERE id = ?')->execute([password_hash($pw, PASSWORD_DEFAULT), $r['user_id']]);
$pdo->prepare('DELETE FROM password_resets WHERE user_id = ?')->execute([$r['user_id']]);
$pdo->prepare('DELETE FROM remember_tokens WHERE user_id = ?')->execute([$r['user_id']]);
$pdo->commit();

json_out(['success' => true, 'message' => 'Password updated! Redirecting to login...', 'redirect' => 'login.html?reset=1']);
