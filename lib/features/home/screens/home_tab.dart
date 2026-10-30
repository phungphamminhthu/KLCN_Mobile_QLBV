import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import 'main_navigation_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onSelectTab,
  });

  final ValueChanged<int> onSelectTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const Color _blue = Color(0xFF2563EB);
  static const Color _text = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _background = Color(0xFFF8FAFC);

  List<Map<String, dynamic>> _latestNews = [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadLatestNews();
  }

  
Future<void> _loadLatestNews() async {
  try {
    final url = '${ApiClient.baseUrl}/api/tin-tuc';

    debugPrint('HOME NEWS URL: $url');

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 20));

    debugPrint('HOME NEWS STATUS: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(
        'API tin tức trả về HTTP ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is! List) {
      throw Exception('Response API không phải danh sách tin tức');
    }

    final articles = decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    // In thông tin để kiểm tra dữ liệu thực tế từ backend.
    debugPrint('HOME NEWS TOTAL: ${articles.length}');

    if (articles.isNotEmpty) {
      debugPrint(
        'HOME NEWS FIRST ARTICLE: ${articles.first}',
      );
      debugPrint(
        'HOME NEWS STATUS VALUE: ${articles.first['trangThai']}',
      );
      debugPrint(
        'HOME NEWS IMAGE: ${articles.first['imageURL']}',
      );
    }

    if (!mounted) return;

    setState(() {
      // Tạm thời lấy 3 bài đầu tiên, chưa lọc trạng thái.
      _latestNews = articles.take(3).toList();
      _loading = false;
      _hasError = false;
    });
  } catch (e, stackTrace) {
    debugPrint('HOME NEWS ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    setState(() {
      _latestNews = [];
      _loading = false;
      _hasError = true;
    });
  }
}


  String _plainText(dynamic value) {
    if (value == null) return '';

    return value
        .toString()
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _imageUrl(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return '';

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final fileName = raw.split('/').last;

    return '${ApiClient.baseUrl}/Images/'
        '${Uri.encodeComponent(fileName)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(),
            _buildNewsSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // HERO
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 55,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'MEDCARE HOSPITAL',
                style: TextStyle(
                  color: _blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Tin tức & thông tin\nsức khỏe',
                style: TextStyle(
                  color: _text,
                  fontSize: 38,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cập nhật những thông tin mới nhất từ bệnh viện, '
                'hướng dẫn khám chữa bệnh và kiến thức chăm sóc sức khỏe.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 15,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TIN TỨC MỚI NHẤT
  Widget _buildNewsSection() {
    return Container(
      color: _background,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 42,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'TIN TỨC',
                style: TextStyle(
                  color: _blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tin tức mới nhất',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _text,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Những thông tin và hoạt động mới nhất '
                'từ MedCare Hospital',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 30),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: CircularProgressIndicator(color: _blue),
                )
              else if (_latestNews.isEmpty)
                _buildEmptyNews()
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 850;
                    final isMedium = constraints.maxWidth >= 560;

                    final crossAxisCount = isWide
                        ? 3
                        : isMedium
                            ? 2
                            : 1;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _latestNews.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 350,
                      ),
                      itemBuilder: (context, index) {
                        return _buildNewsCard(_latestNews[index]);
                      },
                    );
                  },
                ),
              if (_hasError && _latestNews.isEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _hasError = false;
                    });
                    _loadLatestNews();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử tải lại'),
                ),
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: () => widget.onSelectTab(1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xem tất cả tin tức →',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> article) {
    final title = _plainText(article['tieuDe']);
    final description = _plainText(
      article['moTa'] ?? article['noiDung'],
    );
    final category = _plainText(article['tenDanhMuc']);
    final image = _imageUrl(
      article['imageURL'] ?? article['anh'],
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.onSelectTab(1),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: image.isEmpty
                    ? _imageFallback()
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.isEmpty ? 'Tin tức' : category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _blue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        title.isEmpty ? 'Tin tức MedCare' : title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Xem chi tiết →',
                        style: TextStyle(
                          color: _blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFDBEAFE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_hospital_rounded,
        size: 44,
        color: _blue,
      ),
    );
  }

  Widget _buildEmptyNews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            _hasError
                ? Icons.cloud_off_outlined
                : Icons.article_outlined,
            color: _muted,
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            _hasError
                ? 'Chưa thể tải tin tức. Vui lòng thử lại.'
                : 'Hiện chưa có tin tức được đăng tải.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
        ],
      ),
    );
  }

  // FOOTER
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: const Column(
        children: [
          Text(
            'MedCare Hospital',
            style: TextStyle(
              color: _blue,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Giải pháp quản lý bệnh viện hiện đại, hiệu quả và an toàn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              height: 1.7,
            ),
          ),
          SizedBox(height: 14),
          Text(
            '© 2026 MedCare Hospital',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
