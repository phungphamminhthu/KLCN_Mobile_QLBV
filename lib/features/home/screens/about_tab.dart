
import 'package:flutter/material.dart';
import 'main_navigation_screen.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  static const Color _blue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF153F86);
  static const Color _text = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _light = Color(0xFFEFF6FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(context),
            _buildProcess(),
            _buildCallToAction(context),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // 1. HERO - GIỚI THIỆU TỔNG QUAN
  Widget _buildHero(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF0F6FF),
            Colors.white,
            Color(0xFFE8F1FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 42,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('GIỚI THIỆU VỀ MEDCARE'),
          const SizedBox(height: 18),
          const Text.rich(
            TextSpan(
              style: TextStyle(
                color: _text,
                fontSize: 34,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(text: 'Giải pháp hỗ trợ\n'),
                TextSpan(
                  text: 'chăm sóc sức khỏe',
                  style: TextStyle(color: _blue),
                ),
                TextSpan(text: '\nhiện đại'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'MedCare Hospital là hệ thống hỗ trợ quản lý hoạt động '
            'khám chữa bệnh, giúp người bệnh tiếp cận thông tin y tế, '
            'đăng ký lịch khám và theo dõi quá trình khám bệnh '
            'thuận tiện hơn.',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.85,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Hệ thống kết nối các quy trình từ đăng ký lịch khám, '
            'tiếp nhận, khám bệnh đến cận lâm sàng và quản lý hồ sơ, '
            'hướng đến sự thống nhất trong quản lý và trải nghiệm '
            'của người sử dụng.',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.85,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _actionButton(
                label: 'Khám phá dịch vụ',
                primary: true,
                onTap: () => Navigator.of(context).pushNamed('/services'),
              ),
              _actionButton(
                label: 'Tìm hiểu tiện ích',
                primary: false,
                onTap: () {
                  // Cuộn nội dung đến quy trình giới thiệu bên dưới.
                  // Không cần chuyển route.
                },
              ),
            ],
          ),
          // const SizedBox(height: 34),
          // _buildIllustration(),
        ],
      ),
    );
  }

  // Minh họa giao diện MedCare bằng các widget Flutter.
  // Widget _buildIllustration() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(18),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: const Color(0xFFDBEAFE)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: _blue.withValues(alpha: 0.10),
  //           blurRadius: 28,
  //           offset: const Offset(0, 12),
  //         ),
  //       ],
  //     ),
  //     // child: Column(
  //     //   crossAxisAlignment: CrossAxisAlignment.start,
  //     //   children: [
  //     //     Row(
  //     //       children: [
  //     //         Container(
  //     //           width: 38,
  //     //           height: 38,
  //     //           decoration: BoxDecoration(
  //     //             color: _blue,
  //     //             borderRadius: BorderRadius.circular(10),
  //     //           ),
  //     //           child: const Icon(
  //     //             Icons.local_hospital_rounded,
  //     //             color: Colors.white,
  //     //             size: 23,
  //     //           ),
  //     //         ),
  //     //         const SizedBox(width: 10),
  //     //         const Expanded(
  //     //           child: Text(
  //     //             'MedCare Hospital',
  //     //             style: TextStyle(
  //     //               color: _blue,
  //     //               fontWeight: FontWeight.bold,
  //     //               fontSize: 14,
  //     //             ),
  //     //           ),
  //     //         ),
  //     //         const Icon(Icons.more_horiz, color: Color(0xFFCBD5E1)),
  //     //       ],
  //     //     ),
  //     //     const Divider(height: 28, color: _border),
  //     //     Container(
  //     //       padding: const EdgeInsets.symmetric(
  //     //         horizontal: 10,
  //     //         vertical: 6,
  //     //       ),
  //     //       decoration: BoxDecoration(
  //     //         color: _light,
  //     //         borderRadius: BorderRadius.circular(20),
  //     //       ),
  //     //       child: const Text(
  //     //         'HỆ THỐNG Y TẾ',
  //     //         style: TextStyle(
  //     //           color: _blue,
  //     //           fontSize: 10,
  //     //           fontWeight: FontWeight.bold,
  //     //           letterSpacing: 1,
  //     //         ),
  //     //       ),
  //     //     ),
  //     //     const SizedBox(height: 14),
  //     //     const Text(
  //     //       'Chăm sóc sức khỏe\nthuận tiện hơn',
  //     //       style: TextStyle(
  //     //         color: _text,
  //     //         fontSize: 23,
  //     //         height: 1.35,
  //     //         fontWeight: FontWeight.bold,
  //     //       ),
  //     //     ),
  //     //     const SizedBox(height: 20),
  //     //     _illustrationRow(
  //     //       Icons.calendar_month_rounded,
  //     //       'Đặt lịch khám',
  //     //       'Chủ động chọn thời gian',
  //     //     ),
  //     //     _illustrationRow(
  //     //       Icons.folder_shared_outlined,
  //     //       'Hồ sơ khám bệnh',
  //     //       'Tra cứu thông tin',
  //     //     ),
  //     //     _illustrationRow(
  //     //       Icons.medical_services_outlined,
  //     //       'Dịch vụ y tế',
  //     //       'Thông tin rõ ràng',
  //     //     ),
  //     //     const SizedBox(height: 4),
  //     //     Align(
  //     //       alignment: Alignment.centerRight,
  //     //       child: Container(
  //     //         padding: const EdgeInsets.symmetric(
  //     //           horizontal: 12,
  //     //           vertical: 9,
  //     //         ),
  //     //         decoration: BoxDecoration(
  //     //           color: Colors.white,
  //     //           borderRadius: BorderRadius.circular(10),
  //     //           boxShadow: [
  //     //             BoxShadow(
  //     //               color: _darkBlue.withValues(alpha: 0.10),
  //     //               blurRadius: 15,
  //     //             ),
  //     //           ],
  //     //         ),
  //     //         child: const Row(
  //     //           mainAxisSize: MainAxisSize.min,
  //     //           children: [
  //     //             Icon(Icons.check_circle, color: Colors.green, size: 17),
  //     //             SizedBox(width: 7),
  //     //             Text(
  //     //               'Trải nghiệm thuận tiện',
  //     //               style: TextStyle(
  //     //                 color: _text,
  //     //                 fontSize: 11,
  //     //                 fontWeight: FontWeight.bold,
  //     //               ),
  //     //             ),
  //     //           ],
  //     //         ),
  //     //       ),
  //     //     ),
  //     //   ],
  //     // ),
  //   );
  // }

  Widget _illustrationRow(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8EDF5)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _blue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 19,
          ),
        ],
      ),
    );
  }

  // 2. QUY TRÌNH KHÁM BỆNH
  Widget _buildProcess() {
    final steps = [
      (
        number: '01',
        icon: Icons.event_available_rounded,
        title: 'Đăng ký lịch khám',
        description: 'Chọn thông tin lịch khám và gửi yêu cầu đăng ký.',
      ),
      (
        number: '02',
        icon: Icons.assignment_ind_outlined,
        title: 'Tiếp nhận bệnh nhân',
        description: 'Nhân viên tiếp nhận kiểm tra lịch và thông tin.',
      ),
      (
        number: '03',
        icon: Icons.medical_services_outlined,
        title: 'Bác sĩ khám bệnh',
        description: 'Bác sĩ thăm khám và chỉ định cận lâm sàng nếu cần.',
      ),
      (
        number: '04',
        icon: Icons.assignment_turned_in_outlined,
        title: 'Hoàn thiện hồ sơ',
        description: 'Ghi nhận kết quả, kết luận và thông tin điều trị.',
      ),
    ];

    return Container(
      color: const Color(0xFFF3F7FD),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 44,
      ),
      child: Column(
        children: [
          _eyebrow('QUY TRÌNH'),
          const SizedBox(height: 12),
          const Text(
            'Hành trình khám bệnh tại MedCare',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 25,
              height: 1.35,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Quy trình tổng quan giúp người bệnh hình dung các bước '
            'khám chữa bệnh được hệ thống hỗ trợ quản lý.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 28),
          ...steps.map(
            (step) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _darkBlue.withValues(alpha: 0.025),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(step.icon, color: _blue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.number,
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          step.title,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          step.description,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 13,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. KÊU GỌI KHÁM PHÁ DỊCH VỤ
  Widget _buildCallToAction(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF2FF),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 36,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('MEDCARE HOSPITAL'),
          const SizedBox(height: 12),
          const Text(
            'Chủ động tìm hiểu các dịch vụ chăm sóc sức khỏe',
            style: TextStyle(
              color: _text,
              fontSize: 25,
              height: 1.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Khám phá danh mục dịch vụ và cập nhật những thông tin '
            'sức khỏe hữu ích tại MedCare.',
            style: TextStyle(
              color: _muted,
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _actionButton(
                label: 'Xem dịch vụ',
                primary: true,
                onTap: () => Navigator.of(context).pushNamed('/services'),
              ),
              _actionButton(
                label: 'Xem tin tức',
                primary: false,
                onTap: () {
                  // Route tin tức của hệ thống dùng chung.
                  Navigator.of(context).pushNamed('/news');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. FOOTER
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: _border),
        ),
      ),
      child: const Column(
        children: [
          Text(
            'MedCare Hospital',
            style: TextStyle(
              color: _blue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Đồng hành cùng sức khỏe của bạn và gia đình.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.7,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '© 2026 MedCare Hospital',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eyebrow(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _blue,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: primary ? _blue : Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: primary ? _blue : const Color(0xFFBFDBFE),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: primary ? Colors.white : _blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 9),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: primary ? Colors.white : _blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
