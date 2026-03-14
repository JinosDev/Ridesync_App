import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../core/widgets/ridesync_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/utils/validators.dart';
import '../../../router/route_names.dart';
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

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(registerProvider.notifier).register(
      name:     _nameCtrl.text,
      email:    _emailCtrl.text,
      phone:    _phoneCtrl.text,
      password: _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final regState = ref.watch(registerProvider);

    ref.listen(registerProvider, (_, next) {
      if (next.status == RegisterStatus.error && next.errorMessage != null) {
        ErrorBanner.show(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RideSyncTextField(controller: _nameCtrl,  label: AppStrings.name,  prefixIcon: const Icon(Icons.person_outline),  validator: Validators.name),
                const SizedBox(height: AppDimensions.md),
                RideSyncTextField(controller: _emailCtrl, label: AppStrings.email, prefixIcon: const Icon(Icons.email_outlined),  keyboardType: TextInputType.emailAddress, validator: Validators.email),
                const SizedBox(height: AppDimensions.md),
                RideSyncTextField(controller: _phoneCtrl, label: AppStrings.phone, prefixIcon: const Icon(Icons.phone_outlined),  keyboardType: TextInputType.phone, validator: Validators.phone),
                const SizedBox(height: AppDimensions.md),
                RideSyncTextField(
                  controller: _passCtrl, label: AppStrings.password,
                  obscureText: _obscure,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                  validator: Validators.password,
                ),
                const SizedBox(height: AppDimensions.xl),
                RideSyncButton(label: AppStrings.register, isLoading: regState.status == RegisterStatus.loading, onPressed: _submit),
                const SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.hasAccount),
                    GestureDetector(
                      onTap: () => context.goNamed(RouteNames.login),
                      child: const Text(AppStrings.login, style: TextStyle(color: Color(0xFF1E6FFF), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
