// ========================================================
// TRANG TIN TỨC CÔNG KHAI KHI APP MỞ
// ========================================================
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import 'news_detail_screen.dart';
import 'package:html/parser.dart' as html_parser; // lọc html

String resolveNewsImageUrl(dynamic value) {
  final path = value?.toString().trim() ?? '';

  if (path.isEmpty) {
    debugPrint('Tin tức không có imageURL');
    return '';
  }

  final uri = Uri.tryParse(path);
  if (uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https')) {
    return path;
  }

  final fileName = path
      .replaceAll('\\', '/')
      .split('/')
      .last;

  final imageUrl =
      '${ApiClient.baseUrl}/Images/${Uri.encodeComponent(fileName)}';

  debugPrint('IMAGE URL: $imageUrl');
  return imageUrl;
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  List<Map<String, dynamic>> newsItems = [];

  bool isLoading = true;
  String? errorMessage;

  static const int _pageSize = 3;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final response =
          await ApiClient.instance.get('/api/tin-tuc');

      if (response is! List) {
        throw Exception(
          'Dữ liệu tin tức trả về không đúng định dạng.',
        );
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
            status == 'đang đăng' ||
            status == 'dang dang' ||
            status == 'published' ||
            status == 'active' ||
            status == 'đã xuất bản' ||
            status == 'da xuat ban';
      }).toList();

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
        newsItems = items;
        _currentPage = 0;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Lỗi tải tin tức: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        errorMessage =
            'Không thể tải tin tức. Vui lòng thử lại.';
        isLoading = false;
      });
    }
  }

  String cleanHtml(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }

    // Chuyển HTML thành văn bản thuần, tự loại bỏ thẻ và thuộc tính.
    final document = html_parser.parse(value);
    final text = document.body?.text ?? '';

    // Chuẩn hóa khoảng trắng.
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _text(dynamic value, [String fallback = '']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(_text(value));

    if (date == null) return '';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _openNewsDetail(Map<String, dynamic> news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailScreen(news: news),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadNews,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),
              SliverToBoxAdapter(
                child: _buildHero(),
              ),
              SliverToBoxAdapter(
                child: _buildNewsSection(),
              ),
              SliverToBoxAdapter(
                child: _buildFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 16,
          //     vertical: 12,
          //   ),
          //   child: Row(
          //     children: [
          //       Container(
          //         width: 40,
          //         height: 40,
          //         decoration: BoxDecoration(
          //           color: primary,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: const Icon(
          //           Icons.add,
          //           color: Colors.white,
          //           size: 30,
          //         ),
          //       ),
          //       const SizedBox(width: 10),
          //       const Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'MedCare Hospital',
          //               maxLines: 1,
          //               overflow: TextOverflow.ellipsis,
          //               style: TextStyle(
          //                 color: primary,
          //                 fontSize: 15,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             SizedBox(height: 3),
          //             Text(
          //               'Hệ thống quản lý bệnh viện',
          //               style: TextStyle(
          //                 color: textSecondary,
          //                 fontSize: 10,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       OutlinedButton(
          //         onPressed: () {
          //           Navigator.pushNamed(context, '/login');
          //         },
          //         style: OutlinedButton.styleFrom(
          //           foregroundColor: primary,
          //           side: const BorderSide(color: primary),
          //           padding: const EdgeInsets.symmetric(
          //             horizontal: 10,
          //           ),
          //         ),
          //         child: const Text(
          //           'Đăng nhập',
          //           style: TextStyle(fontSize: 12),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const Divider(height: 1, color: borderColor),
          // SizedBox(
          //   height: 46,
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 12,
          //     ),
          //     child: Row(
          //       children: [
          //         _buildNavItem(context, 'Trang chủ', '/home'),
          //         _buildNavItem(
          //           context,
          //           'Tin tức',
          //           '/news',
          //           selected: true,
          //         ),
          //         _buildNavItem(context, 'Dịch vụ', '/services'),
          //         _buildNavItem(context, 'Giới thiệu', '/about'),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Widget _buildNavItem(
  //   BuildContext context,
  //   String label,
  //   String route, {
  //   bool selected = false,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 5),
  //     child: InkWell(
  //       onTap: () {
  //         if (!selected) {
  //           Navigator.pushNamed(context, route);
  //         }
  //       },
  //       child: Container(
  //         alignment: Alignment.center,
  //         padding: const EdgeInsets.symmetric(
  //           horizontal: 10,
  //           vertical: 8,
  //         ),
  //         decoration: BoxDecoration(
  //           border: Border(
  //             bottom: BorderSide(
  //               color: selected ? primary : Colors.transparent,
  //               width: 2,
  //             ),
  //           ),
  //         ),
  //         child: Text(
  //           label,
  //           style: TextStyle(
  //             color: selected
  //                 ? primary
  //                 : const Color(0xFF475569),
  //             fontSize: 12,
  //             fontWeight: selected
  //                 ? FontWeight.w700
  //                 : FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
    // TIN TỨC NỔI BẬT
  Widget _buildHero() {
    if (isLoading) {
      return Container(
        width: double.infinity,
        color: lightBlue,
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: CircularProgressIndicator(color: primary),
        ),
      );
    }

    if (newsItems.isEmpty) {
      return Container(
        width: double.infinity,
        color: lightBlue,
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MEDCARE HOSPITAL',
              style: TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Tin tức & thông tin sức khỏe',
              style: TextStyle(
                color: textPrimary,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Hiện chưa có tin tức được đăng tải.',
              style: const TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.7,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadNews,
                child: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      );
    }

    final featured = newsItems.first;
    final imageUrl = resolveNewsImageUrl(featured['imageURL']);

    return Container(
      width: double.infinity,
      color: lightBlue,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MEDCARE HOSPITAL',
            style: TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Lỗi tải ảnh tin nổi bật: $error');
                  debugPrint('URL ảnh: $imageUrl');
                  return _imagePlaceholder(height: 150);
                },
              ),
            )
          else
            _imagePlaceholder(height: 150),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _text(featured['tenDanhMuc'], 'Tin tức nổi bật'),
              style: const TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            _text(featured['tieuDe'], 'Tin tức MedCare'),
            style: const TextStyle(
              color: textPrimary,
              fontSize: 26,
              height: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cleanHtml(
              _text(
                featured['noiDung'],
                'Cập nhật tin tức từ bệnh viện.',
              ),
            ).replaceAll(RegExp(r'\s+'), ' '),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 10),
          if (_formatDate(featured['ngayDang']).isNotEmpty)
            Text(
              'Ngày đăng: ${_formatDate(featured['ngayDang'])}',
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _openNewsDetail(featured),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đọc tin nổi bật  →'),
          ),
        ],
      ),
    );
  }

  // DANH SÁCH TIN TỨC
  Widget _buildNewsSection() {
    final totalPages = (newsItems.length / _pageSize).ceil();

    final safePage = totalPages == 0
        ? 0
        : _currentPage.clamp(0, totalPages - 1);

    final startIndex = safePage * _pageSize;
    final endIndex =
        (startIndex + _pageSize).clamp(0, newsItems.length);

    final pageNews = newsItems.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 34),
      child: Column(
        children: [
          const Text(
            'TIN TỨC',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tin tức mới nhất',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Những thông tin và hoạt động mới nhất từ MedCare Hospital',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: CircularProgressIndicator(color: primary),
            )
          else if (errorMessage != null)
            _buildError()
          else if (newsItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Chưa có tin tức nào.',
                style: TextStyle(color: textSecondary),
              ),
            )
          else ...[
            ...pageNews.map(
              (news) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _buildNewsCard(news),
              ),
            ),
            const SizedBox(height: 8),
            if (totalPages > 1)
              _buildNewsPagination(
                totalPages: totalPages,
                currentPage: safePage,
              ),
          ],
        ],
      ),
    );
  }

  
  Widget _buildNewsPagination({
    required int totalPages,
    required int currentPage,
  }) {
    // Hiển thị tối đa 3 số trang, trượt từng số
    final startPage = (currentPage - 1).clamp(
      0,
      (totalPages - 3).clamp(0, totalPages),
    );

    final visiblePages = List.generate(
      totalPages < 3 ? totalPages : 3,
      (index) => startPage + index,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Trang trước
          IconButton(
            tooltip: 'Trang trước',
            onPressed: currentPage > 0
                ? () {
                    setState(() {
                      _currentPage = currentPage - 1;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
            color: primary,
          ),

          // Các số trang
          ...visiblePages.map((index) {
            final isSelected = index == currentPage;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _currentPage = index;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? primary : borderColor,
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Trang tiếp theo
          IconButton(
            tooltip: 'Trang tiếp theo',
            onPressed: currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage = currentPage + 1;
                    });
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
            color: primary,
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 38,
            color: textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage ?? 'Không thể tải dữ liệu.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder({double height = 150}) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFDBEAFE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.newspaper_outlined,
        color: primary,
        size: 48,
      ),
    );
  }

  // THẺ TIN TỨC
  Widget _buildNewsCard(Map<String, dynamic> news) {
    final imageUrl = resolveNewsImageUrl(news['imageURL']);

    return InkWell(
      onTap: () => _openNewsDetail(news),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Lỗi tải ảnh tin tức: $error');
                  debugPrint('URL ảnh: $imageUrl');
                  return _imagePlaceholder(height: 150);
                },
              )
            else
              _imagePlaceholder(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text(news['tenDanhMuc'], 'Tin tức'),
                    style: const TextStyle(
                      color: primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _text(news['tieuDe'], 'Chưa có tiêu đề'),
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 17,
                      height: 1.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cleanHtml(news['noiDung']?.toString()),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (_formatDate(news['ngayDang']).isNotEmpty) ...[
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(news['ngayDang']),
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                      ],
                      const Text(
                        'Xem chi tiết →',
                        style: TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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

  // FOOTER
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 28),
      child: const Column(
        children: [
          Text(
            'MedCare Hospital',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Giải pháp quản lý bệnh viện hiện đại, hiệu quả và an toàn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '© 2026 MedCare Hospital',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}