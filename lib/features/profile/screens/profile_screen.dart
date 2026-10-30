
import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/network/api_client.dart';
import 'profile_information_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryColor = Color(0xFF2479F2);
  static const Color backgroundColor = Color(0xFFF5F8FC);
  static const Color textColor = Color(0xFF243247);
  static const Color secondaryColor = Color(0xFF64748B);

  String fullName = '';
  String phone = '';
  String? avatarUrl;

  bool receiveNotifications = true;
  bool isLoadingProfile = true;
  String? profileError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        isLoadingProfile = true;
        profileError = null;
      });
    }

    try {
      final user = await ApiClient.instance.getCurrentUser();

      if (!mounted) return;

      // Hỗ trợ cả tên thuộc tính JSON camelCase và PascalCase.
      final name = (
        user['hoTen'] ?? user['HoTen'] ?? user['tenNguoiDung']
      )?.toString();

      final phoneNumber = (
        user['soDienThoai'] ?? user['SoDienThoai'] ?? user['sdt']
      )?.toString();

      final avatar = (
        user['anhDaiDien'] ?? user['AnhDaiDien']
      )?.toString();

      String? resolvedAvatar;

      if (avatar != null && avatar.trim().isNotEmpty) {
        final value = avatar.trim();

        if (value.startsWith('http://') ||
            value.startsWith('https://')) {
          resolvedAvatar = value;
        } else {
          // Ảnh lưu bằng fileKey trên storage.
          resolvedAvatar = Uri.parse(
            '${ApiClient.baseUrl}/api/images/view',
          ).replace(
            queryParameters: {'fileKey': value},
          ).toString();
        }
      }

      setState(() {
        fullName = name?.trim().isNotEmpty == true
            ? name!.trim()
            : 'Chưa cập nhật họ tên';

        phone = phoneNumber?.trim().isNotEmpty == true
            ? phoneNumber!.trim()
            : 'Chưa cập nhật số điện thoại';

        avatarUrl = resolvedAvatar;
        isLoadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingProfile = false;
        profileError = 'Không thể tải thông tin tài khoản.';
      });

      debugPrint('Lỗi tải hồ sơ bệnh nhân: $e');
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Center(
          child: Text(
            'XÁC NHẬN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        content: const Text(
          'Bạn có đồng ý đăng xuất khỏi ứng dụng MedCare Hospital?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Đồng ý'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Hủy bỏ'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ApiClient.instance.clearToken();

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => false,
      );
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature đang được hoàn thiện.')),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 126,
      height: 126,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF9BC8FF),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 60);
                },
              )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFFE8F3FF),
      alignment: Alignment.center,
      child: const Icon(
        Icons.person,
        size: 68,
        color: primaryColor,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: secondaryColor,
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = primaryColor,
    Color iconBackground = const Color(0xFFEDF5FF),
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 27),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (showArrow)
                const Icon(
                  Icons.chevron_right,
                  size: 30,
                  color: Color(0xFFCBD5E1),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0F4F8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Cá nhân',
      selectedIndex: 3,
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // Header tài khoản
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3989F5),
                    Color(0xFF1670EE),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(42),
                ),
              ),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 22),
                  if (isLoadingProfile)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  else ...[
                    Text(
                      fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      phone,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                    if (profileError != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _loadProfile,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Tải lại thông tin',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                children: [
                  _sectionTitle('Tài khoản'),
                  _menuGroup([    
                    _menuItem(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProfileInformationScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      indent: 18,
                      endIndent: 18,
                      color: Color(0xFFF0F3F7),
                    ),
                    _menuItem(
                      icon: Icons.key_outlined,
                      title: 'Thay đổi mật khẩu',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 28),

                  _sectionTitle('Cài đặt'),
                  _menuGroup([
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF5FF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.notifications_none,
                              color: primaryColor,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Expanded(
                            child: Text(
                              'Nhận thông báo',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          Switch.adaptive(
                            value: receiveNotifications,
                            activeTrackColor: primaryColor,
                            onChanged: (value) {
                              setState(() {
                                receiveNotifications = value;
                              });
                              // TODO: Lưu tùy chọn lên Backend
                              // hoặc bộ nhớ cài đặt của ứng dụng.
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  _menuGroup([
                    _menuItem(
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      iconColor: const Color(0xFFFF4564),
                      iconBackground: const Color(0xFFFFF0F2),
                      onTap: _showLogoutDialog,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
