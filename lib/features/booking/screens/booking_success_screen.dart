
import 'package:flutter/material.dart';
//import 'package:qr_flutter/qr_flutter.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingSuccessScreen({
    super.key,
    required this.booking,
  });

  String _value(dynamic value, [String fallback = '—']) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
  }

  String _money(dynamic value) {
    final amount = double.tryParse(value.toString());
    if (amount == null) return '—';

    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}đ';
  }

  String _trangThaiLich(String value) {
    switch (value) {
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
        return value;
    }
  }

  String _trangThaiThanhToan(String value) {
    switch (value) {
      case 'ChuaThanhToan':
        return 'Chưa thanh toán';
      case 'DaThanhToan':
        return 'Đã thanh toán';
      case 'DaHuy':
        return 'Đã hủy';
      default:
        return value;
    }
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final maLich = _value(booking['maLichKham']);
    final soThuTu = _value(booking['soThuTu']);
    //final maSoThuTu = _value(booking['maSoThuTu']);

    final trangThaiLich = _value(
      booking['trangThaiLichKham'],
      'ChoGoi',
    );

    final trangThaiHoaDon = _value(
      booking['trangThaiHoaDon'],
      'ChuaThanhToan',
    );

    // QR chứa mã lịch khám, chưa chứa dữ liệu cá nhân.
    // Khi có API xác minh QR, thay nội dung này bằng token
    // do backend cấp.
    //final qrData = 'LICH_KHAM:$maLich';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Đặt lịch thành công'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2563EB),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Icon(
            Icons.check_circle,
            color: Color(0xFF16A34A),
            size: 76,
          ),
          const SizedBox(height: 12),
          const Text(
            'Đặt lịch khám thành công!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lịch khám của bạn đã được ghi nhận.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'SỐ THỨ TỰ KHÁM',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    soThuTu,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  //_info('Mã lịch khám', maLich),
                  //_info('Mã số thứ tự', maSoThuTu),
                  _info('Ngày khám', _value(booking['ngayKham'])),
                  _info('Khoa', _value(booking['tenKhoa'])),
                  _info('Bác sĩ', _value(booking['tenBacSi'])),
                  _info(
                    'Khung giờ',
                    '${_value(booking['gioBatDau'])} - '
                    '${_value(booking['gioKetThuc'])}',
                  ),
                  _info('Phòng khám', _value(booking['tenPhong'])),
                  _info('Lý do khám', _value(booking['lyDoKham'])),
                  _info('Tiền khám', _money(booking['tongTien'])),
                  _info(
                    'Trạng thái lịch',
                    _trangThaiLich(trangThaiLich),
                  ),
                  _info(
                    'Thanh toán',
                    _trangThaiThanhToan(trangThaiHoaDon),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              // Nút lịch sử đăng ký
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/appointments');
                    },
                    icon: const Icon(Icons.history),
                    label: const Text(
                      'Lịch sử đăng ký',
                      textAlign: TextAlign.center,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(
                        color: Color(0xFF2563EB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Nút hoàn tất: về trang chủ
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Hoàn tất'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}