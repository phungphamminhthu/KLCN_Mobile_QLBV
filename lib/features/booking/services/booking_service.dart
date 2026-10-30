import '../../../core/network/api_client.dart';
import '../models/department_model.dart';
import '../models/doctor_model.dart';
import 'package:flutter/foundation.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<DepartmentModel>> getDepartments() async {
    final response = await _apiClient.get('/api/khoa');

    if (response is! List) {
      throw Exception('Dữ liệu danh sách khoa không hợp lệ');
    }

    return response
        .map(
          (item) => DepartmentModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  
// Future<List<DoctorModel>> getDoctorsByDepartmentAndDate({
//     required int maKhoa,
//     required String ngayKham,
//   }) async {
//     final response = await _apiClient.get(
//       '/api/bac-si/lich-lam-viec/danh-sach',
//       queryParameters: {
//         'maKhoa': maKhoa.toString(),
//         'ngayLamViec': ngayKham,
//       },
//     );

//     if (response is! List) {
//       throw Exception('Dữ liệu danh sách bác sĩ không hợp lệ.');
//     }

//     final doctors = response.map((item) {
//       return DoctorModel.fromJson(
//         Map<String, dynamic>.from(item as Map),
//       );
//     }).toList();

//     // DEBUG: Kiểm tra dữ liệu bác sĩ và lịch làm việc
//     for (final doctor in doctors) {
//       debugPrint(
//         'Bác sĩ: ${doctor.hoTen}, '
//         'maBacSi: ${doctor.maBacSi}, '
//         'maLichLamViec: ${doctor.maLichLamViec}, '
//         'giờ: ${doctor.gioBatDau} - ${doctor.gioKetThuc}',
//       );
//     }

//     doctors.sort(
//       (a, b) => (a.gioBatDau ?? '').compareTo(b.gioBatDau ?? ''),
//     );

//     return doctors;
//   }


Future<List<DoctorModel>> getDoctorsByDepartmentAndDate({
  required int maKhoa,
  required String ngayKham,
}) async {
  final response = await _apiClient.get(
    '/api/bac-si/lich-lam-viec/danh-sach',
    queryParameters: {
      'maKhoa': maKhoa.toString(),
      'ngayLamViec': ngayKham,
    },
  );

  // 1. Kiểm tra JSON gốc từ backend
  debugPrint('===== JSON GỐC TỪ API BÁC SĨ =====');
  debugPrint(response.toString());

  if (response is! List) {
    throw Exception('Dữ liệu danh sách bác sĩ không hợp lệ.');
  }

  // 2. Kiểm tra từng object trước khi chuyển model
  final doctors = response.map((item) {
    final json = Map<String, dynamic>.from(item as Map);

    debugPrint('===== JSON CHI TIẾT BÁC SĨ =====');
    debugPrint('maBacSi: ${json['maBacSi'] ?? json['MaBacSi']}');
    debugPrint('Các key API trả về: ${json.keys.toList()}');
    debugPrint(
      'soChungChiHanhNghe: '
      '${json['soChungChiHanhNghe'] ?? json['SoChungChiHanhNghe']}',
    );
    debugPrint(
      'anhDaiDien: '
      '${json['anhDaiDien'] ?? json['AnhDaiDien']}',
    );
    debugPrint('fileKey: ${json['fileKey']}');

    return DoctorModel.fromJson(json);
  }).toList();

  // 3. Kiểm tra kết quả sau khi parse
  debugPrint('===== KẾT QUẢ SAU KHI PARSE =====');

  for (final doctor in doctors) {
    debugPrint(
      'Bác sĩ: ${doctor.hoTen} | '
      'Chứng chỉ: ${doctor.soChungChiHanhNghe} | '
      'Ảnh: ${doctor.fileKey}',
    );
  }

  doctors.sort(
    (a, b) => (a.gioBatDau ?? '').compareTo(b.gioBatDau ?? ''),
  );

  return doctors;
}

 // ================================================
 // LẤY KHUNG GIỜ
 // ==============================================
  Future<List<Map<String, dynamic>>> getTimeSlots({
  required int maBacSi,
  required String ngayKham,
}) async {
  final response = await _apiClient.get(
      '/api/bac-si/lich-lam-viec/khung-gio',
      queryParameters: {
        'maBacSi': maBacSi.toString(),
        'ngayKham': ngayKham,
      },
    );

    if (response is! List) {
      throw Exception('Dữ liệu khung giờ không hợp lệ.');
    }

    return response
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

}