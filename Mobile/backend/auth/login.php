<?php
require __DIR__ . '/../config/database.php';
$in = input();

$id = strtolower(trim((string)($in['identifier'] ?? '')));
$pw = (string)($in['password'] ?? '');
if ($id === '' || $pw === '') respond(['success' => false, 'message' => 'Enter your email/username and password.'], 422);

$st = db()->prepare('SELECT * FROM users WHERE email = ? OR username = ? LIMIT 1');
$st->execute([$id, $id]);
$u = $st->fetch();

// Always verify against a hash so timing doesn't reveal whether the account exists
$dummy = '$2y$10$SmXE0Z2qSUkOAotxAK9y0.BKPpehSWkxTpwHZO9aWRIQyOyQE9/6a';
if (!password_verify($pw, $u['password'] ?? $dummy) || !$u) {
    respond(['success' => false, 'message' => 'Incorrect email/username or password.'], 401);
}
if ($u['account_status'] === 'Pending') respond(['success' => false, 'status' => 'Pending', 'message' => 'Your seller account is still waiting for administrator approval.'], 403);
if ($u['account_status'] === 'Rejected') respond(['success' => false, 'status' => 'Rejected', 'message' => 'Your seller application was rejected. Please contact support.'], 403);

$out = ['success' => true, 'message' => 'Login successful!', 'user' => public_user($u)];
if (!empty($in['remember'])) $out['token'] = make_token((int)$u['user_id']);
respond($out);
