import 'package:flutter/material.dart';

import '../router/app_router.dart';
import '../../features/notifications/controllers/notification_badge_controller.dart';

class AppScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final int selectedIndex;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.selectedIndex = 0,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  static const List<String> _routes = [
    AppRouter.patientHome,
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationBadgeController.instance.refreshCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),

      appBar: widget.title.isEmpty
          ? null
          : AppBar(
              title: Text(widget.title),
              backgroundColor: const Color(0xFFF0F8FF),
              foregroundColor: const Color(0xFF1E293B),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),

      body: SafeArea(
        bottom: false,
        child: widget.body,
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
                final isSelected = widget.selectedIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isSelected) return;

                      final route = _routes[index];

                      if (index == 1) {
                        NotificationBadgeController.instance
                            .refreshCount();
                      }

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
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
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

                              if (index == 1)
                                Positioned(
                                  right: -9,
                                  top: -5,
                                  child: AnimatedBuilder(
                                    animation:
                                        NotificationBadgeController.instance,
                                    builder: (context, child) {
                                      final count =
                                          NotificationBadgeController
                                              .instance.unreadCount;

                                      if (count <= 0) {
                                        return const SizedBox.shrink();
                                      }

                                      return Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 17,
                                          minHeight: 17,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEF4444),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          count > 99 ? '99+' : '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
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