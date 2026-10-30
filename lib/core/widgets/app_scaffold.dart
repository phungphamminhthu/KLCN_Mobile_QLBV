// ============================================================
// APP SCAFFOLD - KHUNG GIAO DIỆN DÙNG CHUNG CHO APP MEDCARE
// ============================================================
//
// MỤC ĐÍCH:
// - Tạo khung giao diện thống nhất cho các màn hình bệnh nhân.
// - Quản lý thanh điều hướng dưới gồm 4 tab.
// - Giữ màu sắc, icon, kích thước và vị trí tab đồng nhất.
//
// CÁCH SỬ DỤNG:
// AppScaffold(
//   title: 'Thông báo',
//   selectedIndex: 1,
//   body: NotificationScreenContent(),
// )
//
// LƯU Ý:
// - body là nội dung riêng của từng màn hình.
// - selectedIndex xác định tab đang được chọn.
// - Mỗi màn hình chỉ nên có một Scaffold quản lý thanh tab.
// - Khi thêm tab mới, cần cập nhật danh sách route, nhãn và icon.
// ============================================================
// Vị trí tab đang được chọn:
// 0 = Trang chủ
// 1 = Thông báo
// 2 = Chức năng
// 3 = Cá nhân

import 'package:flutter/material.dart';
import '../router/app_router.dart';


class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.selectedIndex = 0,
  });

  // Thứ tự tab theo giao diện MedCare mới.
  
  static const List<String> _routes = [
    AppRouter.patientHome, // Trang chủ bệnh nhân sau đăng nhập
    AppRouter.notifications,
    AppRouter.features,
    AppRouter.profile,
  ];


  static const List<String> _labels = [
    'Trang chủ',
    'Thông báo',
    'Chức năng',
    'Cá nhân',
  ];

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.notifications_none_rounded,
    Icons.layers_outlined,
    Icons.account_circle_outlined,
  ];

  static const List<IconData> _selectedIcons = [
    Icons.home_rounded,
    Icons.notifications_rounded,
    Icons.layers_rounded,
    Icons.account_circle_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),

      // Giữ AppBar nếu màn hình đó cần tiêu đề riêng.
      appBar: title.isEmpty
          ? null
          : AppBar(
              title: Text(title),
              backgroundColor: const Color(0xFFF0F8FF),
              foregroundColor: const Color(0xFF1E293B),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),

      body: SafeArea(
        bottom: false,
        child: body,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 78,
            child: Row(
              children: List.generate(_labels.length, (index) {
                final isSelected = selectedIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isSelected) return;

                      final route = _routes[index];

                      // Chuyển tab và tránh tạo nhiều trang chồng nhau.
                      if (ModalRoute.of(context)?.settings.name != route) {
                        Navigator.pushReplacementNamed(context, route);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 64,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE0F2FE)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            isSelected
                                ? _selectedIcons[index]
                                : _icons[index],
                            size: 26,
                            color: isSelected
                                ? const Color(0xFF0369A1)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            _labels[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF0369A1)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
