import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

enum RegisterStatus { idle, loading, success, error }

class RegisterState {
  final RegisterStatus status;
  final String? errorMessage;
  const RegisterState({this.status = RegisterStatus.idle, this.errorMessage});
  RegisterState copyWith({RegisterStatus? status, String? errorMessage}) =>
      RegisterState(status: status ?? this.status, errorMessage: errorMessage ?? this.errorMessage);
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(const RegisterState());

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(status: RegisterStatus.loading);
    try {
      // 1. Create Firebase Auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // 2. Sync to backend — sets role claim + Firestore user doc
      final token = await cred.user!.getIdToken();
      await ApiClient.post(
        endpoint: ApiEndpoints.register,
        token: token!,
        body: {'name': name, 'email': email, 'phone': phone},
      );
      state = state.copyWith(status: RegisterStatus.success);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: RegisterStatus.error,
        errorMessage: e.message ?? 'Registration failed.',
      );
    } catch (e) {
      state = state.copyWith(status: RegisterStatus.error, errorMessage: e.toString());
    }
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  return RegisterNotifier();
});
