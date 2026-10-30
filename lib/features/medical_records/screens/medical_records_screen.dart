
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import 'medical_record_detail_screen.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  List<Map<String, dynamic>> _records = [];
  bool _loading = true;
  String? _error;
  String _keyword = '';
  String _status = 'Tất cả';

  final List<String> _statuses = [
  'Tất cả',
  'ChoKham',
  'DangKham',
  'HoanTat',
];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  String _statusLabel(String status) {
    switch (status.trim().toLowerCase()) {
        case 'chokham':
        return 'Chờ khám';
        case 'datiepnhan':
        return 'Đã tiếp nhận';
        case 'dangkham':
        return 'Đang khám';
        case 'chocls':
        return 'Chờ cận lâm sàng';
        case 'dangcls':
        return 'Đang cận lâm sàng';
        case 'hoantat':
        return 'Hoàn tất';
        case 'dahuy':
        return 'Đã hủy';
        case 'khongden':
        return 'Không đến';
        default:
        return status.isEmpty ? 'Chưa cập nhật' : status;
    }
    }

    Color _statusColor(String status) {
    switch (status.trim().toLowerCase()) {
        case 'chokham':
        return const Color(0xFFB45309); // Cam
        case 'datiepnhan':
        return const Color(0xFF7C3AED); // Tím
        case 'dangkham':
        return const Color(0xFF2563EB); // Xanh dương
        case 'chocls':
        return const Color(0xFFD97706); // Vàng cam
        case 'dangcls':
        return const Color(0xFF0891B2); // Xanh cyan
        case 'hoantat':
        return const Color(0xFF15803D); // Xanh lá
        case 'dahuy':
        return const Color(0xFFDC2626); // Đỏ
        case 'khongden':
        return const Color(0xFF64748B); // Xám
        default:
        return textSecondary;
    }
    }

  Future<void> _loadRecords() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // API lấy hồ sơ của bệnh nhân đang đăng nhập.
      // ApiClient cần tự gửi Authorization: Bearer <token>.
      final response =
          await ApiClient.instance.get('/api/medical-records');

      if (response is! List) {
        throw Exception('Dữ liệu hồ sơ không hợp lệ.');
      }

      final records = response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      records.sort((a, b) {
        final dateA = DateTime.tryParse(
          (a['ngayKham'] ?? a['NgayKham'] ?? '').toString(),
        );
        final dateB = DateTime.tryParse(
          (b['ngayKham'] ?? b['NgayKham'] ?? '').toString(),
        );

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải hồ sơ bệnh án: $e');

      if (!mounted) return;

      setState(() {
        _error = 'Không thể tải hồ sơ bệnh án. Vui lòng thử lại.';
        _loading = false;
      });
    }
  }

  String _value(
    Map<String, dynamic> record,
    String key, [
    String? alternate,
  ]) {
    final value = record[key] ?? (alternate == null ? null : record[alternate]);
    if (value == null || value.toString().trim().isEmpty) {
      return '';
    }
    return value.toString();
  }

  String _date(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Chưa cập nhật';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  List<Map<String, dynamic>> get _filteredRecords {
    return _records.where((record) {
      final status = _value(record, 'TrangThai', 'trangThai');
      final diagnosis = _value(record, 'ChanDoan', 'chanDoan');
      final symptoms = _value(record, 'TrieuChung', 'trieuChung');
      final doctor = _value(record, 'TenBacSi', 'tenBacSi');
      final department = _value(record, 'TenKhoa', 'tenKhoa');

      final matchesStatus = _status == 'Tất cả' ||
          status.toLowerCase() == _status.toLowerCase();

      final text = '$diagnosis $symptoms $doctor $department'.toLowerCase();
      final matchesKeyword =
          text.contains(_keyword.trim().toLowerCase());

      return matchesStatus && matchesKeyword;
    }).toList();
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
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: const Text(
          'Hồ sơ bệnh án',
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
    if (_loading) {
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
                size: 52,
                color: textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadRecords,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final records = _filteredRecords;

    return RefreshIndicator(
      onRefresh: _loadRecords,
      color: primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearch(),
          const SizedBox(height: 14),
          _buildStatusFilters(),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lịch sử khám bệnh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              Text(
                '${records.length} hồ sơ',
                style: const TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (records.isEmpty)
            _buildEmpty()
          else
            ...records.map(_buildRecordCard),
            // ...records
            //   .where((record) =>
            //       record.trangThai.toLowerCase() == 'hoantat')
            //   .map(_buildRecordCard),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final completed = _records.where((r) {
      return _value(r, 'TrangThai', 'trangThai').toLowerCase() ==
          'hoantat';
    }).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.folder_shared_outlined,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.health_and_safety_outlined,
                color: Colors.white70,
                size: 34,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Hồ sơ sức khỏe của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Theo dõi lịch sử khám và thông tin điều trị tại MedCare.',
            style: TextStyle(
              color: Colors.white,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _headerStat('Tổng hồ sơ', '${_records.length}'),
              const SizedBox(width: 12),
              _headerStat('Đã hoàn tất', '$completed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) => setState(() => _keyword = value),
      decoration: InputDecoration(
        hintText: 'Tìm theo chẩn đoán, bác sĩ...',
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: textSecondary,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statuses.map((status) {
          final selected = _status == status;
          final label = status == 'Tất cả'
              ? status
              : _statusLabel(status);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => setState(() => _status = status),
              selectedColor: primary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? primary : border,
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  
    Widget _buildRecordCard(Map<String, dynamic> record) {
    final id = _value(record, 'MaHoSoBenhAn', 'maHoSoBenhAn');
    final status = _value(record, 'TrangThai', 'trangThai');
    final diagnosis = _value(record, 'ChanDoan', 'chanDoan');
    final doctor = _value(record, 'tenBacSi', 'TenBacSi');
    final department = _value(record, 'tenKhoa', 'TenKhoa');

    final date = record['ngayKham'] ??
        record['NgayKham'] ??
        record['NgayTao'] ??
        record['ngayTao'];

    final statusColor = _statusColor(status);

    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
            BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
            ),
        ],
        ),
        child: InkWell(
        //onTap: () => _showRecordDetail(record),
        onTap: () {
          final id = _value(
            record,
            'maHoSoBenhAn',
            'MaHoSoBenhAn',
          );

          final maHoSoBenhAn = int.tryParse(id);

          if (maHoSoBenhAn == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mã hồ sơ bệnh án không hợp lệ.'),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicalRecordDetailScreen(
                maHoSoBenhAn: maHoSoBenhAn,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Phần đầu: icon, thông tin hồ sơ và trạng thái
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                        Icons.description_outlined,
                        color: primary,
                        size: 24,
                    ),
                    ),
                    const SizedBox(width: 10),

                    // Thông tin hồ sơ
                    Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                            id.isEmpty ? 'Hồ sơ bệnh án' : 'Hồ sơ #$id',
                            style: const TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                            'Ngày khám: ${_date(date)}',
                            style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            ),
                        ),

                        if (doctor.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Icon(
                                Icons.person_outline_rounded,
                                color: textSecondary,
                                size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                child: Text(
                                    doctor,
                                    softWrap: true,
                                    style: const TextStyle(
                                    color: textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    ),
                                ),
                                ),
                            ],
                            ),
                        ],

                        if (department.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Icon(
                                Icons.local_hospital_outlined,
                                color: textSecondary,
                                size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                child: Text(
                                    department,
                                    softWrap: true,
                                    style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    ),
                                ),
                                ),
                            ],
                            ),
                        ],
                        ],
                    ),
                    ),

                    const SizedBox(width: 8),

                    // Trạng thái cố định bên phải
                    ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 100,
                    ),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                        ),
                        decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                        _statusLabel(status),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                        ),
                        ),
                    ),
                    ),
                ],
                ),

                const SizedBox(height: 16),
                const Divider(
                height: 1,
                color: border,
                ),
                const SizedBox(height: 14),

                // Chẩn đoán
                _infoLine(
                Icons.medical_services_outlined,
                'Chẩn đoán',
                diagnosis.isEmpty ? 'Chưa có kết luận' : diagnosis,
                ),

                const SizedBox(height: 15),

                // Nút xem chi tiết
                Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    const Text(
                    'Xem chi tiết',
                    style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                    ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: primary,
                    ),
                ],
                ),
            ],
            ),
        ),
        ),
    );
    }

  Widget _infoLine(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 9),
        SizedBox(
          width: 83,
          child: Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              size: 35,
              color: primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa tìm thấy hồ sơ',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Hồ sơ khám bệnh sẽ xuất hiện tại đây khi có dữ liệu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (_keyword.isNotEmpty || _status != 'Tất cả') ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                setState(() {
                  _keyword = '';
                  _status = 'Tất cả';
                });
              },
              child: const Text('Xóa bộ lọc'),
            ),
          ],
        ],
      ),
    );
  }

  void _showRecordDetail(Map<String, dynamic> record) {
    final symptoms = _value(record, 'TrieuChung', 'trieuChung');
    final diagnosis = _value(record, 'ChanDoan', 'chanDoan');
    final conclusion = _value(record, 'KetLuan', 'ketLuan');
    final treatment = _value(record, 'HuongDieuTri', 'huongDieuTri');
    final weight = _value(record, 'CanNang', 'canNang');
    final height = _value(record, 'ChieuCao', 'chieuCao');
    final systolic = _value(record, 'HuyetApTamThu', 'huyetApTamThu');
    final diastolic = _value(
      record,
      'HuyetApTamTruong',
      'huyetApTamTruong',
    );
    final followUp = _value(record, 'NgayTaiKham', 'ngayTaiKham');
    final followUpNote = _value(
      record,
      'GhiChuTaiKham',
      'ghiChuTaiKham',
    );
    final status = _value(record, 'TrangThai', 'trangThai');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Chi tiết bệnh án',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Mã hồ sơ: ${_value(record, 'MaHoSoBenhAn', 'maHoSoBenhAn')}',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _detailSection(
                    'Thông tin khám',
                    Icons.medical_information_outlined,
                    [
                      _detailItem(
                        'Trạng thái',
                        _statusLabel(status),
                      ),
                      _detailItem(
                        'Ngày khám',
                        _date(
                          record['ngayKham'] ??
                              record['NgayKham'] ??
                              record['NgayTao'] ??
                              record['ngayTao'],
                        ),
                      ),
                      _detailItem(
                        'Bác sĩ',
                        _value(record, 'TenBacSi', 'tenBacSi'),
                      ),
                      _detailItem(
                        'Chuyên khoa',
                        _value(record, 'TenKhoa', 'tenKhoa'),
                      ),
                    ],
                  ),
                  _detailSection(
                    'Triệu chứng và chẩn đoán',
                    Icons.assignment_outlined,
                    [
                      _detailItem('Triệu chứng', symptoms),
                      _detailItem('Chẩn đoán', diagnosis),
                      _detailItem('Kết luận', conclusion),
                      _detailItem('Hướng điều trị', treatment),
                    ],
                  ),
                  _detailSection(
                    'Chỉ số sức khỏe',
                    Icons.monitor_heart_outlined,
                    [
                      _detailItem(
                        'Cân nặng',
                        weight.isEmpty ? '' : '$weight kg',
                      ),
                      _detailItem(
                        'Chiều cao',
                        height.isEmpty ? '' : '$height cm',
                      ),
                      _detailItem(
                        'Huyết áp',
                        systolic.isEmpty && diastolic.isEmpty
                            ? ''
                            : '${systolic.isEmpty ? '--' : systolic}/'
                                '${diastolic.isEmpty ? '--' : diastolic} mmHg',
                      ),
                    ],
                  ),
                  _detailSection(
                    'Lịch tái khám',
                    Icons.event_available_outlined,
                    [
                      _detailItem(
                        'Ngày tái khám',
                        followUp.isEmpty ? '' : _date(followUp),
                      ),
                      _detailItem('Ghi chú', followUpNote),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thông tin được hiển thị theo dữ liệu bệnh án đã được lưu tại bệnh viện.',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailSection(
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    final visibleItems = items.where((item) {
      return item is _DetailItem && item.value.isNotEmpty;
    }).toList();

    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...visibleItems,
        ],
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return _DetailItem(label: label, value: value);
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
