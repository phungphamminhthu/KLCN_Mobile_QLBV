
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import 'news_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  List<Map<String, dynamic>> _newsList = [];
  bool _isLoading = true;
  String? _error;
  // phân trang
  static const int _pageSize = 5;

  int _currentPage = 0;

  int get _totalPages =>
      (_newsList.length / _pageSize).ceil();

  List<Map<String, dynamic>> get _paginatedNews {
    final start = _currentPage * _pageSize;

    return _newsList.skip(start).take(_pageSize).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  // Lấy toàn bộ tin tức từ API.
  Future<void> _loadNews() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final response = await ApiClient.instance.get('/api/tin-tuc');

    if (response is! List) {
      throw Exception('Dữ liệu tin tức không hợp lệ.');
    }

    // Khai báo items bên trong hàm _loadNews()
    final items = response
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where(_isPublished)
        .toList();

    // Sắp xếp tin mới nhất lên trước
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
      _newsList = items;
      _currentPage = 0; // Quay về trang đầu khi tải lại dữ liệu
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('Lỗi tải danh sách tin tức: $e');

    if (!mounted) return;

    setState(() {
      _error = 'Không thể tải tin tức. Vui lòng thử lại.';
      _isLoading = false;
    });
  }
}

  bool _isPublished(Map<String, dynamic> item) {
    final status = (item['trangThai'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    // Chỉ lọc trạng thái nếu API có trả về trạng thái.
    if (status.isEmpty) return true;

    return [
      'đang hiển thị',
      'dang hien thi',
      'đã đăng',
      'da dang',
      'published',
      'active',
      'đã xuất bản',
      'da xuat ban',
    ].contains(status);
  }

  String _getImageUrl(Map<String, dynamic> news) {
    final rawImage = (news['imageURL'] ?? '').toString().trim();

    if (rawImage.isEmpty) return '';

    final uri = Uri.tryParse(rawImage);

    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      return rawImage;
    }

    final fileName = rawImage
        .replaceAll('\\', '/')
        .split('/')
        .last;

    return '${ApiClient.baseUrl}/Images/'
        '${Uri.encodeComponent(fileName)}';
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return 'Tin tức MedCare';
    }

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Tin tức MedCare';

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Quay lại',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Tin tức MedCare',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadNews,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử tải lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_newsList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNews,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 150),
            Icon(
              Icons.newspaper_outlined,
              size: 64,
              color: textSecondary,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Hiện chưa có tin tức được đăng tải.',
                style: TextStyle(color: textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildIntroduction(),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tất cả tin tức',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              Text(
                '${_newsList.length} bài viết',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ..._paginatedNews.map(_buildNewsCard),
          if (_totalPages > 1) ...[
            const SizedBox(height: 8),
            _buildPagination(),
          ],
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF0EA5E9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 34,
            color: Colors.white,
          ),
          SizedBox(height: 12),
          Text(
            'Tin tức & thông báo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cập nhật thông tin mới nhất từ MedCare Hospital.',
            style: TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    final title =
        (news['tieuDe'] ?? 'Tin tức MedCare').toString();

    final category =
        (news['tenDanhMuc'] ?? 'Tin tức').toString();

    final date = _formatDate(news['ngayDang']);
    final imageUrl = _getImageUrl(news);

    final description = (
      news['moTa'] ??
      news['tomTat'] ??
      news['noiDungTomTat'] ??
      ''
    ).toString().trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openNewsDetail(news),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 190,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 150,
                child: _buildImagePlaceholder(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.4,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textSecondary,
                        height: 1.5,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: primary,
                        size: 18,
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

  // widget phân trang
  Widget _buildPagination() {
    final totalPages = _totalPages;

    // Hiển thị tối đa 3 số trang.
    final startPage = _currentPage
        .clamp(0, (totalPages - 3).clamp(0, totalPages));

    final visibleCount = totalPages < 3 ? totalPages : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trang trước.
              _pageButton(
                icon: Icons.chevron_left_rounded,
                enabled: _currentPage > 0,
                onTap: () => _changePage(_currentPage - 1),
              ),

              const SizedBox(width: 6),

              // Các số trang.
              ...List.generate(visibleCount, (index) {
                final page = startPage + index;
                final isSelected = page == _currentPage;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => _changePage(page),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? primary : border,
                        ),
                      ),
                      child: Text(
                        '${page + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 6),

              // Trang sau.
              _pageButton(
                icon: Icons.chevron_right_rounded,
                enabled: _currentPage < totalPages - 1,
                onTap: () => _changePage(_currentPage + 1),
              ),
            ],
          ),

          // const SizedBox(height: 10),

          // Text(
          //   'Trang ${_currentPage + 1}/$totalPages'
          //   ' • ${_newsList.length} bài viết',
          //   style: const TextStyle(
          //     color: textSecondary,
          //     fontSize: 12,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? primary : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages) return;

    setState(() {
      _currentPage = page;
    });
  }
  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFDBEAFE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.newspaper_outlined,
        size: 54,
        color: primary,
      ),
    );
  }
}
