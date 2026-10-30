import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import 'registration_otp_screen.dart';

// =======================================
// TRANG ĐĂNG KÝ
// ======================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondary = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ============================================
  // KIỂM TRA EMAIL VÀ GỬI OTP
  // ============================================
  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (_loading) return;

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Bước 1: Kiểm tra email.
      final checkResult =
          await ApiClient.instance.checkEmail(email);

      if (!mounted) return;

      if (checkResult['success'] != true) {
        setState(() {
          _errorMessage = checkResult['message']?.toString() ??
              'Email này đã có tài khoản.';
        });
        return;
      }

      // Bước 2: Gửi OTP đến email.
      final otpResult =
          await ApiClient.instance.sendRegistrationOtp(
        email: email,
      );

      if (!mounted) return;

      if (otpResult['success'] != true) {
        setState(() {
          _errorMessage = otpResult['message']?.toString() ??
              'Không thể gửi mã OTP. Vui lòng thử lại.';
        });
        return;
      }

      // Bước 3: Chuyển sang màn hình nhập OTP.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationOtpScreen(
            email: email,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Không thể kết nối máy chủ. Vui lòng thử lại.';
      });

      debugPrint('Register error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nút quay lại
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
                        'Đăng ký tài khoản',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Đăng ký bằng email của bạn',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 58),

                // Khung nhập email
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    28,
                    24,
                    24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _emailController,
                        enabled: !_loading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Vui lòng nhập email.';
                          }

                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailRegex.hasMatch(email)) {
                            return 'Email không đúng định dạng.';
                          }

                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (!_loading) {
                            _register();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Nhập email...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF77808D),
                            fontSize: 18,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF77808D),
                            size: 28,
                          ),
                          filled: true,
                          fillColor: lightBlue,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 24,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: primary,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFB91C1C),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Nút đăng ký
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primary.withValues(alpha: 0.6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Đăng ký tài khoản',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Đường phân cách
                const Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(0xFFD5E2F8),
                        thickness: 1.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'HOẶC TIẾP TỤC VỚI',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Color(0xFFD5E2F8),
                        thickness: 1.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 58),

                // Chuyển đến đăng nhập
                SizedBox(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.login,
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(
                        color: primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
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

@Preview(name: 'Đăng ký')
Widget registerPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegisterScreen(
    ),
  );
}
