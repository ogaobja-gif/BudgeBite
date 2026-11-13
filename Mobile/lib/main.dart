import 'package:flutter/material.dart';
import 'login/login_screen.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'utils/app_colors.dart';
import 'utils/role_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BudgetBiteApp());
}

class BudgetBiteApp extends StatelessWidget {
  const BudgetBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BudgetBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green, primary: AppColors.green, secondary: AppColors.yellow),
        scaffoldBackgroundColor: Colors.white,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const _StartGate(),
    );
  }
}

/// Splash screen: checks for a saved Remember Me session, then opens Login or the user's role screen.
class _StartGate extends StatefulWidget {
  const _StartGate();

  @override
  State<_StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<_StartGate> {
  late final Future<UserModel?> _future = AuthService.autoLogin();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.green,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🍲', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: AppColors.yellow),
                ],
              ),
            ),
          );
        }
        final user = snap.data;
        return user != null ? RoleRouter.screenFor(user) : const LoginScreen();
      },
    );
  }
}
