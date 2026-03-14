import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Forgot password screen — Figma "Pass..." frame.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text('Forgot Password?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text("Enter your email and we'll send a reset link.", style: TextStyle(fontSize: 13, color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _sent ? _buildSentState() : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTitle)),
      const SizedBox(height: 6),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'you@example.com',
          prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.textSecondary),
          filled: true, fillColor: AppColors.surface,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: () => setState(() => _sent = true),
          child: const Text('Send Reset Link'),
        ),
      ),
    ],
  );

  Widget _buildSentState() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(Icons.mark_email_read_outlined, size: 36, color: AppColors.success),
        ),
        const SizedBox(height: 16),
        const Text('Check Your Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text("We've sent a reset link to your email address. Check your inbox.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back to Sign In'),
          ),
        ),
      ],
    ),
  );
}
