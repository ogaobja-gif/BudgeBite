<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_post();

$email = strtolower(clean('email'));
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    json_out(['success' => false, 'message' => 'Enter a valid email address.', 'errors' => ['email' => 'Enter a valid email address.']], 422);
}

$out = ['success' => true, 'message' => 'If that email is registered, a password reset link has been sent. The link expires in 1 hour.'];

$st = db()->prepare("SELECT id FROM users WHERE email = ? AND status IN ('active','pending')");
$st->execute([$email]);
if ($u = $st->fetch()) {
    $token = bin2hex(random_bytes(32));
    db()->prepare('DELETE FROM password_resets WHERE user_id = ?')->execute([$u['id']]);
    db()->prepare('INSERT INTO password_resets (user_id, token_hash, expires_at) VALUES (?,?, DATE_ADD(NOW(), INTERVAL 1 HOUR))')
        ->execute([$u['id'], hash('sha256', $token)]);

    $scheme = !empty($_SERVER['HTTPS']) ? 'https' : 'http';
    $base = rtrim(dirname(dirname($_SERVER['SCRIPT_NAME'])), '/\\');
    $link = "$scheme://{$_SERVER['HTTP_HOST']}$base/reset-password.html?token=$token";

    // TODO (production): send $link by email with PHPMailer/SMTP.
    if (APP_ENV === 'local') {
        file_put_contents(__DIR__ . '/../storage/mail.log', date('c') . " | $email | $link\n", FILE_APPEND);
        $out['dev_link'] = $link;   // shown on screen only in local mode, since no mail server is set up
    }
}
json_out($out);
