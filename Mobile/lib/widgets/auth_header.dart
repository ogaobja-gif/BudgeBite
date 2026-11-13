import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Green, food-themed curved header shared by every auth screen.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;

  const AuthHeader({super.key, required this.title, required this.subtitle, this.showBack = false});

  Widget _circle(double size, int alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.yellow.withAlpha(alpha)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.green, AppColors.greenDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          Positioned(right: -40, top: -30, child: _circle(130, 70)),
          Positioned(left: -30, bottom: -50, child: _circle(90, 55)),
          const Positioned(right: 4, bottom: 0, child: Text('🍛', style: TextStyle(fontSize: 46))),
          const Positioned(right: 62, top: 6, child: Text('🥗', style: TextStyle(fontSize: 26))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBack)
                IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                )
              else
                const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(12)),
                    child: const Text('🍲', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  const Text.rich(TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    children: [TextSpan(text: 'Budget'), TextSpan(text: 'Bite', style: TextStyle(color: AppColors.yellow))],
                  )),
                ],
              ),
              const SizedBox(height: 22),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14.5)),
            ],
          ),
        ],
      ),
    );
  }
}
