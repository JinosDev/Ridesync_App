<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# i need seperate architecture plan for mobile app

I have all the information needed from the updated architecture file. Here is the complete dedicated mobile app architecture document:

***

```markdown
# RideSync — Flutter Mobile App Architecture
> Capstone Project | Group 21 | Sabaragamuwa University of Sri Lanka
> Document: RIDESYNC_MOBILE_ARCHITECTURE.md
> Version: 1.0 | March 2026
> Scope: Flutter Mobile Application only (Passenger + Bus Operator)

---

## Table of Contents

1. [Mobile App Overview](#1-mobile-app-overview)
2. [Architecture Pattern](#2-architecture-pattern)
3. [Role-Based Persona System](#3-role-based-persona-system)
4. [Complete Screen Inventory](#4-complete-screen-inventory)
5. [Full Project Folder Structure](#5-full-project-folder-structure)
6. [State Management — Riverpod](#6-state-management--riverpod)
7. [Navigation — go_router](#7-navigation--go_router)
8. [Firebase Integration Layer](#8-firebase-integration-layer)
9. [GPS Tracking Module](#9-gps-tracking-module)
10. [Live Tracking — Passenger Map](#10-live-tracking--passenger-map)
11. [Booking Module](#11-booking-module)
12. [Seat Picker UI Module](#12-seat-picker-ui-module)
13. [Fare Estimator Module](#13-fare-estimator-module)
14. [Push Notifications Module](#14-push-notifications-module)
15. [AI Chatbot Module](#15-ai-chatbot-module)
16. [Offline Caching — Hive](#16-offline-caching--hive)
17. [API Communication Layer](#17-api-communication-layer)
18. [Mobile Security](#18-mobile-security)
19. [complete pubspec.yaml](#19-complete-pubspecyaml)
20. [Environment Configuration](#20-environment-configuration)
21. [Mobile-Specific Data Flows](#21-mobile-specific-data-flows)
22. [Performance Considerations](#22-performance-considerations)
23. [Mobile Testing Strategy](#23-mobile-testing-strategy)
24. [Build & Release Guide](#24-build--release-guide)

---

## 1. Mobile App Overview

The RideSync Flutter mobile app is a **single codebase, dual-persona application** that serves two distinct user roles:

| Role | Responsibilities | Key Mobile Features |
|---|---|---|
| Passenger | Book seats, track buses, view fares, submit feedback | Route search, seat picker, live map, chatbot, notifications |
| Bus Operator | Drive bus, broadcast GPS, manage trip, update delays | Trip dashboard, GPS broadcaster, seat management, schedule view |

### Mobile Tech Summary

| Concern | Solution |
|---|---|
| UI Framework | Flutter 3 (Dart) — single codebase for Android + iOS |
| State Management | Riverpod 2.x — reactive, testable, no BuildContext dependency |
| Navigation | go_router — declarative, deep-link ready, RBAC-aware |
| Real-time GPS (write) | geolocator + Firebase Realtime Database |
| Real-time GPS (read) | Firebase RTDB StreamProvider |
| Maps | google_maps_flutter |
| Auth | Firebase Authentication (email/password) |
| Database | Cloud Firestore |
| Push Notifications | firebase_messaging + flutter_local_notifications |
| Offline | Hive (local key-value cache) |
| API Calls | http package (REST to Node.js backend) |
| Chatbot | webview_flutter (Dialogflow ES iframe) |

---

## 2. Architecture Pattern

### Feature-First Clean Architecture (3 Layers)

Every feature in the app is organized into three layers:

```

/features/{featureName}
/data
{feature}_repository.dart     ← talks to Firebase SDK or REST API
{feature}_model.dart          ← Dart data class + fromJson/toJson
/presentation
{feature}_screen.dart         ← UI: Scaffold, widgets, Consumer
widgets/                      ← screen-specific sub-widgets
/providers
{feature}_provider.dart       ← Riverpod provider definitions

```

### Why This Pattern

- **Data layer** only knows about Firebase/API. Zero Flutter imports.
- **Presentation layer** only knows about providers. Zero Firebase imports.
- **Providers layer** bridges data and UI. Easy to unit test.
- Each feature is independently developed by one team member.
- Easy to mock the repository in tests without touching the UI.

### Layer Communication Rule

```

Screen (Consumer) → watches Provider → calls Repository → Firebase SDK / REST API
↓
Screen (Consumer) ← rebuilds from Provider ← emits new state ←

```

---

## 3. Role-Based Persona System

### How It Works

The app uses a **single codebase** with role-based routing. When a user logs in, the Firebase Auth token contains a custom claim (`role: "passenger"` or `role: "operator"`). The app reads this claim and routes the user to their persona's shell.

### Auth Role Claim Structure

```dart
// Set server-side via Firebase Admin SDK on registration:
// { role: "passenger" }   → passenger shell
// { role: "operator", busId: "BUS001" }  → operator shell

// Read in Flutter after login:
final idTokenResult = await FirebaseAuth.instance.currentUser!
    .getIdTokenResult(true); // forceRefresh to get latest claims
final role = idTokenResult.claims?['role'] as String?;
final busId = idTokenResult.claims?['busId'] as String?;
```


### Role Detection Provider (`auth_provider.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

final authStateProvider = StreamProvider<AuthState>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return const AuthState(user: null, role: UserRole.unauthenticated);
    }
    final tokenResult = await user.getIdTokenResult(true);
    final role = tokenResult.claims?['role'] as String? ?? 'passenger';
    final busId = tokenResult.claims?['busId'] as String?;
    return AuthState(
      user: user,
      role: role == 'operator' ? UserRole.operator : UserRole.passenger,
      busId: busId,
    );
  });
});
```


### Role-Gated Root Widget (`main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: RideSyncApp()));
}

class RideSyncApp extends ConsumerWidget {
  const RideSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'RideSync',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
```


---

## 4. Complete Screen Inventory

### 4.1 Shared Screens (Both Roles)

| Screen File | Route | Description |
| :-- | :-- | :-- |
| `splash_screen.dart` | `/splash` | App logo, checks auth state, redirects |
| `login_screen.dart` | `/login` | Email/password Firebase Auth login |
| `register_screen.dart` | `/register` | New passenger registration |
| `profile_screen.dart` | `/profile` | View and edit own profile info |
| `notifications_screen.dart` | `/notifications` | In-app FCM notification list |

### 4.2 Passenger Screens

| Screen File | Route | Description |
| :-- | :-- | :-- |
| `home_screen.dart` | `/home` | Origin-destination search, quick booking access |
| `route_search_screen.dart` | `/search` | Input from/to, select date |
| `schedule_list_screen.dart` | `/schedules` | List of available schedules with availability |
| `schedule_detail_screen.dart` | `/schedules/:id` | Schedule info, operator details, departure time |
| `fare_estimator_screen.dart` | `/fare` | Select fromStop/toStop, see fare breakdown before booking |
| `seat_picker_screen.dart` | `/seat-picker` | Visual seat grid, select available seat |
| `booking_confirm_screen.dart` | `/booking-confirm` | Final confirmation before API call |
| `booking_success_screen.dart` | `/booking-success` | Confirmation + e-ticket with QR display |
| `booking_history_screen.dart` | `/my-bookings` | List of all past and upcoming bookings |
| `booking_detail_screen.dart` | `/my-bookings/:id` | Booking details + cancellation option |
| `tracking_map_screen.dart` | `/track/:scheduleId` | Live Google Map with bus marker + ETA |
| `chatbot_screen.dart` | `/chatbot` | Dialogflow chatbot WebView |
| `trip_rating_screen.dart` | `/rate/:scheduleId` | Post-trip star rating + comment form |

### 4.3 Bus Operator Screens

| Screen File | Route | Description |
| :-- | :-- | :-- |
| `operator_home_screen.dart` | `/operator/home` | Today's schedules, active trip status |
| `operator_schedule_list_screen.dart` | `/operator/schedules` | All assigned upcoming schedules |
| `trip_dashboard_screen.dart` | `/operator/trip/:scheduleId` | Start/End trip, GPS status, passenger count |
| `passenger_manifest_screen.dart` | `/operator/manifest/:scheduleId` | List of all booked passengers + seat numbers |
| `status_update_screen.dart` | `/operator/status/:scheduleId` | Report delay, update current stop |
| `seat_management_screen.dart` | `/operator/seats/:scheduleId` | View real-time seat occupancy |


---

## 5. Full Project Folder Structure

```
/mobile
  /android                    ← Android native project (auto-generated)
    /app
      google-services.json    ← Firebase config for Android (never commit)
  /ios                        ← iOS native project (auto-generated)
    /Runner
      GoogleService-Info.plist ← Firebase config for iOS (never commit)
  /lib
    /core
      /constants
        app_colors.dart        ← Brand color palette
        app_strings.dart       ← All UI text strings
        app_dimensions.dart    ← Padding, radius, font sizes
        api_endpoints.dart     ← All backend API URL constants
      /errors
        app_failure.dart       ← Sealed class: NetworkFailure | AuthFailure | ServerFailure
      /utils
        date_formatter.dart
        currency_formatter.dart   ← LKR formatting
        validators.dart           ← Phone, email validation
        logger.dart               ← Dev-mode logging utility
      /theme
        app_theme.dart            ← MaterialTheme light + dark
        app_text_styles.dart
      /widgets
        loading_overlay.dart      ← Full-screen loading indicator
        error_banner.dart         ← Reusable error snackbar
        ridesync_button.dart      ← Branded primary button
        ridesync_text_field.dart  ← Branded input field
        empty_state_widget.dart   ← No data placeholder

    /features
      /auth
        /data
          auth_repository.dart        ← Firebase Auth calls
          user_model.dart             ← User Dart class
        /presentation
          login_screen.dart
          register_screen.dart
          widgets/
            login_form.dart
            register_form.dart
        /providers
          auth_provider.dart          ← authStateProvider (StreamProvider)
          login_provider.dart         ← loginProvider (StateNotifier)
          register_provider.dart

      /booking
        /data
          booking_repository.dart     ← POST /api/bookings, GET /api/bookings/my
          booking_model.dart
          schedule_model.dart
        /presentation
          home_screen.dart
          route_search_screen.dart
          schedule_list_screen.dart
          schedule_detail_screen.dart
          booking_confirm_screen.dart
          booking_success_screen.dart
          booking_history_screen.dart
          booking_detail_screen.dart
          widgets/
            schedule_card.dart
            booking_card.dart
            eticket_widget.dart        ← E-ticket with QR code display
        /providers
          schedule_provider.dart       ← FutureProvider for schedule search
          booking_provider.dart        ← StateNotifier for booking flow state
          booking_history_provider.dart

      /tracking
        /data
          tracking_repository.dart     ← RTDB listener
          bus_location_model.dart
          trip_status_model.dart
        /presentation
          tracking_map_screen.dart
          widgets/
            bus_marker_widget.dart     ← Custom animated map marker
            eta_banner_widget.dart     ← ETA display overlay
            stale_signal_widget.dart   ← Orange "signal lost" banner
        /providers
          tracking_provider.dart       ← StreamProvider.family<BusLocation, String>
          trip_status_provider.dart    ← StreamProvider for ETA and currentStop

      /fare
        /data
          fare_repository.dart         ← GET /api/fare
          fare_model.dart              ← FareBreakdown Dart class
        /presentation
          fare_estimator_screen.dart
          seat_picker_screen.dart
          widgets/
            fare_breakdown_card.dart   ← Displays baseFare + segmentKm + total
            seat_grid_widget.dart      ← Visual seat picker GridView
            stop_selector_widget.dart  ← Dropdown for fromStop/toStop
        /providers
          fare_provider.dart           ← FutureProvider.family

      /operator
        /data
          operator_repository.dart     ← PUT /api/schedules/:id, GET schedule
          operator_schedule_model.dart
        /presentation
          operator_home_screen.dart
          operator_schedule_list_screen.dart
          trip_dashboard_screen.dart
          passenger_manifest_screen.dart
          status_update_screen.dart
          seat_management_screen.dart
          widgets/
            trip_control_buttons.dart  ← Start Trip / End Trip
            passenger_list_tile.dart
            delay_input_form.dart
            gps_status_indicator.dart  ← Live GPS signal strength indicator
        /providers
          operator_schedule_provider.dart
          trip_provider.dart           ← StateNotifier for active trip state
          gps_service.dart             ← GPS broadcasting service

      /notifications
        /data
          notification_repository.dart ← Firestore subcollection read
          notification_model.dart
        /presentation
          notifications_screen.dart
          widgets/
            notification_tile.dart
        /providers
          notifications_provider.dart  ← StreamProvider for real-time notif list
          fcm_provider.dart            ← FCM token management + foreground handler

      /chatbot
        /presentation
          chatbot_screen.dart
          widgets/
            chatbot_webview.dart       ← Dialogflow ES WebView wrapper

      /feedback
        /data
          feedback_repository.dart     ← POST /api/feedback (or direct Firestore)
          feedback_model.dart
        /presentation
          trip_rating_screen.dart
          widgets/
            star_rating_widget.dart

      /profile
        /data
          profile_repository.dart      ← Firestore user document read/write
          profile_model.dart
        /presentation
          profile_screen.dart
          widgets/
            profile_avatar.dart

    /router
      app_router.dart                  ← go_router config + redirect guards
      route_names.dart                 ← Route name constants

    /services
      hive_service.dart                ← Hive box init + helper methods
      fcm_background_handler.dart      ← FCM background message handler (top-level)

    firebase_options.dart              ← Auto-generated by FlutterFire CLI
    main.dart                          ← App entry point

  pubspec.yaml
  pubspec.lock
  .env                                 ← dart-define variables (never commit)
  analysis_options.yaml
  README.md
```


---

## 6. State Management — Riverpod

### Provider Types Used

| Provider Type | Use Case | Example |
| :-- | :-- | :-- |
| `StreamProvider` | Real-time Firebase streams | Auth state, GPS location, notifications |
| `StreamProvider.family` | Real-time stream per parameter | `trackingProvider(busId)` |
| `FutureProvider` | One-shot async data fetch | Schedule list, fare estimate |
| `FutureProvider.family` | One-shot async fetch per param | `scheduleDetailProvider(scheduleId)` |
| `StateNotifierProvider` | Multi-step flow with mutable state | Booking flow, active trip state |
| `Provider` | Synchronous derived values | `isLoggedInProvider`, `userRoleProvider` |

### Example: Booking Flow StateNotifier

```dart
// /features/booking/providers/booking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';

enum BookingStatus { idle, loading, success, error }

class BookingState {
  final BookingStatus status;
  final String? selectedScheduleId;
  final String? selectedSeatNo;
  final String? fromStop;
  final String? toStop;
  final double? estimatedFare;
  final BookingModel? confirmedBooking;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStatus.idle,
    this.selectedScheduleId,
    this.selectedSeatNo,
    this.fromStop,
    this.toStop,
    this.estimatedFare,
    this.confirmedBooking,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStatus? status,
    String? selectedScheduleId,
    String? selectedSeatNo,
    String? fromStop,
    String? toStop,
    double? estimatedFare,
    BookingModel? confirmedBooking,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      selectedScheduleId: selectedScheduleId ?? this.selectedScheduleId,
      selectedSeatNo: selectedSeatNo ?? this.selectedSeatNo,
      fromStop: fromStop ?? this.fromStop,
      toStop: toStop ?? this.toStop,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      confirmedBooking: confirmedBooking ?? this.confirmedBooking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _repo;

  BookingNotifier(this._repo) : super(const BookingState());

  void selectSchedule(String scheduleId) =>
      state = state.copyWith(selectedScheduleId: scheduleId);

  void selectSeat(String seatNo) =>
      state = state.copyWith(selectedSeatNo: seatNo);

  void selectStops(String from, String to) =>
      state = state.copyWith(fromStop: from, toStop: to);

  void setFare(double fare) =>
      state = state.copyWith(estimatedFare: fare);

  Future<void> confirmBooking() async {
    if (state.selectedScheduleId == null ||
        state.selectedSeatNo == null ||
        state.fromStop == null ||
        state.toStop == null) return;

    state = state.copyWith(status: BookingStatus.loading);
    try {
      final booking = await _repo.createBooking(
        scheduleId: state.selectedScheduleId!,
        seatNo: state.selectedSeatNo!,
        fromStop: state.fromStop!,
        toStop: state.toStop!,
      );
      state = state.copyWith(
        status: BookingStatus.success,
        confirmedBooking: booking,
      );
    } catch (e) {
      state = state.copyWith(
        status: BookingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const BookingState();
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier(ref.watch(bookingRepositoryProvider));
});

final bookingRepositoryProvider = Provider((ref) => BookingRepository());
```


### Example: Active Trip StateNotifier (Operator)

```dart
// /features/operator/providers/trip_provider.dart

enum TripStatus { idle, active, ended }

class TripState {
  final TripStatus status;
  final String? activeScheduleId;
  final bool isGpsBroadcasting;
  final int? delayMinutes;
  final String? currentStop;

  const TripState({
    this.status = TripStatus.idle,
    this.activeScheduleId,
    this.isGpsBroadcasting = false,
    this.delayMinutes,
    this.currentStop,
  });

  TripState copyWith({
    TripStatus? status,
    String? activeScheduleId,
    bool? isGpsBroadcasting,
    int? delayMinutes,
    String? currentStop,
  }) => TripState(
    status: status ?? this.status,
    activeScheduleId: activeScheduleId ?? this.activeScheduleId,
    isGpsBroadcasting: isGpsBroadcasting ?? this.isGpsBroadcasting,
    delayMinutes: delayMinutes ?? this.delayMinutes,
    currentStop: currentStop ?? this.currentStop,
  );
}

class TripNotifier extends StateNotifier<TripState> {
  final OperatorRepository _repo;
  final GpsService _gps;

  TripNotifier(this._repo, this._gps) : super(const TripState());

  Future<void> startTrip(String scheduleId, String busId) async {
    await _repo.updateScheduleStatus(scheduleId, 'active');
    _gps.startBroadcasting(busId);
    state = state.copyWith(
      status: TripStatus.active,
      activeScheduleId: scheduleId,
      isGpsBroadcasting: true,
    );
  }

  Future<void> endTrip(String scheduleId) async {
    _gps.stopBroadcasting();
    await _repo.updateScheduleStatus(scheduleId, 'completed');
    state = state.copyWith(
      status: TripStatus.ended,
      isGpsBroadcasting: false,
    );
  }

  Future<void> reportDelay(String scheduleId, int minutes) async {
    await _repo.updateDelay(scheduleId, minutes);
    state = state.copyWith(delayMinutes: minutes);
  }

  Future<void> updateCurrentStop(String scheduleId, String stopName) async {
    await _repo.updateCurrentStop(scheduleId, stopName);
    state = state.copyWith(currentStop: stopName);
  }
}

final tripProvider =
    StateNotifierProvider<TripNotifier, TripState>((ref) {
  return TripNotifier(
    ref.watch(operatorRepositoryProvider),
    ref.watch(gpsServiceProvider),
  );
});

final gpsServiceProvider = Provider((ref) => GpsService());
final operatorRepositoryProvider = Provider((ref) => OperatorRepository());
```


---

## 7. Navigation — go_router

### Route Names Constants (`route_names.dart`)

```dart
class RouteNames {
  static const splash          = 'splash';
  static const login           = 'login';
  static const register        = 'register';
  // Passenger
  static const home            = 'home';
  static const search          = 'search';
  static const schedules       = 'schedules';
  static const scheduleDetail  = 'schedule-detail';
  static const fareEstimator   = 'fare-estimator';
  static const seatPicker      = 'seat-picker';
  static const bookingConfirm  = 'booking-confirm';
  static const bookingSuccess  = 'booking-success';
  static const myBookings      = 'my-bookings';
  static const bookingDetail   = 'booking-detail';
  static const tracking        = 'tracking';
  static const chatbot         = 'chatbot';
  static const tripRating      = 'trip-rating';
  // Operator
  static const operatorHome      = 'operator-home';
  static const operatorSchedules = 'operator-schedules';
  static const tripDashboard     = 'trip-dashboard';
  static const manifest          = 'manifest';
  static const statusUpdate      = 'status-update';
  static const seatManagement    = 'seat-management';
  // Shared
  static const notifications   = 'notifications';
  static const profile         = 'profile';
}
```


### Router Configuration (`app_router.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final auth = authState.valueOrNull;
      if (auth == null) return null; // still loading

      final isLoggedIn = auth.role != UserRole.unauthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
                          state.matchedLocation == '/register' ||
                          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        return auth.role == UserRole.operator ? '/operator/home' : '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash',    name: RouteNames.splash,   builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',     name: RouteNames.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',  name: RouteNames.register, builder: (_, __) => const RegisterScreen()),

      // ── Passenger Shell ──────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => PassengerShell(child: child),
        routes: [
          GoRoute(path: '/home',           name: RouteNames.home,           builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/search',         name: RouteNames.search,         builder: (_, __) => const RouteSearchScreen()),
          GoRoute(
            path: '/schedules',
            name: RouteNames.schedules,
            builder: (_, state) => ScheduleListScreen(
              from: state.uri.queryParameters['from']!,
              to:   state.uri.queryParameters['to']!,
              date: state.uri.queryParameters['date']!,
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.scheduleDetail,
                builder: (_, state) => ScheduleDetailScreen(scheduleId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: '/fare-estimator', name: RouteNames.fareEstimator,  builder: (_, __) => const FareEstimatorScreen()),
          GoRoute(path: '/seat-picker',    name: RouteNames.seatPicker,     builder: (_, __) => const SeatPickerScreen()),
          GoRoute(path: '/booking-confirm',name: RouteNames.bookingConfirm, builder: (_, __) => const BookingConfirmScreen()),
          GoRoute(path: '/booking-success',name: RouteNames.bookingSuccess, builder: (_, __) => const BookingSuccessScreen()),
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
          GoRoute(path: '/chatbot',        name: RouteNames.chatbot,        builder: (_, __) => const ChatbotScreen()),
          GoRoute(path: '/notifications',  name: RouteNames.notifications,  builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile',        name: RouteNames.profile,        builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Operator Shell ────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => OperatorShell(child: child),
        routes: [
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
          GoRoute(path: '/notifications', name: RouteNames.notifications, builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile',       name: RouteNames.profile,       builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});
```


---

## 8. Firebase Integration Layer

### Firebase Services Used by Mobile

| Service | Package | Used By |
| :-- | :-- | :-- |
| Firebase Auth | `firebase_auth` | Both roles — login, token, role claim |
| Cloud Firestore | `cloud_firestore` | Bookings, schedules, routes, fares, feedback |
| Realtime Database | `firebase_database` | GPS writes (operator), GPS reads (passenger) |
| Firebase Messaging | `firebase_messaging` | Push notifications (both roles) |
| Firebase Storage | `firebase_storage` | Profile photos (optional) |

### Firebase Initialization (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_fcmBackgroundHandler);

  // Initialize Hive offline cache
  await HiveService.init();

  runApp(const ProviderScope(child: RideSyncApp()));
}

// Must be a top-level function
@pragma('vm:entry-point')
Future<void> _fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Handle background notification (store to Hive if needed)
}
```


### Firestore Repository Base Pattern

```dart
// All repositories follow this pattern
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<BookingModel> createBooking({
    required String scheduleId,
    required String seatNo,
    required String fromStop,
    required String toStop,
  }) async {
    final token = await _auth.currentUser!.getIdToken();
    // Delegates to Node.js API for Firestore transaction (not direct SDK write)
    // because the seat-lock must be atomic and server-validated
    final response = await ApiClient.post(
      endpoint: ApiEndpoints.createBooking,
      token: token!,
      body: {
        'scheduleId': scheduleId,
        'seatNo': seatNo,
        'fromStop': fromStop,
        'toStop': toStop,
      },
    );
    return BookingModel.fromJson(response);
  }

  Stream<List<BookingModel>> watchMyBookings() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('bookings')
        .where('passengerId', isEqualTo: uid)
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BookingModel.fromJson(d.data()))
            .toList());
  }
}
```


---

## 9. GPS Tracking Module

> The GPS module is **operator-only**. It runs as a periodic timer service that writes to Firebase RTDB every 3–10 seconds based on movement speed.

### GPS Service (`gps_service.dart`)

```dart
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class GpsService {
  final DatabaseReference _rtdb = FirebaseDatabase.instance.ref();
  Timer? _locationTimer;

  static const int _fastIntervalSec = 3;   // when speed > 5 km/h
  static const int _slowIntervalSec = 10;  // when stationary
  static const double _movingThresholdMps = 1.4; // 5 km/h in m/s

  /// Call this when operator taps "Start Trip"
  Future<void> startBroadcasting(String busId) async {
    await _requestPermissions();
    _scheduleUpdate(busId, _fastIntervalSec);
  }

  void _scheduleUpdate(String busId, int intervalSec) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(Duration(seconds: intervalSec), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        final bool isMoving = pos.speed >= _movingThresholdMps;
        final int nextInterval =
            isMoving ? _fastIntervalSec : _slowIntervalSec;

        // Adaptive: if speed mode changed, reschedule at correct interval
        if (nextInterval != intervalSec) {
          _scheduleUpdate(busId, nextInterval);
          return;
        }

        await _rtdb.child('busLocations/$busId').set({
          'lat':       pos.latitude,
          'lng':       pos.longitude,
          'speed':     double.parse((pos.speed * 3.6).toStringAsFixed(1)),
          'heading':   pos.heading,
          'timestamp': ServerValue.timestamp,
        });
      } on TimeoutException {
        debugPrint('GPS timeout — skipping RTDB write');
      } catch (e) {
        debugPrint('GPS write error: $e');
      }
    });
  }

  /// Call this when operator taps "End Trip"
  void stopBroadcasting() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }
  }
}
```


### Android Permissions (`AndroidManifest.xml`)

```xml
<!-- Required for GPS in background while operator is driving -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
```


### GPS Status Indicator Widget (`gps_status_indicator.dart`)

```dart
class GpsStatusIndicator extends ConsumerWidget {
  const GpsStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);

    return Row(
      children: [
        Icon(
          tripState.isGpsBroadcasting ? Icons.gps_fixed : Icons.gps_off,
          color: tripState.isGpsBroadcasting ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          tripState.isGpsBroadcasting
              ? 'GPS Broadcasting'
              : 'GPS Inactive',
          style: AppTextStyles.caption.copyWith(
            color: tripState.isGpsBroadcasting ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
```


---

## 10. Live Tracking — Passenger Map

### Tracking Provider (`tracking_provider.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

class BusLocation {
  final double lat;
  final double lng;
  final double speed;
  final double heading;
  final int timestamp;

  const BusLocation({
    required this.lat,
    required this.lng,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  factory BusLocation.fromSnapshot(DataSnapshot snapshot) {
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return BusLocation(
      lat:       (data['lat'] as num).toDouble(),
      lng:       (data['lng'] as num).toDouble(),
      speed:     (data['speed'] as num).toDouble(),
      heading:   (data['heading'] as num).toDouble(),
      timestamp: data['timestamp'] as int,
    );
  }

  /// True if last update was more than 30 seconds ago
  bool get isStale =>
      DateTime.now().millisecondsSinceEpoch - timestamp > 30000;
}

final trackingProvider =
    StreamProvider.family<BusLocation, String>((ref, busId) {
  return FirebaseDatabase.instance
      .ref('busLocations/$busId')
      .onValue
      .map((event) => BusLocation.fromSnapshot(event.snapshot));
});

// ETA and current stop from tripStatus
final tripStatusProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, scheduleId) {
  return FirebaseDatabase.instance
      .ref('tripStatus/$scheduleId')
      .onValue
      .map((event) {
        final data = event.snapshot.value as Map?;
        return data != null ? Map<String, dynamic>.from(data) : {};
      });
});
```


### Tracking Map Screen (`tracking_map_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingMapScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  final String busId;

  const TrackingMapScreen({
    super.key,
    required this.scheduleId,
    required this.busId,
  });

  @override
  ConsumerState<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends ConsumerState<TrackingMapScreen> {
  GoogleMapController? _mapController;
  Marker? _busMarker;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(trackingProvider(widget.busId));
    final tripStatusAsync = ref.watch(tripStatusProvider(widget.scheduleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.9271, 79.8612), // Default: Colombo
              zoom: 13,
            ),
            markers: _busMarker != null ? {_busMarker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          ),

          // ETA Banner
          tripStatusAsync.when(
            data: (status) => status.isNotEmpty
                ? ETABannerWidget(eta: status['eta'], currentStop: status['currentStop'])
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Stale Signal Warning
          locationAsync.when(
            data: (location) {
              _updateMarker(location);
              return location.isStale
                  ? const StaleSignalWidget()
                  : const SizedBox.shrink();
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: Text('Tracking unavailable')),
          ),
        ],
      ),
    );
  }

  void _updateMarker(BusLocation location) {
    final newPos = LatLng(location.lat, location.lng);
    setState(() {
      _busMarker = Marker(
        markerId: const MarkerId('bus'),
        position: newPos,
        rotation: location.heading,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Bus',
          snippet: '${location.speed.toStringAsFixed(1)} km/h',
        ),
      );
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
  }
}
```


---

## 11. Booking Module

### Booking Repository (`booking_repository.dart`)

```dart
class BookingRepository {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  /// POST /api/bookings — delegates to Node.js for atomic Firestore transaction
  Future<BookingModel> createBooking({
    required String scheduleId,
    required String seatNo,
    required String fromStop,
    required String toStop,
  }) async {
    final token = await _auth.currentUser!.getIdToken();
    final json  = await ApiClient.post(
      endpoint: ApiEndpoints.createBooking,
      token: token!,
      body: {
        'scheduleId': scheduleId,
        'seatNo':     seatNo,
        'fromStop':   fromStop,
        'toStop':     toStop,
      },
    );
    // Cache to Hive for offline access
    await HiveService.cacheBooking(json['data']);
    return BookingModel.fromJson(json['data']);
  }

  /// GET /api/bookings/my
  Future<List<BookingModel>> fetchMyBookings() async {
    final token = await _auth.currentUser!.getIdToken();
    final json  = await ApiClient.get(
      endpoint: ApiEndpoints.myBookings,
      token: token!,
    );
    return (json['data'] as List)
        .map((b) => BookingModel.fromJson(b))
        .toList();
  }

  /// PUT /api/bookings/:id/cancel
  Future<void> cancelBooking(String bookingId) async {
    final token = await _auth.currentUser!.getIdToken();
    await ApiClient.put(
      endpoint: '${ApiEndpoints.booking}/$bookingId/cancel',
      token: token!,
      body: {},
    );
  }
}
```


### BookingModel (`booking_model.dart`)

```dart
class BookingModel {
  final String bookingId;
  final String scheduleId;
  final String fromStop;
  final String toStop;
  final String seatNo;
  final double fare;
  final FareBreakdown fareBreakdown;
  final String status; // "confirmed" | "cancelled" | "completed"
  final DateTime bookedAt;

  const BookingModel({
    required this.bookingId,
    required this.scheduleId,
    required this.fromStop,
    required this.toStop,
    required this.seatNo,
    required this.fare,
    required this.fareBreakdown,
    required this.status,
    required this.bookedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId:     json['bookingId'],
      scheduleId:    json['scheduleId'],
      fromStop:      json['fromStop'],
      toStop:        json['toStop'],
      seatNo:        json['seatNo'],
      fare:          (json['fare'] as num).toDouble(),
      fareBreakdown: FareBreakdown.fromJson(json['fareBreakdown']),
      status:        json['status'],
      bookedAt:      DateTime.parse(json['bookedAt']),
    );
  }
}

class FareBreakdown {
  final double baseFare;
  final double segmentKm;
  final double ratePerKm;
  final double classMultiplier;
  final String busClass;

  const FareBreakdown({
    required this.baseFare,
    required this.segmentKm,
    required this.ratePerKm,
    required this.classMultiplier,
    required this.busClass,
  });

  factory FareBreakdown.fromJson(Map<String, dynamic> json) {
    return FareBreakdown(
      baseFare:        (json['baseFare'] as num).toDouble(),
      segmentKm:       (json['segmentKm'] as num).toDouble(),
      ratePerKm:       (json['ratePerKm'] as num).toDouble(),
      classMultiplier: (json['classMultiplier'] as num).toDouble(),
      busClass:        json['busClass'],
    );
  }
}
```


---

## 12. Seat Picker UI Module

The seat picker is a visual `GridView.builder` where each cell represents one seat, color-coded by availability.

### SeatGridWidget (`seat_grid_widget.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeatGridWidget extends ConsumerWidget {
  /// seatMap from Firestore: { "A1": null, "A2": "uid_xyz", ... }
  final Map<String, dynamic> seatMap;
  final int seatsPerRow;

  const SeatGridWidget({
    super.key,
    required this.seatMap,
    this.seatsPerRow = 4,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seats      = seatMap.keys.toList()..sort();
    final selectedSeat = ref.watch(bookingProvider).selectedSeatNo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(
          children: [
            _LegendTile(color: Colors.green.shade100, label: 'Available'),
            const SizedBox(width: 16),
            _LegendTile(color: Colors.red.shade100,   label: 'Booked'),
            const SizedBox(width: 16),
            _LegendTile(color: Colors.blue.shade200,  label: 'Selected'),
          ],
        ),
        const SizedBox(height: 16),
        // Seat grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: seatsPerRow,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: seats.length,
          itemBuilder: (context, index) {
            final seatNo   = seats[index];
            final bookedBy = seatMap[seatNo];
            final isBooked   = bookedBy != null;
            final isSelected = seatNo == selectedSeat;

            Color color = isSelected
                ? Colors.blue.shade200
                : isBooked
                    ? Colors.red.shade100
                    : Colors.green.shade100;

            return GestureDetector(
              onTap: isBooked
                  ? null
                  : () => ref
                      .read(bookingProvider.notifier)
                      .selectSeat(seatNo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    seatNo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isBooked ? Colors.red.shade400 : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LegendTile extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendTile({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
```


---

## 13. Fare Estimator Module

### Fare Repository (`fare_repository.dart`)

```dart
class FareRepository {
  final _auth = FirebaseAuth.instance;

  Future<FareBreakdown> getFareEstimate({
    required String scheduleId,
    required String fromStop,
    required String toStop,
    required String busClass,
  }) async {
    final token = await _auth.currentUser!.getIdToken();
    final json  = await ApiClient.get(
      endpoint: ApiEndpoints.fare,
      token: token!,
      queryParams: {
        'scheduleId': scheduleId,
        'fromStop':   fromStop,
        'toStop':     toStop,
        'class':      busClass,
      },
    );
    return FareBreakdown.fromJson(json['data']);
  }
}

// Provider
final fareProvider = FutureProvider.family<FareBreakdown, FareParams>((ref, params) {
  return ref.watch(fareRepositoryProvider).getFareEstimate(
    scheduleId: params.scheduleId,
    fromStop:   params.fromStop,
    toStop:     params.toStop,
    busClass:   params.busClass,
  );
});

class FareParams {
  final String scheduleId;
  final String fromStop;
  final String toStop;
  final String busClass;
  const FareParams({
    required this.scheduleId,
    required this.fromStop,
    required this.toStop,
    required this.busClass,
  });
}
```


### Fare Breakdown Card Widget (`fare_breakdown_card.dart`)

```dart
class FareBreakdownCard extends StatelessWidget {
  final FareBreakdown fare;

  const FareBreakdownCard({super.key, required this.fare});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fare Breakdown', style: AppTextStyles.sectionHeader),
            const Divider(),
            _FareRow('Base Fare',       'LKR ${fare.baseFare.toStringAsFixed(2)}'),
            _FareRow('Distance',        '${fare.segmentKm} km'),
            _FareRow('Rate per km',     'LKR ${fare.ratePerKm}'),
            _FareRow('Class',           fare.busClass),
            _FareRow('Multiplier',      '${fare.classMultiplier}x'),
            const Divider(),
            _FareRow(
              'Total Fare',
              'LKR ${_computeTotal(fare).toStringAsFixed(0)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  double _computeTotal(FareBreakdown f) =>
      f.baseFare + (f.segmentKm * f.ratePerKm * f.classMultiplier);
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _FareRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTextStyles.bodyBold : AppTextStyles.body),
          Text(value, style: bold ? AppTextStyles.bodyBold : AppTextStyles.body),
        ],
      ),
    );
  }
}
```


---

## 14. Push Notifications Module

### FCM Provider (`fcm_provider.dart`)

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmProvider = Provider<FcmService>((ref) => FcmService());

class FcmService {
  final _messaging            = FirebaseMessaging.instance;
  final _localNotifications   = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission (iOS requires this; Android 13+ also requires it)
    await _messaging.requestPermission(
      alert:      true,
      badge:      true,
      sound:      true,
      provisional: false,
    );

    // Local notification channel (Android)
    const androidChannel = AndroidNotificationChannel(
      'ridesync_high_importance',
      'RideSync Notifications',
      description: 'Booking confirmations, trip alerts, and delay notifications',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Initialize flutter_local_notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS:     DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // Update FCM token in Firestore on refresh
    _messaging.onTokenRefresh.listen(_uploadToken);

    // Upload initial token
    final token = await _messaging.getToken();
    if (token != null) await _uploadToken(token);
  }

  Future<void> _uploadToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'fcmToken': token});
  }
}
```


### Notification Types Handled

| Type | Trigger | Displayed As |
| :-- | :-- | :-- |
| `booking` | Booking confirmed | "Seat A2 booked on Colombo–Kandy" |
| `delay` | Operator reports delay | "Your bus is delayed by 15 minutes" |
| `alert` | Bus 5 min from your stop | "Bus arriving at Kadawatha in ~5 min" |
| `promo` | Admin broadcast | General announcement |


---

## 15. AI Chatbot Module

The chatbot uses Dialogflow ES via a `WebView` iframe. No custom ML. The backend Node.js `/api/chatbot/message` endpoint proxies messages to Dialogflow.

### Chatbot WebView (`chatbot_webview.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse(
        // Dialogflow Messenger web integration URL
        'https://YOUR_DIALOGFLOW_MESSENGER_URL',
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RideSync Assistant')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
```

> **Alternative (API Proxy):** If the Dialogflow Messenger iframe is not suitable, implement a custom chat UI with `ListView` messages and call `POST /api/chatbot/message` with each user message. The backend returns the Dialogflow intent response.

---

## 16. Offline Caching — Hive

Hive provides local key-value storage for offline access to booking confirmations and cached route data.

### Hive Service (`hive_service.dart`)

```dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _bookingsBox = 'cached_bookings';
  static const _routesBox   = 'cached_routes';
  static const _userBox     = 'cached_user';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_bookingsBox);
    await Hive.openBox(_routesBox);
    await Hive.openBox(_userBox);
  }

  // Cache a confirmed booking for offline e-ticket access
  static Future<void> cacheBooking(Map<String, dynamic> booking) async {
    final box = Hive.box(_bookingsBox);
    await box.put(booking['bookingId'], booking);
  }

  // Retrieve a cached booking by ID (used when offline)
  static Map<String, dynamic>? getCachedBooking(String bookingId) {
    final box = Hive.box(_bookingsBox);
    return box.get(bookingId) as Map<String, dynamic>?;
  }

  // Get all cached bookings
  static List<Map<String, dynamic>> getAllCachedBookings() {
    final box = Hive.box(_bookingsBox);
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  // Cache route list for offline search
  static Future<void> cacheRoutes(List<Map<String, dynamic>> routes) async {
    final box = Hive.box(_routesBox);
    await box.put('routes', routes);
  }

  static List<Map<String, dynamic>> getCachedRoutes() {
    final box = Hive.box(_routesBox);
    final data = box.get('routes');
    return data != null ? List<Map<String, dynamic>>.from(data) : [];
  }

  // Cache user profile
  static Future<void> cacheUser(Map<String, dynamic> user) async {
    final box = Hive.box(_userBox);
    await box.put('user', user);
  }

  static Map<String, dynamic>? getCachedUser() {
    final box = Hive.box(_userBox);
    return box.get('user') as Map<String, dynamic>?;
  }
}
```


### Offline-Aware Repository Pattern

```dart
// In BookingRepository.fetchMyBookings():
Future<List<BookingModel>> fetchMyBookings() async {
  try {
    final token = await _auth.currentUser!.getIdToken();
    final json  = await ApiClient.get(
      endpoint: ApiEndpoints.myBookings,
      token: token!,
    );
    final bookings = (json['data'] as List)
        .map((b) => BookingModel.fromJson(b))
        .toList();

    // Update Hive cache with fresh data
    for (final b in bookings) {
      await HiveService.cacheBooking(b.toJson());
    }
    return bookings;
  } catch (e) {
    // Network error — return cached data
    final cached = HiveService.getAllCachedBookings();
    if (cached.isEmpty) rethrow;
    return cached.map((b) => BookingModel.fromJson(b)).toList();
  }
}
```


---

## 17. API Communication Layer

### API Client (`api_client.dart`)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/errors/app_failure.dart';

class ApiClient {
  static final _baseUrl = Env.apiBaseUrl;
  static final _client  = http.Client();

  static Future<Map<String, dynamic>> get({
    required String endpoint,
    required String token,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );
    final response = await _client.get(
      uri,
      headers: _headers(token),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put({
    required String endpoint,
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final response = await _client.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Map<String, String> _headers(String token) => {
    'Content-Type':  'application/json',
    'Authorization': 'Bearer $token',
  };

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }
    switch (response.statusCode) {
      case 401: throw AuthFailure(json['error'] ?? 'Unauthorized');
      case 403: throw AuthFailure(json['error'] ?? 'Forbidden');
      case 409: throw ServerFailure(json['error'] ?? 'Conflict');
      case 422: throw ServerFailure(json['error'] ?? 'Validation error');
      default:  throw NetworkFailure(json['error'] ?? 'Server error');
    }
  }
}
```


### API Endpoints Constants (`api_endpoints.dart`)

```dart
class ApiEndpoints {
  static const register       = '/api/auth/register';
  static const schedules      = '/api/schedules';
  static const scheduleSeats  = '/api/schedules'; // + /:id/seats
  static const fare           = '/api/fare';
  static const createBooking  = '/api/bookings';
  static const myBookings     = '/api/bookings/my';
  static const booking        = '/api/bookings'; // + /:id
  static const chatbot        = '/api/chatbot/message';
  static const health         = '/api/health';
}
```


---

## 18. Mobile Security

### Token Handling Rules

- Firebase ID tokens expire in 1 hour. The Firebase Auth SDK auto-refreshes them silently.
- **Never store** the raw ID token in Hive or SharedPreferences. Always call `user.getIdToken()` fresh before each API request.
- Role claims are read with `getIdTokenResult(true)` — the `true` forces a server refresh to always get up-to-date claims.


### Firebase App Check (`main.dart`)

```dart
// Prevents unauthorized apps from calling your Firebase resources
import 'package:firebase_app_check/firebase_app_check.dart';

await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.debug,  // Use .playIntegrity for production
  appleProvider:   AppleProvider.debug,    // Use .deviceCheck for production
);
```


### Input Validation (Client-Side)

```dart
// In validators.dart — used in all form fields before API calls
class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || !RegExp(r'^\+?[0-9]{9,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
```


### Security Checklist (Mobile)

- [ ] `google-services.json` and `GoogleService-Info.plist` are in `.gitignore`
- [ ] API base URL loaded from `--dart-define` (not hardcoded in source)
- [ ] Firebase App Check activated before production release
- [ ] `getIdToken()` called fresh before every API request — never cached
- [ ] Role claims read with `forceRefresh: true` on login
- [ ] No sensitive data (token, phone, NIC) stored in Hive in plain text
- [ ] Deep link validation: go_router guards check role on every navigation
- [ ] HTTP timeout set (15s) on all API calls to prevent hanging UI
- [ ] GPS permission explicitly requested at runtime with clear user message
- [ ] Background location permission request deferred until operator taps "Start Trip"

---

## 19. Complete pubspec.yaml

```yaml
name: ridesync
description: RideSync — Smart Public Bus Transportation Platform
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^13.2.1

  # Firebase
  firebase_core:       ^3.3.0
  firebase_auth:       ^5.1.4
  cloud_firestore:     ^5.2.1
  firebase_database:   ^11.1.3
  firebase_messaging:  ^15.1.0
  firebase_storage:    ^12.2.0
  firebase_app_check:  ^0.3.0

  # Maps & Location
  google_maps_flutter: ^2.6.1
  geolocator:          ^12.0.0

  # Push Notifications
  flutter_local_notifications: ^17.2.2

  # HTTP & Networking
  http: ^1.2.2

  # Offline Storage
  hive_flutter: ^1.1.0

  # Chatbot WebView
  webview_flutter: ^4.7.0

  # UI & Utilities
  intl:                ^0.19.0
  cached_network_image: ^3.3.1
  flutter_svg:          ^2.0.10
  shimmer:              ^3.0.0
  qr_flutter:           ^4.1.0
  lottie:               ^3.1.2

  # Code Generation
  freezed_annotation:   ^2.4.4
  json_annotation:      ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints:          ^4.0.0
  build_runner:           ^2.4.11
  freezed:                ^2.5.7
  json_serializable:      ^6.8.0
  riverpod_generator:     ^2.4.0
  mockito:                ^5.4.4
  fake_cloud_firestore:   ^3.0.3

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```


---

## 20. Environment Configuration

### Dart Define Approach (Secure)

```bash
# Development build
flutter run \
  --dart-define=API_BASE_URL=http://localhost:5001/ridesync-prod/asia-southeast1/api \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_DEV_KEY

# Production build (APK)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://asia-southeast1-ridesync-prod.cloudfunctions.net/api \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_PROD_KEY
```


### Env Class (`env.dart`)

```dart
class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://asia-southeast1-ridesync-prod.cloudfunctions.net/api',
  );
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
```


### Google Maps API Key — Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<application ...>
  <meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}" />
</application>
```


---

## 21. Mobile-Specific Data Flows

### Passenger Full Booking Flow (Mobile Steps)

```
1.  HomeScreen → user types origin/destination → taps "Search"
2.  go_router.push('/schedules?from=X&to=Y&date=Z')
3.  scheduleProvider (FutureProvider) calls GET /api/schedules
4.  ScheduleListScreen shows list of ScheduleCard widgets
5.  User taps schedule → go_router.push('/schedules/:id')
6.  ScheduleDetailScreen shows departure time, operator, bus class
7.  User taps "Select Seat" → go_router.push('/fare-estimator')
8.  FareEstimatorScreen: user picks fromStop, toStop from StopSelectorWidget
9.  fareProvider FutureProvider calls GET /api/fare?... → shows FareBreakdownCard
10. User taps "Choose Seat" → go_router.push('/seat-picker')
11. SeatPickerScreen: SeatGridWidget renders seatMap from schedule
12. User taps available seat → bookingProvider.selectSeat(seatNo) called
13. User taps "Confirm" → go_router.push('/booking-confirm')
14. BookingConfirmScreen: shows summary of schedule + seat + fare
15. User taps "Pay & Book" → bookingProvider.confirmBooking() called
16. BookingNotifier sets status = loading → LoadingOverlay shown
17. POST /api/bookings → 201 response → BookingModel created
18. BookingModel cached to Hive via HiveService.cacheBooking()
19. bookingProvider.status = success
20. go_router.pushReplacement('/booking-success')
21. BookingSuccessScreen shows e-ticket with QR, seat number, fare
22. FCM push notification arrives: "Booking Confirmed — Seat A2"
```


### Operator Full Trip Flow (Mobile Steps)

```
1.  OperatorHomeScreen shows today's schedules from operatorScheduleProvider
2.  Operator taps schedule → go_router.push('/operator/trip/:scheduleId')
3.  TripDashboardScreen shows Start Trip button + GPS status indicator
4.  Operator taps "Start Trip":
      tripProvider.startTrip(scheduleId, busId) called
      PUT /api/schedules/:id { status: 'active' }
      GpsService.startBroadcasting(busId) starts Timer (3s adaptive)
5.  GPS broadcasts to RTDB /busLocations/{busId} every 3s (moving) or 10s (idle)
6.  GpsStatusIndicator shows green "GPS Broadcasting"
7.  Operator taps "View Passengers" → go_router.push('/operator/manifest/:scheduleId')
8.  PassengerManifestScreen: list of passengers with seat numbers
9.  Operator reports delay → go_router.push('/operator/status/:scheduleId')
10. StatusUpdateScreen: enters delay minutes + current stop → taps "Update"
      tripProvider.reportDelay(scheduleId, minutes) called
      PUT /api/schedules/:id { delayMinutes: 15, currentStop: 'Kegalle' }
      Admin's FCM broadcast fires to all confirmed passengers on this schedule
11. Operator taps "End Trip" on TripDashboardScreen:
      tripProvider.endTrip(scheduleId) called
      GpsService.stopBroadcasting()
      PUT /api/schedules/:id { status: 'completed' }
12. TripState.status = TripStatus.ended
13. OperatorHomeScreen reloads, showing next schedule
```


---

## 22. Performance Considerations

| Concern | Strategy |
| :-- | :-- |
| GPS battery (operator) | Adaptive interval: 3s moving / 10s idle. Stop timer when trip ends. |
| RTDB write cost | Only operator writes. Passenger only reads (zero write cost on tracking). |
| Firestore reads | Use `snapshots()` stream only for booking history. Use single `get()` for static data (routes, fares). |
| Image loading | `cached_network_image` caches downloaded images to device disk. |
| Map rendering | `GoogleMap` re-renders only on marker state change — avoid `setState()` in the whole tree. |
| Large seat maps | Cap seat grid at 60 seats. If more, use paginated GridView. |
| Notifications | Use `sendEachForMulticast` on server side — single API call, not N calls. |
| APK size | Enable code shrinking + obfuscation in `build.gradle`. Use `flutter build apk --split-per-abi` for smaller APK per device. |
| Cold start | Initialize Firebase and Hive in parallel with `Future.wait([...])` in `main()`. |


---

## 23. Mobile Testing Strategy

### Unit Tests (flutter_test)

```dart
// test/features/fare/fare_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('FareBreakdown model', () {
    test('fromJson parses correctly', () {
      final json = {
        'baseFare': 50.0,
        'segmentKm': 115.3,
        'ratePerKm': 2.5,
        'classMultiplier': 1.5,
        'busClass': 'AC',
      };
      final fare = FareBreakdown.fromJson(json);
      expect(fare.segmentKm, 115.3);
      expect(fare.classMultiplier, 1.5);
      expect(fare.busClass, 'AC');
    });
  });
}
```


### Widget Tests (flutter_test)

```dart
// test/features/booking/seat_grid_widget_test.dart
void main() {
  testWidgets('SeatGridWidget marks booked seats red', (tester) async {
    final seatMap = {
      'A1': null,
      'A2': 'some_uid',  // booked
      'B1': null,
    };

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SeatGridWidget(seatMap: seatMap),
          ),
        ),
      ),
    );

    expect(find.text('A1'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);
    // A2 should be non-tappable (booked)
    await tester.tap(find.text('A2'));
    await tester.pump();
    // Verify selectedSeat is still null (tap did nothing)
  });
}
```


### Test Coverage Targets

| Feature | Unit Tests | Widget Tests | Target |
| :-- | :-- | :-- | :-- |
| Auth (login, register, role detection) | ✅ | ✅ | 85% |
| Booking flow (StateNotifier) | ✅ | ✅ | 85% |
| Fare calculation (fromJson, total display) | ✅ | ✅ | 90% |
| Seat picker (color logic, tap guard) | ✅ | ✅ | 90% |
| GPS service (start, stop, adaptive interval) | ✅ | — | 80% |
| Tracking provider (isStale, stream parsing) | ✅ | ✅ | 80% |
| Hive service (cache/retrieve) | ✅ | — | 85% |
| Notifications (FCM token upload) | ✅ | — | 75% |

### Firebase Emulator for Flutter Tests

```bash
# Start emulators
firebase emulators:start --import=./emulator-seed

# Run all Flutter tests against emulator
FIREBASE_AUTH_EMULATOR_HOST="localhost:9099" \
FIRESTORE_EMULATOR_HOST="localhost:8080" \
FIREBASE_DATABASE_EMULATOR_HOST="localhost:9000" \
flutter test
```


---

## 24. Build \& Release Guide

### Development

```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod, Freezed, JSON serializable)
dart run build_runner build --delete-conflicting-outputs

# Run on device (development)
flutter run \
  --dart-define=API_BASE_URL=http://localhost:5001/ridesync-prod/asia-southeast1/api \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_DEV_KEY

# Run all tests
flutter test

# Analyze code
flutter analyze
```


### Production APK Build

```bash
# Build release APK split by ABI (smaller download per device)
flutter build apk --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=API_BASE_URL=https://asia-southeast1-ridesync-prod.cloudfunctions.net/api \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_PROD_KEY

# Output APKs:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  ← modern phones
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk ← older phones
# build/app/outputs/flutter-apk/app-x86_64-release.apk      ← emulators
```


### GitHub Actions — Flutter CI (already in main CI/CD)

```yaml
test-flutter:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.x'
    - run: cd mobile && flutter pub get
    - run: cd mobile && dart run build_runner build --delete-conflicting-outputs
    - run: cd mobile && flutter analyze
    - run: cd mobile && flutter test
    - run: |
        cd mobile && flutter build apk --release \
          --split-per-abi \
          --dart-define=API_BASE_URL=${{ secrets.API_BASE_URL }} \
          --dart-define=GOOGLE_MAPS_API_KEY=${{ secrets.GOOGLE_MAPS_API_KEY }}
    - uses: actions/upload-artifact@v4
      with:
        name: RideSync-APK
        path: mobile/build/app/outputs/flutter-apk/*.apk
```


---

*Document: RIDESYNC_MOBILE_ARCHITECTURE.md*
*Version: 1.0 | March 2026*
*Scope: Flutter Mobile App only — Passenger + Bus Operator personas*
*Companion to: RIDESYNC_ARCHITECTURE_UPDATED.md (v2.0)*
*Project: IS 4110 Capstone | Group 21 | Sabaragamuwa University of Sri Lanka*

```
<span style="display:none">[^1]</span>

<div align="center">⁂</div>

[^1]: RIDESYNC_ARCHITECTURE_UPDATED.md```

