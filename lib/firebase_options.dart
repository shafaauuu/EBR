// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
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
    apiKey: 'AIzaSyDPzdD0hW-nTLrdzeWNbV4i6j15p_JVkO8',
    appId: '1:20485236317:web:9ecd0d4579156ba9bf4fb4',
    messagingSenderId: '20485236317',
    projectId: 'oji1-745e0',
    authDomain: 'oji1-745e0.firebaseapp.com',
    storageBucket: 'oji1-745e0.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4gpjcm16GZDR11-MyTvWu0DP6YWOMhk0',
    appId: '1:20485236317:android:d4a8c6fdfc7c7b5fbf4fb4',
    messagingSenderId: '20485236317',
    projectId: 'oji1-745e0',
    storageBucket: 'oji1-745e0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZ_fFtqxgDSetZuALNcqFzyCXKKrIsJzs',
    appId: '1:20485236317:ios:c8603985958cdfadbf4fb4',
    messagingSenderId: '20485236317',
    projectId: 'oji1-745e0',
    storageBucket: 'oji1-745e0.firebasestorage.app',
    iosBundleId: 'com.example.oji1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBZ_fFtqxgDSetZuALNcqFzyCXKKrIsJzs',
    appId: '1:20485236317:ios:c8603985958cdfadbf4fb4',
    messagingSenderId: '20485236317',
    projectId: 'oji1-745e0',
    storageBucket: 'oji1-745e0.firebasestorage.app',
    iosBundleId: 'com.example.oji1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDPzdD0hW-nTLrdzeWNbV4i6j15p_JVkO8',
    appId: '1:20485236317:web:3918f9ebd5e7db57bf4fb4',
    messagingSenderId: '20485236317',
    projectId: 'oji1-745e0',
    authDomain: 'oji1-745e0.firebaseapp.com',
    storageBucket: 'oji1-745e0.firebasestorage.app',
  );
}
