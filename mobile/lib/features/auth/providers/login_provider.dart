import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import 'auth_provider.dart';

enum LoginStatus { idle, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String? errorMessage;
  const LoginState({this.status = LoginStatus.idle, this.errorMessage});
  LoginState copyWith({LoginStatus? status, String? errorMessage}) =>
      LoginState(status: status ?? this.status, errorMessage: errorMessage ?? this.errorMessage);
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: LoginStatus.loading);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = state.copyWith(status: LoginStatus.success);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: LoginStatus.error,
        errorMessage: _parseFirebaseError(e.code),
      );
    } catch (_) {
      state = state.copyWith(status: LoginStatus.error, errorMessage: 'An unexpected error occurred.');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const LoginState();
  }

  String _parseFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':    return 'No account found with this email.';
      case 'wrong-password':    return 'Incorrect password. Please try again.';
      case 'invalid-email':     return 'Invalid email address.';
      case 'user-disabled':     return 'This account has been disabled.';
      case 'too-many-requests': return 'Too many attempts. Please try again later.';
      default: return 'Login failed. Please check your credentials.';
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
