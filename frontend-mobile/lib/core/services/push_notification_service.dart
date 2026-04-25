import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kids_challenge/data/datasources/api_client.dart';
import 'package:kids_challenge/firebase_options.dart';

/// FCM 토큰 등록 및 수신. [firebase_options.dart] 를 채운 뒤 동작합니다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] background: ${message.messageId}');
}

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'kids_default',
  'Kids Challenge',
  description: '미션·상점 알림',
  importance: Importance.defaultImportance,
);

class PushNotificationService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e, st) {
      debugPrint('[FCM] Firebase.initializeApp failed (firebase_options 를 확인하세요): $e\n$st');
      return;
    }

    await _setupLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('[FCM] permission: ${settings.authorizationStatus}');
    }

    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await messaging.getToken().then((t) {
      if (t != null) unawaited(_registerToken(t));
    });
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final n = message.notification;
      if (n != null) {
        _showForegroundNotification(n.title ?? '알림', n.body ?? '');
      }
    });
  }

  static Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const init = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(settings: init);

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  static Future<void> _showForegroundNotification(String title, String body) async {
    await _localNotifications.show(
      id: title.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'kids_default',
          'Kids Challenge',
          channelDescription: '미션·상점 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// 로그인 직후 등 세션( Bearer )이 준비된 뒤 호출
  static Future<void> syncTokenToBackend() async {
    if (kIsWeb) return;
    try {
      if (Firebase.apps.isEmpty) {
        return;
      }
      final t = await FirebaseMessaging.instance.getToken();
      if (t != null) {
        await _registerToken(t);
      }
    } catch (e) {
      debugPrint('[FCM] syncTokenToBackend: $e');
    }
  }

  static Future<void> _registerToken(String token) async {
    if (kIsWeb) return;
    try {
      final client = ApiClient();
      final platform = Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'other');
      await client.post(
        '/kids/push-tokens',
        data: {
          'fcmToken': token,
          'platform': platform,
        },
      );
      if (kDebugMode) {
        debugPrint('[FCM] token registered on server');
      }
    } catch (e) {
      debugPrint('[FCM] register token failed: $e');
    }
  }
}
