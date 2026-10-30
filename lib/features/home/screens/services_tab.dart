import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import 'main_navigation_screen.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  static const Color _primary = Color(0xFF2563EB);
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _text = Color(0xFF1E293B);
  static const Color _secondaryText = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _muted = Color(0xFF64748B);

  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _filteredServices = [];

  bool _loading = true;
  String? _error;
  String _selectedCategory = 'Tất cả';
  String _keyword = '';
  // Phân trang danh sách dịch vụ
  static const int _pageSize = 3;
  int _currentPage = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // LẤY DANH SÁCH DỊCH VỤ TỪ API SPRING BOOT
  // GET /api/dich-vu-y-te
  // =========================================================
  Future<void> _loadServices() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = '${ApiClient.baseUrl}/api/dich-vu-y-te';

      debugPrint('SERVICES API URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: const {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('SERVICES API STATUS: ${response.statusCode}');
      debugPrint('SERVICES API BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Không thể tải danh sách dịch vụ '
          '(HTTP ${response.statusCode}).',
        );
      }

      final dynamic decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is! List) {
        throw Exception('Dữ liệu dịch vụ từ API không đúng định dạng.');
      }

      final services = decoded
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _services = services;
        _loading = false;
        _error = null;
        _applyFilters();
      });

      debugPrint('SERVICES TOTAL: ${_services.length}');
    } catch (e, stackTrace) {
      debugPrint('SERVICES API ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
        _services = [];
        _filteredServices = [];
      });
    }
  }

  // =========================================================
  // DANH SÁCH LOẠI DỊCH VỤ
  // =========================================================
  List<String> get _categories {
    final categories = _services
        .map((service) => service['loaiDichVu']?.toString().trim() ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return ['Tất cả', ...categories];
  }

  // =========================================================
  // TÌM KIẾM VÀ LỌC DỊCH VỤ
  // =========================================================
  void _applyFilters() {
    final keyword = _keyword.trim().toLowerCase();

    _filteredServices = _services.where((service) {
      final name = service['tenDichVu']?.toString() ?? '';
      final description = service['moTa']?.toString() ?? '';
      final category = service['loaiDichVu']?.toString() ?? '';

      final matchesKeyword = keyword.isEmpty ||
          name.toLowerCase().contains(keyword) ||
          description.toLowerCase().contains(keyword) ||
          category.toLowerCase().contains(keyword);

      final matchesCategory = _selectedCategory == 'Tất cả' ||
          category == _selectedCategory;

      return matchesKeyword && matchesCategory;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _keyword = value;
      _currentPage = 0;
      _applyFilters();
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _currentPage = 0;
      _applyFilters();
    });
  }

  // =========================================================
  // ĐỊNH DẠNG GIÁ TIỀN
  // =========================================================
  String _formatPrice(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Liên hệ';
    }

    final number = num.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    final formatted = number.toStringAsFixed(
      number % 1 == 0 ? 0 : 2,
    );

    final parts = formatted.split('.');
    final integerPart = parts.first;
    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      buffer.write(integerPart[i]);

      final remaining = integerPart.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    return '${buffer.toString()}$decimalPart đ';
  }

  // =========================================================
  // GIAO DIỆN CHÍNH
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(),
            _buildServiceSection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HERO
  // =========================================================
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFDBEAFE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: _primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Dịch vụ y tế',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _text,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Khám phá các dịch vụ chăm sóc sức khỏe '
                'tại MedCare Hospital.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 16,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // KHU VỰC DANH SÁCH DỊCH VỤ
  // =========================================================
  Widget _buildServiceSection() {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Các dịch vụ của chúng tôi',
              style: TextStyle(
                color: _text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tìm kiếm dịch vụ phù hợp với nhu cầu của bạn.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _buildSearchField(),
            const SizedBox(height: 16),
            _buildCategoryFilters(),
            const SizedBox(height: 24),

            if (_loading)
              _buildLoading()
            else if (_error != null)
              _buildError()
            else if (_filteredServices.isEmpty)
              _buildEmpty()
            else ...[
              _buildServiceList(),
              const SizedBox(height: 8),

              if (_filteredServices.length > _pageSize)
                _buildServicePagination(),
            ],
          ],
        ),
      ),
    ),
  );
}

  // =========================================================
  // Ô TÌM KIẾM
  // =========================================================
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm dịch vụ...',
        hintStyle: const TextStyle(
          color: _secondaryText,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: _secondaryText,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                tooltip: 'Xóa tìm kiếm',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BỘ LỌC LOẠI DỊCH VỤ
  // =========================================================
  Widget _buildCategoryFilters() {
    if (_loading || _error != null || _categories.length <= 1) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final selected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => _onCategoryChanged(category),
              selectedColor: _primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : _secondaryText,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: selected ? _primary : _border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================
  // DANH SÁCH THẺ DỊCH VỤ
  // =========================================================
  
Widget _buildServiceList() {
  final totalPages = (_filteredServices.length / _pageSize).ceil();

  final safePage = totalPages == 0
      ? 0
      : _currentPage.clamp(0, totalPages - 1);

  final startIndex = safePage * _pageSize;
  final endIndex =
      (startIndex + _pageSize).clamp(0, _filteredServices.length);

  final pageServices =
      _filteredServices.sublist(startIndex, endIndex);

  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 760;
      final isMedium = constraints.maxWidth >= 520;

      final columns = isWide
          ? 3
          : isMedium
              ? 2
              : 1;

      const spacing = 16.0;
      final itemWidth =
          (constraints.maxWidth - spacing * (columns - 1)) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: pageServices.map((service) {
          return SizedBox(
            width: itemWidth,
            child: _buildServiceCard(service),
          );
        }).toList(),
      );
    },
  );
}

// Phân trang giống trang Tin tức
Widget _buildServicePagination() {
  final totalPages = (_filteredServices.length / _pageSize).ceil();

  if (totalPages <= 1) {
    return const SizedBox.shrink();
  }

  final currentPage = _currentPage.clamp(0, totalPages - 1);

  return Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
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
        color: _primary,
      ),

      ...List.generate(
        totalPages < 3 ? totalPages : 3,
        (index) {
          final startPage = (currentPage ~/ 3) * 3;
          final pageIndex = startPage + index;

          if (pageIndex >= totalPages) {
            return const SizedBox.shrink();
          }

          final isSelected = pageIndex == currentPage;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentPage = pageIndex;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? _primary : _border,
                  ),
                ),
                child: Text(
                  '${pageIndex + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : _text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),

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
        color: _primary,
      ),
    ],
  ),
);
}


  // =========================================================
  // THẺ DỊCH VỤ
  // =========================================================
  Widget _buildServiceCard(Map<String, dynamic> service) {
    final name = service['tenDichVu']?.toString().trim().isNotEmpty == true
        ? service['tenDichVu'].toString()
        : 'Dịch vụ y tế';

    final description =
        service['moTa']?.toString().trim().isNotEmpty == true
            ? service['moTa'].toString()
            : 'Thông tin chi tiết về dịch vụ sẽ được cập nhật.';

    final category =
        service['loaiDichVu']?.toString().trim().isNotEmpty == true
            ? service['loaiDichVu'].toString()
            : 'Dịch vụ y tế';

    final price = _formatPrice(service['gia']);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Container(
            //       width: 48,
            //       height: 48,
            //       decoration: BoxDecoration(
            //         color: const Color(0xFFEFF6FF),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: const Icon(
            //         Icons.medical_services_outlined,
            //         color: _primary,
            //         size: 26,
            //       ),
            //     ),
            //     const Spacer(),
            //     Flexible(
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //           vertical: 6,
            //         ),
            //         decoration: BoxDecoration(
            //           color: const Color(0xFFEFF6FF),
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Text(
            //           category,
            //           maxLines: 2,
            //           overflow: TextOverflow.ellipsis,
            //           textAlign: TextAlign.center,
            //           style: const TextStyle(
            //             color: _primary,
            //             fontSize: 11,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: _primary,
                    size: 26,
                  ),
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 170),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 13,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: _border, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: _primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    price,
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showServiceDetails(service),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CHI TIẾT DỊCH VỤ
  // =========================================================
  void _showServiceDetails(Map<String, dynamic> service) {
    final name = service['tenDichVu']?.toString() ?? 'Dịch vụ y tế';
    final description = service['moTa']?.toString().trim().isNotEmpty == true
        ? service['moTa'].toString()
        : 'Chưa có mô tả cho dịch vụ này.';
    final category =
        service['loaiDichVu']?.toString() ?? 'Dịch vụ y tế';
    final price = _formatPrice(service['gia']);
    final id = service['maDichVu']?.toString() ?? '—';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            name,
            style: const TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Mã dịch vụ', id),
                const SizedBox(height: 12),
                _detailRow('Loại dịch vụ', category),
                const SizedBox(height: 12),
                _detailRow('Giá dịch vụ', price),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả',
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: _secondaryText,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Đóng',
                style: TextStyle(color: _primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ĐANG TẢI
  // =========================================================
  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 16),
            Text(
              'Đang tải danh sách dịch vụ...',
              style: TextStyle(color: _secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LỖI API
  // =========================================================
  Widget _buildError() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const BorderSide(color: _border).toString().isEmpty
              ? null
              : Border.all(color: _border),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải dịch vụ',
              style: TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Đã xảy ra lỗi khi kết nối máy chủ.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadServices,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // KHÔNG CÓ DỮ LIỆU
  // =========================================================
  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.medical_information_outlined,
            color: Color(0xFF94A3B8),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _keyword.isNotEmpty || _selectedCategory != 'Tất cả'
                ? 'Không tìm thấy dịch vụ phù hợp'
                : 'Hiện chưa có dịch vụ',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vui lòng thử từ khóa khác hoặc quay lại sau.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
            ),
          ),
          if (_keyword.isNotEmpty ||
              _selectedCategory != 'Tất cả') ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _searchController.clear();

                setState(() {
                  _keyword = '';
                  _selectedCategory = 'Tất cả';
                  _applyFilters();
                });
              },
              child: const Text('Xóa bộ lọc'),
            ),
          ],
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