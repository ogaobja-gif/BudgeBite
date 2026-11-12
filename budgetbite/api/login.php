<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_post();

$id = strtolower(clean('identifier'));
$pw = $_POST['password'] ?? '';
$remember = !empty($_POST['remember']);
$ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';

if ($id === '' || $pw === '') json_out(['success' => false, 'message' => 'Please enter your email/username and password.'], 422);

$pdo = db();
$pdo->exec('DELETE FROM login_attempts WHERE attempted_at < NOW() - INTERVAL 1 DAY');
$st = $pdo->prepare('SELECT COUNT(*) FROM login_attempts WHERE identifier = ? AND ip = ? AND attempted_at > NOW() - INTERVAL ' . (int)LOCK_MINUTES . ' MINUTE');
$st->execute([$id, $ip]);
if ((int)$st->fetchColumn() >= MAX_ATTEMPTS) {
    json_out(['success' => false, 'message' => 'Too many failed attempts. Please try again in ' . LOCK_MINUTES . ' minutes.'], 429);
}

$st = $pdo->prepare('SELECT * FROM users WHERE email = ? OR username = ? LIMIT 1');
$st->execute([$id, $id]);
$u = $st->fetch();

// Always run a hash check so response time doesn't reveal whether the account exists
$dummy = '$2y$10$SmXE0Z2qSUkOAotxAK9y0.BKPpehSWkxTpwHZO9aWRIQyOyQE9/6a';
$ok = password_verify($pw, $u['password_hash'] ?? $dummy) && $u;
if (!$ok) {
    $pdo->prepare('INSERT INTO login_attempts (identifier, ip) VALUES (?, ?)')->execute([$id, $ip]);
    json_out(['success' => false, 'message' => 'Incorrect email/username or password.'], 401);
}

$blocked = [
    'pending'   => 'Your seller account is still awaiting administrator approval. Please check back later.',
    'rejected'  => 'Your seller application was not approved. Please contact support.',
    'suspended' => 'This account has been suspended. Please contact support.',
];
if (isset($blocked[$u['status']])) {
    json_out(['success' => false, 'status' => $u['status'], 'message' => $blocked[$u['status']]], 403);
}

$pdo->prepare('DELETE FROM login_attempts WHERE identifier = ? AND ip = ?')->execute([$id, $ip]);
if (password_needs_rehash($u['password_hash'], PASSWORD_DEFAULT)) {
    $pdo->prepare('UPDATE users SET password_hash = ? WHERE id = ?')->execute([password_hash($pw, PASSWORD_DEFAULT), $u['id']]);
}
$pdo->prepare('UPDATE users SET last_login = NOW() WHERE id = ?')->execute([$u['id']]);
login_user($u);

if ($remember) {
    $sel = bin2hex(random_bytes(12));
    $val = bin2hex(random_bytes(32));
    $pdo->prepare('INSERT INTO remember_tokens (user_id, selector, validator_hash, expires_at) VALUES (?,?,?, DATE_ADD(NOW(), INTERVAL ' . (int)REMEMBER_DAYS . ' DAY))')
        ->execute([$u['id'], $sel, hash('sha256', $val)]);
    set_remember_cookie("$sel:$val", time() + REMEMBER_DAYS * 86400);
}

json_out([
    'success' => true,
    'message' => 'Welcome back, ' . explode(' ', $u['full_name'])[0] . '! Logging you in...',
    'redirect' => ROLE_REDIRECTS[$u['role']] ?? 'welcome.php',
]);
