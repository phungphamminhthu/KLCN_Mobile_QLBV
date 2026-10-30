
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';

class FollowUpsScreen extends StatefulWidget {
  const FollowUpsScreen({super.key});

  @override
  State<FollowUpsScreen> createState() => _FollowUpsScreenState();
}

class _FollowUpsScreenState extends State<FollowUpsScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D9488);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textColor = Color(0xFF1E293B);

  List<Map<String, dynamic>> _followUps = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFollowUps();
  }

  Future<void> _loadFollowUps() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await ApiClient.instance.get('/api/follow-ups/my');

      if (response is! List) {
        throw Exception('Dữ liệu lịch tái khám không hợp lệ.');
      }

      final items = response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      items.sort((a, b) {
        final dateA = _parseDate(a['ngayTaiKham']);
        final dateB = _parseDate(b['ngayTaiKham']);

        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });

      if (!mounted) return;

      setState(() {
        _followUps = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _formatDate(dynamic value) {
    final date = _parseDate(value);
    if (date == null) return 'Chưa xác định';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _text(dynamic value, [String fallback = 'Chưa cập nhật']) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  List<Map<String, dynamic>> get _upcoming {
    final today = DateUtils.dateOnly(DateTime.now());

    return _followUps.where((item) {
      final date = _parseDate(item['ngayTaiKham']);
      return date != null &&
          !DateUtils.dateOnly(date).isBefore(today);
    }).toList();
  }

  List<Map<String, dynamic>> get _past {
    final today = DateUtils.dateOnly(DateTime.now());

    return _followUps.where((item) {
      final date = _parseDate(item['ngayTaiKham']);
      return date != null &&
          DateUtils.dateOnly(date).isBefore(today);
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: textColor,
            onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Lịch tái khám',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadFollowUps,
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
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
                color: textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Không tải được lịch tái khám',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadFollowUps,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_followUps.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadFollowUps,
        color: primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 110),
            Icon(
              Icons.event_available_outlined,
              color: Color(0xFF94A3B8),
              size: 76,
            ),
            SizedBox(height: 18),
            Text(
              'Chưa có lịch tái khám',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Lịch tái khám sẽ xuất hiện tại đây khi bác sĩ '
                'cập nhật ngày tái khám trong hồ sơ bệnh án.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowUps,
      color: primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          _buildSummary(),
          const SizedBox(height: 24),

          if (_upcoming.isNotEmpty) ...[
            _sectionTitle(
              'Lịch sắp tới',
              '${_upcoming.length} lịch',
              teal,
            ),
            const SizedBox(height: 12),
            ..._upcoming.map(
              (item) => _buildFollowUpCard(item, upcoming: true),
            ),
          ],

          if (_past.isNotEmpty) ...[
            const SizedBox(height: 18),
            _sectionTitle(
              'Lịch đã qua',
              '${_past.length} lịch',
              textSecondary,
            ),
            const SizedBox(height: 12),
            ..._past.map(
              (item) => _buildFollowUpCard(item, upcoming: false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theo dõi lịch tái khám',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_upcoming.length} lịch sắp tới · '
                  '${_past.length} lịch đã qua',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
        ),
        Text(
          count,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowUpCard(
    Map<String, dynamic> item, {
    required bool upcoming,
  }) {
    final status = _text(item['trangThai']);
    final color = upcoming ? teal : textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showDetails(item, upcoming: upcoming),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _parseDate(item['ngayTaiKham'])?.day
                                  .toString() ??
                              '--',
                          style: TextStyle(
                            color: color,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          _parseDate(item['ngayTaiKham']) != null
                              ? 'T${_parseDate(item['ngayTaiKham'])!.month}'
                              : '--',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(item['ngayTaiKham']),
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Hồ sơ #${_text(item['maHoSoBenhAn'], '--')}',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (item['tenKhoa'] != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            item['tenKhoa'].toString(),
                            style: const TextStyle(
                              color: primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: border),
              const SizedBox(height: 12),
              _infoLine(
                Icons.medical_information_outlined,
                'Chẩn đoán',
                _text(item['chanDoan']),
              ),
              const SizedBox(height: 8),
              _infoLine(
                Icons.person_outline_rounded,
                'Bác sĩ',
                _text(item['tenBacSi']),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    upcoming ? 'Cần theo dõi lịch' : 'Ngày đã qua',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Biến status được giữ để hiển thị trạng thái hồ sơ
              // nếu backend cập nhật thêm trạng thái nghiệp vụ.
              if (status.isNotEmpty && status != 'Chưa cập nhật')
                const SizedBox(height: 0),
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
        Icon(icon, size: 17, color: textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 82,
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showDetails(
    Map<String, dynamic> item, {
    required bool upcoming,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Chi tiết lịch tái khám',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _detailRow(
                    'Ngày tái khám',
                    _formatDate(item['ngayTaiKham']),
                  ),
                  _detailRow(
                    'Mã hồ sơ',
                    _text(item['maHoSoBenhAn']),
                  ),
                  _detailRow(
                    'Mã lịch khám trước',
                    _text(item['maLichKham']),
                  ),
                  _detailRow(
                    'Khoa',
                    _text(item['tenKhoa']),
                  ),
                  _detailRow(
                    'Bác sĩ',
                    _text(item['tenBacSi']),
                  ),
                  _detailRow(
                    'Trạng thái hồ sơ',
                    _text(item['trangThai']),
                  ),
                  const SizedBox(height: 18),
                  _detailSection('Chẩn đoán', item['chanDoan']),
                  _detailSection('Kết luận', item['ketLuan']),
                  _detailSection(
                    'Hướng điều trị',
                    item['huongDieuTri'],
                  ),
                  _detailSection(
                    'Ghi chú tái khám',
                    item['ghiChuTaiKham'],
                  ),
                  _detailSection('Triệu chứng', item['trieuChung']),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSection(String title, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value.toString(),
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
