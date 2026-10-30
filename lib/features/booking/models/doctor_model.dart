class DoctorModel {
  final int maBacSi;
  final String hoTen;
  final String? chuyenMon;
  final String? trinhDo;
  final String? gioBatDau;
  final String? gioKetThuc;
  final int? maLichLamViec;
  final int? maPhong;
  final String? tenPhong;
  final String? soChungChiHanhNghe;
  final String? fileKey;

  const DoctorModel({
    required this.maBacSi,
    required this.hoTen,
    this.chuyenMon,
    this.trinhDo,
    this.gioBatDau,
    this.gioKetThuc,
    this.maLichLamViec,
    this.maPhong,
    this.tenPhong,
    this.soChungChiHanhNghe,
    this.fileKey,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      maBacSi: int.parse(
        (json['maBacSi'] ?? json['MaBacSi']).toString(),
      ),
      hoTen: (json['hoTen'] ??
              json['HoTen'] ??
              'Bác sĩ')
          .toString(),
      chuyenMon: (json['chuyenMon'] ?? json['ChuyenMon'])
          ?.toString(),
      trinhDo: (json['trinhDo'] ?? json['TrinhDo'])
          ?.toString(),
      gioBatDau: (json['gioBatDau'] ?? json['GioBatDau'])
          ?.toString(),
      gioKetThuc: (json['gioKetThuc'] ?? json['GioKetThuc'])
          ?.toString(),
      maLichLamViec: _parseNullableInt(
        json['maLichLamViec'] ?? json['MaLichLamViec'],
      ),
      maPhong: int.tryParse(
        '${json['maPhong'] ?? json['MaPhong'] ?? ''}',
      ),
      tenPhong: (json['tenPhong'] ?? json['TenPhong'])?.toString(),
      soChungChiHanhNghe: (
        json['soChungChiHanhNghe'] ??
        json['SoChungChiHanhNghe']
      )?.toString(),
      fileKey: (
        json['fileKey'] ??
        json['anhDaiDien'] ??
        json['AnhDaiDien']
      )?.toString(),
    );
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }
}
