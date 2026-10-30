
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'lich_kham_channel',
    'Thông báo lịch khám',
    description: 'Thông báo lịch khám và nhắc thanh toán',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // 1. Xin quyền nhận thông báo
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'FCM permission: ${settings.authorizationStatus}',
    );

    // 2. Khởi tạo thông báo cục bộ
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint(
          'Người dùng nhấn thông báo: ${response.payload}',
        );
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Lấy FCM token của thiết bị
    final token = await _messaging.getToken();

    if (token != null) {
      debugPrint('FCM TOKEN: $token');

      // TODO: Gửi token lên Spring Boot
      // sau khi xác định tài khoản bệnh nhân đăng nhập.
    }

    // 4. Theo dõi token thay đổi
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM TOKEN UPDATED: $newToken');

      // TODO: Cập nhật token mới lên backend.
    });

    // 5. Nhận thông báo khi app đang mở
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint(
        'FCM foreground: '
        '${message.notification?.title} - '
        '${message.notification?.body}',
      );

      final notification = message.notification;

      if (notification == null) return;

      await _localNotifications.show(
        id: notification.hashCode,
        title: notification.title ?? 'Thông báo bệnh viện',
        body: notification.body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'lich_kham_channel',
            'Thông báo lịch khám',
            channelDescription: 'Thông báo lịch khám và nhắc thanh toán',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['route'],
      );
    });

    // 6. Người dùng nhấn thông báo khi app chạy nền
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Người dùng mở thông báo FCM');
      debugPrint('FCM data: ${message.data}');

      // TODO: Điều hướng dựa vào message.data.
    });

    // 7. Người dùng mở app từ thông báo khi app đã tắt
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App được mở từ thông báo FCM');
      debugPrint('FCM data: ${initialMessage.data}');

      // TODO: Xử lý điều hướng sau khi app khởi tạo.
    }
  }
}
