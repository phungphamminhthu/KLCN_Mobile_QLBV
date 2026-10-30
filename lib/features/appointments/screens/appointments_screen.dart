
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import 'appointment_detail_screen.dart';
import 'payment_qr_screen.dart';


class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF0F8FF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  String _filter = 'Tất cả';
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response =
          await ApiClient.instance.get('/api/lich-kham/cua-toi');

      if (response is! List) {
        throw const FormatException(
          'Dữ liệu lịch khám từ máy chủ không hợp lệ.',
        );
      }

      final appointments = response.map<Map<String, dynamic>>((item) {
        if (item is! Map) {
          throw const FormatException('Thông tin lịch khám không hợp lệ.');
        }

        final json = Map<String, dynamic>.from(item);

        // DEBUG LỖI
        debugPrint('DEBUG lịch khám: $json');

        return {
          'maLichKham': json['maLichKham'],
          'maSoThuTu': json['maSoThuTu'],
          'soThuTu': json['soThuTu'],
          'ngayKham': json['ngayKham']?.toString() ?? '',
          'gioKham': json['gioKham']?.toString() ?? '',
          'tenKhoa': json['tenKhoa']?.toString() ?? 'Chưa cập nhật',
          'tenBacSi': json['tenBacSi']?.toString() ?? 'Chưa phân công',
          'tenPhong': json['tenPhong']?.toString() ?? 'Chưa cập nhật',
          'lyDoKham': json['lyDoKham']?.toString() ?? '',
          'trangThaiLichKham':
              json['trangThaiLichKham']?.toString() ?? '',
          'trangThaiSoThuTu':
              json['trangThaiSoThuTu']?.toString() ?? '',
          'tongChiPhi': _toDouble(json['tongChiPhi']),
          'tongDaThanhToan': _toDouble(json['tongDaThanhToan']),
          'soTienConLai': _toDouble(json['soTienConLai']),
        };
      }).toList();
      
      // tải danh sách hóa đơn cho từng lịch khám 
      for (final appointment in appointments) {
        final maLichKham = int.tryParse(
          appointment['maLichKham']?.toString() ?? '',
        );

        appointment['danhSachHoaDon'] = <Map<String, dynamic>>[];

        if (maLichKham == null) continue;

        try {

          debugPrint('ĐANG GỌI API HÓA ĐƠN: $maLichKham');

          final invoiceResponse = await ApiClient.instance.get(
            '/api/thanh-toan/lich-kham/$maLichKham/hoa-don',
          );

          debugPrint('KẾT QUẢ API HÓA ĐƠN: $invoiceResponse');

          if (invoiceResponse is List) {
            appointment['danhSachHoaDon'] =
                invoiceResponse
                    .whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList();
          }
        } catch (e) {
          debugPrint(
            'Không tải được hóa đơn của lịch $maLichKham: $e',
          );
        }
      }
      if (!mounted) return;

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiException
            ? e.message
            : 'Không thể tải lịch khám. Vui lòng thử lại.';
      });
    }
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ====================================
  // ĐIỀU HƯỚNG ĐẾN MÀN HÌNH THANH TOÁN 
  //=====================================
  Future<void> _openPayment(int maHoaDon) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PaymentQrScreen(
          maHoaDon: maHoaDon,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // Tải lại danh sách lịch khám sau khi thanh toán.
      await _loadAppointments();
    }
  }

  // List<Map<String, dynamic>> get _filteredAppointments {
  //   switch (_filter) {
  //     case 'Chưa thanh toán':
  //       return _appointments.where((a) {
  //         return (a['soTienConLai'] as double) > 0 &&
  //             a['trangThaiLichKham'] != 'DaHuy';
  //       }).toList();

  //     case 'Đã thanh toán':
  //       return _appointments.where((a) {
  //         return (a['tongChiPhi'] as double) > 0 &&
  //             (a['soTienConLai'] as double) <= 0 &&
  //             a['trangThaiLichKham'] != 'DaHuy';
  //       }).toList();

  //     default:
  //       return _appointments;
  //   }
  // }
  
List<Map<String, dynamic>> get _filteredAppointments {
  double getAmount(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  return _appointments.where((appointment) {
    final status = appointment['trangThaiLichKham']?.toString();
    final total = getAmount(appointment['tongChiPhi']);
    final remaining = getAmount(appointment['soTienConLai']);

    // Không hiển thị lịch đã hủy trong các bộ lọc thanh toán
    if (status == 'DaHuy') {
      return false;
    }

    switch (_filter) {
      case 'Chưa thanh toán':
        return remaining > 0;

      case 'Đã thanh toán':
        return total > 0 && remaining <= 0;

      default:
        return true;
    }
  }).toList();
}


  String _money(dynamic value) {
    final amount = _toDouble(value).round();
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '$formatted đ';
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value.isEmpty ? 'Chưa cập nhật' : value;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(String value) {
    if (value.isEmpty) return 'Chưa cập nhật';

    // LocalTime từ Java thường được serialize thành HH:mm:ss.
    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return value;
  }

  
String _appointmentStatus(String status) {
  switch (status.trim()) {
    case 'ChoGoi':
      return 'Chờ gọi';

    case 'DaGoi':
      return 'Đã gọi';

    case 'DaTiepNhan':
      return 'Đã tiếp nhận';

    case 'DangKham':
      return 'Đang khám';

    case 'ChoThanhToan':
      return 'Chờ thanh toán';

    case 'ChoCLS':
      return 'Chờ cận lâm sàng';

    case 'DangCLS':
      return 'Đang thực hiện cận lâm sàng';

    case 'ChoKham':
      return 'Chờ khám';

    case 'ChoLayThuoc':
      return 'Chờ lấy thuốc';

    case 'DangLayThuoc':
      return 'Đang lấy thuốc';

    case 'HoanTat':
      return 'Hoàn tất';

    case 'HoanThanh':
      return 'Hoàn thành';

    case 'DaXacNhan':
      return 'Đã xác nhận';

    case 'DaHuy':
      return 'Đã hủy';

    case 'KhongDen':
      return 'Không đến';

    default:
      return status.isEmpty ? 'Chưa cập nhật' : status;
  }
}


  
Color _appointmentColor(String status) {
  switch (status.trim()) {
    case 'HoanTat':
    case 'HoanThanh':
      return const Color(0xFF15803D);

    case 'DaHuy':
    case 'KhongDen':
      return const Color(0xFFDC2626);

    case 'DangKham':
    case 'DangCLS':
    case 'DangLayThuoc':
      return const Color(0xFF7C3AED);

    case 'ChoThanhToan':
      return const Color(0xFFD97706);

    case 'ChoLayThuoc':
    case 'ChoCLS':
    case 'ChoKham':
    case 'ChoGoi':
    case 'DaGoi':
    case 'DaTiepNhan':
    case 'DaXacNhan':
      return primary;

    default:
      return textSecondary;
  }
}


  bool _isCancelled(Map<String, dynamic> appointment) {
    final status = appointment['trangThaiLichKham'];
    return status == 'DaHuy' || status == 'KhongDen';
  }

  bool _isPaid(Map<String, dynamic> appointment) {
  final invoices =
      (appointment['danhSachHoaDon'] as List?)
              ?.whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          <Map<String, dynamic>>[];

  if (invoices.isNotEmpty) {
    // Chỉ xem lịch đã thanh toán đủ khi tất cả hóa đơn
    // hợp lệ đều đã thanh toán.
    final activeInvoices = invoices.where(
      (invoice) => invoice['trangThai'] != 'DaHuy',
    ).toList();

    if (activeInvoices.isEmpty) return false;

    return activeInvoices.every(
      (invoice) => invoice['trangThai'] == 'DaThanhToan',
    );
  }

  // Dự phòng khi lịch chưa có hóa đơn.
  final remaining = _toDouble(appointment['soTienConLai']);
  final total = _toDouble(appointment['tongChiPhi']);

  return total > 0 && remaining <= 0;
}

  // bool _isPaid(Map<String, dynamic> appointment) {
  //   return (appointment['soTienConLai'] as double) <= 0 &&
  //       (appointment['tongChiPhi'] as double) > 0;
  // }

  // void _showDetails(Map<String, dynamic> appointment) {
  //   final total = appointment['tongChiPhi'] as double;
  //   final paid = appointment['tongDaThanhToan'] as double;
  //   final remaining = appointment['soTienConLai'] as double;

  //   showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //     ),
  //     builder: (sheetContext) {
  //       return SafeArea(
  //         child: SingleChildScrollView(
  //           padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Center(
  //                 child: Container(
  //                   width: 42,
  //                   height: 4,
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFFCBD5E1),
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 20),
  //               const Text(
  //                 'Chi tiết lịch khám',
  //                 style: TextStyle(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: textPrimary,
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               _detail('Mã lịch khám',
  //                   '${appointment['maLichKham'] ?? '—'}'),
  //               _detail('Số thứ tự',
  //                   '${appointment['soThuTu'] ?? '—'}'),
  //               _detail('Khoa', '${appointment['tenKhoa']}'),
  //               _detail('Bác sĩ', '${appointment['tenBacSi']}'),
  //               _detail(
  //                 'Ngày khám',
  //                 _formatDate('${appointment['ngayKham']}'),
  //               ),
  //               _detail(
  //                 'Giờ khám',
  //                 _formatTime('${appointment['gioKham']}'),
  //               ),
  //               _detail('Phòng khám', '${appointment['tenPhong']}'),
  //               _detail(
  //                 'Lý do khám',
  //                 (appointment['lyDoKham'] as String).isEmpty
  //                     ? 'Không có'
  //                     : '${appointment['lyDoKham']}',
  //               ),
  //               const Divider(height: 24),
  //               _detail('Tổng chi phí', _money(total)),
  //               _detail('Đã thanh toán', _money(paid)),
  //               _detail('Còn phải thanh toán', _money(remaining)),
  //               _detail(
  //                 'Trạng thái lịch',
  //                 _appointmentStatus(
  //                   '${appointment['trangThaiLichKham']}',
  //                 ),
  //               ),
  //               _detail(
  //                 'Trạng thái thanh toán',
  //                 remaining <= 0 && total > 0
  //                     ? 'Đã thanh toán đủ'
  //                     : remaining > 0
  //                         ? 'Chưa thanh toán đủ'
  //                         : 'Chưa có chi phí',
  //               ),
  //               const SizedBox(height: 16),
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 48,
  //                 child: OutlinedButton(
  //                   onPressed: () => Navigator.pop(sheetContext),
  //                   child: const Text('Đóng'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showDetails(Map<String, dynamic> appointment) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppointmentDetailScreen(
          appointment: appointment,
        ),
      ),
    );
  }

  // Widget _detail(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 7),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Expanded(
  //           child: Text(
  //             label,
  //             style: const TextStyle(color: textSecondary),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Text(
  //             value,
  //             textAlign: TextAlign.end,
  //             style: const TextStyle(
  //               color: textPrimary,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final appointments = _filteredAppointments;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        //foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử đặt khám',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            onPressed: _isLoading ? null : _loadAppointments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Container(
          //   width: double.infinity,
          //   color: Colors.white,
          //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
          //   child: const Text(
          //     'Theo dõi lịch khám và tình trạng thanh toán của bạn.',
          //     style: TextStyle(color: textSecondary, fontSize: 14),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Tất cả'),
                  const SizedBox(width: 8),
                  _filterChip('Chưa thanh toán'),
                  const SizedBox(width: 8),
                  _filterChip('Đã thanh toán'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _errorState()
                    : appointments.isEmpty
                        ? _emptyState()
                        : RefreshIndicator(
                            onRefresh: _loadAppointments,
                            child: ListView.separated(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              itemCount: appointments.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                return _appointmentCard(
                                  appointments[index],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _filter == label;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = label),
      selectedColor: primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      side: BorderSide(
        color: selected ? primary : const Color(0xFFE2E8F0),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> appointment) {
    final total = appointment['tongChiPhi'] as double;
    final remaining = appointment['soTienConLai'] as double;
    final status = '${appointment['trangThaiLichKham']}';
    final paid = _isPaid(appointment);
    final cancelled = _isCancelled(appointment);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
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
                      '${appointment['tenKhoa']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'BS. ${appointment['tenBacSi']}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STT: ${appointment['soThuTu'] ?? 'Chưa cấp'}',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.blueGrey.shade300),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),
          _appointmentInfo(
            Icons.calendar_month_outlined,
            '${_formatDate('${appointment['ngayKham']}')}  •  '
                '${_formatTime('${appointment['gioKham']}')}',
          ),
          const SizedBox(height: 10),
          _appointmentInfo(
            Icons.meeting_room_outlined,
            'Phòng ${appointment['tenPhong']}',
          ),
          // final tenPhong = (appointment['tenPhong'] ?? '').toString().trim();

          // _appointmentInfo(
          //   Icons.meeting_room_outlined,
          //   tenPhong.isNotEmpty
          //       ? 'Phòng $tenPhong'
          //       : 'Chưa có thông tin phòng khám',
          // ),
          const SizedBox(height: 10),
          _appointmentInfo(
            Icons.payments_outlined,
            'Tổng chi phí: ${_money(total)}',
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 8),
            _appointmentInfo(
              Icons.account_balance_wallet_outlined,
              'Còn phải trả: ${_money(remaining)}',
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusBadge(
                _appointmentStatus(status),
                _appointmentColor(status),
              ),
              _statusBadge(
                paid
                    ? 'Đã thanh toán'
                    : remaining > 0
                        ? 'Chưa thanh toán đủ'
                        : 'Chưa có chi phí',
                paid
                    ? const Color(0xFF15803D)
                    : const Color(0xFFD97706),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDetails(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xem chi tiết lịch',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              if (remaining > 0 && !cancelled) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final invoices =
                          (appointment['danhSachHoaDon'] as List?)
                                  ?.cast<Map<String, dynamic>>() ??
                              <Map<String, dynamic>>[];

                      final invoice = invoices.cast<Map<String, dynamic>?>().firstWhere(
                        (item) => item?['trangThai'] == 'ChuaThanhToan',
                        orElse: () => null,
                      );

                      final maHoaDon = int.tryParse(
                        invoice?['maHoaDon']?.toString() ?? '',
                      );

                      if (maHoaDon == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Chưa tìm thấy hóa đơn chưa thanh toán.',
                            ),
                          ),
                        );
                        return;
                      }

                      _openPayment(maHoaDon);
                    },
                    icon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                    ),
                    label: const Text('Thanh toán'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              // if (remaining > 0 && !cancelled) ...[
              //   const SizedBox(width: 10),
              //   Expanded(
              //     child: ElevatedButton.icon(
              //       onPressed: () {
              //         // TODO: Điều hướng sang màn hình thanh toán
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           const SnackBar(
              //             content: Text('Đang tích hợp chức năng thanh toán.'),
              //           ),
              //         );
              //       },
              //       icon: const Icon(
              //         Icons.account_balance_wallet_outlined,
              //         size: 18,
              //       ),
              //       label: const Text('Thanh toán'),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: primary,
              //         foregroundColor: Colors.white,
              //         padding: const EdgeInsets.symmetric(vertical: 12),
              //         elevation: 0,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //     ),
              //   ),
              // ],
            ],
          ),
          // SizedBox(
          //   width: double.infinity,
          //   child:OutlinedButton(
          //       onPressed: () => _showDetails(appointment),
          //       child: const Text('Xem chi tiết lịch'),
          //     )
          //   // OutlinedButton(
          //   //   onPressed: () => _showDetails(appointment),
          //   //   style: OutlinedButton.styleFrom(
          //   //     foregroundColor: primary,
          //   //     side: const BorderSide(color: primary),
          //   //     padding: const EdgeInsets.symmetric(vertical: 12),
          //   //     shape: RoundedRectangleBorder(
          //   //       borderRadius: BorderRadius.circular(12),
          //   //     ),
          //   //   ),
          //   //   child: const Text('Xem chi tiết lịch'),
          //   // ),
          // ),
          // if (remaining > 0 && !cancelled) ...[
          //   const SizedBox(height: 8),
          //   const Text(
          //     'Để thanh toán chính xác, cần lấy mã và trạng thái '
          //     'của từng hóa đơn từ backend.',
          //     style: TextStyle(
          //       color: textSecondary,
          //       fontSize: 12,
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  Widget _appointmentInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
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

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
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
              'Không tải được lịch khám',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Vui lòng thử lại.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAppointments,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 44,
                color: primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Chưa có lịch khám',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Các lịch khám của bạn sẽ xuất hiện tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
