
import 'package:flutter/material.dart';

import '../models/doctor_model.dart';
import '../services/booking_service.dart';
import '../widgets/booking_stepper.dart';
import 'doctor_detail_screen.dart';
import 'booking_confirmation_screen.dart';

class DoctorSelectionScreen extends StatefulWidget {
  final int maKhoa;
  final String tenKhoa;
  final String ngayKham;
  final double giaKham;

  const DoctorSelectionScreen({
    super.key,
    required this.maKhoa,
    required this.tenKhoa,
    required this.ngayKham,
    required this.giaKham,
  });

  @override
  State<DoctorSelectionScreen> createState() =>
      _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState
    extends State<DoctorSelectionScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);

  final BookingService _service = BookingService();

  List<DoctorModel> _doctors = [];
  DoctorModel? _selectedDoctor;

  final Map<int, List<Map<String, dynamic>>> _slotsByDoctor = {};
  final Set<int> _expandedDoctors = {};
  final Map<int, bool> _loadingSlots = {};

  int? _selectedDoctorId;
  String? _selectedStartTime;
  String? _selectedEndTime;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result =
          await _service.getDoctorsByDepartmentAndDate(
        maKhoa: widget.maKhoa,
        ngayKham: widget.ngayKham,
      );

      debugPrint('===== DANH SÁCH BÁC SĨ =====');

      for (final doctor in result) {
        debugPrint(
          'Bác sĩ: ${doctor.hoTen} | '
          'Mã lịch: ${doctor.maLichLamViec} | '
          'Mã phòng: ${doctor.maPhong} | '
          'Tên phòng: ${doctor.tenPhong} |'
          'Chứng chỉ: ${doctor.soChungChiHanhNghe} | '
          'Ảnh: ${doctor.fileKey}',
        );
      }
      if (!mounted) return;

      setState(() {
        _doctors = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'Không thể tải danh sách bác sĩ. '
            'Vui lòng kiểm tra kết nối hoặc API backend.';
      });
    }
  }

  String _formatDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return value;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  // =====================================
  // LẤY KHUNG GIỜ
  // =====================================
  Future<void> _loadSlots(DoctorModel doctor) async {
    final doctorId = doctor.maBacSi;

    if (_slotsByDoctor.containsKey(doctorId)) return;

    setState(() {
      _loadingSlots[doctorId] = true;
    });

    try {
      final slots = await _service.getTimeSlots(
        maBacSi: doctorId,
        ngayKham: widget.ngayKham,
      );

      if (!mounted) return;

      setState(() {
        _slotsByDoctor[doctorId] = slots;
        _loadingSlots[doctorId] = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingSlots[doctorId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải khung giờ khám.'),
        ),
      );
    }
  }

  // =======================================
  // BÁC SĨ VÀ CHỌN GIỜ
  // =======================================
  Future<void> _toggleDoctor(DoctorModel doctor) async {
    final id = doctor.maBacSi;

    if (_expandedDoctors.contains(id)) {
      setState(() {
        _expandedDoctors.remove(id);
      });
      return;
    }

    setState(() {
      _expandedDoctors.add(id);
      _selectedDoctor = doctor;
    });

    await _loadSlots(doctor);
  }

  void _selectSlot(
    DoctorModel doctor,
    Map<String, dynamic> slot,
  ) {

    debugPrint('===== KHUNG GIỜ ĐƯỢC CHỌN =====');
    debugPrint('Bác sĩ: ${doctor.hoTen}');
    debugPrint('maBacSi: ${doctor.maBacSi}');
    debugPrint('maLichLamViec: ${doctor.maLichLamViec}');
    debugPrint('Khung giờ: ${slot['gioBatDau']} - ${slot['gioKetThuc']}');
    debugPrint('Dữ liệu slot: $slot');

    if (slot['hetCho'] == true) return;

    final remaining =
        int.tryParse('${slot['conTrong']}') ?? 0;

    if (remaining <= 0) return;

    setState(() {
      _selectedDoctor = doctor;
      _selectedDoctorId = doctor.maBacSi;
      _selectedStartTime = '${slot['gioBatDau']}';
      _selectedEndTime = '${slot['gioKetThuc']}';
    });
  }

  // Ngày khám được truyền từ màn hình trước theo dạng yyyy-MM-dd.
  // Dùng ngày này để so sánh giờ khám, không dùng ngày hiện tại mặc định.
  DateTime get _bookingDate {
    return DateTime.tryParse(widget.ngayKham) ?? DateTime.now();
  }

  // =====================================
  // KIỂM TRA GIỜ 
  // =====================================
  bool _isPastTime(String gioBatDau) {
    final parts = gioBatDau.split(':');

    if (parts.length < 2) return false;

    final now = DateTime.now();

    final slotTime = DateTime(
      _bookingDate.year,
      _bookingDate.month,
      _bookingDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    return !slotTime.isAfter(now);
  }

  // ============================================
  // HIỂN THỊ CẢNH BÁO KHUNG GIỜ
  // ============================================
  void _showSlotWarning(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thông báo'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // ========================================
  // BUILD
  // ========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
          ),
        ),
        title: const Text(
          'Chọn bác sĩ',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFBFDBFE),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      color: primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.tenKhoa,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ngày khám: ${_formatDate(widget.ngayKham)}',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _buildDoctorList()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _selectedDoctor == null ||
                  _selectedStartTime == null ||
                  _selectedEndTime == null
                  ? null
                  : _continueBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor:
                    const Color(0xFFCBD5E1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Tiếp tục →',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
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
                size: 48,
                color: Color(0xFF64748B),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadDoctors,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_doctors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 56,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 12),
              Text(
                'Không có bác sĩ làm việc tại khoa '
                'này vào ngày đã chọn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _doctors.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doctor = _doctors[index];
        final expanded = _expandedDoctors.contains(doctor.maBacSi);
        final selected = _selectedDoctor?.maBacSi == doctor.maBacSi;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? primary : const Color(0xFFE2E8F0),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 56,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 36,
                    color: primary,
                  ),
                ),
                title: Text(
                  doctor.hoTen,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((doctor.trinhDo ?? '').isNotEmpty)
                        Text(doctor.trinhDo!),

                      if ((doctor.chuyenMon ?? '').isNotEmpty)
                        Text(doctor.chuyenMon!),

                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.meeting_room_outlined,
                            size: 17,
                            color: primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              (doctor.tenPhong ?? '').trim().isNotEmpty
                                  ? 'Phòng khám: ${doctor.tenPhong}'
                                  : 'Chưa có thông tin phòng khám',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onTap: () => _toggleDoctor(doctor),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorDetailScreen(
                            maBacSi: doctor.maBacSi,
                            maKhoa: widget.maKhoa,
                            tenBacSi: doctor.hoTen,
                            trinhDo: doctor.trinhDo,
                            chuyenMon: doctor.chuyenMon,
                            soChungChiHanhNghe: doctor.soChungChiHanhNghe,
                            fileKey: doctor.fileKey,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Thông tin bác sĩ'),
                  ),
                ),
              ),

              if (expanded) _buildTimeSlots(doctor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepper() {
    return const BookingStepper(currentStep: 2);
  }


  void _continueBooking() {
    final doctor = _selectedDoctor;

    if (doctor == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn bác sĩ và khung giờ khám.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          maLichLamViec: doctor.maLichLamViec,
          maKhoa: widget.maKhoa,
          ngayKham: widget.ngayKham,
          tenKhoa: widget.tenKhoa,
          maBacSi: doctor.maBacSi,
          tenBacSi: doctor.hoTen,
          gioBatDau: _selectedStartTime!,
          gioKetThuc: _selectedEndTime!,
          tenPhong: doctor.tenPhong ?? 'Chưa xác định',
          giaKham: widget.giaKham,
        ),
      ),
    );
  }

  // =====================================
  // =====================================
  Widget _buildTimeSlots(DoctorModel doctor) {
  final id = doctor.maBacSi;

  if (_loadingSlots[id] == true) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  final slots = _slotsByDoctor[id] ?? [];

  if (slots.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Bác sĩ chưa có khung giờ khám trong ngày này.',
        style: TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KHUNG GIỜ KHÁM',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 78,
          ),
          itemBuilder: (context, index) {
            final slot = slots[index];
            final full = slot['hetCho'] == true;
            final start = '${slot['gioBatDau']}';
            final end = '${slot['gioKetThuc']}';
            final remaining =
                int.tryParse('${slot['conTrong']}') ?? 0;

            // Kiểm tra khung giờ đã qua hay chưa.
          final parts = start.split(':');
          var pastTime = false;

          if (parts.length >= 2) {
            final now = DateTime.now();

            final hour = int.tryParse(parts[0]);
            final minute = int.tryParse(parts[1]);

            if (hour != null && minute != null) {
              final slotTime = DateTime(
                _bookingDate.year,
                _bookingDate.month,
                _bookingDate.day,
                hour,
                minute,
              );

              pastTime = !slotTime.isAfter(now);
            }
          }

          final unavailable = full || remaining <= 0 || pastTime;
          
            final selected =
                _selectedDoctorId == id &&
                _selectedStartTime == start &&
                _selectedEndTime == end;

            // return InkWell(
            //   onTap: full
            //       ? null
            //       : () => _selectSlot(doctor, slot),
            //   borderRadius: BorderRadius.circular(12),
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: full
            //           ? const Color(0xFFF1F5F9)
            //           : selected
            //               ? const Color(0xFFDBEAFE)
            //               : Colors.white,
            //       borderRadius: BorderRadius.circular(12),
            //       border: Border.all(
            //         color: selected
            //             ? const Color(0xFF2563EB)
            //             : const Color(0xFFE2E8F0),
            //         width: selected ? 2 : 1,
            //       ),
            //     ),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text(
            //           '$start - $end',
            //           style: TextStyle(
            //             fontWeight: FontWeight.w700,
            //             color: full
            //                 ? const Color(0xFF94A3B8)
            //                 : const Color(0xFF1E293B),
            //           ),
            //         ),
            //         const SizedBox(height: 5),
            //         Text(
            //           full ? 'Hết chỗ' : 'Còn $remaining/10 chỗ',
            //           style: TextStyle(
            //             fontSize: 12,
            //             color: full
            //                 ? const Color(0xFF94A3B8)
            //                 : const Color(0xFF2563EB),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // );

            return InkWell(
              onTap: () {
                if (pastTime) {
                  _showSlotWarning(
                    'Đã qua khung giờ đó không thể đặt được',
                  );
                  return;
                }

                if (full || remaining <= 0) {
                  _showSlotWarning(
                    'Đã hết số cho khung giờ này. '
                    'Vui lòng chọn khung giờ khác.',
                  );
                  return;
                }

                _selectSlot(doctor, slot);
              },
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: unavailable ? 0.55 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: unavailable
                        ? const Color(0xFFF1F5F9)
                        : selected
                            ? const Color(0xFFDBEAFE)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$start - $end',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: unavailable
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        pastTime
                            ? 'Đã qua giờ'
                            : (full || remaining <= 0)
                                ? 'Hết số'
                                : 'Còn $remaining/10 chỗ',
                        style: TextStyle(
                          fontSize: 12,
                          color: unavailable
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
}
