<?php
require_once __DIR__ . '/includes/bootstrap.php';
$u = current_user();
if (!$u) { header('Location: login.html'); exit; }
$h = fn($s) => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
$labels = ['customer' => 'Customer', 'seller' => 'Carinderia Seller', 'admin' => 'Administrator'];
?>
<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Welcome · BudgetBite</title>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="assets/css/auth.css"></head>
<body><main class="panel" style="min-height:100vh"><div class="card" style="text-align:center">
<div class="logo" style="margin:0 auto 16px">🍲</div>
<h1>Hi, <?= $h($u['full_name']) ?>!</h1>
<p class="sub">You are logged in as <strong><?= $h($labels[$u['role']] ?? $u['role']) ?></strong>.<br>Your dashboard is coming soon.</p>
<form method="post" action="api/logout.php">
<input type="hidden" name="csrf" value="<?= $h(csrf_token()) ?>">
<button class="btn" type="submit">Log Out</button></form>
</div></main></body></html>
