import 'package:flutter/material.dart';
import '../widgets/booking_stepper.dart';
import 'doctor_selection_screen.dart';

class DateSelectionScreen extends StatefulWidget {
  final int maKhoa;
  final String tenKhoa;
  final double giaKham;

  const DateSelectionScreen({
    super.key,
    required this.maKhoa,
    required this.tenKhoa,
    required this.giaKham,
  });

  @override
  State<DateSelectionScreen> createState() =>
      _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color disabledColor = Color(0xFFBFC7D2);
  static const Color availableColor = Color(0xFFDBEAFE);

  DateTime? _selectedDate;

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatApiDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final lastDate = DateTime(
      today.year + 1,
      today.month,
      today.day,
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
          ),
        ),
        title: const Text(
          'Đặt khám',
          style: TextStyle(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // const Text(
                //   'Chọn ngày khám',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.w800,
                //     color: textPrimary,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // const Text(
                //   'Chọn ngày bạn muốn đến bệnh viện. '
                //   'Bác sĩ sẽ được lọc theo lịch làm việc '
                //   'vào ngày này.',
                //   style: TextStyle(
                //     fontSize: 15,
                //     height: 1.5,
                //     color: textSecondary,
                //   ),
                // ),
                const SizedBox(height: 20),

                // Khoa đã chọn
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_hospital_outlined,
                        color: primary,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Chuyên khoa đã chọn',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.tenKhoa,
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Chú thích màu sắc
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chú thích ngày khám',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        color: disabledColor,
                        title: 'Ngày đã qua',
                        description: 'Màu xám - không thể chọn',
                      ),
                      const SizedBox(height: 10),
                      _buildLegendItem(
                        color: primary,
                        title: 'Hôm nay và các ngày tương lai',
                        description:
                            'Màu xanh biển - có thể chọn ngày',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Lịch chọn ngày
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: primary,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: textPrimary,
                          ),
                      datePickerTheme: DatePickerThemeData(
                        dayBackgroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.transparent;
                            }
                            if (states.contains(WidgetState.selected)) {
                              return primary;
                            }
                            return availableColor;
                          },
                        ),
                        dayForegroundColor:
                            WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return const Color(0xFFB0B8C4);
                            }
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return primary;
                          },
                        ),
                        todayForegroundColor:
                            WidgetStateProperty.all(primary),
                        todayBackgroundColor:
                            WidgetStateProperty.all(availableColor),
                        todayBorder: const BorderSide(
                          color: primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _selectedDate ?? today,
                      firstDate: today,
                      lastDate: lastDate,
                      currentDate: today,
                      onDateChanged: (date) {
                        setState(() {
                          _selectedDate = _dateOnly(date);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ngày đã chọn
                if (_selectedDate != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_available,
                          color: primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ngày khám đã chọn',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(_selectedDate!),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Bỏ chọn ngày',
                          onPressed: () {
                            setState(() => _selectedDate = null);
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                // const SizedBox(height: 8),
                // Text(
                //   'Bạn có thể chọn ngày từ hôm nay đến '
                //   '${_formatDate(lastDate)}.',
                //   style: const TextStyle(
                //     color: textSecondary,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE8EEF5)),
            ),
          ),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              
              onPressed: _selectedDate == null
                  ? null
                  : () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorSelectionScreen(
                            maKhoa: widget.maKhoa,
                            tenKhoa: widget.tenKhoa,
                            ngayKham: _formatApiDate(_selectedDate!),
                            giaKham: widget.giaKham,
                          ),
                        ),
                      );

                      if (!mounted || result == null) return;

                      // Nhận lại dữ liệu khi quay về nếu cần sử dụng sau.
                      debugPrint('Bác sĩ đã chọn: ${result['hoTenBacSi']}');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Tiếp tục  →',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            color == primary ? Icons.check : Icons.close,
            size: 14,
            color: color == primary ? Colors.white : Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return const BookingStepper(currentStep: 1);
  }

}