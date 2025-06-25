import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAEXVTUZ274y97db-ZX2DEDQLTuBJrq-4Y',
    appId: '1:755202607632:web:YOUR_WEB_APP_ID', // You need to get this from Firebase Console
    messagingSenderId: '755202607632',
    projectId: 'hearme-12944',
    authDomain: 'hearme-12944.firebaseapp.com',
    storageBucket: 'hearme-12944.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEXVTUZ274y97db-ZX2DEDQLTuBJrq-4Y',
    appId: '1:755202607632:android:a9634b7bed5b9275f29895',
    messagingSenderId: '755202607632',
    projectId: 'hearme-12944',
    storageBucket: 'hearme-12944.firebasestorage.app',
    androidClientId: '755202607632-qapg9ofc1db75335ocv7tdfter78e5km.apps.googleusercontent.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAEXVTUZ274y97db-ZX2DEDQLTuBJrq-4Y',
    appId: '1:755202607632:ios:YOUR_IOS_APP_ID', // You need to get this from Firebase Console if you have iOS
    messagingSenderId: '755202607632',
    projectId: 'hearme-12944',
    storageBucket: 'hearme-12944.firebasestorage.app',
    androidClientId: '755202607632-qapg9ofc1db75335ocv7tdfter78e5km.apps.googleusercontent.com',
    iosClientId: '755202607632-ba43qf3ollm6eajgh1c46l5slmh5vvab.apps.googleusercontent.com',
    iosBundleId: 'com.example.hearme',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAEXVTUZ274y97db-ZX2DEDQLTuBJrq-4Y',
    appId: '1:755202607632:macos:YOUR_MACOS_APP_ID', // Add if you have macOS app
    messagingSenderId: '755202607632',
    projectId: 'hearme-12944',
    storageBucket: 'hearme-12944.firebasestorage.app',
    iosClientId: '755202607632-ba43qf3ollm6eajgh1c46l5slmh5vvab.apps.googleusercontent.com',
    iosBundleId: 'com.example.hearme',
  );
}