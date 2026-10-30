
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';

class NotificationBadgeController extends ChangeNotifier {
  NotificationBadgeController._();

  static final NotificationBadgeController instance =
      NotificationBadgeController._();

  int unreadCount = 0;
  bool isLoading = false;

  Future<void> refreshCount() async {
    if (!ApiClient.instance.hasToken) {
      unreadCount = 0;
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final count =
          await ApiClient.instance.getUnreadNotificationCount();

      unreadCount = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi tải số thông báo chưa đọc: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Gọi khi có thông báo mới từ FCM.
  Future<void> onNewNotification() async {
    await refreshCount();
  }

  /// Gọi sau khi người dùng đánh dấu thông báo đã đọc.
  Future<void> onNotificationRead() async {
    await refreshCount();
  }

  /// Reset badge khi đăng xuất.
  void reset() {
    unreadCount = 0;
    isLoading = false;
    notifyListeners();
  }
}
