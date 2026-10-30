
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const Color primary = Color(0xFF0284C7);
  static const Color background = Color(0xFFF4F7FC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _keyword = '';

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

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // API cần trả về JSON array các dịch vụ y tế.
      final response = await ApiClient.instance.get(
        '/api/dich-vu-y-te',
      );

      final dynamic data = response;

      if (data is! List) {
        throw Exception('Dữ liệu API không phải danh sách dịch vụ.');
      }

      final services = data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _value(Map<String, dynamic> service, String key) {
    final value = service[key];
    if (value == null) return '';
    return value.toString().trim();
  }

  String _formatMoney(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );

    return '$formatted đ';
  }

  List<Map<String, dynamic>> get _filteredServices {
    final keyword = _keyword.trim().toLowerCase();

    if (keyword.isEmpty) return _services;

    return _services.where((service) {
      final name = _value(service, 'tenDichVu').toLowerCase();
      final type = _value(service, 'loaiDichVu').toLowerCase();
      final description = _value(service, 'moTa').toLowerCase();

      return name.contains(keyword) ||
          type.contains(keyword) ||
          description.contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,

        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bảng giá dịch vụ kỹ thuật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        // actions: [
        //   IconButton(
        //     tooltip: 'Trang đầu',
        //     onPressed: () {
        //       Navigator.popUntil(context, (route) => route.isFirst);
        //     },
        //     icon: const Icon(Icons.home_rounded),
        //   ),
        // ],
      ),
      body: Column(
        children: [
        //   Container(
        //     width: double.infinity,
        //     margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        //     padding: const EdgeInsets.all(18),
        //     decoration: BoxDecoration(
        //       color: primary,
        //       borderRadius: BorderRadius.circular(20),
        //     ),
        //     // child: const Row(
        //     //   children: [
        //     //     Icon(
        //     //       Icons.medical_services_outlined,
        //     //       color: Colors.white,
        //     //       size: 38,
        //     //     ),
        //     //     SizedBox(width: 14),
        //     //     Expanded(
        //     //       child: Column(
        //     //         crossAxisAlignment: CrossAxisAlignment.start,
        //     //         // children: [
        //     //         //   Text(
        //     //         //     'Dịch vụ y tế',
        //     //         //     style: TextStyle(
        //     //         //       color: Colors.white,
        //     //         //       fontSize: 19,
        //     //         //       fontWeight: FontWeight.w800,
        //     //         //     ),
        //     //         //   ),
        //     //         //   SizedBox(height: 5),
        //     //         //   Text(
        //     //         //     'Tra cứu danh mục và giá dịch vụ tại bệnh viện',
        //     //         //     style: TextStyle(
        //     //         //       color: Colors.white,
        //     //         //       fontSize: 12.5,
        //     //         //       height: 1.4,
        //     //         //     ),
        //     //         //   ),
        //     //         // ],
        //     //       ),
        //     //     ),
        //     //   ],
        //     // ),
        //   ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _keyword = value),
              decoration: InputDecoration(
                hintText: 'Tìm tên hoặc loại dịch vụ...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primary,
                ),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _keyword = '');
                        },
                        icon: const Icon(Icons.close),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Danh mục dịch vụ',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${services.length} dịch vụ',
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildBody(services)),
        ],
      ),
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> services) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: textSecondary,
              ),
              const SizedBox(height: 12),
              const Text(
                'Không tải được bảng giá dịch vụ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadServices,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (services.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadServices,
        child: ListView(
          children: const [
            SizedBox(height: 90),
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: textSecondary,
            ),
            SizedBox(height: 12),
            Center(child: Text('Không tìm thấy dịch vụ phù hợp')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadServices,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        itemCount: services.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = services[index];

          final name = _value(service, 'tenDichVu');
          final type = _value(service, 'loaiDichVu');
          final description = _value(service, 'moTa');
          final price = service['gia'];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    color: primary,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Dịch vụ y tế' : name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      if (type.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: primary,
                            size: 19,
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'Giá dịch vụ',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              _formatMoney(price),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
