import 'package:go_router/go_router.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/booking/presentation/home_screen.dart';
import '../features/booking/presentation/schedule_list_screen.dart';
import '../features/fare/presentation/seat_picker_screen.dart';
import '../features/booking/presentation/booking_confirm_screen.dart';
import '../features/booking/presentation/booking_success_screen.dart';
import '../features/tracking/presentation/tracking_map_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/booking/presentation/booking_history_screen.dart';
import '../features/operator/presentation/operator_home_screen.dart';
import '../features/operator/presentation/trip_dashboard_screen.dart';
import '../features/operator/presentation/passenger_manifest_screen.dart';
import '../features/operator/presentation/seat_management_screen.dart';
import '../features/operator/presentation/status_update_screen.dart';
import '../features/chatbot/presentation/chat_screen.dart';
import '../router/route_names.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: RouteNames.forgotPassword, // Added this name (verify it exists)
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/',
      name: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/schedule-list',
      name: RouteNames.schedules,
      builder: (context, state) => const ScheduleListScreen(),
    ),
    GoRoute(
      path: '/seat-picker',
      name: RouteNames.seatPicker,
      builder: (context, state) => const SeatPickerScreenV2(scheduleId: 'test-123'),
    ),
    GoRoute(
      path: '/booking-confirm',
      name: RouteNames.bookingConfirm,
      builder: (context, state) => const BookingConfirmScreenV2(),
    ),
    GoRoute(
      path: '/booking-success',
      name: RouteNames.bookingSuccess,
      builder: (context, state) => const BookingSuccessScreen(),
    ),
    GoRoute(
      path: '/tracking',
      name: RouteNames.tracking,
      builder: (context, state) => const TrackingMapScreenV2(scheduleId: 'test-123'),
    ),
    GoRoute(
      path: '/profile',
      name: RouteNames.profile,
      builder: (context, state) => const ProfileScreenV2(),
    ),
    GoRoute(
      path: '/booking-history',
      name: RouteNames.myBookings,
      builder: (context, state) => const BookingHistoryScreen(),
    ),
    // ── Operator Routes ──────────────────────────────────────────────────
    GoRoute(
      path: '/operator-home',
      name: RouteNames.operatorHome,
      builder: (context, state) => const OperatorHomeScreen(),
    ),
    GoRoute(
      path: '/trip-dashboard/:scheduleId',
      name: RouteNames.tripDashboard,
      builder: (context, state) => TripDashboardScreen(scheduleId: state.pathParameters['scheduleId'] ?? 'test-123'),
    ),
    GoRoute(
      path: '/manifest/:scheduleId',
      name: RouteNames.manifest,
      builder: (context, state) => PassengerManifestScreen(scheduleId: state.pathParameters['scheduleId'] ?? 'test-123'),
    ),
    GoRoute(
      path: '/seat-management/:scheduleId',
      name: RouteNames.seatManagement,
      builder: (context, state) => SeatManagementScreen(scheduleId: state.pathParameters['scheduleId'] ?? 'test-123'),
    ),
    GoRoute(
      path: '/status-update/:scheduleId',
      name: RouteNames.statusUpdate,
      builder: (context, state) => StatusUpdateScreen(scheduleId: state.pathParameters['scheduleId'] ?? 'test-123'),
    ),
    GoRoute(
      path: '/chatbot',
      name: RouteNames.chatbot,
      builder: (context, state) => const ChatScreen(),
    ),
  ],
);
