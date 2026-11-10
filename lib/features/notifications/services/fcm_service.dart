
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/network/api_client.dart';
import '../controllers/notification_badge_controller.dart';

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  static final ValueNotifier<int> notificationUpdateSignal =
    ValueNotifier<int>(0);

  void _notifyNotificationUpdated() {
    notificationUpdateSignal.value++;
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  bool _initialized = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'lich_kham_channel',
    'Thông báo lịch khám',
    description: 'Thông báo lịch khám và nhắc thanh toán',
    importance: Importance.high,
  );

  /// Khởi tạo FCM và các listener.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Xin quyền nhận thông báo.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'FCM permission: ${settings.authorizationStatus}',
      );

      // 2. Khởi tạo local notifications.
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initializationSettings = InitializationSettings(
        android: androidSettings,
      );

      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) async {
          debugPrint(
            'Người dùng nhấn thông báo local: ${response.payload}',
          );

          await _refreshBadge();
          
          // TODO: Điều hướng theo payload.
        },
      );

      // 3. Tạo notification channel.
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // 4. Theo dõi token thay đổi.
      // Giữ API token hiện tại để tương thích với Spring Boot.
      _tokenRefreshSubscription =
          _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM token đã thay đổi');

        if (ApiClient.instance.hasToken) {
          await _registerToken(newToken);
        }
      });

      // 5. Nhận thông báo khi app đang mở.
      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Người dùng nhấn thông báo khi app chạy nền.
      _openedSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(
        _handleMessageOpened,
      );

      // 7. Người dùng mở app từ thông báo khi app đã tắt.
      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('App được mở từ thông báo FCM');
        debugPrint('FCM data: ${initialMessage.data}');

        await _refreshBadge();
        _notifyNotificationUpdated();

        // TODO: Điều hướng theo initialMessage.data.
      }

      _initialized = true;

      // Cập nhật badge ban đầu nếu người dùng đã đăng nhập.
      await _refreshBadge();

      debugPrint('FCM khởi tạo thành công');
    } catch (e, stackTrace) {
      debugPrint('Lỗi khởi tạo FCM: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Cập nhật số thông báo chưa đọc từ backend.
  Future<void> _refreshBadge() async {
    if (!ApiClient.instance.hasToken) return;

    await NotificationBadgeController.instance.refreshCount();
  }

  /// Xử lý thông báo khi app đang mở.
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      'FCM foreground: '
      '${message.notification?.title} - '
      '${message.notification?.body}',
    );

    // Backend đã lưu thông báo nên cập nhật lại badge.
    await _refreshBadge();
    _notifyNotificationUpdated();

    final notification = message.notification;

    // Nếu chỉ có data mà không có notification thì không hiển thị local.
    if (notification == null) return;

    await _localNotifications.show(
      id: message.hashCode,
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
  }

  /// Xử lý khi người dùng nhấn thông báo lúc app chạy nền.
  Future<void> _handleMessageOpened(RemoteMessage message) async {
    debugPrint('Người dùng mở thông báo FCM');
    debugPrint('FCM data: ${message.data}');

    await _refreshBadge();
    _notifyNotificationUpdated();

    // TODO: Điều hướng dựa vào message.data.
  }

  /// Đăng ký token lên backend sau khi bệnh nhân đăng nhập.
  Future<void> registerDevice() async {
    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('Không lấy được FCM Token');
        return;
      }

      await _registerToken(token);
    } catch (e) {
      debugPrint('Lỗi đăng ký FCM Token: $e');
    }
  }

  /// Gửi token lên Spring Boot.
  Future<void> _registerToken(String token) async {
    try {
      await ApiClient.instance.post(
        '/api/thiet-bi/dang-ky',
        body: {
          'fcmToken': token,
          'loaiThietBi': defaultTargetPlatform == TargetPlatform.android
              ? 'ANDROID'
              : defaultTargetPlatform == TargetPlatform.iOS
                  ? 'IOS'
                  : defaultTargetPlatform.name.toUpperCase(),
        },
      );

      debugPrint('Đăng ký FCM Token thành công');
    } catch (e) {
      debugPrint('Lỗi gửi FCM Token lên backend: $e');
    }
  }

  /// Hủy đăng ký thiết bị trên backend khi bệnh nhân đăng xuất.
  Future<void> unregisterDevice() async {
    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) return;

      await ApiClient.instance.post(
        '/api/thiet-bi/huy-dang-ky',
        body: {
          'fcmToken': token,
        },
      );

      debugPrint('Đã hủy đăng ký thiết bị trên backend');
    } catch (e) {
      debugPrint('Lỗi hủy đăng ký FCM Token: $e');
    }
  }

  /// Giải phóng listener khi thực sự cần.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();

    _tokenRefreshSubscription = null;
    _foregroundSubscription = null;
    _openedSubscription = null;

    _initialized = false;
  }
}
