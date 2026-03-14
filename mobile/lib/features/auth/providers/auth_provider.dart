import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { passenger, operator, unauthenticated }

class AuthState {
  final User? user;
  final UserRole role;
  final String? busId;

  const AuthState({
    required this.user,
    required this.role,
    this.busId,
  });
}

/// Watches Firebase auth state and resolves the user's role claim.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return const AuthState(user: null, role: UserRole.unauthenticated);
    }
    // forceRefresh = true ensures latest role claim is read from server
    final tokenResult = await user.getIdTokenResult(true);
    final roleStr = tokenResult.claims?['role'] as String? ?? 'passenger';
    final busId   = tokenResult.claims?['busId'] as String?;

    return AuthState(
      user:  user,
      role:  roleStr == 'operator' ? UserRole.operator : UserRole.passenger,
      busId: busId,
    );
  });
});

/// Convenience provider — true if any authenticated user
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.role != UserRole.unauthenticated;
});

/// Convenience provider — current user role
final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.role ?? UserRole.unauthenticated;
});
