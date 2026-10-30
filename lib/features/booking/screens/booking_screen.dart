import 'package:flutter/material.dart';

import '../models/department_model.dart';
import '../services/booking_service.dart';
import '../widgets/booking_stepper.dart';
import 'date_selection_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  final BookingService _service = BookingService();
  final TextEditingController _searchController = TextEditingController();

  List<DepartmentModel> _departments = [];
  DepartmentModel? _selectedDepartment;

  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final result = await _service.getDepartments();

      if (!mounted) return;

      setState(() {
        _departments = result;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Không thể tải danh sách khoa. '
            'Vui lòng kiểm tra kết nối Backend.';
      });
    }
  }

  List<DepartmentModel> get _filteredDepartments {
    final keyword = _search.trim().toLowerCase();

    if (keyword.isEmpty) return _departments;

    return _departments.where((department) {
      return department.tenKhoa.toLowerCase().contains(keyword) ||
          (department.moTa ?? '').toLowerCase().contains(keyword);
    }).toList();
  }

  IconData _departmentIcon(String name) {
    final value = name.toLowerCase();

    if (value.contains('nội')) return Icons.apartment_rounded;
    if (value.contains('ngoại')) return Icons.content_cut_rounded;
    if (value.contains('tim')) return Icons.favorite_border_rounded;
    if (value.contains('thần kinh')) return Icons.auto_awesome;
    if (value.contains('tai') || value.contains('mũi')) {
      return Icons.mic_none_rounded;
    }
    if (value.contains('da liễu')) return Icons.wb_sunny_outlined;

    return Icons.local_hospital_outlined;
  }

  Color _departmentColor(int index) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF059669),
      Color(0xFFF43F5E),
      Color(0xFF0284C7),
      Color(0xFF0D9488),
      Color(0xFFF59E0B),
    ];

    return colors[index % colors.length];
  }

  String _description(DepartmentModel department) {
    final description = department.moTa?.trim();

    if (description != null && description.isNotEmpty) {
      return description;
    }

    return 'Khám và điều trị tại ${department.tenKhoa}';
  }

  String _formatGiaKham(double giaKham) {
  final amount = giaKham.toStringAsFixed(0);
  final formatted = amount.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  return '$formatted đ';
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đặt khám',
          style: TextStyle(
            color: textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepper(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm chuyên khoa...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 30,
                  color: Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: const Color(0xFFEDF2F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildDepartmentList()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFE8EEF5)),
            ),
          ),
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              onPressed: _selectedDepartment == null
                  ? null
                  : _continueBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                foregroundColor: Colors.white,
                elevation: 2,
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

  Widget _buildStepper() {
    return const BookingStepper(currentStep: 0);
  }




  Widget _buildDepartmentList() {
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
                color: textSecondary,
              ),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _loading = true);
                  _loadDepartments();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final departments = _filteredDepartments;

    if (departments.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy chuyên khoa phù hợp.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: departments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      //separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final department = departments[index];
        final selected =
            _selectedDepartment?.maKhoa == department.maKhoa;
        final color = _departmentColor(index);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () {
              setState(() => _selectedDepartment = department);
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 126),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF5B91FF)
                      : const Color(0xFFF1F5F9),
                  width: selected ? 1.8 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 76,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Icon(
                      _departmentIcon(department.tenKhoa),
                      size: 38,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                department.tenKhoa,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatGiaKham(department.giaKham),
                              style: const TextStyle(
                                color: primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        // mô tả khoa
                        const SizedBox(height: 6),
                        Text(
                          _description(department),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.chevron_right_rounded,
                    size: 30,
                    color: selected
                        ? primary
                        : const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

Future<void> _continueBooking() async {
  final department = _selectedDepartment;
  if (department == null) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DateSelectionScreen(
        maKhoa: department.maKhoa,
        tenKhoa: department.tenKhoa,
        giaKham: department.giaKham,
      ),
    ),
  );
}

}