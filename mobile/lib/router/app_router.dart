import 'package:flutter/material.dart';
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

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/schedule-list',
      name: 'schedule-list',
      builder: (context, state) => const ScheduleListScreen(),
    ),
    GoRoute(
      path: '/seat-picker',
      name: 'seat-picker',
      builder: (context, state) => const SeatPickerScreenV2(scheduleId: 'test-123'),
    ),
    GoRoute(
      path: '/booking-confirm',
      name: 'booking-confirm',
      builder: (context, state) => const BookingConfirmScreenV2(),
    ),
    GoRoute(
      path: '/booking-success',
      name: 'booking-success',
      builder: (context, state) => const BookingSuccessScreen(),
    ),
    GoRoute(
      path: '/tracking',
      name: 'tracking',
      builder: (context, state) => const TrackingMapScreenV2(scheduleId: 'test-123'),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreenV2(),
    ),
  ],
);
