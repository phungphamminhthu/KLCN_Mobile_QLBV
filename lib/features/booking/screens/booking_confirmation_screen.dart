
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import 'booking_success_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String ngayKham;
  final String tenKhoa;
  final String tenBacSi;
  final String gioBatDau;
  final String gioKetThuc;
  final String tenPhong;
  final double giaKham;

  final int? maBacSi;
  final int? maKhoa;
  final int? maLichLamViec; // ID lịch làm việc thực tế

  const BookingConfirmationScreen({
    super.key,
    required this.ngayKham,
    required this.tenKhoa,
    required this.tenBacSi,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.tenPhong,
    required this.giaKham,
    this.maBacSi,
    this.maKhoa,
    this.maLichLamViec,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  final TextEditingController _lyDoKhamController =
      TextEditingController();

    bool _isSubmitting = false;

  @override
  void dispose() {
    _lyDoKhamController.dispose();
    super.dispose();
  }

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        )}đ';
  }

  Widget _buildStepper() {
    const labels = [
        'Chọn khoa',
        'Chọn ngày',
        'Chọn bác sĩ',
        'Xác nhận',
    ];

    return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Row(
        children: List.generate(4, (index) {
            final completed = index < 3;
            final active = index == 3;

            return Expanded(
            child: Column(
                children: [
                Row(
                    children: [
                    if (index > 0)
                        Expanded(
                        child: Container(
                            height: 2,
                            color: const Color(0xFFE2E8F0),
                        ),
                        ),
                    Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed || active
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        border: Border.all(
                            color: const Color(0xFF2563EB),
                        ),
                        ),
                        child: completed
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                            )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                    ),
                    if (index < 3)
                        Expanded(
                        child: Container(
                            height: 2,
                            color: const Color(0xFFE2E8F0),
                        ),
                        ),
                    ],
                ),
                const SizedBox(height: 6),
                Text(
                    labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w400,
                    color: active
                        ? const Color(0xFF2563EB)
                        : completed
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                    ),
                ),
                ],
            ),
            );
        }),
        ),
    );
    }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: primary, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF65A30D),
                  size: 23,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: borderColor),
      ],
    );
  }

  Widget _buildReasonInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.medical_information_outlined,
                color: primary,
                size: 24,
              ),
              SizedBox(width: 9),
              Text(
                'Lý do khám',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lyDoKhamController,
            minLines: 4,
            maxLines: 5,
            maxLength: 255,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText:
                  'Ví dụ: Đau đầu, chóng mặt, đau bụng, khám định kỳ...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const Text(
            'Vui lòng mô tả triệu chứng hoặc nhu cầu khám của bạn.',
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  
Future<void> _continueBooking() async {
  final lyDoKham = _lyDoKhamController.text.trim();

  if (lyDoKham.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vui lòng nhập lý do khám.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  if (lyDoKham.length > 255) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lý do khám không được vượt quá 255 ký tự.'),
      ),
    );
    return;
  }

  final maLichLamViec = widget.maLichLamViec;

  if (maLichLamViec == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Thiếu mã lịch làm việc. Vui lòng chọn lại lịch khám.',
        ),
      ),
    );
    return;
  }

  if (_isSubmitting) return;

  setState(() => _isSubmitting = true);

  debugPrint('===== REQUEST ĐẶT LỊCH =====');
  debugPrint('maLichLamViec: ${widget.maLichLamViec}');
  debugPrint('gioKham: ${widget.gioBatDau}');
  debugPrint('lyDoKham: ${_lyDoKhamController.text.trim()}');

  try {
    final response = await ApiClient.instance.post(
      '/api/lich-kham/dat-lich',
      body: {
        'maLichLamViec': maLichLamViec,
        'gioKham': widget.gioBatDau, 
        'lyDoKham': _lyDoKhamController.text.trim(),
      },
    );

    debugPrint('===== RESPONSE ĐẶT LỊCH =====');
    debugPrint(response.toString());

    if (!mounted) return;

    if (response is! Map) {
      throw const ApiException(
        'Dữ liệu đặt lịch từ máy chủ không hợp lệ.',
      );
    }

    final data = Map<String, dynamic>.from(response);

    // Backend phải trả về đủ thông tin xác nhận đặt lịch.
    final maLichKham = data['maLichKham'];
    final maSoThuTu = data['maSoThuTu'];
    final soThuTu = data['soThuTu'];
    final maHoaDon = data['maHoaDon'];

    if (maLichKham == null ||
        maSoThuTu == null ||
        soThuTu == null ||
        maHoaDon == null) {
      throw const ApiException(
        'Máy chủ chưa trả về đầy đủ thông tin lịch khám.',
      );
    }

    // Chỉ quay lại màn hình trước sau khi API thành công.
    
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(
                booking: <String, dynamic>{
                    'maLichKham': maLichKham,
                    'maSoThuTu': maSoThuTu,
                    'soThuTu': soThuTu,
                    'maHoaDon': maHoaDon,
                    'tongTien': data['tongTien'],
                    'trangThaiLichKham': data['trangThaiLichKham'],
                    'trangThaiSoThuTu': data['trangThaiSoThuTu'],
                    'trangThaiHoaDon': data['trangThaiHoaDon'],
                    'message': data['message'] ?? 'Đặt lịch khám thành công.',
                'ngayKham': widget.ngayKham,
                'tenKhoa': widget.tenKhoa,
                'maKhoa': widget.maKhoa,
                'maBacSi': widget.maBacSi,
                'tenBacSi': widget.tenBacSi,
                'gioBatDau': widget.gioBatDau,
                'gioKetThuc': widget.gioKetThuc,
                'tenPhong': widget.tenPhong,
                'giaKham': data['tongTien'] ?? widget.giaKham,
                'lyDoKham': lyDoKham,
                },
            ),
        ),
    );

  } on ApiException catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xảy ra lỗi khi đặt lịch khám.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint('Lỗi đặt lịch khám: $e');
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        //foregroundColor: primary,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, size: 30),
        //   onPressed: () => Navigator.pop(context),
        // ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chọn thông tin khám',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.home_rounded,
        //       color: primary,
        //       size: 32,
        //     ),
        //     onPressed: () {
        //       Navigator.popUntil(context, (route) => route.isFirst);
        //     },
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
        children: [
          _buildStepper(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Ngày khám',
                  value: _formatDate(widget.ngayKham),
                ),
                _buildInfoRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Chuyên khoa',
                  value: widget.tenKhoa,
                ),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Giờ khám và phòng',
                  value:
                      '${widget.gioBatDau} - ${widget.gioKetThuc}, '
                      '${widget.tenPhong}',
                ),
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Bác sĩ',
                  value: widget.tenBacSi,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildReasonInput(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiền khám',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    _formatCurrency(widget.giaKham),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                    ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  //onPressed: _continueBooking,
                  onPressed: _isSubmitting ? null : _continueBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Text(
                //         'Tiếp tục',
                //         style: TextStyle(
                //           fontSize: 17,
                //           fontWeight: FontWeight.w700,
                //         ),
                //       ),
                //       SizedBox(width: 10),
                //       Icon(Icons.arrow_forward_rounded),
                //     ],
                //   ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                        ),
                    )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Text(
                            'Xác nhận đặt lịch',
                            style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded),
                        ],
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
