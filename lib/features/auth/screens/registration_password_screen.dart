// ================================================
// TRANG NHẬP MẬT KHẨU 
// ================================================
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../shared/widgets/password_visibility_icon.dart';
import '../../../core/router/app_router.dart';

import 'patient_profile_screen.dart';

class RegistrationPasswordScreen extends StatefulWidget {
  final String email;

  const RegistrationPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<RegistrationPasswordScreen> createState() =>
      _RegistrationPasswordScreenState();
}

class _RegistrationPasswordScreenState
    extends State<RegistrationPasswordScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color textColor = Color(0xFF1E293B);
  //static const Color secondary = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;
  final bool _loading = false;

  bool get _hasLength => _passwordController.text.length >= 8;
  bool get _hasLower =>
      RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasUpper =>
      RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasDigit =>
      RegExp(r'[0-9]').hasMatch(_passwordController.text);

  bool get _matches =>
      _passwordController.text == _confirmController.text &&
      _confirmController.text.isNotEmpty;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _passwordRule(String text, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.circle_outlined,
            color: passed ? Colors.teal : Colors.blueGrey,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            passed ? 'Hoàn thành' : 'Chưa đạt',
            style: TextStyle(
              color: passed ? Colors.teal : Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
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

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PatientProfileScreen(
            email: widget.email,
            password: _passwordController.text,
            ),
        ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: TextButton.icon(
                //     onPressed: () => Navigator.pop(context),
                //     icon: const Icon(Icons.arrow_back),
                //     label: const Text('Quay lại'),
                //   ),
                // ),
                // const SizedBox(height: 20),
                // const Icon(
                //   Icons.local_hospital_rounded,
                //   size: 76,
                //   color: primary,
                // ),
                // const SizedBox(height: 12),
                // const Text(
                //   'MedCare Hospital',
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     color: Color(0xFF0369A1),
                //     fontSize: 29,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _loading
                        ? null
                        : () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter.home,
                              );
                            }
                          },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 23,
                    ),
                    label: const Text('Quay lại'),
                    style: TextButton.styleFrom(
                      foregroundColor: textColor,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                // Logo bệnh viện
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_hospital_rounded,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8EB4E6),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.health_and_safety_outlined,
                              color: Color(0xFF006D69),
                              size: 21,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'HỆ THỐNG Y TẾ QUỐC TẾ',
                              style: TextStyle(
                                color: Color(0xFF006D69),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'MedCare Hospital',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0369A1),
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 42),
                // const Text(
                //   'Đặt mật khẩu mới',
                //   style: TextStyle(
                //     color: Color(0xFF0F2037),
                //     fontSize: 23,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // const Text(
                //   'Tạo mật khẩu an toàn cho tài khoản của bạn',
                //   style: TextStyle(
                //     color: Color(0xFF475569),
                //     fontSize: 15,
                //   ),
                // ),
                // Tiêu đề đăng ký
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.025),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Đặt mật khẩu mới',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tạo mật khẩu an toàn cho tài khoản của bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Email chỉ đọc
                const Text(
                  'Email đã xác minh',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: widget.email,
                  readOnly: true,
                  decoration: _decoration(
                    hint: '',
                    icon: Icons.email_outlined,
                  ).copyWith(
                    filled: true,
                    fillColor: const Color(0xFFE0F0F8),
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  'Mật khẩu mới',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Mật khẩu phải có ít nhất 8 ký tự.';
                    }
                    if (!_hasLower || !_hasUpper || !_hasDigit) {
                      return 'Cần có chữ thường, chữ hoa và chữ số.';
                    }
                    return null;
                  },
                  decoration: _decoration(
                    hint: 'Nhập mật khẩu mới',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      onPressed: () => setState(
                        () => _hidePassword = !_hidePassword,
                      ),
                    //   icon: Icon(
                    //     _hidePassword
                    //         ? Icons.visibility_outlined
                    //         : Icons.visibility_off_outlined,
                    //   ),
                    icon: PasswordVisibilityIcon(
                        isHidden: _hidePassword,
                    ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Nhập lại mật khẩu',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _hideConfirm,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không trùng khớp.';
                    }
                    return null;
                  },
                  decoration: _decoration(
                    hint: 'Nhập lại mật khẩu',
                    icon: Icons.lock_reset,
                    suffix: IconButton(
                      onPressed: () => setState(
                        () => _hideConfirm = !_hideConfirm,
                      ),
                    //   icon: Icon(
                    //     _hideConfirm
                    //         ? Icons.visibility_outlined
                    //         : Icons.visibility_off_outlined,
                    //   ),
                    icon: PasswordVisibilityIcon(
                        isHidden: _hideConfirm,
                    ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yêu cầu mật khẩu',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _passwordRule(
                        'Mật khẩu từ 8 ký tự trở lên',
                        _hasLength,
                      ),
                      _passwordRule(
                        'Chứa ít nhất 1 chữ thường (a-z)',
                        _hasLower,
                      ),
                      _passwordRule(
                        'Chứa ít nhất 1 chữ hoa (A-Z)',
                        _hasUpper,
                      ),
                      _passwordRule(
                        'Chứa ít nhất 1 chữ số (0-9)',
                        _hasDigit,
                      ),
                      _passwordRule(
                        'Xác nhận mật khẩu trùng khớp',
                        _matches,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                
                SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                    onPressed: _loading ? null : _continue,
                    style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primary.withValues(alpha: 0.6),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                    ),
                    ),
                    child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                        'Tiếp tục',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                        ),
                        ),
                        SizedBox(width: 10),
                        Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        ),
                    ],
                    ),
                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(name: 'Đặt mật khẩu mới')
Widget registrationPasswordPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegistrationPasswordScreen(
      email: 'nguyenvana@example.com',
    ),
  );
}
