<?php
require_once __DIR__ . '/../includes/bootstrap.php';
require_post();

$name  = clean('full_name');
$email = strtolower(clean('email'));
$phone = clean('phone');
$user  = clean('username');
$pw    = $_POST['password'] ?? '';
$cpw   = $_POST['confirm_password'] ?? '';
$role  = clean('role');
$e = [];

if (!preg_match("/^[\p{L}][\p{L} .'\-]{1,98}$/u", $name)) $e['full_name'] = 'Enter your full name (letters only, at least 2 characters).';
if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 150) $e['email'] = 'Enter a valid email address.';
$digits = preg_replace('/\D/', '', $phone);
if (!preg_match('/^\+?[0-9][0-9\s\-]{6,18}$/', $phone) || strlen($digits) < 7 || strlen($digits) > 15) $e['phone'] = 'Enter a valid phone number (7-15 digits).';
if (!preg_match('/^[A-Za-z0-9_]{4,20}$/', $user)) $e['username'] = '4-20 characters: letters, numbers and underscores only.';
if ($m = password_error($pw)) $e['password'] = $m;
if ($pw !== $cpw) $e['confirm_password'] = 'Passwords do not match.';
if (!in_array($role, ['customer', 'seller'], true)) $e['role'] = 'Please choose an account type.';

if (!$e) {
    $st = db()->prepare('SELECT email, username FROM users WHERE email = ? OR username = ?');
    $st->execute([$email, $user]);
    foreach ($st->fetchAll() as $row) {
        if (strtolower($row['email']) === $email) $e['email'] = 'This email is already registered.';
        if (strtolower($row['username']) === strtolower($user)) $e['username'] = 'This username is already taken.';
    }
}
if ($e) json_out(['success' => false, 'message' => 'Please fix the highlighted fields.', 'errors' => $e], 422);

$status = $role === 'seller' ? 'pending' : 'active';
try {
    $st = db()->prepare('INSERT INTO users (full_name,email,phone,username,password_hash,role,status) VALUES (?,?,?,?,?,?,?)');
    $st->execute([$name, $email, $phone, $user, password_hash($pw, PASSWORD_DEFAULT), $role, $status]);
} catch (PDOException $ex) {
    if ($ex->getCode() === '23000') {   // duplicate key (race condition)
        json_out(['success' => false, 'message' => 'That email or username was just taken. Please try another.', 'errors' => ['email' => 'Email or username already in use.']], 409);
    }
    throw $ex;
}

if ($status === 'pending') {
    json_out(['success' => true, 'message' => 'Account created! Your seller account is awaiting administrator approval. You will be able to log in once approved.', 'redirect' => 'login.html?pending=1']);
}
json_out(['success' => true, 'message' => 'Account created successfully! Redirecting to login...', 'redirect' => 'login.html?registered=1']);
