// =============================================
// TRANG ĐĂNG KÝ THÀNH CÔNG
// =============================================

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/router/app_router.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String email;

  const RegistrationSuccessScreen({
    super.key,
    required this.email,
  });

  static const Color teal = Color(0xFF00796B);

  static const Color primary = Color(0xFF2563EB);
  //static const Color background = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  //static const Color secondaryText = Color(0xFF64748B);
  //static const Color borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD9F7F4),
                      border: Border.all(
                        color: Colors.white,
                        width: 10,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: teal,
                      size: 76,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Đăng Ký Thành Công!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCF2EE),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Tài khoản đã được tạo thành công',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Color(0xFFDBEAFE),
                              child: Icon(
                                Icons.medical_information_outlined,
                                color: primary,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chào mừng bạn đến với MedCare Hospital!',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Hồ sơ y tế cá nhân của bạn đã được khởi tạo. '
                                    'MedCare luôn đồng hành cùng bạn trên hành trình sức khỏe.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF4FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                color: primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  email,
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.check_circle,
                                color: teal,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.eco_outlined,
                              color: teal,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Chúc bạn luôn có trải nghiệm chăm sóc sức khỏe '
                                'an tâm, chủ động và ấm áp.',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.support_agent_rounded,
                          color: primary,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đội ngũ y tế MedCare Hospital luôn bên bạn',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Sẵn sàng hỗ trợ bạn trong hành trình chăm sóc sức khỏe.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.patientHome,
                          (route) => false,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bắt đầu sử dụng ngay',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ==========================================
// PREVIEW GIAO DIỆN
// ==========================================

@Preview(name: 'Đăng ký thành công')
Widget registrationsuccessPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegistrationSuccessScreen(
      email: 'nguyenvana@example.com',
    ),
  );
}