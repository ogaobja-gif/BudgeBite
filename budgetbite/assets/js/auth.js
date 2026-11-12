(() => {
  'use strict';
  const $ = (s, r = document) => r.querySelector(s);

  // ---------- Validation rules (mirror the PHP rules) ----------
  const passwordError = v =>
    v.length < 8 ? 'Use at least 8 characters.' :
    v.length > 72 ? 'Password is too long (72 characters max).' :
    !/[a-z]/.test(v) ? 'Include at least one lowercase letter.' :
    !/[A-Z]/.test(v) ? 'Include at least one uppercase letter.' :
    !/[0-9]/.test(v) ? 'Include at least one number.' : '';
  const R = {
    full_name: v => /^[\p{L}][\p{L} .'\-]{1,98}$/u.test(v) || 'Enter your full name (letters only, at least 2 characters).',
    email: v => (/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(v) && v.length <= 150) || 'Enter a valid email address.',
    phone: v => { const d = v.replace(/\D/g, ''); return (/^\+?[0-9][0-9\s\-]{6,18}$/.test(v) && d.length >= 7 && d.length <= 15) || 'Enter a valid phone number (7-15 digits).'; },
    username: v => /^[A-Za-z0-9_]{4,20}$/.test(v) || '4-20 characters: letters, numbers and underscores only.',
    password: v => passwordError(v) || true,
    confirm_password: (v, f) => v === f.elements.password.value || 'Passwords do not match.',
    role: (v, f) => !!f.querySelector('[name="role"]:checked') || 'Please choose an account type.',
    identifier: v => v.length >= 3 || 'Enter your email or username.',
    login_password: v => v.length > 0 || 'Enter your password.',
  };
  const valueOf = el => el.type === 'password' ? el.value : (el.value || '').trim();

  // ---------- UI helpers ----------
  const alertBox = $('#alert');
  function showAlert(type, msg, link) {
    if (!alertBox) return;
    alertBox.className = 'alert ' + type;
    alertBox.textContent = msg;
    if (link) {
      const a = document.createElement('a');
      a.href = link; a.textContent = link;
      alertBox.append(document.createElement('br'), 'Dev mode (no mail server): ', a);
    }
    alertBox.hidden = false;
    alertBox.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }
  const hideAlert = () => { if (alertBox) alertBox.hidden = true; };

  function setError(form, name, msg) {
    const el = form.querySelector(`[name="${name}"]`);
    const field = el && el.closest('.field');
    if (!field) return;
    field.classList.toggle('invalid', !!msg);
    field.querySelector('.error').textContent = msg || '';
  }

  document.querySelectorAll('[data-toggle]').forEach(btn => {
    btn.addEventListener('click', () => {
      const input = document.getElementById(btn.dataset.toggle);
      const show = input.type === 'password';
      input.type = show ? 'text' : 'password';
      btn.textContent = show ? 'Hide' : 'Show';
      btn.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
    });
  });

  const pw = $('#password'), meter = $('#meter i');
  if (pw && meter) {
    pw.addEventListener('input', () => {
      const v = pw.value;
      const score = [v.length >= 8, /[a-z]/.test(v) && /[A-Z]/.test(v), /\d/.test(v), /[^A-Za-z0-9]/.test(v) || v.length >= 12].filter(Boolean).length;
      meter.style.width = (v ? score * 25 : 0) + '%';
      meter.style.background = ['#d64545', '#d64545', '#ffc933', '#7bc67e', '#1f9d55'][score];
    });
  }

  // ---------- Server communication ----------
  let csrf = '';
  const init = fetch('api/init.php', { credentials: 'same-origin' })
    .then(r => r.json()).then(d => { csrf = d.csrf || ''; return d; }).catch(() => ({}));

  async function post(endpoint, fd) {
    await init;
    fd.set('csrf', csrf);
    try {
      const r = await fetch('api/' + endpoint, { method: 'POST', body: fd, credentials: 'same-origin' });
      return await r.json();
    } catch {
      return { success: false, message: 'Could not reach the server. Make sure Apache and MySQL are running.' };
    }
  }

  function bind(formId, endpoint, fields, onSuccess, extra) {
    const form = document.getElementById(formId);
    if (!form) return;

    fields.forEach(([name, key]) => {
      const el = form.querySelector(`[name="${name}"]`);
      if (!el || el.type === 'radio') return;
      el.addEventListener('blur', () => {
        if (!el.value) return;
        const r = R[key](valueOf(el), form);
        setError(form, name, r === true ? '' : r);
      });
      el.addEventListener('input', () => setError(form, name, ''));
    });

    form.addEventListener('submit', async ev => {
      ev.preventDefault();
      hideAlert();
      let first = null;
      fields.forEach(([name, key]) => {
        const el = form.querySelector(`[name="${name}"]`);
        const r = R[key](valueOf(el), form);
        setError(form, name, r === true ? '' : r);
        if (r !== true && !first) first = el;
      });
      if (first) { first.focus(); return; }

      const btn = form.querySelector('.btn');
      btn.disabled = true; btn.classList.add('loading');
      const fd = new FormData(form);
      if (extra) extra(fd);
      const res = await post(endpoint, fd);
      btn.disabled = false; btn.classList.remove('loading');

      if (res.errors) Object.entries(res.errors).forEach(([n, m]) => setError(form, n, m));
      if (res.success) onSuccess(res, form);
      else showAlert(res.status === 'pending' ? 'warning' : 'error', res.message + (res.debug ? ' (' + res.debug + ')' : ''));
    });
  }

  // ---------- Pages ----------
  bind('loginForm', 'login.php', [['identifier', 'identifier'], ['password', 'login_password']], res => {
    showAlert('success', res.message);
    setTimeout(() => location.href = res.redirect, 700);
  });

  bind('signupForm', 'register.php', [
    ['full_name', 'full_name'], ['email', 'email'], ['phone', 'phone'], ['username', 'username'],
    ['password', 'password'], ['confirm_password', 'confirm_password'], ['role', 'role'],
  ], (res, form) => {
    showAlert(res.redirect.includes('pending') ? 'warning' : 'success', res.message);
    form.reset(); if (meter) meter.style.width = '0';
    form.querySelector('.btn').disabled = true;
    setTimeout(() => location.href = res.redirect, 2800);
  });

  bind('forgotForm', 'forgot_password.php', [['email', 'email']], (res, form) => {
    showAlert('success', res.message, res.dev_link);
    form.reset();
  });

  const token = new URLSearchParams(location.search).get('token') || '';
  bind('resetForm', 'reset_password.php', [['password', 'password'], ['confirm_password', 'confirm_password']], res => {
    showAlert('success', res.message);
    setTimeout(() => location.href = res.redirect, 1800);
  }, fd => fd.set('token', token));
  if ($('#resetForm') && !token) {
    $('#resetForm').hidden = true;
    showAlert('error', 'This reset link is missing its token. Please request a new one.');
  }

  // Seller approval note on signup
  const note = $('#sellerNote');
  document.querySelectorAll('[name="role"]').forEach(r => r.addEventListener('change', () => {
    if (note) note.hidden = !(r.value === 'seller' && r.checked);
  }));

  // Messages from other pages + auto-redirect when already logged in
  const q = new URLSearchParams(location.search);
  if ($('#loginForm')) {
    if (q.has('registered')) showAlert('success', 'Account created! You can now log in.');
    if (q.has('pending')) showAlert('warning', 'Your seller account is awaiting administrator approval. You can log in once approved.');
    if (q.has('reset')) showAlert('success', 'Password updated. Please log in with your new password.');
    if (q.has('logged_out')) showAlert('info', 'You have been logged out.');
  }
  init.then(d => { if (d.logged_in && ($('#loginForm') || $('#signupForm'))) location.replace(d.redirect); });
})();
