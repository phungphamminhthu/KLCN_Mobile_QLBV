// ================================================
// MÀN HÌNH QUÊN MẬT KHẨU
// ================================================
import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  //final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  int _step = 0;
  int _seconds = 120;
  Timer? _timer;

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  String? _error;
  String? _success;

  static const Color primary = Color(0xFF2563EB);
  static const Color textColor = Color(0xFF1E293B);

  static const int _otpDurationSeconds = 120;

late final List<TextEditingController> _otpControllers;
late final List<FocusNode> _otpFocusNodes;

bool _otpExpired = false;

String get _otp =>
    _otpControllers.map((controller) => controller.text).join();

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
}

  String get _email => _emailController.text.trim().toLowerCase();

  bool get _passwordValid {
    final password = _passwordController.text;
    return password.length >= 8 &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  String get _countdown {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    //_otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    for (final controller in _otpControllers) {
        controller.dispose();
        }

        for (final node in _otpFocusNodes) {
        node.dispose();
        }
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _success = null;
    });
  }

  void _showSuccess(String message) {
    setState(() {
      _success = message;
      _error = null;
    });
  }

  bool _isSuccessful(Map<String, dynamic> response) {
    return response['success'] != false &&
        response['status'] != 'error';
  }

//   void _startCountdown() {
//     _timer?.cancel();

//     setState(() {
//       _seconds = 120;
//     });

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       if (_seconds <= 1) {
//         timer.cancel();
//         setState(() {
//           _seconds = 0;
//         });
//       } else {
//         setState(() {
//           _seconds--;
//         });
//       }
//     });
//   }
void _startCountdown() {
  _timer?.cancel();

  setState(() {
    _seconds = _otpDurationSeconds;
    _otpExpired = false;
    _error = null;
    _success = null;
  });

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_seconds <= 1) {
        timer.cancel();

        setState(() {
          _seconds = 0;
          _otpExpired = true;
          _error = null;
          _success = null;
        });

        return;
      }

      setState(() {
        _seconds--;
      });
    },
  );
}

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final email = _email;

    if (email.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showError('Vui lòng nhập địa chỉ email hợp lệ.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final response =
          await ApiClient.instance.sendPasswordResetOtp(email: email);

      if (!mounted) return;

      if (!_isSuccessful(response)) {
        _showError(
          (response['message'] ?? 'Không thể gửi mã OTP.').toString(),
        );
        return;
      }

      // setState(() {
      //   _step = 1;
      //   _otpController.clear();
      // });
      setState(() {
        _step = 1;
        _otpExpired = false;
        _seconds = _otpDurationSeconds;
        _error = null;
        _success = null;
      });

_clearOtp();
_startCountdown();
_showSuccess('Mã OTP đã được gửi đến email của bạn.');

    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Không thể kết nối máy chủ.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_seconds <= 0) {
      _showError('Mã OTP đã hết hạn. Vui lòng gửi mã mới.');
      return;
    }

    // if (!RegExp(r'^[0-9]{6}$').hasMatch(_otpController.text.trim())) {
    //   _showError('Vui lòng nhập mã OTP gồm 6 chữ số.');
    //   return;
    // }
    final otp = _otp;

    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      _showError('Vui lòng nhập đủ 6 chữ số OTP.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final response =
          await ApiClient.instance.verifyPasswordResetOtp(
        email: _email,
        //otp: _otpController.text.trim(),
        otp: otp,
      );

      if (!mounted) return;

      if (!_isSuccessful(response)) {
        _showError(
          (response['message'] ?? 'Mã OTP không chính xác.').toString(),
        );
        return;
      }

      _timer?.cancel();

      setState(() {
        _step = 2;
        _error = null;
        _success = null;
      });
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Không thể xác minh OTP.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_passwordValid) {
      _showError(
        'Mật khẩu cần ít nhất 8 ký tự, có chữ hoa, chữ thường và số.',
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showError('Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final response = await ApiClient.instance.resetPassword(
        email: _email,
        newPassword: _passwordController.text,
        confirmPassword: _confirmController.text,
      );

      if (!mounted) return;

      if (!_isSuccessful(response)) {
        _showError(
          (response['message'] ?? 'Không thể đặt lại mật khẩu.').toString(),
        );
        return;
      }

      _timer?.cancel();

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 56,
          ),
          title: const Text('Đổi mật khẩu thành công'),
          content: const Text(
            'Mật khẩu mới đã được cập nhật. '
            'Vui lòng đăng nhập lại bằng mật khẩu mới.',
            textAlign: TextAlign.center,
          ),
          // Căn giữa nút bên dưới thông báo
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Về đăng nhập'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Không thể đặt lại mật khẩu.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    int maxLength = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLength: maxLength > 0 ? maxLength : null,
          enabled: !_loading,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _message() {
    if (_error == null && _success == null) {
      return const SizedBox.shrink();
    }

    final isError = _error != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _error ?? _success!,
        style: TextStyle(
          color: isError
              ? const Color(0xFFB91C1C)
              : const Color(0xFF15803D),
        ),
      ),
    );
  }

  Widget _passwordRules() {
    final password = _passwordController.text;

    final rules = <String, bool>{
      'Ít nhất 8 ký tự': password.length >= 8,
      'Có chữ thường': RegExp(r'[a-z]').hasMatch(password),
      'Có chữ hoa': RegExp(r'[A-Z]').hasMatch(password),
      'Có chữ số': RegExp(r'[0-9]').hasMatch(password),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rules.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                entry.value
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 18,
                color: entry.value
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Text(
                entry.key,
                style: TextStyle(
                  color: entry.value
                      ? const Color(0xFF15803D)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _clearOtp() {
  for (final controller in _otpControllers) {
    controller.clear();
  }

  _otpFocusNodes.first.requestFocus();
}

void _handleOtpChanged(int index, String value) {
  if (_otpExpired || _seconds <= 0) return;

  setState(() {
    _error = null;
    _success = null;
  });

  if (value.isNotEmpty) {
    if (index < _otpControllers.length - 1) {
      _otpFocusNodes[index + 1].requestFocus();
    } else {
      _otpFocusNodes[index].unfocus();
    }
  } else if (index > 0) {
    _otpFocusNodes[index - 1].requestFocus();
  }
}

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
          enabled: !_loading && !_otpExpired,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
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
        ),
      );
    }),
  );
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
            style: TextButton.styleFrom(
              foregroundColor: textColor,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    const SizedBox(height: 16),
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
              // const SizedBox(height: 20),
              // Text(
              //   titles[_step],
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(
              //     fontSize: 25,
              //     fontWeight: FontWeight.bold,
              //     color: textColor,
              //   ),
              // ),
              const SizedBox(height: 10),
              if (_step != 1)
              Text(
                _step == 0
                    ? 'Nhập email đã đăng ký để nhận mã OTP đặt lại mật khẩu.'
                    : 'Tạo mật khẩu mới để bảo vệ tài khoản MedCare.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              // Text(
              //   [
              //     'Nhập email đã đăng ký để nhận mã OTP đặt lại mật khẩu.',
              //     //'Nhập mã 6 chữ số đã được gửi đến $_email.',
              //     'Tạo mật khẩu mới để bảo vệ tài khoản MedCare.',
              //   ][_step],
              //   textAlign: TextAlign.center,
              //   style: const TextStyle(
              //     color: Color(0xFF64748B),
              //     height: 1.5,
              //   ),
              // ),
              const SizedBox(height: 28),

              if (_step == 0)
                _field(
                  label: 'Email',
                  hint: 'Nhập email đã đăng ký',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              if (_step == 1) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            size: 32,
                            color: primary,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Xác thực email',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Mã OTP 6 chữ số đã được gửi đến:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildOtpFields(),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _otpExpired
                              ? Icons.timer_off_outlined
                              : Icons.access_time,
                          color: _otpExpired ? Colors.red : primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _otpExpired
                                ? 'Mã OTP đã hết hạn'
                                : 'Mã OTP có hiệu lực trong',
                            style: TextStyle(
                              color: _otpExpired
                                  ? Colors.red
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        if (!_otpExpired) ...[
                          const SizedBox(width: 8),
                          Text(
                            _countdown,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (_otpExpired)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Mã OTP đã hết hiệu lực sau 2 phút. '
                                'Bạn không thể sử dụng mã cũ. '
                                'Vui lòng bấm "Gửi mã lại" để nhận mã mới.',
                                style: TextStyle(
                                  color: Colors.red,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Thông báo gửi OTP thành công hoặc lỗi
                      _message(),
              // Hiển thị nút theo trạng thái OTP
                const SizedBox(height: 20),

                if (_otpExpired || _seconds <= 0)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: TextButton(
                      onPressed: _loading ? null : _sendOtp,
                      child: const Text(
                        'Gửi mã OTP mới',
                        style: TextStyle(
                          color: primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _verifyOtp,
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
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
                          : const Text(
                              'Xác nhận mã OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              if (_step == 2) ...[
                _field(
                  label: 'Mật khẩu mới',
                  hint: 'Nhập mật khẩu mới',
                  controller: _passwordController,
                  obscure: _hidePassword,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _passwordRules(),
                const SizedBox(height: 20),
                _field(
                  label: 'Xác nhận mật khẩu',
                  hint: 'Nhập lại mật khẩu mới',
                  controller: _confirmController,
                  obscure: _hideConfirm,
                  suffix: IconButton(
                    onPressed: () {
                      setState(() => _hideConfirm = !_hideConfirm);
                    },
                    icon: Icon(
                      _hideConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ],

              // _message(),
              // const SizedBox(height: 24),

              // SizedBox(
              //   height: 54,
              //   child: FilledButton(
              //     // onPressed: _loading
              //     //     ? null
              //     //     : _step == 0
              //     //         ? _sendOtp
              //     //         : _step == 1
              //     //             ? _verifyOtp
              //     //             : _resetPassword,
              //     onPressed: _loading ||
              //         (_step == 1 && _otpExpired)
              //     ? null
              //     : _step == 0
              //         ? _sendOtp
              //         : _step == 1
              //             ? _verifyOtp
              //             : _resetPassword,
              //     style: FilledButton.styleFrom(
              //       backgroundColor: primary,
              //       foregroundColor: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(13),
              //       ),
              //     ),
              //     child: _loading
              //         ? const SizedBox(
              //             width: 22,
              //             height: 22,
              //             child: CircularProgressIndicator(
              //               color: Colors.white,
              //               strokeWidth: 2,
              //             ),
              //           )
              //         : Text(
              //             [
              //               'Gửi mã OTP',
              //               'Xác nhận OTP',
              //               'Đặt lại mật khẩu',
              //             ][_step],
              //             style: const TextStyle(
              //               fontWeight: FontWeight.bold,
              //               fontSize: 16,
              //             ),
              //           ),
              //   ),
              // ),
              _message(),

              if (_step != 1) ...[
                const SizedBox(height: 24),

                SizedBox(
                  height: 54,
                  child: FilledButton(
                    onPressed: _loading
                        ? null
                        : _step == 0
                            ? _sendOtp
                            : _resetPassword,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
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
                        : Text(
                            _step == 0
                                ? 'Gửi mã OTP'
                                : 'Đặt lại mật khẩu',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],

              // const SizedBox(height: 12),
              // TextButton(
              //   onPressed: _loading
              //       ? null
              //       : () {
              //           if (_step == 0) {
              //             Navigator.pop(context);
              //           } else {
              //             setState(() {
              //               _step--;
              //               _error = null;
              //               _success = null;
              //             });
              //           }
              //         },
              //   child: Text(
              //     _step == 0 ? 'Quay về đăng nhập' : 'Quay lại',
              //   ),
              // ),
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

@Preview(name: 'Quên mật khẩu')
Widget forgotPassswordPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ForgotPasswordScreen(
    ),
  );
}