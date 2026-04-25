// `google-services.json` / `GoogleService-Info.plist` 와 동일한 Firebase 앱. 재생성: flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('웹 FCM은 별도 설정이 필요합니다.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('지원하지 않는 플랫폼입니다.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBFgdb7pgaXEjKjHLXO_WOxEYPlXn4aHTw',
    appId: '1:358360545410:android:a77959883557030ab35c9b',
    messagingSenderId: '358360545410',
    projectId: 'kidspoint-3397c',
    storageBucket: 'kidspoint-3397c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbBSesmGo5rFIUXe53I8HvSOa2z4KQtj0',
    appId: '1:358360545410:ios:9a8f55705190cdfab35c9b',
    messagingSenderId: '358360545410',
    projectId: 'kidspoint-3397c',
    storageBucket: 'kidspoint-3397c.firebasestorage.app',
    iosBundleId: 'com.kidspoint.kidsChallenge',
  );
}
