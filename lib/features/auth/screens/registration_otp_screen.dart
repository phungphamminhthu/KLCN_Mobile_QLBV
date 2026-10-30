// ==========================================
// TRANG NHẬP MÃ OTP ĐĂNG KÝ
// ==========================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../core/network/api_client.dart';
import 'registration_password_screen.dart';

class RegistrationOtpScreen extends StatefulWidget {
  final String email;

  const RegistrationOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<RegistrationOtpScreen> createState() =>
      _RegistrationOtpScreenState();
}

class _RegistrationOtpScreenState extends State<RegistrationOtpScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondary = Color(0xFF64748B);

  static const int otpDurationSeconds = 120;

  // Sáu ô nhập OTP.
  late final List<TextEditingController> _otpControllers;
late final List<FocusNode> _otpFocusNodes;

  Timer? _countdownTimer;

  int _remainingSeconds = otpDurationSeconds;

  bool _loading = false;
  bool _otpExpired = false;

  String? _errorMessage;
  String? _successMessage;

  // Ghép 6 ô thành một mã OTP.
  String get _otp =>
      _otpControllers.map((controller) => controller.text).join();

  bool get _canVerify => !_loading;

  bool get _canResend => !_loading && _otpExpired;

  String get _formattedTime {
    final minutes =
        (_remainingSeconds ~/ 60).toString().padLeft(2, '0');

    final seconds =
        (_remainingSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();


  _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  _otpFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
    _startCountdown();
  }

  // ============================================
  // ĐẾM NGƯỢC 2 PHÚT
  // ============================================

  void _startCountdown() {
    _countdownTimer?.cancel();

    setState(() {
      _remainingSeconds = otpDurationSeconds;
      _otpExpired = false;
      _errorMessage = null;
      _successMessage = null;
    });

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds <= 1) {
          timer.cancel();

          setState(() {
            _remainingSeconds = 0;
            _otpExpired = true;
            _errorMessage = null;
            _successMessage = null;
          });

          return;
        }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  // ============================================
  // XÓA TOÀN BỘ OTP
  // ============================================

  void _clearOtp() {
    for (final controller in _otpControllers) {
      controller.clear();
    }

    _otpFocusNodes.first.requestFocus();
  }

  // ============================================
  // TỰ ĐỘNG CHUYỂN Ô OTP
  // ============================================

  void _handleOtpChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (value.isNotEmpty) {
      // Nhập xong một số thì chuyển sang ô tiếp theo.
      if (index < _otpControllers.length - 1) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        // Ô cuối cùng: đóng bàn phím.
        _otpFocusNodes[index].unfocus();
      }
    } else if (index > 0) {
      // Xóa số thì quay về ô trước.
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  // ============================================
  // XÁC MINH OTP
  // ============================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_loading) return;

    // Không gửi OTP khi đã hết hạn.
    if (_otpExpired || _remainingSeconds <= 0) {
      setState(() {
        _otpExpired = true;
        _errorMessage = null;
        _successMessage = null;
      });

      return;
    }

    final otp = _otp.trim();

    // Kiểm tra đủ 6 chữ số.
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đủ 6 chữ số OTP.';
        _successMessage = null;
      });

      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result =
          await ApiClient.instance.verifyRegistrationOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;

      // Không chuyển trang nếu OTP hết hạn trong lúc chờ API.
      if (_otpExpired || _remainingSeconds <= 0) {
        setState(() {
          _otpExpired = true;
          _errorMessage = null;
          _successMessage = null;
        });

        return;
      }

      if (result['success'] == true) {
        _countdownTimer?.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationPasswordScreen(
              email: widget.email,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message']?.toString() ??
              'Mã OTP không chính xác hoặc đã hết hạn.';
        });
      }
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

      debugPrint('Verify registration OTP error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================
  // GỬI LẠI OTP
  // ============================================

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result =
          await ApiClient.instance.sendRegistrationOtp(
        email: widget.email,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _clearOtp();

        _startCountdown();

        setState(() {
          _successMessage =
              'Mã OTP mới đã được gửi đến email của bạn.';
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = result['message']?.toString() ??
              'Không thể gửi lại mã OTP.';
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Không thể gửi mã OTP. Vui lòng kiểm tra kết nối.';
      });

      debugPrint('Resend registration OTP error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================
  // WIDGET 6 Ô OTP
  // ============================================

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 44,
          height: 56,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            enabled: !_loading,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textInputAction: index == 5
                ? TextInputAction.done
                : TextInputAction.next,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            onChanged: (value) {
              _handleOtpChanged(index, value);
            },
            onSubmitted: (_) {
              if (index == 5) {
                _verifyOtp();
              }
            },
          ),
        );
      }),
    );
  }

  // ============================================
  // WIDGET THÔNG BÁO
  // ============================================

  Widget _buildMessage({
    required String message,
    required Color color,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // GIẢI PHÓNG TÀI NGUYÊN
  // ============================================

  @override
  void dispose() {
    _countdownTimer?.cancel();

    for (final controller in _otpControllers) {
      controller.dispose();
    }

    for (final node in _otpFocusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  // ============================================
  // GIAO DIỆN
  // ============================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nút quay lại.
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 23,
                  ),
                  label: const Text('Quay lại'),
                  style: TextButton.styleFrom(
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Logo MedCare.
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

              // Tiêu đề nhập OTP.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.025),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Nhập mã OTP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Khung hướng dẫn xác thực email.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 30,
                      color: primary,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Xác thực email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Mã 6 chữ số đã được gửi đến email:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: secondary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Vui lòng nhập mã xác thực bên dưới.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Sáu ô OTP.
              _buildOtpFields(),

              const SizedBox(height: 20),

              // Đồng hồ đếm ngược.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _otpExpired
                        ? Icons.timer_off_outlined
                        : Icons.access_time,
                    color: _otpExpired ? Colors.red : primary,
                    size: 24,
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      _otpExpired
                          ? 'Mã OTP đã hết hạn'
                          : 'Mã OTP có hiệu lực trong',
                      style: TextStyle(
                        fontSize: 15,
                        color: _otpExpired ? Colors.red : secondary,
                      ),
                    ),
                  ),

                  if (!_otpExpired) ...[
                    const SizedBox(width: 8),

                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              if (_otpExpired)
                const Text(
                  'Mã OTP hết hiệu lực. Vui lòng bấm Gửi mã lại.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),

              // Thông báo lỗi.
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),

                _buildMessage(
                  message: _errorMessage!,
                  color: Colors.red,
                  backgroundColor: const Color(0xFFFFEEEE),
                  icon: Icons.error_outline,
                ),
              ],

              // Thông báo thành công.
              if (_successMessage != null) ...[
                const SizedBox(height: 16),

                _buildMessage(
                  message: _successMessage!,
                  color: Colors.green,
                  backgroundColor: const Color(0xFFE8F8EF),
                  icon: Icons.check_circle_outline,
                ),
              ],

              const SizedBox(height: 24),

              // Nút xác nhận.
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _canVerify ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        primary.withValues(alpha: 0.6),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
                          'Xác nhận mã',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // Gửi lại mã chỉ được bật sau khi OTP hết hạn.
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Chưa nhận được mã OTP? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: secondary,
                    ),
                  ),

                  TextButton(
                    onPressed: _canResend ? _resendOtp : null,
                    child: Text(
                      _loading ? 'Đang gửi...' : 'Gửi mã lại',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _canResend
                            ? primary
                            : Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PREVIEW GIAO DIỆN
// ==========================================

@Preview(name: 'Nhập mã OTP')
Widget registrationOtpPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RegistrationOtpScreen(
      email: 'nguyenvana@example.com',
    ),
  );
}