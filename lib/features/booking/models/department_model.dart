
 // ======================================
 // BẢNG KHOA
 // ======================================
class DepartmentModel {
  final int maKhoa;
  final String tenKhoa;
  final String? moTa;
  final double giaKham;

  const DepartmentModel({
    required this.maKhoa,
    required this.tenKhoa,
    this.moTa,
    required this.giaKham,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      maKhoa: (json['maKhoa'] ?? json['MaKhoa']) as int,
      tenKhoa: (json['tenKhoa'] ?? json['TenKhoa']).toString(),
      moTa: (json['moTa'] ?? json['MoTa'])?.toString(),
      giaKham: double.tryParse(
            (json['giaKham'] ?? json['GiaKham'] ?? 0).toString(),
          ) ??
          0,
    );
  }
}
