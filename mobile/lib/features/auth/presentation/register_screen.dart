import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ridesync_button.dart';
import '../providers/register_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _obscure = true;
  bool _agreed  = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
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
                    Row(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                            Text('Join RideSync today', style: TextStyle(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form
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
                      _FieldGroup(
                        label: 'Full Name',
                        child: TextFormField(
                          controller: _nameCtrl,
                          decoration: _dec(hint: 'John Doe', icon: Icons.person_outline_rounded),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name required' : null,
                        ),
                      ),
                      _FieldGroup(
                        label: 'Email Address',
                        child: TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _dec(hint: 'you@example.com', icon: Icons.mail_outline_rounded),
                          validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                        ),
                      ),
                      _FieldGroup(
                        label: 'Phone Number',
                        child: TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: _dec(hint: '+94 7X XXX XXXX', icon: Icons.phone_outlined),
                          validator: (v) => (v == null || v.length < 9) ? 'Valid phone required' : null,
                        ),
                      ),
                      _FieldGroup(
                        label: 'Password',
                        child: TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: _dec(
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            suffix: GestureDetector(
                              onTap: () => setState(() => _obscure = !_obscure),
                              child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textSecondary),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                        ),
                      ),

                      // Terms
                      Row(
                        children: [
                          Checkbox(
                            value: _agreed,
                            onChanged: (v) => setState(() => _agreed = v ?? false),
                            activeColor: AppColors.primary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  const TextSpan(text: ' and '),
                                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      RideSyncButton(
                        label: 'Create Account',
                        isLoading: state.isLoading,
                        onPressed: _agreed
                            ? () async {
                                if (!_formKey.currentState!.validate()) return;
                                await ref.read(registerProvider.notifier).register(
                                  name: _nameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                  password: _passCtrl.text,
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
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

  InputDecoration _dec({required String hint, required IconData icon, Widget? suffix}) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
    prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary), suffixIcon: suffix,
    filled: true, fillColor: const Color(0xFFF8FAFC),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary, width: 2)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class _FieldGroup extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldGroup({required this.label, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTitle)),
      const SizedBox(height: 6),
      child,
      const SizedBox(height: 16),
    ],
  );
}
