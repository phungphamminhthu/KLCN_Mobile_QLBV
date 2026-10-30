
import 'package:flutter/material.dart';

import '../../news/screens/news_screen.dart';
import 'home_tab.dart';
import 'services_tab.dart';
import 'about_tab.dart';

const Color medCareBlue = Color(0xFF2563EB);
const Color medCareLightBlue = Color(0xFFDBEAFE);
const Color medCareText = Color(0xFF1E293B);
const Color medCareSecondary = Color(0xFF64748B);
const Color medCareBackground = Color(0xFFF8FAFC);
const Color medCareBorder = Color(0xFFE2E8F0);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<String> _menuItems = const [
    'Trang chủ',
    'Tin tức',
    'Dịch vụ',
    'Giới thiệu',
  ];

  void _selectTab(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _screens = [
    HomeTab(onSelectTab: _selectTab),
    const NewsScreen(),
    const ServicesTab(),
    const AboutTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: medCareBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 650;

        return Container(
          width: double.infinity,
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: 10,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 1220),
                      child: Row(
                        children: [
                          // Logo
                          InkWell(
                            onTap: () => _selectTab(0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: isMobile ? 38 : 36,
                                  height: isMobile ? 38 : 36,
                                  decoration: BoxDecoration(
                                    color: medCareBlue,
                                    borderRadius:
                                        BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.local_hospital_rounded,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                SizedBox(width: isMobile ? 8 : 10),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'MedCare Hospital',
                                      style: TextStyle(
                                        color: medCareBlue,
                                        fontSize: isMobile ? 14 : 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    if (!isMobile)
                                      const Text(
                                        'Hệ thống quản lý bệnh viện',
                                        style: TextStyle(
                                          color: medCareSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Nút đăng nhập luôn nằm bên phải
                          OutlinedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed('/login');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: medCareBlue,
                              side: const BorderSide(
                                color: medCareBlue,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 20,
                                vertical: isMobile ? 10 : 12,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Menu ngang riêng trên desktop,
                // cuộn ngang trên điện thoại.
                SizedBox(
                  height: 42,
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 1220),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _menuItems.length,
                            (index) => _buildMenuItem(
                              _menuItems[index],
                              index,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: medCareBorder,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String title, int index) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _selectTab(index),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? medCareBlue : medCareText,
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
