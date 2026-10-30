
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ============================================================
/// API CLIENT - MEDCARE HOSPITAL MOBILE
/// ============================================================
/// Flutter gọi Spring Boot REST API.
/// Spring Boot xử lý nghiệp vụ và truy vấn MySQL.
///
/// Cấu hình API:
/// - Android Emulator trên máy chạy backend:
///   http://10.0.2.2:8080
///
/// - Emulator trên máy thành viên khác:
///   Dùng IP LAN của máy đang chạy backend nếu hai máy
///   có thể kết nối với nhau.
///
/// - Backend dùng chung trên server:
///   Dùng URL HTTPS của server.
///
/// Có thể truyền URL khi chạy app:
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
///
/// Lưu ý: URL mặc định và ví dụ bên trên chỉ là ví dụ.
/// Cần thay cổng và địa chỉ cho đúng backend của nhóm.
/// ============================================================

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  /// URL có thể thay đổi theo môi trường mà không cần sửa code.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  String? _token;
  String? _resetToken;

  /// Gọi sau khi đăng nhập thành công.
  void setToken(String? token) {
    _token = token;
  }

  /// Xóa token khi đăng xuất.
  void clearToken() {
    _token = null;
  }

  /// Tạo URL trang web hồ sơ bệnh án từ địa chỉ backend.
  static String buildMedicalRecordQrUrl(String qrToken) {
    final serverUri = Uri.parse(baseUrl);

    return serverUri
        .replace(
          path: '/medical-records/qr',
          queryParameters: {'token': qrToken},
        )
        .toString();
  }

  Map<String, String> _headers({bool hasBody = false}) {
    return {
      'Accept': 'application/json',
      if (hasBody) 'Content-Type': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }

  Uri _buildUri(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) {
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    final uri = Uri.parse('$baseUrl$normalizedEndpoint');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: queryParameters);
  }

  dynamic _decodeResponse(http.Response response) {
    final body = response.body;
    dynamic data;

    if (body.isNotEmpty) {
      try {
        data = jsonDecode(body);
      } on FormatException {
        data = body;
      }
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    final serverMessage = data is String && data.trim().isNotEmpty
    ? data
    : 'Yêu cầu thất bại (HTTP ${response.statusCode}).';

  throw ApiException(
    serverMessage.toString(),
    statusCode: response.statusCode,
    data: data,
  );
}

    // Future<dynamic> get(
    //   String endpoint, {
    //   Map<String, String>? queryParameters,
    // }) async {
    //   try {
    //     final response = await http
    //         .get(
    //           _buildUri(
    //             endpoint,
    //             queryParameters: queryParameters,
    //           ),
    //           headers: _headers(),
    //         )
    //         .timeout(const Duration(seconds: 20));

    //     return _decodeResponse(response);
    //   } on ApiException {
    //     rethrow;
    //   } catch (e) {
    //     throw ApiException(
    //       'Không thể kết nối máy chủ. '
    //       'Hãy kiểm tra địa chỉ API và kết nối mạng.',
    //       cause: e,
    //     );
    //   }
    // }
  
Future<dynamic> get(
  String endpoint, {
  Map<String, String>? queryParameters,
}) async {
  final uri = _buildUri(
    endpoint,
    queryParameters: queryParameters,
  );

  debugPrint('========== DEBUG API GET ==========');
  debugPrint('URL: $uri');

  try {
    final response = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 20));

    debugPrint('HTTP STATUS: ${response.statusCode}');
    debugPrint('RESPONSE BODY: ${response.body}');

    return _decodeResponse(response);
  } on ApiException {
    rethrow;
  } catch (e) {
    debugPrint('API ERROR: $e');

    throw ApiException(
      'Không thể kết nối máy chủ. '
      'Hãy kiểm tra địa chỉ API và kết nối mạng.',
      cause: e,
    );
  }
}


  // post
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final response = await http
          .post(
            _buildUri(
              endpoint,
              queryParameters: queryParameters,
            ),
            headers: _headers(hasBody: body != null),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Không thể gửi dữ liệu đến máy chủ.',
        cause: e,
      );
    }
  }
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .put(
            _buildUri(endpoint),
            headers: _headers(hasBody: body != null),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Không thể cập nhật dữ liệu trên máy chủ.',
        cause: e,
      );
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .patch(
            _buildUri(endpoint),
            headers: _headers(hasBody: body != null),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Không thể cập nhật dữ liệu trên máy chủ.',
        cause: e,
      );
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            _buildUri(endpoint),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 20));

      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        'Không thể xóa dữ liệu trên máy chủ.',
        cause: e,
      );
    }
  }

  // login 
  
  Future<Map<String, dynamic>> login({
    required String tenDangNhap,
    required String matKhau,
  }) async {
    final username = tenDangNhap.trim();

    if (username.isEmpty) {
      throw const ApiException(
        'Vui lòng nhập tên đăng nhập hoặc email.',
      );
    }
    // debug lỗi dùm mình 
    debugPrint('DEBUG Flutter username = [${tenDangNhap.trim()}]');
    final result = await post(
      '/api/auth/login',
      body: {
        'tenDangNhap': tenDangNhap.trim(),
        'matKhau': matKhau,
      },
    );

    if (result is! Map) {
      throw const ApiException(
        'Dữ liệu đăng nhập từ máy chủ không hợp lệ.',
      );
    }

    final data = Map<String, dynamic>.from(result);
    final token = data['Token'];

    if (token is! String || token.isEmpty) {
      throw const ApiException(
        'Máy chủ chưa trả về JWT token.',
      );
    }

    setToken(token);
    return data;
  }

  // ============================================
  // OTP
  // ===========================================
  
  /// Gửi OTP đăng ký đến email.
  Future<Map<String, dynamic>> sendRegistrationOtp({
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw const ApiException('Vui lòng nhập email.');
    }

    final result = await post(
      '/api/auth/register/send-otp',
      body: {
        'email': normalizedEmail,
      },
    );

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    throw const ApiException(
      'Phản hồi gửi OTP từ máy chủ không hợp lệ.',
    );
  }

  /// Xác minh OTP đăng ký.
  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    final result = await post(
      '/api/auth/register/verify-otp',
      body: {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      },
    );

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    throw const ApiException(
      'Phản hồi xác minh OTP từ máy chủ không hợp lệ.',
    );
  }

  // kiểm tra email trước khi xử lý 
  Future<Map<String, dynamic>> checkEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw const ApiException('Vui lòng nhập email.');
    }

    final result = await post(
      '/api/auth/check-email',
      body: {'email': normalizedEmail},
    );

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    throw const ApiException(
      'Phản hồi kiểm tra email từ máy chủ không hợp lệ.',
    );
  }

  
  // ============================================
  // QUÊN MẬT KHẨU
  // ============================================
  Future<Map<String, dynamic>> sendPasswordResetOtp({
    required String email,
  }) async {
    final result = await post(
      '/api/auth/forgot-password',
      queryParameters: {
        'email': email.trim().toLowerCase(),
      },
    );

    debugPrint('SEND OTP RESPONSE: $result');
    debugPrint('SEND OTP TYPE: ${result.runtimeType}');

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    if (result is String) {
      return {
        'success': true,
        'message': result,
      };
    }

    throw const ApiException('Phản hồi gửi OTP không hợp lệ.');
  }


  Future<Map<String, dynamic>> verifyPasswordResetOtp({
  required String email,
  required String otp,
}) async {
  final result = await post(
    '/api/auth/verify-otp',
    queryParameters: {
      'email': email.trim().toLowerCase(),
      'otp': otp.trim(),
    },
  );

  if (result is Map) {
    final response = Map<String, dynamic>.from(result);
    final token = response['resetToken']?.toString();

    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Backend không trả về resetToken.',
      );
    }

    _resetToken = token;
    return response;
  }

  throw const ApiException(
    'Phản hồi xác minh OTP không hợp lệ.',
  );
}

  Future<Map<String, dynamic>> resetPassword({
  required String email,
  required String newPassword,
  required String confirmPassword,
  }) async {
    final token = _resetToken;

    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Bạn cần xác minh OTP trước khi đặt lại mật khẩu.',
      );
    }

    final result = await post(
      '/api/auth/reset-password',
      queryParameters: {
        'email': email.trim().toLowerCase(),
        'resetToken': token,
        'matKhauMoi': newPassword,
        'matKhauXacNhan': confirmPassword,
      },
    );

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    if (result is String) {
      _resetToken = null;
      return {
        'success': true,
        'message': result,
      };
    }

    throw const ApiException(
      'Phản hồi đặt lại mật khẩu không hợp lệ.',
    );
  }


  /// Lấy hồ sơ của tài khoản đang đăng nhập.
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (_token == null || _token!.isEmpty) {
      throw const ApiException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }

    final result = await get('/api/auth/me');

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    throw const ApiException(
      'Dữ liệu hồ sơ từ máy chủ không hợp lệ.',
    );
  }

  
/// Đổi mật khẩu khi người dùng đã đăng nhập.
/// Backend cần có POST /api/auth/change-password.
Future<Map<String, dynamic>> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  if (_token == null || _token!.isEmpty) {
    throw const ApiException(
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
    );
  }

  final result = await post(
    '/api/auth/change-password',
    body: {
      'matKhauHienTai': currentPassword,
      'matKhauMoi': newPassword,
      'matKhauXacNhan': confirmPassword,
    },
  );

  if (result is Map) {
    return Map<String, dynamic>.from(result);
  }

  if (result is String) {
    return {
      'success': true,
      'message': result,
    };
  }

  throw const ApiException(
    'Phản hồi đổi mật khẩu từ máy chủ không hợp lệ.',
  );
}




}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final Object? cause;

  const ApiException(
    this.message, {
    this.statusCode,
    this.data,
    this.cause,
  });

  @override
  String toString() {
    return 'ApiException: $message'
        '${statusCode == null ? '' : ' (HTTP $statusCode)'}';
  }
}
