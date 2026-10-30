
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';

class ServicePriceScreen extends StatefulWidget {
  const ServicePriceScreen({super.key});

  @override
  State<ServicePriceScreen> createState() => _ServicePriceScreenState();
}

class _ServicePriceScreenState extends State<ServicePriceScreen>
    with SingleTickerProviderStateMixin {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);

  late final TabController _tabController;
  final TextEditingController _searchController =
      TextEditingController();

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _departments = [];

  bool _isLoading = true;
  String? _errorMessage;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPrices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _toList(dynamic result) {
    dynamic data = result;

    if (data is Map) {
      data = data['data'] ??
          data['content'] ??
          data['items'] ??
          data['danhSach'] ??
          data['DanhSach'] ??
          data['dichVuYTe'] ??
          data['khoa'];
    }

    if (data is! List) {
      throw const FormatException(
        'Dữ liệu bảng giá từ máy chủ không hợp lệ.',
      );
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _loadPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiClient.instance.get('/api/dich-vu-y-te'),
        ApiClient.instance.get('/api/khoa'),
      ]);

      final services = _toList(results[0]);
      final departments = _toList(results[1]);

      if (!mounted) return;

      setState(() {
        _services = services;
        _departments = departments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiException
            ? e.message
            : 'Không thể tải bảng giá. Vui lòng thử lại.';
      });

      debugPrint('Lỗi tải bảng giá: $e');
    }
  }

  String _text(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = 'Chưa cập nhật',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  double _price(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];

      if (value is num) return value.toDouble();

      if (value != null) {
        final parsed = double.tryParse(
          value.toString().replaceAll(',', '').trim(),
        );
        if (parsed != null) return parsed;
      }
    }

    return 0;
  }

  List<Map<String, dynamic>> get _filteredServices {
    final keyword = _keyword.trim().toLowerCase();

    if (keyword.isEmpty) return _services;

    return _services.where((item) {
      final name = _text(item, ['tenDichVu', 'TenDichVu']);
      final type = _text(item, ['loaiDichVu', 'LoaiDichVu']);
      final description = _text(item, ['moTa', 'MoTa']);

      return '$name $type $description'.toLowerCase().contains(keyword);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredDepartments {
    final keyword = _keyword.trim().toLowerCase();

    if (keyword.isEmpty) return _departments;

    return _departments.where((item) {
      final name = _text(item, ['tenKhoa', 'TenKhoa']);
      final description = _text(item, ['moTa', 'MoTa']);

      return '$name $description'.toLowerCase().contains(keyword);
    }).toList();
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _keyword = value),
      decoration: InputDecoration(
        hintText: 'Tìm dịch vụ, kỹ thuật hoặc khoa...',
        prefixIcon: const Icon(Icons.search, color: primary),
        suffixIcon: _keyword.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _keyword = '');
                },
                icon: const Icon(Icons.close),
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    final name = _text(item, ['tenDichVu', 'TenDichVu']);
    final type = _text(
      item,
      ['loaiDichVu', 'LoaiDichVu'],
      fallback: 'Dịch vụ y tế',
    );
    final description = _text(
      item,
      ['moTa', 'MoTa'],
      fallback: '',
    );
    final price = _price(item, ['gia', 'Gia']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: primary,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 12,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  _currencyFormat.format(price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    //color: Color(0xFF059669),
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> item) {
    final name = _text(item, ['tenKhoa', 'TenKhoa']);
    final description = _text(
      item,
      ['moTa', 'MoTa'],
      fallback: '',
    );
    final price = _price(item, ['giaKham', 'GiaKham']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            // decoration: BoxDecoration(
            //   color: const Color(0xFFD1FAE5),
            //   borderRadius: BorderRadius.circular(13),
            // ),
            // child: const Icon(
            //   Icons.local_hospital_outlined,
            //   color: Color(0xFF059669),
            //   size: 25,
            // ),
            decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                Icons.local_hospital_outlined,
                color: primary,
                size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Text(
                //   'Giá khám: ${_currencyFormat.format(price)}',
                //   style: const TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //     //color: Color(0xFF059669),
                //     color: Color(0xFF059669),
                //   ),
                // ),
                Text( 
                    _currencyFormat.format(price),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        // color: Color(0xFF059669),
                        color: primary,
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;
    final departments = _filteredDepartments;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: 'Quay lại',
        ),
        title: const Text(
          'Bảng giá dịch vụ',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.medical_services_outlined),
              text: 'Dịch vụ kỹ thuật',
            ),
            Tab(
              icon: Icon(Icons.local_hospital_outlined),
              text: 'Giá khám theo khoa',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildSearch(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primary),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_off_outlined,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _loadPrices,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            onRefresh: _loadPrices,
                            child: services.isEmpty
                                ? ListView(
                                    children: [
                                      _buildEmpty(
                                        'Không tìm thấy dịch vụ phù hợp.',
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      16, 12, 16, 24,
                                    ),
                                    itemCount: services.length,
                                    itemBuilder: (context, index) =>
                                        _buildServiceCard(services[index]),
                                  ),
                          ),
                          RefreshIndicator(
                            onRefresh: _loadPrices,
                            child: departments.isEmpty
                                ? ListView(
                                    children: [
                                      _buildEmpty(
                                        'Không tìm thấy khoa phù hợp.',
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      16, 12, 16, 24,
                                    ),
                                    itemCount: departments.length,
                                    itemBuilder: (context, index) =>
                                        _buildDepartmentCard(
                                          departments[index],
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
}
