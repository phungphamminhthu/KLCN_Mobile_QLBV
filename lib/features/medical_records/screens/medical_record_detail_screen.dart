import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/network/api_client.dart';

class MedicalRecordDetailScreen extends StatefulWidget {
  final int maHoSoBenhAn;
  const MedicalRecordDetailScreen({super.key, required this.maHoSoBenhAn});

  @override
  State<MedicalRecordDetailScreen> createState() => _MedicalRecordDetailScreenState();
}

class _MedicalRecordDetailScreenState extends State<MedicalRecordDetailScreen> {
  static const String qrWebBaseUrl = String.fromEnvironment(
    'QR_WEB_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
  static const primary = Color(0xFF2563EB);
  static const background = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  Map<String, dynamic>? detail;
  String? error, qrToken, qrError;
  bool loading = true, qrLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final response = await ApiClient.instance.get('/api/medical-records/${widget.maHoSoBenhAn}');
      if (response is! Map) throw Exception('Dữ liệu chi tiết hồ sơ không hợp lệ.');
      if (!mounted) return;
      setState(() { detail = Map<String, dynamic>.from(response); loading = false; });
      await _loadQr();
    } catch (e) {
      if (!mounted) return;
      setState(() { error = e is ApiException ? e.message : 'Không thể tải chi tiết hồ sơ. Vui lòng thử lại.'; loading = false; });
    }
  }

  String _buildQrUrl() {
  return Uri.parse(qrWebBaseUrl)
      .replace(
        path: '/medical-records/qr',
        queryParameters: {'token': qrToken!},
      )
      .toString();
}

  Future<void> _loadQr() async {
    setState(() { qrLoading = true; qrError = null; });
    try {
      final response = await ApiClient.instance.get('/api/medical-records/${widget.maHoSoBenhAn}/qr-token');
      final token = response is Map ? (response['qrToken'] ?? response['token'])?.toString() : null;
      if (token == null || token.trim().isEmpty) throw Exception('Máy chủ chưa trả về QR token.');
      if (!mounted) return;
      setState(() { qrToken = token; qrLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { qrError = e is ApiException ? e.message : 'Chưa tải được mã QR.'; qrLoading = false; });
    }
  }

  String val(Map? m, String key, [String? alt]) {
    final v = m?[key] ?? (alt == null ? null : m?[alt]);
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') return '';
    return v.toString();
  }
  String date(dynamic v) {
    if (v == null || v.toString().isEmpty) return 'Chưa cập nhật';
    final d = DateTime.tryParse(v.toString());
    return d == null ? v.toString() : '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }
  String money(dynamic v) {
    final n = v is num ? v.round() : int.tryParse('$v') ?? 0;
    final s = n.toString(); final b = StringBuffer();
    for (var i=0; i<s.length; i++) { b.write(s[i]); if (i < s.length-1 && (s.length-i-1)%3==0) b.write('.'); }
    return '${b.toString()} đ';
  }
  List<Map<String,dynamic>> maps(dynamic v) => v is List ? v.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList() : [];
  String statusLabel(String s) => switch (s.toLowerCase()) {
    'chokham' => 'Chờ khám', 'datiepnhan' => 'Đã tiếp nhận', 'dangkham' => 'Đang khám',
    'chocls' => 'Chờ cận lâm sàng', 'dangcls' => 'Đang cận lâm sàng', 'hoantat' => 'Hoàn tất',
    'dahuy' => 'Đã hủy', 'khongden' => 'Không đến', _ => s.isEmpty ? 'Chưa cập nhật' : s,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0,
      leading: IconButton(onPressed: ()=>Navigator.maybePop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20)),
      title: const Text('Chi tiết bệnh án', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800))),
    body: loading ? const Center(child: CircularProgressIndicator(color: primary)) : error != null ? Center(child: Padding(
      padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_outlined, size: 48, color: textSecondary), const SizedBox(height: 12),
        Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: textSecondary)), const SizedBox(height: 16),
        FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Thử lại'), style: FilledButton.styleFrom(backgroundColor: primary)),
      ]))) : RefreshIndicator(color: primary, onRefresh: _load, child: _content(detail!),),
  );

  Widget _content(Map<String,dynamic> d) {
    final status = val(d,'trangThai','TrangThai');
    final costs = d['chiPhi'] is Map ? Map<String,dynamic>.from(d['chiPhi']) : <String,dynamic>{};
    final orders = maps(d['chiDinh']); final prescriptions = maps(d['donThuoc']); final invoices = maps(d['hoaDon']);
    final sys = val(d,'huyetApTamThu','HuyetApTamThu'); final dia = val(d,'huyetApTamTruong','HuyetApTamTruong');
    if (qrToken != null) {
      debugPrint('QR WEB URL: ${_buildQrUrl()}');
    }
    return ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(16,16,16,30), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors:[Color(0xFF2563EB),Color(0xFF0EA5E9)]), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        const Icon(Icons.folder_shared_outlined,color:Colors.white,size:30), const SizedBox(height:12),
        Text('Hồ sơ #${widget.maHoSoBenhAn}',style: const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w800)),
        Text('Ngày khám: ${date(d['ngayKham'] ?? d['NgayKham'])}',style: const TextStyle(color:Colors.white70)), const SizedBox(height:12),
        Container(padding: const EdgeInsets.symmetric(horizontal:11,vertical:7), decoration: BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(9)), child: Text(statusLabel(status),style: const TextStyle(color:primary,fontWeight:FontWeight.w800))),
      ])),
      _section('Thông tin khám bệnh', Icons.medical_information_outlined, [
        _field('Giờ khám',val(d,'gioKham','GioKham')), _field('Bác sĩ',val(d,'tenBacSi','TenBacSi')), _field('Chuyên khoa',val(d,'tenKhoa','TenKhoa')),
        _field('Lý do khám',val(d,'lyDoKham','LyDoKham')), _field('Triệu chứng',val(d,'trieuChung','TrieuChung')), _field('Chẩn đoán',val(d,'chanDoan','ChanDoan')),
        _field('Kết luận',val(d,'ketLuan','KetLuan')), _field('Hướng điều trị',val(d,'huongDieuTri','HuongDieuTri')),
      ]),
      _section('Chỉ số sức khỏe',Icons.monitor_heart_outlined,[
        _field('Cân nặng',val(d,'canNang','CanNang').isEmpty?'':'${val(d,'canNang','CanNang')} kg'),
        _field('Chiều cao',val(d,'chieuCao','ChieuCao').isEmpty?'':'${val(d,'chieuCao','ChieuCao')} cm'),
        _field('Huyết áp',sys.isEmpty && dia.isEmpty ? '' : '${sys.isEmpty?'--':sys}/${dia.isEmpty?'--':dia} mmHg'),
      ]),
      _section('Chỉ định y tế',Icons.biotech_outlined, orders.isEmpty ? [_empty('Chưa có chỉ định y tế.')] : orders.map(_order).toList()),
      _section('Đơn thuốc',Icons.medication_outlined,prescriptions.isEmpty ? [_empty('Chưa có đơn thuốc.')] : prescriptions.map(_prescription).toList()),
      _section('Chi phí khám bệnh',Icons.receipt_long_outlined,[
        _cost('Phí khám',costs['phiKham']),_cost('Phí chỉ định',costs['phiChiDinh']),_cost('Tiền thuốc',costs['tienThuoc']),
        const Divider(),_cost('Tổng tiền hóa đơn',costs['tongCong'],bold:true),
        if(invoices.isNotEmpty) ...invoices.map(_invoice),
      ]),
      _section('Lịch tái khám',Icons.event_available_outlined,[
        _field('Ngày tái khám',val(d,'ngayTaiKham','NgayTaiKham').isEmpty?'':date(d['ngayTaiKham'] ?? d['NgayTaiKham'])),
        _field('Ghi chú',val(d,'ghiChuTaiKham','GhiChuTaiKham')),
      ]),
      _section('Mã QR hồ sơ', Icons.qr_code_2_rounded, [
            if (qrLoading)
                const Center(
                child: Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(color: primary),
                ),
                )
            else if (qrToken != null)
                Center(
                // child: Column(
                //     children: [
                //     Container(
                //         padding: const EdgeInsets.all(12),
                //         decoration: BoxDecoration(
                //         border: Border.all(color: border),
                //         borderRadius: BorderRadius.circular(14),
                //         ),
                //         child: 
                //         // QrImageView(
                //         // data: Uri(
                //         //     scheme: Uri.parse(qrWebBaseUrl).scheme,
                //         //     host: Uri.parse(qrWebBaseUrl).host,
                //         //     port: Uri.parse(qrWebBaseUrl).hasPort
                //         //         ? Uri.parse(qrWebBaseUrl).port
                //         //         : null,
                //         //     path: '/medical-records/qr',
                //         //     queryParameters: {'token': qrToken!},
                //         // ).toString(),
                //         // version: QrVersions.auto,
                //         // size: 190,
                //         // ),
                //         final qrUrl = Uri.parse(qrWebBaseUrl)
                //             .replace(
                //             path: '/medical-records/qr',
                //             queryParameters: {'token': qrToken!},
                //             )
                //             .toString();

                //         debugPrint('QR WEB URL: $qrUrl');
                //         QrImageView(
                //             data: Uri.parse(qrWebBaseUrl)
                //                 .replace(
                //                     path: '/medical-records/qr',
                //                     queryParameters: {'token': qrToken!},
                //                 )
                //                 .toString(),
                //             version: QrVersions.auto,
                //             size: 190,
                //         )   
                //     ),
                //     const SizedBox(height: 8),
                //     const Text(
                //         'Quét mã QR để mở trang hồ sơ bệnh án.',
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //         color: textSecondary,
                //         fontSize: 12,
                //         ),
                //     ),
                //     ],
                // ),
                child: QrImageView(
                    data: _buildQrUrl(),
                    version: QrVersions.auto,
                    size: 190,
                    ),
                )
            else
                Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                    qrError ?? 'Chưa có mã QR.',
                    style: const TextStyle(color: textSecondary),
                    ),
                    TextButton.icon(
                    onPressed: _loadQr,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại mã QR'),
                    ),
                ],
                ),
            ]),
      const SizedBox(height:10), const Text('Thông tin được hiển thị theo hồ sơ đã lưu tại bệnh viện.',textAlign:TextAlign.center,style:TextStyle(color:textSecondary,fontSize:11)),
    ]);
  }

  Widget _section(String title, IconData icon, List<Widget> children) => Container(margin:const EdgeInsets.only(top:14),padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(17),border:Border.all(color:border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Icon(icon,color:primary,size:21),const SizedBox(width:9),Expanded(child:Text(title,style:const TextStyle(color:textPrimary,fontSize:15,fontWeight:FontWeight.w800)))]),const SizedBox(height:14),...children,
  ]));
  Widget _field(String label,String value) => value.trim().isEmpty ? const SizedBox.shrink() : Padding(padding:const EdgeInsets.only(bottom:11),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(color:textSecondary,fontSize:12)),const SizedBox(height:4),Text(value,style:const TextStyle(color:textPrimary,fontSize:13,height:1.45,fontWeight:FontWeight.w500))]));
  Widget _empty(String s) => Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Text(s,style:const TextStyle(color:textSecondary,fontSize:13)));
  Widget _cost(String label,dynamic amount,{bool bold=false}) => Padding(padding:const EdgeInsets.symmetric(vertical:4),child:Row(children:[Expanded(child:Text(label,style:TextStyle(color:bold?textPrimary:textSecondary,fontSize:bold?14:12,fontWeight:bold?FontWeight.w800:FontWeight.w500))),Text(money(amount),style:TextStyle(color:bold?primary:textPrimary,fontWeight:FontWeight.w800,fontSize:bold?15:12))]));
  Widget _order(Map<String,dynamic> m) => Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:background,borderRadius:BorderRadius.circular(11)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text(val(m,'tenDichVu','TenDichVu').isEmpty?'Dịch vụ y tế':val(m,'tenDichVu','TenDichVu'),style:const TextStyle(fontWeight:FontWeight.w700,color:textPrimary)),
    _field('Loại chỉ định',val(m,'loaiChiDinh','LoaiChiDinh')),_field('Ngày chỉ định',date(m['ngayChiDinh'] ?? m['NgayChiDinh'])),_field('Trạng thái',statusLabel(val(m,'trangThai','TrangThai'))),_field('Đơn giá tham khảo',money(m['donGia'])),
  ]));
  Widget _prescription(Map<String,dynamic> m) {
    final meds=maps(m['chiTiet']);
    return Container(margin:const EdgeInsets.only(bottom:9),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:background,borderRadius:BorderRadius.circular(11)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Đơn thuốc #${val(m,'maDonThuoc','MaDonThuoc')}',style:const TextStyle(fontWeight:FontWeight.w800,color:textPrimary)),
      _field('Ngày kê',date(m['ngayKeThuoc'] ?? m['NgayKeThuoc'])),_field('Chẩn đoán',val(m,'chanDoan','ChanDoan')),_field('Ghi chú',val(m,'ghiChu','GhiChu')),
      if(meds.isEmpty) _empty('Chưa có thuốc trong đơn.') else ...meds.map((t)=>Container(margin:const EdgeInsets.only(top:7),padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(9),border:Border.all(color:border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(val(t,'tenThuoc','TenThuoc').isEmpty?'Thuốc':val(t,'tenThuoc','TenThuoc'),style:const TextStyle(fontWeight:FontWeight.w700,color:textPrimary)),
        _field('Số lượng','${val(t,'soLuong','SoLuong')} ${val(t,'donViTinh','DonViTinh')}'),_field('Đơn giá',money(t['donGia'])),_field('Thành tiền',money(t['thanhTien'])),_field('Liều dùng',val(t,'lieuDung','LieuDung')),_field('Thời gian dùng',val(t,'thoiGianDung','ThoiGianDung')),_field('Hướng dẫn',val(t,'huongDanSuDung','HuongDanSuDung')),
      ]))),_cost('Tổng đơn thuốc',m['tongTien'],bold:true),
    ]));
  }
  Widget _invoice(Map<String,dynamic> m) {
    final lines=maps(m['chiTiet']);
    return Container(margin:const EdgeInsets.only(top:10),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:background,borderRadius:BorderRadius.circular(11)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Hóa đơn #${val(m,'maHoaDon','MaHoaDon')}',style:const TextStyle(fontWeight:FontWeight.w800,color:textPrimary)),
      _field('Ngày lập',date(m['ngayLapHoaDon'] ?? m['NgayLapHoaDon'])),_field('Loại hóa đơn',val(m,'loaiHoaDon','LoaiHoaDon')),_field('Trạng thái thanh toán',val(m,'trangThai','TrangThai')),
      if(lines.isNotEmpty) ...lines.map((line)=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[Expanded(child:Text(val(line,'noiDung','NoiDung').isEmpty?'Khoản thu':val(line,'noiDung','NoiDung'),style:const TextStyle(fontSize:12,color:textPrimary))),Text(money(line['thanhTien']),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w700))]))),
      _cost('Tổng hóa đơn',m['tongTien'],bold:true),
    ]));
  }
}
