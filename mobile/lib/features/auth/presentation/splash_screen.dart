import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Splash / Welcome screen — Figma "Title" frame.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.directions_bus_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 28),
              const Text(
                'RideSync',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'Smart Bus Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 56),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
