import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

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
  
/// Hiển thị thông tin liên hệ bệnh viện.
void _showContactDialog(BuildContext context) {
  const String hotline = '1900 2699'; // Thay bằng hotline thật
  const String email = 'hospitalmedcare38@gmail.com'; // Thay bằng email thật
  const String address = '120 Lũy Bán Bích,P.Tân Thới Hòa, TP.Hồ Chí Minh'; // Thay bằng địa chỉ thật

  Future<void> openLink(String value) async {
    final uri = Uri.parse(value);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở ứng dụng tương ứng.'),
        ),
      );
    }
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0EEFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF2563EB),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Liên hệ bệnh viện',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _ContactItem(
                icon: Icons.phone_in_talk_rounded,
                title: 'Hotline',
                value: hotline,
                color: const Color(0xFF2563EB),
                onTap: () => openLink('tel:$hotline'),
              ),

              const SizedBox(height: 14),

              _ContactItem(
                icon: Icons.email_outlined,
                title: 'Email',
                value: email,
                color: const Color(0xFF0D9488),
                onTap: () => openLink('mailto:$email'),
              ),

              const SizedBox(height: 14),

              _ContactItem(
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ',
                value: address,
                color: const Color(0xFFEA580C),
              ),

              const SizedBox(height: 14),

              _ContactItem(
                icon: Icons.access_time_rounded,
                title: 'Giờ làm việc',
                value: 'Thứ 2 - Thứ 7: 07:00 - 17:00',
                color: const Color(0xFF7C3AED),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(
                      color: Color(0xFFBFDBFE),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
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


class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              Icons.open_in_new_rounded,
              size: 17,
              color: Color(0xFF94A3B8),
            ),
        ],
      ),
    );
  }
}

