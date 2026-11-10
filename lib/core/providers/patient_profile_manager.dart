import 'package:flutter/material.dart';
import '../network/api_client.dart';

class PatientProfile {
  final int maBenhNhan;
  final String hoTen;
  final String moiQuanHe;
  final bool laHoSoMacDinh;

  PatientProfile({
    required this.maBenhNhan,
    required this.hoTen,
    required this.moiQuanHe,
    required this.laHoSoMacDinh,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    final defaultValue = json['LaHoSoMacDinh'] ??
        json['laHoSoMacDinh'];

    return PatientProfile(
      maBenhNhan: int.parse(
        (json['MaBenhNhan'] ?? json['maBenhNhan']).toString(),
      ),
      hoTen: (json['HoTen'] ?? json['hoTen'] ?? '').toString(),
      moiQuanHe:
          (json['MoiQuanHe'] ?? json['moiQuanHe'] ?? '').toString(),
      laHoSoMacDinh: defaultValue == true ||
          defaultValue.toString() == '1' ||
          defaultValue.toString().toLowerCase() == 'true',
    );
  }
}

class PatientProfileManager extends ChangeNotifier {
  PatientProfileManager._();

  static final PatientProfileManager instance =
      PatientProfileManager._();

  List<PatientProfile> _profiles = [];
  PatientProfile? _selectedProfile;
  bool _isLoading = false;

  List<PatientProfile> get profiles => List.unmodifiable(_profiles);

  PatientProfile? get selectedProfile => _selectedProfile;

  int? get selectedPatientId => _selectedProfile?.maBenhNhan;

  bool get hasProfiles => _profiles.isNotEmpty;

  bool get isLoading => _isLoading;

  /// Tải danh sách hồ sơ từ tài khoản đang đăng nhập.
  Future<void> loadProfiles({bool resetToDefault = true}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.getCurrentUser();
      final rawProfiles = response['DanhSachBenhNhan'];

      if (rawProfiles is List) {
        _profiles = rawProfiles
            .whereType<Map>()
            .map(
              (item) => PatientProfile.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      } else {
        _profiles = [];
      }

      if (_profiles.isEmpty) {
        _selectedProfile = null;
      } else if (resetToDefault || _selectedProfile == null) {
        _selectedProfile = _profiles.firstWhere(
          (profile) => profile.laHoSoMacDinh,
          orElse: () => _profiles.first,
        );
      } else {
        final oldSelectedId = _selectedProfile!.maBenhNhan;

        _selectedProfile = _profiles.firstWhere(
          (profile) => profile.maBenhNhan == oldSelectedId,
          orElse: () => _profiles.first,
        );
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách hồ sơ bệnh nhân: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo hồ sơ bệnh nhân mới.
  Future<void> createProfile({
    required String hoTen,
    required String moiQuanHe,
    String? ngaySinh,
    String? gioiTinh,
    String? diaChi,
    String? soDienThoaiKhanCap,
    String? tienSuBenh,
  }) async {
    final response = await ApiClient.instance.createPatientProfile(
      hoTen: hoTen,
      moiQuanHe: moiQuanHe,
      ngaySinh: ngaySinh,
      gioiTinh: gioiTinh,
      diaChi: diaChi,
      soDienThoaiKhanCap: soDienThoaiKhanCap,
      tienSuBenh: tienSuBenh,
    );

    // Lấy mã hồ sơ trả về từ backend nếu có.
    final rawId = response['MaBenhNhan'] ?? response['maBenhNhan'];
    final newProfileId = int.tryParse(rawId?.toString() ?? '');

    // Tải lại danh sách nhưng không tự chuyển về hồ sơ mặc định.
    await loadProfiles(resetToDefault: false);

    // Tự động chọn hồ sơ vừa tạo nếu backend trả về mã hồ sơ.
    if (newProfileId != null) {
      final newProfile = _profiles.where(
        (profile) => profile.maBenhNhan == newProfileId,
      );

      if (newProfile.isNotEmpty) {
        _selectedProfile = newProfile.first;
        notifyListeners();
      }
    }
  }

  /// Chuyển sang hồ sơ bệnh nhân khác.
  void selectProfile(PatientProfile profile) {
    final exists = _profiles.any(
      (item) => item.maBenhNhan == profile.maBenhNhan,
    );

    if (!exists) return;

    _selectedProfile = profile;
    notifyListeners();
  }

  /// Xóa dữ liệu hồ sơ khi đăng xuất.
  void clear() {
    _profiles = [];
    _selectedProfile = null;
    _isLoading = false;
    notifyListeners();
  }
}