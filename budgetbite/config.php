<?php
// ---- Database ----
define('DB_HOST', 'localhost');
define('DB_NAME', 'budgetbite');
define('DB_USER', 'root');
define('DB_PASS', '');            // XAMPP default is empty

// ---- App ----
define('APP_ENV', 'local');       // 'local' shows reset links on screen and DB error details. Use 'production' when live.
define('REMEMBER_DAYS', 30);
define('MAX_ATTEMPTS', 5);        // failed logins allowed...
define('LOCK_MINUTES', 15);       // ...within this many minutes

// Where each role lands after login (point these to real dashboards later)
const ROLE_REDIRECTS = [
    'customer' => 'welcome.php',
    'seller'   => 'welcome.php',
    'admin'    => 'welcome.php',
];
