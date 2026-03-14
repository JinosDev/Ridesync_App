/// Sealed class hierarchy for all possible failure types in the app.
/// Used as the error type in providers and repositories.
sealed class AppFailure implements Exception {
  final String message;
  const AppFailure(this.message);

  @override
  String toString() => message;
}

/// Network / connectivity failure (no internet, timeout)
class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network error. Check your connection.']);
}

/// Authentication failure (invalid token, expired session, forbidden)
class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Authentication failed. Please log in again.']);
}

/// Server-side business logic failure (409 seat taken, 422 validation)
class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

/// Local data / cache failure
class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}
