<?php
require_once __DIR__ . '/../includes/bootstrap.php';
$out = ['csrf' => csrf_token(), 'logged_in' => false];
try {
    if ($u = current_user()) {
        $out['logged_in'] = true;
        $out['redirect'] = ROLE_REDIRECTS[$u['role']] ?? 'welcome.php';
    }
} catch (Throwable $e) { error_log($e); }
json_out($out);
