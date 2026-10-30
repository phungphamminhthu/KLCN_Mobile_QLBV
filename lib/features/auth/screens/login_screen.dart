import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/password_visibility_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';

//===========================================
// TRANG ĐĂNG NHẬP 
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color lightBlue = Color(0xFFEFF6FF);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondary = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  static const String _rememberKey = 'medcare_remember_login';
  static const String _savedUsernameKey = 'medcare_saved_username';

  bool _isPasswordHidden = true;
  bool _rememberLogin = false;
  bool _loading = false;

  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadRememberedLogin();
  }

  Future<void> _loadRememberedLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final shouldRemember = prefs.getBool(_rememberKey) ?? false;
    final savedUsername = prefs.getString(_savedUsernameKey) ?? '';

    setState(() {
      _rememberLogin = shouldRemember;

      if (shouldRemember) {
        _usernameController.text = savedUsername;
      }
    });
  }

  Future<void> _saveRememberedLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_rememberKey, _rememberLogin);

    if (_rememberLogin) {
      await prefs.setString(_savedUsernameKey, username);
    } else {
      await prefs.remove(_savedUsernameKey);
    }
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Kiểm tra thông tin trước khi gọi API.
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _successMessage = null;

        if (username.isEmpty && password.isEmpty) {
          _errorMessage = 'Vui lòng nhập đầy đủ thông tin.';
        } else if (username.isEmpty) {
          _errorMessage = 'Vui lòng nhập email hoặc tên đăng nhập.';
        } else {
          _errorMessage = 'Vui lòng nhập mật khẩu.';
        }
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final user = await ApiClient.instance.login(
        tenDangNhap: username,
        matKhau: password,
      );
      await _saveRememberedLogin(username);
      if (!mounted) return;

      final role = (user['VaiTro'] ?? '').toString().trim().toUpperCase();

      if (role != 'BENHNHAN') {
        ApiClient.instance.clearToken();

        setState(() {
          _errorMessage = 'Tài khoản này không thuộc vai trò bệnh nhân.';
          _successMessage = null;
        });
        return;
      }

      // Hiển thị thông báo thành công trước khi chuyển trang.
      setState(() {
        _errorMessage = null;
        _successMessage = 'Đăng nhập thành công!';
      });

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.patientHome,
        (route) => false,
        arguments: user,
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.message;
        _successMessage = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Không thể kết nối máy chủ. Vui lòng thử lại.';
        _successMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nút quay lại.
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
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

                const SizedBox(height: 16),

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

                // Tiêu đề form.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Đăng nhập tài khoản',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Chào mừng bạn quay trở lại',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form đăng nhập.
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email hoặc tên đăng nhập',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 9),

                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) {
                          if (_errorMessage != null ||
                              _successMessage != null) {
                            setState(() {
                              _errorMessage = null;
                              _successMessage = null;
                            });
                          }
                        },
                        decoration: _inputDecoration(
                          hint: 'Nhập email...',
                          icon: Icons.badge_outlined,
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Mật khẩu',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 9),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isPasswordHidden,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) {
                          if (_errorMessage != null ||
                              _successMessage != null) {
                            setState(() {
                              _errorMessage = null;
                              _successMessage = null;
                            });
                          }
                        },
                        onFieldSubmitted: (_) {
                          if (!_loading) _login();
                        },
                        decoration:
                            _inputDecoration(
                              hint: 'Nhập mật khẩu...',
                              icon: Icons.lock_outline_rounded,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordHidden = !_isPasswordHidden;
                                  });
                                },
                                icon: PasswordVisibilityIcon(
                                  isHidden: _isPasswordHidden,
                                ),
                              ),
                            ),
                      ),

                      const SizedBox(height: 16),

                      // Ghi nhớ đăng nhập và quên mật khẩu.
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberLogin,
                            activeColor: primary,
                            onChanged: (value) async {
                              // setState(() {
                              //   _rememberLogin = value ?? false;
                              // });
                              final shouldRemember = value ?? false;
                              setState(() {
                                _rememberLogin = shouldRemember;
                              });

                              final prefs = await SharedPreferences.getInstance();

                              await prefs.setBool(_rememberKey, shouldRemember);

                              if (!shouldRemember) {
                                await prefs.remove(_savedUsernameKey);
                              }
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Ghi nhớ đăng nhập',
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            // onPressed: () {
                            //   Navigator.pushNamed(context, '/forgot-password');
                            // },
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Thông báo lỗi phía trên nút đăng nhập.
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFB91C1C),
                                size: 18,
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

                      // Thông báo đăng nhập thành công.
                      if (_successMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF15803D),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFF15803D),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Nút đăng nhập.
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Đăng nhập',
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

                const SizedBox(height: 44),

                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFD5E2F8))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'HOẶC TIẾP TỤC VỚI',
                        style: TextStyle(
                          color: secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFD5E2F8))),
                  ],
                ),

                const SizedBox(height: 44),

                const Text(
                  'Chưa có tài khoản MedCare?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF475569), fontSize: 16),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.register,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đăng ký tài khoản mới',
                      style: TextStyle(
                        fontSize: 16,
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: secondary),
      filled: true,
      fillColor: lightBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }
}
