import 'package:flutter/material.dart';
import '../home/welcome_screen.dart';
import '../models/user_model.dart';

/// Decides which screen each role sees after login.
/// Dashboards don't exist yet, so every role goes to WelcomeScreen.
/// Later, replace the screens below with CustomerHome(), SellerHome(), AdminHome().
class RoleRouter {
  static Widget screenFor(UserModel user) {
    switch (user.accountType) {
      case 'admin':
        return WelcomeScreen(user: user);
      case 'seller':
        return WelcomeScreen(user: user);
      default:
        return WelcomeScreen(user: user);
    }
  }
}
