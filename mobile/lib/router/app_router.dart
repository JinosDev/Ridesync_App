import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/auth/providers/auth_provider.dart';

// Screen imports — Shared
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';

// Passenger screens
import '../features/booking/presentation/home_screen.dart';
import '../features/booking/presentation/route_search_screen.dart';
import '../features/booking/presentation/schedule_list_screen.dart';
import '../features/booking/presentation/schedule_detail_screen.dart';
import '../features/booking/presentation/booking_confirm_screen.dart';
import '../features/booking/presentation/booking_success_screen.dart';
import '../features/booking/presentation/booking_history_screen.dart';
import '../features/booking/presentation/booking_detail_screen.dart';
import '../features/fare/presentation/fare_estimator_screen.dart';
import '../features/fare/presentation/seat_picker_screen.dart';
import '../features/tracking/presentation/tracking_map_screen.dart';
import '../features/chatbot/presentation/chatbot_screen.dart';
import '../features/feedback/presentation/trip_rating_screen.dart';

// Operator screens
import '../features/operator/presentation/operator_home_screen.dart';
import '../features/operator/presentation/operator_schedule_list_screen.dart';
import '../features/operator/presentation/trip_dashboard_screen.dart';
import '../features/operator/presentation/passenger_manifest_screen.dart';
import '../features/operator/presentation/status_update_screen.dart';
import '../features/operator/presentation/seat_management_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth = authState.valueOrNull;
      if (auth == null) return null; // still loading

      final isLoggedIn  = auth.role != UserRole.unauthenticated;
      final isAuthRoute = ['/login', '/register', '/splash']
          .contains(state.matchedLocation);

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        return auth.role == UserRole.operator ? '/operator/home' : '/home';
      }
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(path: '/splash',   name: RouteNames.splash,   builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',    name: RouteNames.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', name: RouteNames.register, builder: (_, __) => const RegisterScreen()),

      // ── Passenger Shell ───────────────────────────────────────────────
      GoRoute(path: '/home', name: RouteNames.home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/search', name: RouteNames.search, builder: (_, __) => const RouteSearchScreen()),
      GoRoute(
        path: '/schedules',
        name: RouteNames.schedules,
        builder: (_, state) => ScheduleListScreen(
          from: state.uri.queryParameters['from'] ?? '',
          to:   state.uri.queryParameters['to']   ?? '',
          date: state.uri.queryParameters['date'] ?? '',
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: RouteNames.scheduleDetail,
            builder: (_, state) => ScheduleDetailScreen(
              scheduleId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(path: '/fare-estimator',  name: RouteNames.fareEstimator,  builder: (_, __) => const FareEstimatorScreen()),
      GoRoute(path: '/seat-picker',     name: RouteNames.seatPicker,     builder: (_, __) => const SeatPickerScreen()),
      GoRoute(path: '/booking-confirm', name: RouteNames.bookingConfirm, builder: (_, __) => const BookingConfirmScreen()),
      GoRoute(path: '/booking-success', name: RouteNames.bookingSuccess, builder: (_, __) => const BookingSuccessScreen()),
      GoRoute(
        path: '/my-bookings',
        name: RouteNames.myBookings,
        builder: (_, __) => const BookingHistoryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: RouteNames.bookingDetail,
            builder: (_, state) => BookingDetailScreen(bookingId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/track/:scheduleId',
        name: RouteNames.tracking,
        builder: (_, state) => TrackingMapScreen(scheduleId: state.pathParameters['scheduleId']!),
      ),
      GoRoute(
        path: '/rate/:scheduleId',
        name: RouteNames.tripRating,
        builder: (_, state) => TripRatingScreen(scheduleId: state.pathParameters['scheduleId']!),
      ),
      GoRoute(path: '/chatbot',        name: RouteNames.chatbot,       builder: (_, __) => const ChatbotScreen()),
      GoRoute(path: '/notifications',  name: RouteNames.notifications, builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/profile',        name: RouteNames.profile,       builder: (_, __) => const ProfileScreen()),

      // ── Operator Shell ────────────────────────────────────────────────
      GoRoute(path: '/operator/home',      name: RouteNames.operatorHome,      builder: (_, __) => const OperatorHomeScreen()),
      GoRoute(path: '/operator/schedules', name: RouteNames.operatorSchedules, builder: (_, __) => const OperatorScheduleListScreen()),
      GoRoute(
        path: '/operator/trip/:scheduleId',
        name: RouteNames.tripDashboard,
        builder: (_, state) => TripDashboardScreen(scheduleId: state.pathParameters['scheduleId']!),
      ),
      GoRoute(
        path: '/operator/manifest/:scheduleId',
        name: RouteNames.manifest,
        builder: (_, state) => PassengerManifestScreen(scheduleId: state.pathParameters['scheduleId']!),
      ),
      GoRoute(
        path: '/operator/status/:scheduleId',
        name: RouteNames.statusUpdate,
        builder: (_, state) => StatusUpdateScreen(scheduleId: state.pathParameters['scheduleId']!),
      ),
      GoRoute(
        path: '/operator/seats/:scheduleId',
        name: RouteNames.seatManagement,
        builder: (_, state) => SeatManagementScreen(scheduleId: state.pathParameters['scheduleId']!),
      ),
    ],
  );
});
