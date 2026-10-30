
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../core/network/api_client.dart';

const Color _primary = Color(0xFF2563EB);
const Color _primaryDark = Color(0xFF1D4ED8);
const Color _background = Color(0xFFF8FAFC);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _border = Color(0xFFE2E8F0);

class NewsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreen({
    super.key,
    required this.news,
  });

  String _text(dynamic value) => value?.toString().trim() ?? '';

  String _resolveImageUrl(dynamic value) {
    final path = _text(value);

    if (path.isEmpty) return '';

    final uri = Uri.tryParse(path);

    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https')) {
      return path;
    }

    final fileName = path
        .replaceAll('\\', '/')
        .split('/')
        .last;

    return '${ApiClient.baseUrl}/Images/'
        '${Uri.encodeComponent(fileName)}';
  }

  String _formatDate(dynamic value) {
    final raw = _text(value);
    if (raw.isEmpty) return '';

    final date = DateTime.tryParse(raw);
    if (date == null) return raw;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _shareNews(BuildContext context, String title) {
    Clipboard.setData(ClipboardData(text: title));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép tiêu đề tin tức.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _text(news['tieuDe']).isEmpty
        ? 'Tin tức bệnh viện'
        : _text(news['tieuDe']);

    final content = _text(news['noiDung']);
    final imageUrl = _resolveImageUrl(news['imageURL']);

    final category = _text(
      news['tenDanhMuc'] ?? news['danhMuc'],
    );

    final date = _formatDate(news['ngayDang']);

    return Scaffold(
      backgroundColor: _background,
      body: CustomScrollView(
        slivers: [
          // Thanh điều hướng cố định theo nội dung cuộn.
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Quay lại',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: _textPrimary,
              ),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.local_hospital_rounded,
                  color: _primary,
                  size: 25,
                ),
                SizedBox(width: 9),
                Flexible(
                  child: Text(
                    'MedCare Hospital',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Sao chép tiêu đề',
                onPressed: () => _shareNews(context, title),
                icon: const Icon(
                  Icons.share_outlined,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Ảnh bìa.
                if (imageUrl.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return Container(
                          color: const Color(0xFFEFF6FF),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: _primary,
                          ),
                        );
                      },
                    ),
                  ),

                // Phần bài viết.
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 900,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        24,
                        16,
                        32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb.
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Tin tức',
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 17,
                                color: _textSecondary,
                              ),
                              const Text(
                                'Chi tiết bài viết',
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Nhãn danh mục.
                          if (category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDBEAFE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: _primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Tiêu đề chính.
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 27,
                              height: 1.35,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: _textPrimary,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Thông tin bài viết.
                          Wrap(
                            spacing: 20,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (date.isNotEmpty)
                                _metadataItem(
                                  Icons.calendar_month_outlined,
                                  date,
                                ),
                              _metadataItem(
                                Icons.local_hospital_outlined,
                                'MedCare Hospital',
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Divider(
                              color: _border,
                              height: 1,
                            ),
                          ),

                          // Khung nội dung.
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _border),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.025),
                                  blurRadius: 18,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: content.isEmpty
                                ? const Text(
                                    'Nội dung đang được cập nhật.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.9,
                                      color: _textSecondary,
                                    ),
                                  )
                                : Html(
                                    data: content,
                                    style: {
                                      'body': Style(
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                        fontSize: FontSize(16),
                                        lineHeight: const LineHeight(1.9),
                                        color: _textSecondary,
                                        textAlign: TextAlign.start,
                                      ),
                                      'p': Style(
                                        margin: Margins.only(bottom: 16),
                                      ),
                                      'h1': Style(
                                        fontSize: FontSize(25),
                                        fontWeight: FontWeight.bold,
                                        color: _textPrimary,
                                        margin: Margins.only(
                                          top: 22,
                                          bottom: 12,
                                        ),
                                      ),
                                      'h2': Style(
                                        fontSize: FontSize(22),
                                        fontWeight: FontWeight.bold,
                                        color: _textPrimary,
                                        margin: Margins.only(
                                          top: 20,
                                          bottom: 10,
                                        ),
                                      ),
                                      'h3': Style(
                                        fontSize: FontSize(19),
                                        fontWeight: FontWeight.bold,
                                        color: _textPrimary,
                                      ),
                                      'strong': Style(
                                        fontWeight: FontWeight.bold,
                                        color: _textPrimary,
                                      ),
                                      'ul': Style(
                                        padding: HtmlPaddings.only(left: 22),
                                      ),
                                      'ol': Style(
                                        padding: HtmlPaddings.only(left: 22),
                                      ),
                                      'li': Style(
                                        margin: Margins.only(bottom: 8),
                                      ),
                                      'img': Style(
                                        width: Width(100, Unit.percent),
                                      ),
                                      'blockquote': Style(
                                        margin: Margins.symmetric(
                                          horizontal: 0,
                                          vertical: 14,
                                        ),
                                        padding: HtmlPaddings.only(
                                          left: 14,
                                          top: 8,
                                          bottom: 8,
                                        ),
                                        border: const Border(
                                          left: BorderSide(
                                            color: _primary,
                                            width: 4,
                                          ),
                                        ),
                                        backgroundColor:
                                            const Color(0xFFF1F5F9),
                                      ),
                                    },
                                  ),
                          ),

                          const SizedBox(height: 24),                        
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metadataItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: _textSecondary,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      color: const Color(0xFFEFF6FF),
      alignment: Alignment.center,
      child: const Icon(
        Icons.newspaper_outlined,
        size: 60,
        color: _primary,
      ),
    );
  }
}
