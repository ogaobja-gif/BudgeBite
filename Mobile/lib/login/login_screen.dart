import 'package:flutter/material.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../services/auth_service.dart';
import '../signup/signup_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_route.dart';
import '../utils/role_router.dart';
import '../utils/ui_helpers.dart';
import '../utils/validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _remember = false;
  bool _loading = false;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final res = await AuthService.login(_id.text, _pw.text, _remember);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success && res.user != null) {
      Navigator.of(context).pushAndRemoveUntil(AppRoute(RoleRouter.screenFor(res.user!)), (_) => false);
    } else if (res.status == 'Pending') {
      showInfoDialog(context,
          title: 'Awaiting approval', message: res.message, icon: Icons.hourglass_top_rounded, color: AppColors.yellowDark);
    } else if (res.status == 'Rejected') {
      showInfoDialog(context, title: 'Application rejected', message: res.message, icon: Icons.cancel_rounded, color: AppColors.error);
    } else {
      showSnack(context, res.message, error: true);
    }
  }

  Future<void> _open(Widget page) async {
    final msg = await Navigator.push<String>(context, AppRoute<String>(page));
    if (msg != null && mounted) showSnack(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(title: 'Welcome Back!', subtitle: 'Log in to enjoy affordable, home-cooked meals.'),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _id,
                      label: 'Email or username',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.identifier,
                    ),
                    CustomTextField(
                      controller: _pw,
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.loginPassword,
                      onSubmitted: (_) => _login(),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _remember,
                          activeColor: AppColors.green,
                          onChanged: (v) => setState(() => _remember = v ?? false),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _remember = !_remember),
                          child: const Text('Remember me'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _open(const ForgotPasswordScreen()),
                          child: const Text('Forgot password?', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(label: 'Log In', loading: _loading, onPressed: _login),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('New to BudgetBite? ', style: TextStyle(color: AppColors.muted)),
                        GestureDetector(
                          onTap: () => _open(const SignupScreen()),
                          child: const Text('Sign Up', style: TextStyle(color: AppColors.greenDark, fontWeight: FontWeight.w700)),
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
}
