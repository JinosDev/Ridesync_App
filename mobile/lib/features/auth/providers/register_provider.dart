import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterState {
  const RegisterState({this.isLoading = false, this.errorMessage});
  final bool isLoading;
  final String? errorMessage;

  RegisterState copyWith({bool? isLoading, String? errorMessage}) =>
      RegisterState(isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage);
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier() : super(const RegisterState());

  Future<void> register({required String name, required String email, required String phone, required String password}) async {
    state = state.copyWith(isLoading: true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isLoading: false);
  }
}

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) => RegisterNotifier());
