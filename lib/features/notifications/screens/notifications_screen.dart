
import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../shared/widgets/feature_placeholder.dart';

/// Màn hình Thông báo dành cho bệnh nhân.
/// selectedIndex = 1 vì Thông báo là tab thứ hai từ trái sang.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Thông báo',
      selectedIndex: 1,
      body: FeaturePlaceholder(
        icon: Icons.notifications_none,
        title: 'Thông báo bệnh viện',
        description: 'Danh sách thông báo sẽ được bổ sung tại đây.',
      ),
    );
  }
}
