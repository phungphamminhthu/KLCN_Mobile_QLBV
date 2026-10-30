import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';

/// ============================================================
/// FEATURES SCREEN - MÀN HÌNH CHỨC NĂNG
/// ============================================================
/// Các chức năng:
/// 1. Tiện ích chính:
///    - Thông tin bác sĩ
/// 2. Hỗ trợ & Liên hệ:
///    - Liên hệ
///
/// Sử dụng AppScaffold để thống nhất thanh điều hướng dưới.
/// selectedIndex = 2: tab Chức năng.
/// ============================================================

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  static const Color background = Color(0xFFF4F7FC);
  static const Color primary = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '',
      selectedIndex: 2,
      body: Container(
        color: background,
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              // Tiêu đề màn hình.
              const Center(
                child: Text(
                  'Chức năng',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172F59),
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // Nhóm tiện ích chính.
              _buildSectionTitle('Tiện ích chính'),
              const SizedBox(height: 24),

              _FeatureMenuCard(
                icon: Icons.playlist_add_check_rounded,
                title: 'Thông tin bác sĩ',
                onTap: () {
                  _openRoute(context, '/doctors');
                },
              ),

              const SizedBox(height: 28),

              // Nhóm hỗ trợ và liên hệ.
              _buildSectionTitle('Hỗ trợ & Liên hệ'),
              const SizedBox(height: 24),

              _FeatureMenuCard(
                icon: Icons.phone_in_talk_outlined,
                title: 'Liên hệ',
                onTap: () {
                  _showContactDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tiêu đề của từng nhóm chức năng.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: Color(0xFF607D9C),
        ),
      ),
    );
  }

  /// Mở màn hình theo route đã khai báo.
  void _openRoute(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  /// Hiển thị thông tin liên hệ mẫu.
  /// Thay nội dung bằng thông tin chính thức của bệnh viện sau này.
  void _showContactDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: primary,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Liên hệ bệnh viện',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Thông tin liên hệ của bệnh viện sẽ được cập nhật tại đây.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Đóng',
                style: TextStyle(color: primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ============================================================
/// THẺ CHỨC NĂNG
/// ============================================================
/// Thành phần dùng chung cho các mục trong màn hình Chức năng.
/// ============================================================

class _FeatureMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FeatureMenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(minHeight: 128),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Row(
            children: [
              // Icon trong ô nền xanh nhạt.
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EEFF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: const Color(0xFF3B82F6),
                ),
              ),

              const SizedBox(width: 24),

              // Tên chức năng.
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              // Mũi tên ở cuối thẻ.
              const Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
