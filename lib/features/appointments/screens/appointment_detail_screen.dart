
import 'package:flutter/material.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  final Map<String, dynamic> appointment;

  static const Color primary = Color(0xFF078DBB);
  static const Color background = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  double get _total => _number(appointment['tongChiPhi']);
  double get _paid => _number(appointment['tongDaThanhToan']);
  double get _remaining => _number(appointment['soTienConLai']);

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(double value) {
    return '${value.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    )} đ';
  }

  String _date(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) {
      return value.isEmpty ? 'Chưa cập nhật' : value;
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _time(String value) {
    if (value.isEmpty) return 'Chưa cập nhật';

    final parts = value.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : value;
  }

  String _appointmentStatus(String status) {
    switch (status) {
      case 'ChoGoi':
        return 'Chờ khám';
      case 'DaXacNhan':
        return 'Đã xác nhận';
      case 'DaTiepNhan':
        return 'Đã tiếp nhận';
      case 'DangKham':
        return 'Đang khám';
      case 'HoanThanh':
        return 'Hoàn thành';
      case 'DaHuy':
        return 'Đã hủy';
      case 'KhongDen':
        return 'Không đến';
      default:
        return status.isEmpty ? 'Chưa cập nhật' : status;
    }
  }

  Color _appointmentStatusColor(String status) {
    switch (status) {
      case 'HoanThanh':
        return const Color(0xFF15803D);
      case 'DaHuy':
      case 'KhongDen':
        return const Color(0xFFDC2626);
      case 'DangKham':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = '${appointment['trangThaiLichKham'] ?? ''}';
    final paymentStatus = _remaining <= 0 && _total > 0
        ? 'Đã thanh toán'
        : _remaining > 0
            ? 'Chưa thanh toán'
            : 'Chưa có chi phí';

    final paymentColor = _remaining <= 0 && _total > 0
        ? const Color(0xFF15803D)
        : const Color(0xFFD97706);

    final reason = '${appointment['lyDoKham'] ?? ''}'.trim();
    final room = '${appointment['tenPhong'] ?? ''}'.trim();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        //foregroundColor: textPrimary,
        //foregroundColor: primary,
        // leading: IconButton(
        //   tooltip: 'Quay lại',
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết lịch hẹn',
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Thông tin lịch khám và bệnh nhân
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin lịch khám',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // _infoRow(
                    //   Icons.confirmation_number_outlined,
                    //   'Mã lịch khám',
                    //   '${appointment['maLichKham'] ?? '—'}',
                    // ),
                    _infoRow(
                      Icons.local_hospital_outlined,
                      'Khoa',
                      '${appointment['tenKhoa'] ?? 'Chưa cập nhật'}',
                    ),
                    _infoRow(
                      Icons.person_outline,
                      'Bác sĩ',
                      '${appointment['tenBacSi'] ?? 'Chưa phân công'}',
                    ),
                    _infoRow(
                      Icons.calendar_month_outlined,
                      'Ngày khám',
                      _date('${appointment['ngayKham'] ?? ''}'),
                    ),
                    _infoRow(
                      Icons.access_time,
                      'Giờ khám',
                      _time('${appointment['gioKham'] ?? ''}'),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Trạng thái lịch',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        _badge(
                          _appointmentStatus(status),
                          _appointmentStatusColor(status),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Số thứ tự và phòng khám nổi bật
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FBFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF9EDFF0),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Số thứ tự khám',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${appointment['soThuTu'] ?? '—'}',
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF2563EB),
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Phòng khám',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  room.isNotEmpty
                                      ? room
                                      : 'Chưa cập nhật phòng khám',
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Vui lòng theo dõi số thứ tự khi đến khám.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Lý do khám
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lý do khám',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      reason.isNotEmpty ? reason : 'Không có thông tin',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Thanh toán
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thanh toán',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _paymentRow('Tổng chi phí', _money(_total)),
                    const SizedBox(height: 14),
                    _paymentRow('Đã thanh toán', _money(_paid)),
                    const SizedBox(height: 14),
                    _paymentRow(
                      'Còn phải thanh toán',
                      _money(_remaining),
                      valueColor: _remaining > 0
                          ? const Color(0xFFD97706)
                          : const Color(0xFF15803D),
                      bold: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: border),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Trạng thái thanh toán',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _badge(paymentStatus, paymentColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primary),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(
    String label,
    String value, {
    Color valueColor = textPrimary,
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
