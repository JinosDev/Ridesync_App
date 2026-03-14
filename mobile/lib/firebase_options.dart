// GENERATED FILE — do NOT edit manually.
// Run: flutterfire configure
// See: https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform not supported in this mobile project. '
        'Use the admin web repo for the web dashboard.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  // TODO: Replace with your actual Firebase project values from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'ridesync-prod',
    databaseURL: 'https://ridesync-prod-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'ridesync-prod.appspot.com',
  );

  // TODO: Replace with your actual Firebase project values from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'ridesync-prod',
    databaseURL: 'https://ridesync-prod-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'ridesync-prod.appspot.com',
    iosBundleId: 'com.ridesync.app',
  );
}
