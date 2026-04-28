import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginState {

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  LoginState copyWith({bool? isLoading, String? errorMessage, bool? isSuccess}) =>
      LoginState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'An unknown error occurred');
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) => LoginNotifier());
