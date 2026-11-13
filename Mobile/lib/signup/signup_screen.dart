import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/ui_helpers.dart';
import '../utils/validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _role = 'customer';
  bool _loading = false;
  Map<String, String> _serverErrors = {}; // e.g. duplicate email / username from the API

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _username, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clearServerErrors(String _) {
    if (_serverErrors.isNotEmpty) _serverErrors = {};
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _serverErrors = {};
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await AuthService.register(
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      username: _username.text,
      password: _password.text,
      accountType: _role,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      await showInfoDialog(
        context,
        title: _role == 'seller' ? 'Registration received' : 'Welcome to BudgetBite!',
        message: res.message,
        icon: _role == 'seller' ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
        color: _role == 'seller' ? AppColors.yellowDark : AppColors.green,
      );
      if (mounted) Navigator.pop(context, 'Account created. Please log in.');
      return;
    }
    if (res.errors.isNotEmpty) {
      _serverErrors = res.errors;
      _form.currentState!.validate();
    }
    showSnack(context, res.message, error: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(title: 'Create Account', subtitle: 'Join BudgetBite and start eating smart.', showBack: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _form,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _name,
                      label: 'Full name',
                      icon: Icons.badge_outlined,
                      capitalization: TextCapitalization.words,
                      validator: Validators.fullName,
                      onChanged: _clearServerErrors,
                    ),
                    CustomTextField(
                      controller: _email,
                      label: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => Validators.email(v) ?? _serverErrors['email'],
                      onChanged: _clearServerErrors,
                    ),
                    CustomTextField(
                      controller: _phone,
                      label: 'Phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => Validators.phone(v) ?? _serverErrors['phone_number'],
                      onChanged: _clearServerErrors,
                    ),
                    CustomTextField(
                      controller: _username,
                      label: 'Username',
                      icon: Icons.alternate_email_rounded,
                      validator: (v) => Validators.username(v) ?? _serverErrors['username'],
                      onChanged: _clearServerErrors,
                    ),
                    CustomTextField(
                      controller: _password,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: Validators.password,
                    ),
                    CustomTextField(
                      controller: _confirm,
                      label: 'Confirm password',
                      icon: Icons.lock_reset_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) => Validators.confirm(v, _password.text),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('Account type', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: _roleCard('customer', '🍽️', 'Customer')),
                        const SizedBox(width: 12),
                        Expanded(child: _roleCard('seller', '🏪', 'Carinderia Seller')),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _role == 'seller'
                          ? Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFFFF7D6), borderRadius: BorderRadius.circular(12)),
                              child: const Text(
                                'Seller accounts must be approved by an administrator before you can log in.',
                                style: TextStyle(color: Color(0xFF7A5C00), fontSize: 13),
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(label: 'Register', loading: _loading, onPressed: _submit),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: AppColors.muted)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text('Log In', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(String value, String emoji, String label) {
    final selected = _role == value;
    return GestureDetector(
      onTap: () => setState(() => _role = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.green : AppColors.line, width: selected ? 2 : 1.2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: selected ? AppColors.greenDark : AppColors.ink)),
          ],
        ),
      ),
    );
  }
}
