
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/patient_profile_manager.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState
    extends State<ProfileInformationScreen> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> patientInfo = {};

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiClient.instance.getCurrentUser();

      final rawProfiles = result['DanhSachBenhNhan'] ??
          result['danhSachBenhNhan'];

      Map<String, dynamic> selectedPatient = {};

      if (rawProfiles is List && rawProfiles.isNotEmpty) {
        final selectedId =
            PatientProfileManager.instance.selectedPatientId;

        final profiles = rawProfiles
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        // Ưu tiên hồ sơ đang được người dùng chọn.
        if (selectedId != null) {
          for (final profile in profiles) {
            final id = int.tryParse(
              (profile['MaBenhNhan'] ??
                      profile['maBenhNhan'] ??
                      '')
                  .toString(),
            );

            if (id == selectedId) {
              selectedPatient = profile;
              break;
            }
          }
        }

        // Nếu không tìm thấy hồ sơ đang chọn,
        // lấy hồ sơ mặc định.
        if (selectedPatient.isEmpty) {
          for (final profile in profiles) {
            final value = profile['LaHoSoMacDinh'] ??
                profile['laHoSoMacDinh'];

            final isDefault = value == true ||
                value.toString() == '1' ||
                value.toString().toLowerCase() == 'true';

            if (isDefault) {
              selectedPatient = profile;
              break;
            }
          }
        }

        // Nếu không có hồ sơ mặc định thì lấy hồ sơ đầu tiên.
        if (selectedPatient.isEmpty && profiles.isNotEmpty) {
          selectedPatient = profiles.first;
        }
      }

      if (!mounted) return;

      setState(() {
        userInfo = result;
        patientInfo = selectedPatient;
        isLoading = false;
      });

      debugPrint('===== THÔNG TIN TÀI KHOẢN =====');
      debugPrint('$userInfo');

      debugPrint('===== HỒ SƠ BỆNH NHÂN ĐANG CHỌN =====');
      debugPrint('$patientInfo');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Không thể tải thông tin cá nhân.';
      });

      debugPrint('Lỗi tải thông tin cá nhân: $e');
    }
  }

  String _getValue(List<String> keys) {
    for (final key in keys) {
      final value = userInfo[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return 'Chưa cập nhật';
  }

  String _getPatientValue(List<String> keys) {
    for (final key in keys) {
      final value = patientInfo[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return 'Chưa cập nhật';
  }

  String _formatPatientDate(String value) {
    if (value == 'Chưa cập nhật') return value;

    try {
      final date = DateTime.parse(value);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _getPatientValue([
      'HoTen',
      'hoTen',
    ]);

    final avatarUrl = _getValue([
      'anhDaiDien',
      'AnhDaiDien',
    ]);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: 'Quay lại',
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 54,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadUserInfo,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserInfo,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Thông tin tài khoản
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor:
                                    const Color(0xFFDBEAFE),
                                backgroundImage:
                                    avatarUrl != 'Chưa cập nhật' &&
                                            (avatarUrl.startsWith('http://') ||
                                             avatarUrl.startsWith('https://'))
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                child: avatarUrl == 'Chưa cập nhật' ||
                                        (!avatarUrl.startsWith('http://') &&
                                         !avatarUrl.startsWith('https://'))
                                    ? const Icon(
                                        Icons.person,
                                        size: 46,
                                        color: primaryColor,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              fullName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Thông tin tài khoản của bạn',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Padding(
                        padding: EdgeInsets.only(
                          left: 4,
                          bottom: 10,
                        ),
                        child: Text(
                          'THÔNG TIN CHI TIẾT',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoItem(
                              icon: Icons.person_outline,
                              title: 'Họ và tên',
                              value: fullName,
                            ),
                            const Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 16,
                            ),
                            _buildInfoItem(
                              icon: Icons.phone_outlined,
                              title: 'Số điện thoại',
                              value: _getValue([
                                'soDienThoai',
                                'SoDienThoai',
                                'sdt',
                                'SDT',
                              ]),
                            ),
                            const Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 16,
                            ),
                            _buildInfoItem(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              value: _getValue([
                                'email',
                                'Email',
                              ]), 
                            ),
                            const Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 16,
                            ),
                            _buildInfoItem(
                              icon: Icons.cake_outlined,
                              title: 'Ngày sinh',
                              value: _formatPatientDate(
                              _getPatientValue([
                                'NgaySinh',
                                'ngaySinh',
                              ]),
                            ),
                            ),
                            const Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 16,
                            ),
                            _buildInfoItem(
                              icon: Icons.wc_outlined,
                              title: 'Giới tính',
                             value: _getPatientValue([
                                'GioiTinh',
                                'gioiTinh',
                              ]),
                            ),
                            const Divider(
                              height: 1,
                              indent: 72,
                              endIndent: 16,
                            ),
                            _buildInfoItem(
                              icon: Icons.location_on_outlined,
                              title: 'Địa chỉ',
                              value: _getPatientValue([
                                'DiaChi',
                                'diaChi',
                              ]),
                            ),
                            const Divider(
                            height: 1,
                            indent: 72,
                            endIndent: 16,
                            ),
                            _buildInfoItem(
                            icon: Icons.emergency_outlined,
                            title: 'Số điện thoại khẩn cấp',
                            value: _getPatientValue([
                                'SoDienThoaiKhanCap',
                                'soDienThoaiKhanCap',
                              ]),
                            ),
                            const Divider(
                            height: 1,
                            indent: 72,
                            endIndent: 16,
                            ),
                            _buildInfoItem(
                            icon: Icons.medical_information_outlined,
                            title: 'Tiền sử bệnh',
                            value: _getPatientValue([
                                'TienSuBenh',
                                'tienSuBenh',
                              ]),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
