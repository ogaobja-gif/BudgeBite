import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_route.dart';
import '../widgets/auth_header.dart';
import '../widgets/primary_button.dart';

/// Temporary landing screen after login (NOT a dashboard). Replace per role later via RoleRouter.
class WelcomeScreen extends StatelessWidget {
  final UserModel user;
  const WelcomeScreen({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(AppRoute(const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthHeader(title: 'Hi, ${user.firstName}!', subtitle: 'Logged in as ${user.roleLabel}'),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text('@${user.username}  •  ${user.email}', style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 12),
                  const Text('Your dashboard is coming soon.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 28),
                  PrimaryButton(label: 'Log Out', onPressed: () => _logout(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
