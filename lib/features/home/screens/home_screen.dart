import 'package:flutter/material.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/router/app_router.dart';
import '../../../core/network/api_client.dart';
import '../../news/screens/news_detail_screen.dart';

/// ============================================================
/// HOME SCREEN - MÀN HÌNH CHÍNH ỨNG DỤNG MEDCARE
/// ============================================================
/// Chức năng:
/// - Hiển thị thương hiệu MedCare Hospital.
/// - Hiển thị các chức năng dành cho bệnh nhân.
/// - Hiển thị banner giới thiệu bệnh viện.
/// - Hiển thị tin tức.
/// - Sử dụng AppScaffold để dùng chung thanh điều hướng dưới.
///
/// Lưu ý:
/// - Không tạo thêm thanh điều hướng trong file này.
/// - Các route phải được khai báo trong AppRouter.
/// - Dữ liệu tin tức và ảnh hiện là dữ liệu giao diện mẫu.
/// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Bảng màu của màn hình chính.
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF0F8FF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

   Map<String, dynamic>? _latestNews;
  bool _newsLoading = true;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    _loadLatestNews();
  }

  Future<void> _loadLatestNews() async {
    try {
      final response = await ApiClient.instance.get('/api/tin-tuc');

      if (response is! List) {
        throw Exception('Dữ liệu tin tức không hợp lệ.');
      }

      final items = response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) {
            final status = (item['trangThai'] ?? '')
                .toString()
                .trim()
                .toLowerCase();

            return status.isEmpty ||
                status == 'đang hiển thị' ||
                status == 'dang hien thi' ||
                status == 'đã đăng' ||
                status == 'da dang' ||
                status == 'published' ||
                status == 'active' ||
                status == 'đã xuất bản' ||
                status == 'da xuat ban';
          })
          .toList();

      items.sort((a, b) {
        final dateA = DateTime.tryParse(
          (a['ngayDang'] ?? '').toString(),
        );
        final dateB = DateTime.tryParse(
          (b['ngayDang'] ?? '').toString(),
        );

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        _latestNews = items.isEmpty ? null : items.first;
        _newsLoading = false;
        _newsError = null;
      });
    } catch (e) {
      debugPrint('Lỗi tải tin tức trang chủ: $e');

      if (!mounted) return;

      setState(() {
        _newsLoading = false;
        _newsError = 'Không thể tải tin tức.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dùng AppScaffold làm khung giao diện chung.
    // selectedIndex = 0: tab Trang chủ đang được chọn.
    return AppScaffold(
      title: '',
      selectedIndex: 0,
      body: Container(
        color: background,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. Logo và tên bệnh viện.
                  _buildHeader(),

                  const SizedBox(height: 24),

                  // 2. Các chức năng chính dành cho bệnh nhân.
                  _buildFeatures(context),

                  const SizedBox(height: 26),

                  // 3. Banner giới thiệu bệnh viện.
                  _buildHospitalBanner(),

                  const SizedBox(height: 26),

                  // 4. Tiêu đề và nút xem thêm tin tức.
                  _buildNewsHeader(context),

                  const SizedBox(height: 14),

                  // 5. Thẻ tin tức nổi bật.
                  _buildNewsCard(context),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 1. HEADER - LOGO VÀ TÊN BỆNH VIỆN
  // ==========================================================
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container(
        //   width: 52,
        //   height: 52,
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(16),
        //     boxShadow: [
        //       BoxShadow(
        //         color: primary.withValues(alpha: 0.10),
        //         blurRadius: 12,
        //         offset: const Offset(0, 4),
        //       ),
        //     ],
        //   ),
        //   child: const Icon(
        //     Icons.medical_services_outlined,
        //     color: Color(0xFF0284C7),
        //     size: 30,
        //   ),
        // ),

        Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

        const SizedBox(height: 18),

        const Text(
          'MedCare Hospital',
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: Color(0xFF0369A1),
          ),
        ),

        const SizedBox(height: 2),

        const Text(
          'Ứng dụng dành cho Người bệnh',
          style: TextStyle(
            fontSize: 17,
            color: Color(0xFF2877A8),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // 2. KHUNG CHỨC NĂNG
  // ==========================================================
  Widget _buildFeatures(BuildContext context) {
    // Danh sách chức năng.
    // Khi xây dựng các màn hình thật, cần khai báo route tương ứng.
    final features = <_Feature>[
      _Feature(
        title: 'Đặt khám',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF0284C7),
        background: const Color(0xFFF0F9FF),
        border: const Color(0xFFDBEAFE),
        route: '/booking',
      ),
      _Feature(
        title: 'Lịch sử đặt khám',
        icon: Icons.medical_information_outlined,
        color: const Color(0xFF0284C7),
        background: const Color(0xFFF0FDFF),
        border: const Color(0xFFCFFAFE),
        route: AppRouter.appointments,
      ),
      _Feature(
        title: 'Hồ sơ bệnh án',
        icon: Icons.folder_shared_outlined,
        color: const Color(0xFF0284C7),
        background: const Color(0xFFFFFDF2),
        border: const Color(0xFFFEF0B5),
        route: '/medical-records',
      ),
      _Feature(
        title: 'Hoá đơn',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF059669),
        background: const Color(0xFFF0FDF4),
        border: const Color(0xFFD1FAE5),
        route: '/invoices',
      ),
      _Feature(
        title: 'Lịch tái khám',
        icon: Icons.assignment_outlined,
        color: const Color(0xFF0D9488),
        background: const Color(0xFFF0FDFA),
        border: const Color(0xFF99F6E4),
        route: '/follow-ups',
      ),
      _Feature(
        title: 'Hỏi - đáp\n(Chatbot)',
        icon: Icons.smart_toy_outlined,
        color: const Color(0xFF0284C7),
        background: const Color(0xFFF0F9FF),
        border: const Color(0xFFDBEAFE),
        route: '/chatbot',
      ),
      _Feature(
        title: 'Bảng giá dịch\nvụ kỹ thuật',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF0284C7),
        background: Colors.white,
        border: const Color(0xFFE2E8F0),
        route: '/services',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF93C5FD).withValues(alpha: 0.13),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 22),
            child: Text(
              'Chức năng',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0C4A6E),
              ),
            ),
          ),

          // Tự điều chỉnh số cột theo chiều rộng màn hình.
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount =
                  constraints.maxWidth >= 480 ? 4 : 3;

              const spacing = 8.0;
              final itemWidth =
                  (constraints.maxWidth -
                      spacing * (columnCount - 1)) /
                  columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: 24,
                children: features.map((feature) {
                  return SizedBox(
                    width: itemWidth,
                    child: _FeatureItem(
                      feature: feature,
                      onTap: () => _navigate(
                        context,
                        feature.route,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 3. BANNER GIỚI THIỆU BỆNH VIỆN
  // ==========================================================
  Widget _buildHospitalBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 185,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ảnh mẫu tải từ Internet.
            Image.network(
              'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d'
              '?auto=format&fit=crop&w=1200&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFDBEAFE),
                  child: const Center(
                    child: Icon(
                      Icons.local_hospital_outlined,
                      size: 70,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                );
              },
            ),

            // Lớp phủ giúp nhãn phía dưới dễ nhìn.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.22),
                  ],
                ),
              ),
            ),

            // Nhãn giới thiệu bệnh viện.
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF10B981),
                      size: 11,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đa khoa Tiêu chuẩn Quốc tế',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C3555),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 4. TIÊU ĐỀ TIN TỨC VÀ NÚT XEM THÊM
  // ==========================================================
  Widget _buildNewsHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Tin tức',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
        ),

        TextButton(
          onPressed: () => _navigate(context, AppRouter.news),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Xem thêm',
                style: TextStyle(
                  color: Color(0xFF0284C7),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Color(0xFF0284C7),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // 5. THẺ TIN TỨC MẪU
  // ==========================================================
  // Widget _buildNewsCard(BuildContext context) {
  //   return InkWell(
  //     onTap: () => _navigate(context, '/news'),
  //     borderRadius: BorderRadius.circular(24),
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(24),
  //         border: Border.all(
  //           color: const Color(0xFFE8EEF5),
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(0xFF64748B).withValues(alpha: 0.08),
  //             blurRadius: 12,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(16),
  //             child: SizedBox(
  //               width: 92,
  //               height: 100,
  //               child: Image.network(
  //                 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d'
  //                 '?auto=format&fit=crop&w=300&q=80',
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) {
  //                   return Container(
  //                     color: const Color(0xFFE0F2FE),
  //                     child: const Icon(
  //                       Icons.local_hospital_outlined,
  //                       size: 42,
  //                       color: Color(0xFF0284C7),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ),

  //           const SizedBox(width: 14),

  //           const Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'THÔNG BÁO',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Color(0xFF0284C7),
  //                     fontWeight: FontWeight.w700,
  //                     letterSpacing: 0.5,
  //                   ),
  //                 ),

  //                 SizedBox(height: 7),

  //                 Text(
  //                   'Lịch khám chuyên gia & Hoạt động khám chữa bệnh',
  //                   maxLines: 3,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(
  //                     fontSize: 15,
  //                     height: 1.35,
  //                     fontWeight: FontWeight.w700,
  //                     color: textPrimary,
  //                   ),
  //                 ),

  //                 SizedBox(height: 8),

  //                 Row(
  //                   children: [
  //                     Icon(
  //                       Icons.access_time,
  //                       size: 16,
  //                       color: Color(0xFF94A3B8),
  //                     ),
  //                     SizedBox(width: 6),
  //                     Text(
  //                       'Tin tức bệnh viện',
  //                       style: TextStyle(
  //                         fontSize: 13,
  //                         color: textSecondary,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  
  Widget _buildNewsCard(BuildContext context) {
    if (_newsLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            color: primary,
          ),
        ),
      );
    }

    if (_newsError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _newsError!,
              style: const TextStyle(color: textSecondary),
            ),
            TextButton(
              onPressed: _loadLatestNews,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final news = _latestNews;

    if (news == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Hiện chưa có tin tức được đăng tải.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textSecondary),
        ),
      );
    }

    final title = (news['tieuDe'] ?? 'Tin tức MedCare').toString();
    final category = (news['tenDanhMuc'] ?? 'Tin tức').toString();
    final rawImage = (news['imageURL'] ?? '').toString().trim();

    String imageUrl = '';

    if (rawImage.isNotEmpty) {
      final uri = Uri.tryParse(rawImage);

      if (uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https')) {
        imageUrl = rawImage;
      } else {
        final fileName = rawImage
            .replaceAll('\\', '/')
            .split('/')
            .last;

        imageUrl =
            '${ApiClient.baseUrl}/Images/${Uri.encodeComponent(fileName)}';
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsDetailScreen(news: news),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8EEF5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 100,
                height: 115,
                child: imageUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFE0F2FE),
                        child: const Icon(
                          Icons.newspaper_outlined,
                          size: 38,
                          color: primary,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: const Color(0xFFE0F2FE),
                            child: const Icon(
                              Icons.newspaper_outlined,
                              size: 38,
                              color: primary,
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0284C7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 16,
                        color: textSecondary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Đọc tin tức',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                        color: primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ==========================================================
  // 6. ĐIỀU HƯỚNG ĐẾN CÁC CHỨC NĂNG
  // ==========================================================
  // Chỉ hoạt động khi route đã được khai báo trong AppRouter.
  void _navigate(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}

// ============================================================
// MODEL GIAO DIỆN CHO MỘT CHỨC NĂNG
// ============================================================
// Lưu tiêu đề, icon, màu sắc và route của từng ô chức năng.
// Đây là model giao diện, không phải model dữ liệu API.

class _Feature {
  final String title;
  final IconData icon;
  final Color color;
  final Color background;
  final Color border;
  final String route;

  const _Feature({
    required this.title,
    required this.icon,
    required this.color,
    required this.background,
    required this.border,
    required this.route,
  });
}

// ============================================================
// WIDGET HIỂN THỊ MỘT Ô CHỨC NĂNG
// ============================================================

class _FeatureItem extends StatelessWidget {
  final _Feature feature;
  final VoidCallback onTap;

  const _FeatureItem({
  required this.feature,
  required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 84,
            decoration: BoxDecoration(
              color: feature.background,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: feature.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: feature.color.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              feature.icon,
              size: 35,
              color: feature.color,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            feature.title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
