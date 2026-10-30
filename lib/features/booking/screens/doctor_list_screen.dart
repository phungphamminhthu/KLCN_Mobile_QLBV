import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final ApiClient _apiClient = ApiClient.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _keyword = '';

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lấy danh sách bác sĩ từ Spring Boot.
  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get(
        '/api/bac-si/lich-lam-viec/danh-sach-tat-ca',
      );

      if (response is! List) {
        throw Exception('API chưa trả về danh sách bác sĩ dạng JSON List.');
      }

      final doctors = response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) return;

      setState(() {
        _doctors = doctors;
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

  String _stringValue(Map<String, dynamic> doctor, List<String> keys) {
    for (final key in keys) {
      final value = doctor[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    return '';
  }

  int _intValue(Map<String, dynamic> doctor, List<String> keys) {
    return int.tryParse(_stringValue(doctor, keys)) ?? 0;
  }

  String _imageUrl(String fileKey) {
    final key = fileKey.trim();

    if (key.isEmpty) return '';

    // Nếu backend đã trả về URL đầy đủ thì sử dụng trực tiếp.
    final uri = Uri.tryParse(key);
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      return key;
    }

    // Nếu chỉ có fileKey R2 thì lấy ảnh qua Spring Boot.
    return Uri.parse(
      '${ApiClient.baseUrl}/api/images/view',
    ).replace(queryParameters: {'fileKey': key}).toString();
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    final keyword = _keyword.trim().toLowerCase();

    if (keyword.isEmpty) return _doctors;

    return _doctors.where((doctor) {
      final name = _stringValue(doctor, [
        'tenBacSi',
        'hoTen',
        'HoTen',
        'TenBacSi',
      ]).toLowerCase();

      final specialty = _stringValue(doctor, [
        'chuyenMon',
        'ChuyenMon',
      ]).toLowerCase();

      return name.contains(keyword) || specialty.contains(keyword);
    }).toList();
  }

  void _openDoctor(Map<String, dynamic> doctor) {
    final maBacSi = _intValue(doctor, ['maBacSi', 'MaBacSi']);

    final maKhoa = _intValue(doctor, ['maKhoa', 'MaKhoa']);

    final tenBacSi = _stringValue(doctor, [
      'tenBacSi',
      'hoTen',
      'HoTen',
      'TenBacSi',
    ]);

    if (maBacSi == 0 || maKhoa == 0 || tenBacSi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dữ liệu bác sĩ thiếu mã bác sĩ, mã khoa hoặc họ tên.'),
        ),
      );
      return;
    }

    final trinhDo = _stringValue(doctor, ['trinhDo', 'TrinhDo']);

    final chuyenMon = _stringValue(doctor, ['chuyenMon', 'ChuyenMon']);

    final chungChi = _stringValue(doctor, [
      'soChungChiHanhNghe',
      'SoChungChiHanhNghe',
      'soGiayPhepHanhNghe',
      'SoGiayPhepHanhNghe',
    ]);

    final fileKey = _stringValue(doctor, [
      'fileKey',
      'anhDaiDien',
      'AnhDaiDien',
    ]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailScreen(
          maBacSi: maBacSi,
          maKhoa: maKhoa,
          tenBacSi: tenBacSi,
          trinhDo: trinhDo,
          chuyenMon: chuyenMon,
          soChungChiHanhNghe: chungChi,
          fileKey: fileKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin bác sĩ',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _keyword = value);
              },
              decoration: InputDecoration(
                hintText: 'Tìm bác sĩ, chuyên môn...',
                prefixIcon: const Icon(Icons.search, color: primary),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildContent(doctors)),
        ],
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> doctors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: primary));
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
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              const Text(
                'Không tải được danh sách bác sĩ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (doctors.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadDoctors,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.person_search_outlined,
              size: 56,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 12),
            Center(child: Text('Không tìm thấy bác sĩ')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDoctors,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: doctors.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doctor = doctors[index];

          final name = _stringValue(doctor, [
            'tenBacSi',
            'hoTen',
            'HoTen',
            'TenBacSi',
          ]);

          final specialty = _stringValue(doctor, ['chuyenMon', 'ChuyenMon']);

          final degree = _stringValue(doctor, ['trinhDo', 'TrinhDo']);

          final fileKey = _stringValue(doctor, [
            'fileKey',
            'anhDaiDien',
            'AnhDaiDien',
          ]);

          final imageUrl = _imageUrl(fileKey);

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => _openDoctor(doctor),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 82,
                        height: 90,
                        child: imageUrl.isEmpty
                            ? _defaultAvatar()
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _defaultAvatar(),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Bác sĩ' : name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _infoLine(
                            Icons.medical_services_outlined,
                            specialty.isEmpty
                                ? 'Chưa cập nhật chuyên môn'
                                : specialty,
                          ),
                          const SizedBox(height: 5),
                          _infoLine(
                            Icons.school_outlined,
                            degree.isEmpty ? 'Chưa cập nhật trình độ' : degree,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFFE0EEFF),
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 48, color: primary),
    );
  }
}
