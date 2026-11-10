import 'package:flutter/material.dart';

import '../../../core/providers/patient_profile_manager.dart';

class AddPatientProfileScreen extends StatefulWidget {
  const AddPatientProfileScreen({super.key});

  @override
  State<AddPatientProfileScreen> createState() =>
      _AddPatientProfileScreenState();
}

class _AddPatientProfileScreenState
    extends State<AddPatientProfileScreen> {
  static const Color primary = Color(0xFF2563EB);

  final _formKey = GlobalKey<FormState>();

  final _hoTenController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _tienSuBenhController = TextEditingController();

  String _moiQuanHe = 'Con';
  String? _gioiTinh;
  DateTime? _ngaySinh;

  bool _isSaving = false;

  final Map<String, String> _relationships = {
    'BanThan': 'Bản thân',
    'VoChong': 'Vợ / Chồng',
    'Con': 'Con',
    'ChaMe': 'Cha / Mẹ',
    'AnhChiEm': 'Anh / Chị / Em',
    'Khac': 'Khác',
  };

  @override
  void dispose() {
    _hoTenController.dispose();
    _diaChiController.dispose();
    _soDienThoaiController.dispose();
    _tienSuBenhController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
    );

    if (selected != null) {
      setState(() => _ngaySinh = selected);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await PatientProfileManager.instance.createProfile(
        hoTen: _hoTenController.text.trim(),
        moiQuanHe: _moiQuanHe,
        ngaySinh: _ngaySinh == null
            ? null
            : '${_ngaySinh!.year}-'
                '${_ngaySinh!.month.toString().padLeft(2, '0')}-'
                '${_ngaySinh!.day.toString().padLeft(2, '0')}',
        gioiTinh: _gioiTinh,
        diaChi: _diaChiController.text.trim(),
        soDienThoaiKhanCap: _soDienThoaiController.text.trim(),
        tienSuBenh: _tienSuBenhController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo hồ sơ bệnh nhân thành công.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF059669),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tạo hồ sơ: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primary),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text(
          'Thêm hồ sơ bệnh nhân',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primary,
                    size: 25,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn có thể tạo hồ sơ cho người thân để đặt lịch '
                      'và theo dõi thông tin khám chữa bệnh trên cùng '
                      'một tài khoản.',
                      style: TextStyle(
                        color: Color(0xFF1E40AF),
                        height: 1.45,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _buildSectionTitle('Thông tin cá nhân'),

            TextFormField(
              controller: _hoTenController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration(
                'Họ và tên *',
                Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập họ và tên.';
                }
                return null;
              },
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: _moiQuanHe,
              decoration: _decoration(
                'Mối quan hệ *',
                Icons.people_outline,
              ),
              items: _relationships.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _moiQuanHe = value);
                }
              },
            ),

            const SizedBox(height: 14),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: _decoration(
                  'Ngày sinh',
                  Icons.calendar_month_outlined,
                ),
                child: Text(
                  _ngaySinh == null
                      ? 'Chọn ngày sinh'
                      : _formatDate(_ngaySinh!),
                  style: TextStyle(
                    color: _ngaySinh == null
                        ? Colors.grey.shade600
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
                initialValue: _gioiTinh, 
                decoration: _decoration(
                    'Giới tính',
                    Icons.wc_outlined,
                ),
                hint: const Text('Chọn giới tính'),
                items: const [
                    DropdownMenuItem(
                    value: 'Nam',
                    child: Text('Nam'),
                    ),
                    DropdownMenuItem(
                    value: 'Nữ',
                    child: Text('Nữ'),
                    ),
                    DropdownMenuItem(
                    value: 'Khác',
                    child: Text('Khác'),
                    ),
                ],
                onChanged: (value) {
                    setState(() {
                    _gioiTinh = value;
                    });
                },
                ),

            const SizedBox(height: 22),

            _buildSectionTitle('Thông tin liên hệ'),

            TextFormField(
              controller: _diaChiController,
              maxLines: 2,
              decoration: _decoration(
                'Địa chỉ',
                Icons.location_on_outlined,
              ),
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: _soDienThoaiController,
              keyboardType: TextInputType.phone,
              decoration: _decoration(
                'Số điện thoại khẩn cấp',
                Icons.phone_outlined,
              ),
            ),

            const SizedBox(height: 22),

            _buildSectionTitle('Thông tin sức khỏe'),

            TextFormField(
              controller: _tienSuBenhController,
              maxLines: 4,
              decoration: _decoration(
                'Tiền sử bệnh',
                Icons.medical_information_outlined,
              ).copyWith(
                hintText: 'Nhập tiền sử bệnh nếu có...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Tạo hồ sơ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}