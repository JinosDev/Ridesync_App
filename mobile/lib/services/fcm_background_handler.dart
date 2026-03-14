import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

/// Top-level FCM background message handler.
/// MUST be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  // Firebase must be initialized in the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Optionally store the notification to Hive here for later display
  // HiveService doesn't need to be init'd for simple logging
}
