import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import 'package:intl/intl.dart';

class PaymentQrScreen extends StatefulWidget {
  final int maHoaDon;

  const PaymentQrScreen({super.key, required this.maHoaDon});

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  static const Color primary = Color(0xFF078DBB);
  static const Color textPrimary = Color(0xFF1E293B);

  Map<String, dynamic>? _data;
  Timer? _timer;

  bool _loading = true;
  bool _checking = false;
  String? _error;
  bool _paid = false;

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQr() async {
    try {
      final response = await ApiClient.instance.get(
        '/api/thanh-toan/hoa-don/${widget.maHoaDon}/qr',
      );

      if (!mounted) return;

      setState(() {
        _data = Map<String, dynamic>.from(response as Map);
        _loading = false;
      });

      await _checkStatus();

      if (mounted && !_paid) {
        _timer = Timer.periodic(
          const Duration(seconds: 3),
          (_) => _checkStatus(),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _checkStatus() async {
    if (_checking || _paid || !mounted) return;

    _checking = true;

    try {
      final response = await ApiClient.instance.get(
        '/api/thanh-toan/hoa-don/'
        '${widget.maHoaDon}/trang-thai',
      );

      if (!mounted) return;

      final data = Map<String, dynamic>.from(response as Map);
      final status = data['trangThai']?.toString();

      if (status == 'DaThanhToan') {
        _timer?.cancel();

        setState(() {
          _paid = true;
          _data = {...?_data, ...data};
        });
      } else if (status == 'DaHuy') {
        _timer?.cancel();

        setState(() {
          _error = 'Hóa đơn đã bị hủy.';
        });
      }
    } catch (_) {
      // Lỗi mạng tạm thời: lần kiểm tra tiếp theo sẽ thử lại.
    } finally {
      _checking = false;
    }
  }

  //   String _formatMoney(dynamic value) {
  //     final amount = double.tryParse(value?.toString() ?? '') ?? 0;
  //     return '${amount.toStringAsFixed(0)} đ';
  //   }

  String _formatMoney(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    return '${NumberFormat('#,##0', 'vi_VN').format(amount)}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      //   appBar: AppBar(
      //     title: const Text('Thanh toán hóa đơn'),
      //     backgroundColor: Colors.white,
      //     foregroundColor: textPrimary,
      //     elevation: 0,
      //   ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
        //   color: primary, // Icon quay lại màu xanh
        //   onPressed: () => Navigator.pop(context),
        // ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thanh toán hóa đơn',
          style: TextStyle(
            color: textPrimary, // Chữ tiêu đề màu xanh đen
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _data == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        _loadQr();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          : _buildContent(primary),
    );
  }

  //   Widget _buildContent(Color primary) {
  //     final qrUrl = _data?['qrUrl']?.toString() ?? '';
  //     final amount = _formatMoney(_data?['soTien']);
  //     final content =
  //         _data?['noiDungChuyenKhoan']?.toString() ?? '';

  //     return ListView(
  //       padding: const EdgeInsets.all(20),
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           child: Column(
  //             children: [
  //               Icon(
  //                 _paid ? Icons.check_circle : Icons.qr_code_2,
  //                 size: 48,
  //                 color: _paid ? Colors.green : primary,
  //               ),
  //               const SizedBox(height: 12),
  //               Text(
  //                 _paid ? 'Thanh toán thành công' : 'Quét mã để thanh toán',
  //                 style: const TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Hóa đơn #${widget.maHoaDon}',
  //                 style: const TextStyle(color: Colors.blueGrey),
  //               ),
  //               const SizedBox(height: 20),
  //               Text(
  //                 amount,
  //                 style: TextStyle(
  //                   color: primary,
  //                   fontSize: 28,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               if (!_paid) ...[
  //                 const SizedBox(height: 20),
  //                 if (qrUrl.isNotEmpty)
  //                   Image.network(
  //                     qrUrl,
  //                     width: 240,
  //                     height: 240,
  //                     fit: BoxFit.contain,
  //                     errorBuilder: (_, __, ___) => const Text(
  //                       'Không tải được ảnh QR. Vui lòng thử lại.',
  //                     ),
  //                   ),
  //                 const SizedBox(height: 16),
  //                 const Text(
  //                   'Nội dung chuyển khoản',
  //                   style: TextStyle(color: Colors.blueGrey),
  //                 ),
  //                 const SizedBox(height: 6),
  //                 SelectableText(
  //                   content,
  //                   style: const TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 const Text(
  //                   'Giữ nguyên số tiền và nội dung chuyển khoản '
  //                   'để hệ thống nhận diện giao dịch.',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(color: Colors.blueGrey),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 const Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     SizedBox(
  //                       width: 18,
  //                       height: 18,
  //                       child: CircularProgressIndicator(strokeWidth: 2),
  //                     ),
  //                     SizedBox(width: 10),
  //                     Flexible(
  //                       child: Text('Đang chờ xác nhận từ ngân hàng...'),
  //                     ),
  //                   ],
  //                 ),
  //               ] else ...[
  //                 const SizedBox(height: 16),
  //                 const Text(
  //                   'Hệ thống đã xác nhận hóa đơn được thanh toán.',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(color: Colors.green),
  //                 ),
  //               ],
  //               if (_error != null && _data != null) ...[
  //                 const SizedBox(height: 12),
  //                 Text(
  //                   _error!,
  //                   style: const TextStyle(color: Colors.red),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         OutlinedButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(_paid);
  //           },
  //           child: Text(_paid ? 'Hoàn tất' : 'Quay lại'),
  //         ),
  //       ],
  //     );
  //   }

  Widget _buildContent(Color primary) {
    final qrUrl = _data?['qrUrl']?.toString() ?? '';
    final amount = _formatMoney(_data?['soTien']);
    final content = _data?['noiDungChuyenKhoan']?.toString() ?? '';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Khung nội dung thanh toán
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _paid ? Icons.check_circle : Icons.qr_code_2,
                size: 48,
                color: _paid ? Colors.green : primary,
              ),
              const SizedBox(height: 12),

              Text(
                _paid ? 'Thanh toán thành công' : 'Quét mã để thanh toán',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Hóa đơn #${widget.maHoaDon}',
                style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),

              Text(
                amount,
                style: TextStyle(
                  color: primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (_paid) ...[
                const SizedBox(height: 20),
                const Text(
                  'Hệ thống đã xác nhận hóa đơn được thanh toán.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF65A779), fontSize: 14),
                ),
              ] else ...[
                const SizedBox(height: 20),

                if (qrUrl.isNotEmpty)
                  Image.network(
                    qrUrl,
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'Không tải được ảnh QR. Vui lòng thử lại.',
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),
                const Text(
                  'Nội dung chuyển khoản',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                const SizedBox(height: 6),

                SelectableText(
                  content,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Giữ nguyên số tiền và nội dung chuyển khoản '
                  'để hệ thống nhận diện giao dịch.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                ),

                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Flexible(child: Text('Đang chờ xác nhận từ ngân hàng...')),
                  ],
                ),
              ],

              if (_error != null && _data != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Nút bên ngoài khung
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop(_paid);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: const BorderSide(color: Color(0xFFB8B8B8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(_paid ? 'Hoàn tất' : 'Quay lại'),
          ),
        ),
      ],
    );
  }
}
