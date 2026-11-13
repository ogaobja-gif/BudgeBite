<?php
require __DIR__ . '/../config/database.php';
$in = input();

$name  = trim((string)($in['full_name'] ?? ''));
$email = strtolower(trim((string)($in['email'] ?? '')));
$phone = trim((string)($in['phone_number'] ?? ''));
$user  = trim((string)($in['username'] ?? ''));
$pw    = (string)($in['password'] ?? '');
$role  = (string)($in['account_type'] ?? '');
$e = [];

if (!preg_match("/^\p{L}[\p{L} .'\-]{1,98}$/u", $name)) $e['full_name'] = 'Enter a valid full name (letters only).';
if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 150) $e['email'] = 'Enter a valid email address.';
$digits = preg_replace('/\D/', '', $phone);
if (!preg_match('/^\+?[0-9][0-9\s\-]{6,18}$/', $phone) || strlen($digits) < 7 || strlen($digits) > 15) $e['phone_number'] = 'Enter a valid phone number.';
if (!preg_match('/^[A-Za-z0-9_]{4,20}$/', $user)) $e['username'] = '4-20 letters, numbers or underscores.';
if ($m = password_error($pw)) $e['password'] = $m;
if (!in_array($role, ['customer', 'seller'], true)) $e['account_type'] = 'Choose Customer or Carinderia Seller.'; // 'admin' is never accepted

if (!$e) {
    $st = db()->prepare('SELECT email, username FROM users WHERE email = ? OR username = ?');
    $st->execute([$email, $user]);
    foreach ($st->fetchAll() as $row) {
        if (strtolower($row['email']) === $email) $e['email'] = 'This email is already registered.';
        if (strtolower($row['username']) === strtolower($user)) $e['username'] = 'This username is already taken.';
    }
}
if ($e) respond(['success' => false, 'message' => reset($e), 'errors' => $e], 422);

$status = $role === 'seller' ? 'Pending' : 'Active';
try {
    db()->prepare('INSERT INTO users (full_name,email,phone_number,username,password,account_type,account_status) VALUES (?,?,?,?,?,?,?)')
        ->execute([$name, $email, $phone, $user, password_hash($pw, PASSWORD_DEFAULT), $role, $status]);
} catch (PDOException $ex) {
    if ($ex->getCode() === '23000') respond(['success' => false, 'message' => 'That email or username is already registered.', 'errors' => ['email' => 'Email or username already in use.']], 409);
    throw $ex;
}

respond(['success' => true, 'message' => $status === 'Pending'
    ? 'Account created! Your seller account must be approved by an administrator before you can log in.'
    : 'Account created! You can now log in.']);
