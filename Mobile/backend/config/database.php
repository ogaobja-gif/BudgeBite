<?php
const DB_HOST = 'localhost';
const DB_NAME = 'budgetbite_db';
const DB_USER = 'root';
const DB_PASS = '';            // XAMPP default is empty
const APP_DEBUG = true;        // true = the reset code is returned by the API (no email server yet). Use false in production.
const REMEMBER_DAYS = 30;

header('Content-Type: application/json; charset=utf-8');

function respond(array $data, int $code = 200): never {
    http_response_code($code);
    echo json_encode($data);
    exit;
}

set_exception_handler(function (Throwable $e) {
    error_log($e);
    $out = ['success' => false, 'message' => 'Server error. Make sure MySQL is running and the database exists.'];
    if (APP_DEBUG) $out['debug'] = $e->getMessage();
    respond($out, 500);
});

function db(): PDO {
    static $pdo = null;
    if (!$pdo) {
        $pdo = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4', DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }
    return $pdo;
}

function input(): array {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') respond(['success' => false, 'message' => 'Invalid request.'], 405);
    $d = json_decode(file_get_contents('php://input'), true);
    return is_array($d) ? $d : [];
}

function password_error(string $p): ?string {
    if (strlen($p) < 8) return 'Password must be at least 8 characters.';
    if (strlen($p) > 72) return 'Password is too long (72 characters max).';
    if (!preg_match('/[a-z]/', $p)) return 'Password needs a lowercase letter.';
    if (!preg_match('/[A-Z]/', $p)) return 'Password needs an uppercase letter.';
    if (!preg_match('/[0-9]/', $p)) return 'Password needs a number.';
    return null;
}

function public_user(array $u): array {
    return [
        'user_id' => (int)$u['user_id'], 'full_name' => $u['full_name'], 'email' => $u['email'],
        'phone_number' => $u['phone_number'], 'username' => $u['username'],
        'account_type' => $u['account_type'], 'account_status' => $u['account_status'],
    ];
}

function make_token(int $userId): string {
    $sel = bin2hex(random_bytes(12));
    $val = bin2hex(random_bytes(32));
    db()->prepare('INSERT INTO auth_tokens (user_id, selector, validator_hash, expires_at) VALUES (?,?,?, DATE_ADD(NOW(), INTERVAL ' . (int)REMEMBER_DAYS . ' DAY))')
        ->execute([$userId, $sel, hash('sha256', $val)]);
    return "$sel:$val";
}
