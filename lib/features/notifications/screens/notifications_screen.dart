import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/notification_badge_controller.dart';
import '../services/fcm_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];

  bool isLoading = true;
  bool isMarkingAll = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    FcmService.notificationUpdateSignal.addListener(
      _onNotificationUpdated,
    );

    loadNotifications();
  }

  @override
  void dispose() {
    FcmService.notificationUpdateSignal.removeListener(
      _onNotificationUpdated,
    );

    super.dispose();
  }

  void _onNotificationUpdated() {
  if (!mounted || isLoading) return;

  loadNotifications();
}

  Future<void> loadNotifications() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await ApiClient.instance.getNotifications(limit: 50);

      if (!mounted) return;

      setState(() {
        notifications = result
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      });

      await NotificationBadgeController.instance.refreshCount();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> markAsRead(int index) async {
    final item = notifications[index];

    if (item['unread'] != true) return;

    final id = item['id'];

    if (id is! num) return;

    try {
      await ApiClient.instance.markNotificationAsRead(id.toInt());

      if (!mounted) return;

      setState(() {
        notifications[index]['unread'] = false;
      });

      await NotificationBadgeController.instance.refreshCount();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể đánh dấu đã đọc: $e'),
        ),
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (notifications.every((item) => item['unread'] != true)) {
      return;
    }

    setState(() {
      isMarkingAll = true;
    });

    try {
      await ApiClient.instance.markAllNotificationsAsRead();

      if (!mounted) return;

      setState(() {
        for (final item in notifications) {
          item['unread'] = false;
        }
      });

      await NotificationBadgeController.instance.refreshCount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả thông báo là đã đọc.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật thông báo: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isMarkingAll = false;
        });
      }
    }
  }

  String formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');

      return '$hour:$minute - $day/$month/${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  IconData getNotificationIcon(String type) {
    final normalized = type.toLowerCase();

    if (normalized.contains('lich') ||
        normalized.contains('appointment')) {
      return Icons.calendar_month_rounded;
    }

    if (normalized.contains('thuoc') ||
        normalized.contains('medicine')) {
      return Icons.medication_outlined;
    }

    if (normalized.contains('thanh') ||
        normalized.contains('payment') ||
        normalized.contains('hoa_don')) {
      return Icons.receipt_long_rounded;
    }

    if (normalized.contains('kham') ||
        normalized.contains('medical')) {
      return Icons.local_hospital_outlined;
    }

    if (normalized.contains('ho_so') ||
        normalized.contains('benh_nhan')) {
      return Icons.folder_shared_outlined;
    }

    return Icons.notifications_active_outlined;
  }

  Color getNotificationColor(String type) {
    final normalized = type.toLowerCase();

    if (normalized.contains('lich') ||
        normalized.contains('appointment')) {
      return const Color(0xFF2563EB);
    }

    if (normalized.contains('thuoc') ||
        normalized.contains('medicine')) {
      return const Color(0xFF0D9488);
    }

    if (normalized.contains('thanh') ||
        normalized.contains('payment')) {
      return const Color(0xFFD97706);
    }

    if (normalized.contains('ho_so') ||
        normalized.contains('benh_nhan')) {
      return const Color(0xFF2563EB);
    }

    return const Color(0xFF7C3AED);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications
        .where((item) => item['unread'] == true)
        .length;

    return AppScaffold(
      title: '',
      selectedIndex: 1,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông báo của bạn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unreadCount > 0
                            ? '$unreadCount thông báo chưa đọc'
                            : 'Bạn đã xem tất cả thông báo',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // TextButton(
                //   onPressed: isMarkingAll || unreadCount == 0
                //       ? null
                //       : markAllAsRead,
                //   child: isMarkingAll
                //       ? const SizedBox(
                //           width: 16,
                //           height: 16,
                //           child: CircularProgressIndicator(
                //             strokeWidth: 2,
                //           ),
                //         )
                //       : const Text(
                //           'Đọc tất cả',
                //           style: TextStyle(
                //             fontSize: 12,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                // ),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút tải lại
                      IconButton(
                        tooltip: 'Tải lại thông báo',
                        onPressed: isLoading ? null : loadNotifications,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF2563EB),
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Color(0xFF2563EB),
                                size: 23,
                              ),
                      ),

                      // Nút đọc tất cả
                      TextButton(
                        onPressed: isMarkingAll || unreadCount == 0
                            ? null
                            : markAllAsRead,
                        child: isMarkingAll
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Đọc tất cả',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: loadNotifications,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null && notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.cloud_off_outlined,
            size: 55,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Không thể tải thông báo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: loadNotifications,
              child: const Text('Thử lại'),
            ),
          ),
        ],
      );
    }

    if (notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 110),
          Icon(
            Icons.notifications_off_outlined,
            size: 65,
            color: Color(0xFFCBD5E1),
          ),
          SizedBox(height: 14),
          Center(
            child: Text(
              'Chưa có thông báo nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
          ),
          SizedBox(height: 6),
          Center(
            child: Text(
              'Các thông báo từ bệnh viện sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: notifications.length,
      //separatorBuilder: (_, __) => const SizedBox(height: 10),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = notifications[index];

        final title =
            item['title']?.toString() ?? 'Thông báo bệnh viện';

        final message = item['message']?.toString() ?? '';

        final type = item['type']?.toString() ?? 'general';

        final unread = item['unread'] == true;

        final color = getNotificationColor(type);

        return Material(
          color: unread ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => markAsRead(index),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: unread
                      ? const Color(0xFFBFDBFE)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      getNotificationIcon(type),
                      color: color,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: unread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),

                            if (unread)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(
                                  left: 6,
                                  top: 5,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          formatDate(item['createdAt']),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}