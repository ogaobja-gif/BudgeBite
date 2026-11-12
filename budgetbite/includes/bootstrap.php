<?php
require_once __DIR__ . '/../config.php';

session_set_cookie_params([
    'lifetime' => 0, 'path' => '/', 'httponly' => true,
    'samesite' => 'Lax', 'secure' => !empty($_SERVER['HTTPS']),
]);
session_start();

set_exception_handler(function (Throwable $e) {
    error_log($e);
    $out = ['success' => false, 'message' => 'Server error. Please check that MySQL is running and config.php is correct.'];
    if (APP_ENV === 'local') $out['debug'] = $e->getMessage();
    json_out($out, 500);
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

function json_out(array $data, int $code = 200): never {
    http_response_code($code);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data);
    exit;
}

function csrf_token(): string {
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf'];
}

function require_post(): void {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') json_out(['success' => false, 'message' => 'Invalid request.'], 405);
    if (!hash_equals($_SESSION['csrf'] ?? '', $_POST['csrf'] ?? '')) {
        json_out(['success' => false, 'message' => 'Your session expired. Please refresh the page and try again.'], 419);
    }
}

function clean(string $key): string { return trim((string)($_POST[$key] ?? '')); }

function password_error(string $p): ?string {
    if (strlen($p) < 8) return 'Use at least 8 characters.';
    if (strlen($p) > 72) return 'Password is too long (72 characters max).';
    if (!preg_match('/[a-z]/', $p)) return 'Include at least one lowercase letter.';
    if (!preg_match('/[A-Z]/', $p)) return 'Include at least one uppercase letter.';
    if (!preg_match('/[0-9]/', $p)) return 'Include at least one number.';
    return null;
}

function set_remember_cookie(string $value, int $expires): void {
    setcookie('bb_remember', $value, [
        'expires' => $expires, 'path' => '/', 'httponly' => true,
        'samesite' => 'Lax', 'secure' => !empty($_SERVER['HTTPS']),
    ]);
}

function login_user(array $u): void {
    session_regenerate_id(true);
    $_SESSION['user'] = [
        'id' => (int)$u['id'], 'full_name' => $u['full_name'], 'username' => $u['username'],
        'email' => $u['email'], 'role' => $u['role'],
    ];
    csrf_token();
}

function current_user(): ?array {
    if (!empty($_SESSION['user']['id'])) return $_SESSION['user'];
    $c = $_COOKIE['bb_remember'] ?? '';
    if ($c && str_contains($c, ':')) {
        [$sel, $val] = explode(':', $c, 2);
        $st = db()->prepare('SELECT u.*, t.validator_hash FROM remember_tokens t JOIN users u ON u.id = t.user_id WHERE t.selector = ? AND t.expires_at > NOW()');
        $st->execute([$sel]);
        $row = $st->fetch();
        if ($row && $row['status'] === 'active' && hash_equals($row['validator_hash'], hash('sha256', $val))) {
            login_user($row);
            return $_SESSION['user'];
        }
        set_remember_cookie('', time() - 3600);
    }
    return null;
}
