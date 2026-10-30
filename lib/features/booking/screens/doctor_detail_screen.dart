import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';

class DoctorDetailScreen extends StatelessWidget {
  final int maBacSi;
  final int maKhoa;
  final String tenBacSi;
  final String? trinhDo;
  final String? chuyenMon;
  final String? soChungChiHanhNghe;

  // URL ảnh do Backend trả về.
  // Có thể là URL ảnh lưu trong CSDL hoặc URL ảnh mặc định.
  final String? fileKey;

  const DoctorDetailScreen({
    super.key,
    required this.maBacSi,
    required this.maKhoa,
    required this.tenBacSi,
    this.trinhDo,
    this.chuyenMon,
    this.soChungChiHanhNghe,
    this.fileKey,
  });

  static const Color primary = Color(0xFF078DBB);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    //final imageUrl = fileKey?.trim() ?? '';

    final imageKey = fileKey?.trim() ?? '';

    final imageUrl = imageKey.isEmpty
        ? ''
        : Uri.parse('${ApiClient.baseUrl}/api/images/view')
            .replace(
              queryParameters: {'fileKey': imageKey},
        )
        .toString();

    debugPrint('Tên bác sĩ: $tenBacSi');
    debugPrint('fileKey: $fileKey');
    debugPrint('imageUrl: $imageUrl');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin bác sĩ',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // 1. Thẻ hồ sơ chính (Avatar, Tên, Chuyên môn, Thống kê nhanh)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar bác sĩ có viền và dấu tích xác thực
                Center(
                  child: _buildDoctorAvatar(imageUrl),
                ),
                const SizedBox(height: 16),

                // Tên bác sĩ
                Text(
                  tenBacSi,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Chip chuyên môn nổi bật
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.medical_services_outlined,
                        size: 15,
                        color: primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _displayValue(chuyenMon),
                        style: const TextStyle(
                          color: primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3 ô thông tin nhanh
                //_buildQuickStats(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Thẻ chi tiết thông tin hành nghề
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Thông tin hành nghề',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Hợp lệ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(
                  height: 16,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                // _infoRow(
                //   icon: Icons.apartment_rounded,
                //   label: 'Mã khoa',
                //   value: '$maKhoa',
                // ),
                _infoRow(
                  icon: Icons.school_outlined,
                  label: 'Trình độ',
                  value: _displayValue(trinhDo),
                ),
                _infoRow(
                  icon: Icons.healing_rounded,
                  label: 'Chuyên môn',
                  value: _displayValue(chuyenMon),
                ),
                _infoRow(
                  icon: Icons.badge_outlined,
                  label: 'Số chứng chỉ hành nghề',
                  value: _displayValue(soChungChiHanhNghe),
                  isBadge: true,
                  showDivider: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Thẻ cam kết dịch vụ & y đức
          _buildCommitmentCard(),

          //const SizedBox(height: 22),

          // 4. Nút quay lại chọn lịch khám
          // SizedBox(
          //   width: double.infinity,
          //   height: 50,
          //   child: ElevatedButton.icon(
          //     onPressed: () => Navigator.pop(context),
          //     icon: const Icon(
          //       Icons.arrow_back_ios_new_rounded,
          //       size: 15,
          //     ),
          //     label: const Text(
          //       'Quay lại chọn lịch khám',
          //       style: TextStyle(
          //         fontSize: 15,
          //         fontWeight: FontWeight.w700,
          //       ),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color(0xFF2563EB), // Nền xanh
          //       foregroundColor: Colors.white, // Chữ và icon trắng
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(16),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // 3 ô chỉ số tóm tắt dưới tên bác sĩ
  // Widget _buildQuickStats() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _statItem(
  //           icon: Icons.badge_outlined,
  //           label: 'Mã bác sĩ',
  //           value: '#$maBacSi',
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: _statItem(
  //           icon: Icons.apartment_rounded,
  //           label: 'Chuyên khoa',
  //           value: 'Khoa $maKhoa',
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       Expanded(
  //         child: _statItem(
  //           icon: Icons.verified_outlined,
  //           label: 'Trạng thái',
  //           value: 'Đang nhận lịch',
  //           valueColor: const Color(0xFF16A34A),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _statItem({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  //   Color? valueColor,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF8FAFC),
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: const Color(0xFFE2E8F0)),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(icon, size: 20, color: primary),
  //         const SizedBox(height: 5),
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             color: textSecondary,
  //             fontSize: 11,
  //             fontWeight: FontWeight.w500,
  //           ),
  //           maxLines: 1,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //         const SizedBox(height: 3),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: valueColor ?? textPrimary,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w700,
  //           ),
  //           maxLines: 1,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Khung cam kết chất lượng
  Widget _buildCommitmentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Cam kết chất lượng phục vụ',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _commitmentRow(
            icon: Icons.check_circle_outline_rounded,
            text: 'Bác sĩ có chứng chỉ hành nghề được Bộ Y Tế chứng nhận',
          ),
          const SizedBox(height: 8),
          _commitmentRow(
            icon: Icons.check_circle_outline_rounded,
            text: 'Thăm khám tận tâm, chu đáo theo đúng quy chuẩn chuyên môn',
          ),
          const SizedBox(height: 8),
          _commitmentRow(
            icon: Icons.check_circle_outline_rounded,
            text: 'Bảo mật tuyệt đối thông tin và hồ sơ bệnh án của bạn',
          ),
        ],
      ),
    );
  }

  Widget _commitmentRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF16A34A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // Avatar bác sĩ với viền trắng và icon tích xanh
  Widget _buildDoctorAvatar(String imageUrl) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Container(
        //   width: 110,
        //   height: 110,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: const Color(0xFFE0F2FE),
        //     border: Border.all(
        //       color: Colors.white,
        //       width: 3.5,
        //     ),
        //     boxShadow: [
        //       BoxShadow(
        //         color: primary.withValues(alpha: 0.16),
        //         blurRadius: 16,
        //         offset: const Offset(0, 5),
        //       ),
        //     ],
        //   ),
        //   clipBehavior: Clip.antiAlias,
        //   child: imageUrl.isNotEmpty
        //       ? Image.network(
        //           imageUrl,
        //           fit: BoxFit.cover,
        //           errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
        //         )
        //       : _defaultAvatar(),
        // ),

        Container(
          width: 110,
          height: 110,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE0F2FE),
            border: Border.all(
              color: Colors.white,
              width: 3.5,
            ),
          ),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Lỗi tải ảnh bác sĩ: $error');
                    debugPrint('URL ảnh: $imageUrl');
                    return _defaultAvatar();
                  },
                )
              : _defaultAvatar(),
        ),
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 13,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFFE0F2FE),
      child: const Icon(
        Icons.person,
        size: 64,
        color: primary,
      ),
    );
  }

  String _displayValue(String? value) {
    final result = value?.trim() ?? '';
    return result.isEmpty ? 'Chưa cập nhật' : result;
  }

  // Dòng hiển thị thông tin với khoảng cách rộng rãi, căn lề 2 bên rõ ràng
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isBadge = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon mục thông tin
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primary, size: 19),
              ),
              const SizedBox(width: 12),

              // Cột nhãn
              Expanded(
                flex: 5,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Khoảng cách rõ ràng giữa 2 cột (16px)
              const SizedBox(width: 16),

              // Cột giá trị
              Expanded(
                flex: 6,
                child: isBadge
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}
