import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ridesync_button.dart';
import '../providers/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passwordCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top orange header ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 24),
                    const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                    const SizedBox(height: 6),
                    const Text('Sign in to your account', style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4)),
                  ],
                ),
              ),

              // ── Form card ─────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // Email
                      _Label('Email Address'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDec(hint: 'you@example.com', icon: Icons.mail_outline_rounded),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _Label('Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: _inputDec(
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          suffix: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textSecondary),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                      ),
                      const SizedBox(height: 8),

                      // Forgot pw
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                          child: const Text('Forgot Password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Submit
                      RideSyncButton(
                        label: 'Sign In',
                        isLoading: loginState.isLoading,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          await ref.read(loginProvider.notifier).login(
                            email: _emailCtrl.text.trim(),
                            password: _passwordCtrl.text,
                          );
                          if (loginState.errorMessage != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loginState.errorMessage!), backgroundColor: AppColors.error));
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed('/register'),
                            child: Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
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
      ),
    );
  }

  InputDecoration _inputDec({required String hint, required IconData icon, Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
    prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
    suffixIcon: suffix,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 2)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTitle));
}
