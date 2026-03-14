import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/hive_service.dart';
import 'services/fcm_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

  // Initialize Hive offline cache (parallel init)
  await HiveService.init();

  runApp(const ProviderScope(child: RideSyncApp()));
}

class RideSyncApp extends ConsumerWidget {
  const RideSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'RideSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
