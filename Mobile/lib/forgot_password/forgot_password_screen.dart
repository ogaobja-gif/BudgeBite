import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/ui_helpers.dart';
import '../utils/validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  int _step = 0; // 0 = enter email, 1 = enter code + new password
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_email, _code, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await AuthService.forgotPassword(_email.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!res.success) {
      showSnack(context, res.message, error: true);
      return;
    }
    setState(() => _step = 1);
    if (res.devCode != null) {
      // Local testing only: there is no email server yet, so the API returns the code.
      _code.text = res.devCode!;
      showInfoDialog(
        context,
        title: 'Reset code (test mode)',
        message: 'Your code is ${res.devCode}. It was filled in for you.\n\nIn production this code is emailed instead.',
        icon: Icons.mark_email_read_outlined,
      );
    } else {
      showSnack(context, res.message);
    }
  }

  Future<void> _reset() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await AuthService.resetPassword(_email.text, _code.text, _password.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      Navigator.pop(context, res.message);
    } else {
      showSnack(context, res.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthHeader(
              title: _step == 0 ? 'Forgot Password?' : 'Reset Password',
              subtitle: _step == 0 ? "Enter your email and we'll send you a reset code." : 'Enter the code and choose a new password.',
              showBack: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _form,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0 ? _emailStep() : _resetStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailStep() => Column(
        key: const ValueKey(0),
        children: [
          CustomTextField(
            controller: _email,
            label: 'Registered email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            onSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Send Reset Code', loading: _loading, onPressed: _sendCode),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to login', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w600)),
          ),
        ],
      );

  Widget _resetStep() => Column(
        key: const ValueKey(1),
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(12)),
            child: Text('Code for ${_email.text.trim()} (valid for 15 minutes)',
                style: const TextStyle(color: AppColors.greenDark, fontSize: 13)),
          ),
          CustomTextField(
            controller: _code,
            label: 'Reset code',
            icon: Icons.pin_outlined,
            capitalization: TextCapitalization.characters,
            validator: Validators.code,
          ),
          CustomTextField(
            controller: _password,
            label: 'New password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            validator: Validators.password,
          ),
          CustomTextField(
            controller: _confirm,
            label: 'Confirm new password',
            icon: Icons.lock_reset_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (v) => Validators.confirm(v, _password.text),
            onSubmitted: (_) => _reset(),
          ),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Reset Password', loading: _loading, onPressed: _reset),
          TextButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('Use a different email', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w600)),
          ),
        ],
      );
}
