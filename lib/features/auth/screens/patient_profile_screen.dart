import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import 'registration_success_screen.dart';

// ============================================
// TRANG TẠO HỒ SƠ BỆNH NHÂN
// ============================================

class PatientProfileScreen extends StatefulWidget {
  final String email;
  final String password;

  const PatientProfileScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient.instance;

  // Controllers
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  // Dữ liệu tỉnh/thành phố và phường/xã
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _wards = [];

  Map<String, dynamic>? _selectedProvince;
  Map<String, dynamic>? _selectedWard;

  bool _loadingProvinces = false;
  bool _loading = false;

  String? _addressError;
  DateTime? _dateOfBirth;
  String? _gender;

  // Màu giao diện MedCare
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    _emergencyPhoneController.dispose();
    _medicalHistoryController.dispose();

    super.dispose();
  }

  // ============================================
  // TẢI DANH SÁCH TỈNH/THÀNH PHỐ
  // ============================================
  Future<void> _loadProvinces() async {
    setState(() {
      _loadingProvinces = true;
      _addressError = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://provinces.open-api.vn/api/v2/?depth=2'))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Không tải được danh sách tỉnh/thành phố.');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is! List) {
        throw Exception('Dữ liệu địa chỉ không hợp lệ.');
      }

      final provinces = decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      provinces.sort(
        (a, b) => (a['name'] ?? '').toString().compareTo(
          (b['name'] ?? '').toString(),
        ),
      );

      if (!mounted) return;

      setState(() {
        _provinces = provinces;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _addressError =
            'Không tải được danh sách địa chỉ. '
            'Vui lòng kiểm tra Internet và thử lại.';
      });

      debugPrint('Load provinces error: $error');
    } finally {
      if (mounted) {
        setState(() {
          _loadingProvinces = false;
        });
      }
    }
  }

  // ============================================
  // CHỌN TỈNH/THÀNH PHỐ
  // ============================================
  void _onProvinceChanged(Map<String, dynamic>? province) {
    setState(() {
      _selectedProvince = province;
      _selectedWard = null;
      _wards = [];

      if (province == null) return;

      final wardsData = province['wards'];

      if (wardsData is List) {
        _wards = wardsData
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        _wards.sort(
          (a, b) => (a['name'] ?? '').toString().compareTo(
            (b['name'] ?? '').toString(),
          ),
        );
      }
    });
  }

  // ============================================
  // GHÉP ĐỊA CHỈ
  // ============================================
  String _buildAddress() {
    final parts = <String>[
      _addressController.text.trim(),
      _selectedWard?['name']?.toString() ?? '',
      _selectedProvince?['name']?.toString() ?? '',
    ].where((part) => part.isNotEmpty).toList();

    return parts.join(', ');
  }

  // ============================================
  // NGÀY SINH
  // ============================================
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dateOfBirth = selectedDate;
      });
    }
  }

  // ============================================
  // THÔNG BÁO
  // ============================================
  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color(0xFFDC2626)
              : const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _extractError(dynamic error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  // ============================================
  // KIỂM TRA DỮ LIỆU
  // ============================================
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại.';
    }

    final phone = value.trim();

    if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone)) {
      return 'Số điện thoại không hợp lệ.';
    }

    return null;
  }

  String? _validateEmergencyPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
        return null;
    }

    final phone = value.trim();

    if (!RegExp(r'^(0|\+84)[0-9]{9,10}$').hasMatch(phone)) {
        return 'Số điện thoại khẩn cấp không hợp lệ.';
    }

    return null;
  }

  // ============================================
  // GỬI THÔNG TIN ĐĂNG KÝ
  // ============================================
  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      _showMessage('Vui lòng chọn ngày sinh.', isError: true);
      return;
    }

    if (_gender == null) {
      _showMessage('Vui lòng chọn giới tính.', isError: true);
      return;
    }

    if (_selectedProvince == null) {
      _showMessage('Vui lòng chọn tỉnh/thành phố.', isError: true);
      return;
    }

    if (_selectedWard == null) {
      _showMessage('Vui lòng chọn phường/xã.', isError: true);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final response = await _apiClient.post(
        '/api/auth/register',
        body: {
          'email': widget.email.trim().toLowerCase(),
          'tenDangNhap': _usernameController.text.trim(),
          'matKhau': widget.password,
          'hoTen': _fullNameController.text.trim(),
          'soDienThoai': _phoneController.text.trim(),
          'ngaySinh': _dateOfBirth!.toIso8601String().split('T').first,
          'gioiTinh': _gender,
          'diaChi': _buildAddress(),
          'soDienThoaiKhanCap':
            _emergencyPhoneController.text.trim().isEmpty
                ? null
                : _emergencyPhoneController.text.trim(),

        'tienSuBenh':
            _medicalHistoryController.text.trim().isEmpty
                ? null
                : _medicalHistoryController.text.trim(),
        },
      );

      if (!mounted) return;

      if (response is Map &&
          (response['success'] == true ||
              response['MaNguoiDung'] != null ||
              response['maNguoiDung'] != null)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationSuccessScreen(email: widget.email),
          ),
        );
      } else {
        final message = response is Map
            ? (response['message'] ??
                  response['error'] ??
                  'Đăng ký chưa thành công. Vui lòng thử lại.')
            : 'Đăng ký chưa thành công. Vui lòng thử lại.';

        _showMessage(message.toString(), isError: true);
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Không thể đăng ký tài khoản: '
        '${_extractError(error)}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================
  // Ô NHẬP LIỆU DÙNG CHUNG
  // ============================================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: textColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: secondaryText, size: 20),
        labelStyle: const TextStyle(color: secondaryText),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
    );
  }

  // ============================================
  // CHỌN TỈNH/THÀNH PHỐ HOẶC PHƯỜNG/XÃ CÓ TÌM KIẾM
  // ============================================
  Future<Map<String, dynamic>?> _showAddressPicker({
    required String title,
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? selectedItem,
  }) async {
    final searchController = TextEditingController();

      return await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              final keyword = searchController.text.trim().toLowerCase();

              final filteredItems = items.where((item) {
                final name = (item['name'] ?? '').toString().toLowerCase();

                return name.contains(keyword);
              }).toList();

              return Theme(
                data: ThemeData.light().copyWith(
                  scaffoldBackgroundColor: Colors.white,
                  colorScheme: const ColorScheme.light(
                    primary: primary,
                    surface: Colors.white,
                    onSurface: textColor,
                  ),
                ),
                child: SizedBox(
                  height: MediaQuery.of(sheetContext).size.height * 0.75,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                //Navigator.pop(sheetContext);
                                Navigator.of(sheetContext).pop();
                              },
                              icon: const Icon(
                                Icons.close,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (_) {
                            setSheetState(() {});
                          },
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 14,
                          ),
                          cursorColor: primary,
                          decoration: InputDecoration(
                            hintText: 'Nhập tên để tìm kiếm...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: secondaryText,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setSheetState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      color: secondaryText,
                                    ),
                                  )
                                : null,
                            filled: true,
                            fillColor: background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filteredItems.length} kết quả',
                            style: const TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredItems.isEmpty
                            ? const Center(
                                child: Text(
                                  'Không tìm thấy kết quả phù hợp.',
                                  style: TextStyle(color: secondaryText),
                                ),
                              )
                            : ListView.separated(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: filteredItems.length,
                                separatorBuilder: (_, _) => const Divider(
                                  height: 1,
                                  color: borderColor,
                                ),
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];

                                  final isSelected =
                                      selectedItem?['code'] == item['code'];

                                  return ListTile(
                                    tileColor: Colors.white,
                                    title: Text(
                                      (item['name'] ?? '').toString(),
                                      style: TextStyle(
                                        color: isSelected ? primary : textColor,
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: primary,
                                          )
                                        : null,
                                    onTap: () {
                                      //Navigator.pop(sheetContext, item);
                                      Navigator.of(sheetContext).pop(item);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    //  finally {
    //   searchController.dispose();
    // }
  }

  // ============================================
  // Ô CHỌN ĐỊA CHỈ
  // ============================================
  Widget _buildAddressDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic>? selectedItem,
    required ValueChanged<Map<String, dynamic>?> onChanged,
    bool isLoading = false,
  }) {
    return FormField<Map<String, dynamic>>(
      validator: (_) {
        if (selectedItem == null) {
          return 'Vui lòng chọn $label.';
        }

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isLoading || items.isEmpty
                  ? null
                  : () async {
                      final selected = await _showAddressPicker(
                        title: label,
                        items: items,
                        selectedItem: selectedItem,
                      );

                      if (selected != null && mounted) {
                        onChanged(selected);
                        field.didChange(selected);
                      }
                    },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon, color: secondaryText, size: 20),
                  suffixIcon: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primary,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.keyboard_arrow_down,
                          color: secondaryText,
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  errorText: field.errorText,
                ),
                child: Text(
                  selectedItem?['name']?.toString() ?? hint,
                  style: TextStyle(
                    color: selectedItem == null
                        ? const Color(0xFF94A3B8)
                        : textColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Đang tải danh sách địa chỉ...',
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  // ============================================
  // TIÊU ĐỀ NHÓM THÔNG TIN
  // ============================================
  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: secondaryText, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // THẺ CHỨA NỘI DUNG
  // ============================================
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================
  // CHỌN GIỚI TÍNH
  // ============================================
  Widget _buildGenderSelector() {
    return DropdownButtonFormField<String>(
      //value: _gender,
      initialValue: _gender,    
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: secondaryText,
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(
        color: textColor,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: 'Giới tính',
        hintText: 'Chọn giới tính',
        prefixIcon: const Icon(
          Icons.person_outline,
          color: secondaryText,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
          ),
        ),
      ),
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
          _gender = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn giới tính.';
        }
        return null;
      },
    );
  }

  // ============================================
  // NÚT CHỌN NGÀY SINH
  // ============================================
  Widget _buildDateOfBirthField() {
    return FormField<DateTime>(
      validator: (_) {
        if (_dateOfBirth == null) {
          return 'Vui lòng chọn ngày sinh.';
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await _selectDateOfBirth();
                field.didChange(_dateOfBirth);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: secondaryText,
                  ),
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: secondaryText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  errorText: field.errorText,
                ),
                child: Text(
                  _dateOfBirth == null
                      ? 'Chọn ngày/tháng/năm'
                      : _formatDate(_dateOfBirth!),
                  style: TextStyle(
                    color: _dateOfBirth == null
                        ? const Color(0xFF94A3B8)
                        : textColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // BUILD GIAO DIỆN CHÍNH
  // ============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hoàn thiện hồ sơ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: borderColor),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Phần giới thiệu
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medical_information_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào mừng đến MedCare',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Vui lòng cung cấp thông tin '
                            'để hoàn thiện hồ sơ bệnh nhân.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Thông tin tài khoản
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      icon: Icons.account_circle_outlined,
                      title: 'Thông tin tài khoản',
                      subtitle: 'Thông tin đăng nhập hệ thống',
                    ),
                    const SizedBox(height: 22),
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Tên đăng nhập',
                      hint: 'Nhập tên đăng nhập',
                      icon: Icons.person_outline,
                      validator: (value) =>
                          _validateRequired(value, 'tên đăng nhập'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: widget.email,
                      readOnly: true,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: secondaryText,
                        ),
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Thông tin cá nhân
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      subtitle: 'Thông tin cơ bản của bệnh nhân',
                    ),
                    const SizedBox(height: 22),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Họ và tên',
                      hint: 'Nhập họ và tên đầy đủ',
                      icon: Icons.badge_outlined,
                      validator: (value) =>
                          _validateRequired(value, 'họ và tên'),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      hint: 'Ví dụ: 0912345678',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Số điện thoại khẩn cấp',
                    hint: 'Số điện thoại người thân',
                    icon: Icons.emergency_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _validateEmergencyPhone,
                    ),

                    const SizedBox(height: 8),

                    const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                        'Không bắt buộc. Dùng để liên hệ người thân khi cần.',
                        style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        ),
                    ),
                    ),
                    
                    const SizedBox(height: 16),

                    _buildTextField(
                    controller: _medicalHistoryController,
                    label: 'Tiền sử bệnh',
                    hint: 'Ví dụ: hen suyễn, dị ứng thuốc...',
                    icon: Icons.medical_information_outlined,
                    maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _buildDateOfBirthField(),
                    const SizedBox(height: 20),
                    _buildGenderSelector(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Địa chỉ
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ liên hệ',
                      subtitle: 'Chọn tỉnh/thành phố và phường/xã',
                    ),
                    const SizedBox(height: 22),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Địa chỉ cụ thể',
                      hint: 'Số nhà, tên đường, khu phố...',
                      icon: Icons.home_outlined,
                      validator: (value) =>
                          _validateRequired(value, 'địa chỉ cụ thể'),
                    ),
                    const SizedBox(height: 16),
                    _buildAddressDropdown(
                      label: 'Tỉnh/Thành phố',
                      hint: _loadingProvinces
                          ? 'Đang tải dữ liệu...'
                          : 'Chọn tỉnh/thành phố',
                      icon: Icons.location_city_outlined,
                      items: _provinces,
                      selectedItem: _selectedProvince,
                      isLoading: _loadingProvinces,
                      onChanged: _onProvinceChanged,
                    ),
                    const SizedBox(height: 16),
                    _buildAddressDropdown(
                      label: 'Phường/Xã',
                      hint: _selectedProvince == null
                          ? 'Vui lòng chọn tỉnh/thành phố trước'
                          : 'Chọn phường/xã',
                      icon: Icons.place_outlined,
                      items: _wards,
                      selectedItem: _selectedWard,
                      onChanged: (ward) {
                        setState(() {
                          _selectedWard = ward;
                        });
                      },
                    ),
                    if (_addressError != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _addressError!,
                              style: const TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadProvinces,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nút đăng ký
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: const Color(0xFF93C5FD),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline),
                            SizedBox(width: 10),
                            Text(
                              'Hoàn tất đăng ký',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 15, color: secondaryText),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Thông tin của bạn được sử dụng để '
                      'quản lý hồ sơ khám chữa bệnh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// PREVIEW
// ============================================
@Preview(name: 'Patient Profile Screen')
Widget patientProfileScreenPreview() {
  return const MaterialApp(
    home: PatientProfileScreen(
      email: 'patient@example.com',
      password: 'DemoPassword123',
    ),
  );
}
