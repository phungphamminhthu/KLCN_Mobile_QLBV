
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';

const Color primaryBlue = Color(0xFF2563EB);
const Color backgroundColor = Color(0xFFF8FAFC);
const Color textColor = Color(0xFF1E293B);
const Color secondaryTextColor = Color(0xFF64748B);
const Color borderColor = Color(0xFFE2E8F0);
const Color successColor = Color(0xFF059669);

class Invoice {
  final String id;
  final DateTime createdAt;
  final String description;
  final String department;
  final int amount;
  final String paymentMethod;
  final String transactionId;
  final DateTime paidAt;
  final DateTime appointmentDate;

  const Invoice({
    required this.id,
    required this.createdAt,
    required this.description,
    required this.department,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.paidAt,
    required this.appointmentDate,
  });
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<Invoice> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    if (!mounted || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appointmentResponse =
          await ApiClient.instance.get('/api/lich-kham/cua-toi');

      if (appointmentResponse is! List) {
        throw const FormatException(
          'Danh sách lịch khám không đúng định dạng.',
        );
      }

      final List<Invoice> loadedInvoices = [];
      final Set<String> seenInvoiceIds = {};
      final List<String> requestErrors = [];

      for (final item in appointmentResponse) {
        if (item is! Map) continue;
        final appointment = Map<String, dynamic>.from(item);
        final maLichKham = int.tryParse(
          (appointment['maLichKham'] ?? '').toString(),
        );
        if (maLichKham == null || maLichKham <= 0) continue;

        try {
          final response = await ApiClient.instance.get(
            '/api/thanh-toan/lich-kham/$maLichKham/hoa-don',
          );
          if (response is! List) continue;

          for (final invoiceItem in response) {
            if (invoiceItem is! Map) continue;
            final json = Map<String, dynamic>.from(invoiceItem);
            final rawId = json['maHoaDon'] ?? json['id'] ?? json['maHD'];
            if (rawId == null || rawId.toString().trim().isEmpty) continue;

            final invoiceId = rawId.toString().trim();
            if (seenInvoiceIds.contains(invoiceId)) continue;

            // API mới trả thanhToan dạng danh sách; vẫn hỗ trợ dạng object cũ.
            final List<Map<String, dynamic>> payments = [];
            final rawPayments = json['thanhToan'];
            if (rawPayments is List) {
              for (final p in rawPayments) {
                if (p is Map) payments.add(Map<String, dynamic>.from(p));
              }
            } else if (rawPayments is Map) {
              payments.add(Map<String, dynamic>.from(rawPayments));
            }

            final successfulPayments = payments.where((p) =>
                (p['trangThai'] ?? '').toString().trim().toLowerCase() ==
                'dathanhtoan').toList();

            // Trạng thái trong bảng ThanhToan mới là căn cứ xác nhận giao dịch.
            // Chỉ dùng trạng thái hóa đơn khi backend chưa trả danh sách thanh toán.
            final invoiceStatus = (json['trangThai'] ?? '')
                .toString().trim().toLowerCase();
            final isPaid = successfulPayments.isNotEmpty ||
                (payments.isEmpty && invoiceStatus == 'dathanhtoan');
            if (!isPaid) continue;

            successfulPayments.sort((a, b) =>
                _parseDate(b['ngayThanhToan']).compareTo(
                  _parseDate(a['ngayThanhToan']),
                ));
            final payment = successfulPayments.isNotEmpty
                ? successfulPayments.first
                : <String, dynamic>{};

            final rawDetails = json['chiTietHoaDon'];
            final detailTexts = <String>[];
            if (rawDetails is List) {
              for (final detailItem in rawDetails) {
                if (detailItem is! Map) continue;
                final detail = Map<String, dynamic>.from(detailItem);
                final content = (detail['noiDung'] ??
                        detail['tenDichVu'] ?? detail['moTa'] ?? '')
                    .toString().trim();
                if (content.isNotEmpty && !detailTexts.contains(content)) {
                  detailTexts.add(content);
                }
              }
            }

            final createdAt = _parseDate(
              json['ngayLapHoaDon'] ?? json['ngayTao'] ?? json['ngayLap'],
            );
            final paidAt = _parseDate(
              payment['ngayThanhToan'] ?? json['ngayThanhToan'],
            );

            debugPrint('========== PARSE HOA DON ==========');
            debugPrint('MA HOA DON: $invoiceId');
            final appointmentDate = _parseDate(appointment['ngayKham']);

            debugPrint(
              'NGAY KHAM: ${appointment['ngayKham']} -> $appointmentDate',
            );
            debugPrint('NGAY LAP: ${json['ngayLapHoaDon']} -> $createdAt');
            debugPrint('CHI TIET: $detailTexts');
            debugPrint('PAYMENT SUCCESS: $payment');
            debugPrint('NGAY THANH TOAN: ${payment['ngayThanhToan']} -> $paidAt');
            debugPrint('SO TIEN: ${payment['soTien'] ?? json['tongTien']}');
            debugPrint('===================================');

            seenInvoiceIds.add(invoiceId);
            loadedInvoices.add(Invoice(
              id: invoiceId,
              createdAt: createdAt,
              description: detailTexts.isNotEmpty
                  ? detailTexts.join(', ')
                  : (json['loaiHoaDon'] ?? json['noiDung'] ??
                      json['tenDichVu'] ?? 'Hóa đơn khám bệnh').toString(),
              department: (json['tenKhoa'] ?? appointment['tenKhoa'] ??
                  'Chưa cập nhật').toString(),
              amount: _parseAmount(payment['soTien'] ?? json['tongTien']),
              paymentMethod: (payment['phuongThucThanhToan'] ??
                  json['phuongThucThanhToan'] ?? 'Chưa cập nhật').toString(),
              transactionId: (payment['maGiaoDich'] ??
                  json['maGiaoDich'] ?? 'Chưa cập nhật').toString(),
              paidAt: paidAt,
              appointmentDate: appointmentDate,
            ));
          }
        } catch (_) {
          requestErrors.add('Không tải được hóa đơn của lịch khám $maLichKham.');
        }
      }

      loadedInvoices.sort((a, b) => b.paidAt.compareTo(a.paidAt));
      if (!mounted) return;
      setState(() {
        _invoices = loadedInvoices;
        _isLoading = false;
        _errorMessage = loadedInvoices.isEmpty && requestErrors.isNotEmpty
            ? 'Không thể tải được hóa đơn. Vui lòng thử lại.'
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e is ApiException
            ? e.message
            : e is FormatException
                ? e.message
                : 'Không thể tải lịch sử hóa đơn. Vui lòng thử lại.';
      });
    }
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime(2000);
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime(2000);
  }

  int _parseAmount(dynamic value) {
    if (value is num) return value.round();
    if (value == null) return 0;

    var text = value.toString().trim();
    if (text.isEmpty) return 0;

    // Hỗ trợ chuỗi tiền VND dạng "1.500.000" hoặc "1,500,000".
    text = text.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (text.contains('.') && text.contains(',')) {
      // Dấu phân cách xuất hiện cuối cùng được coi là dấu thập phân.
      if (text.lastIndexOf(',') > text.lastIndexOf('.')) {
        text = text.replaceAll('.', '').replaceAll(',', '.');
      } else {
        text = text.replaceAll(',', '');
      }
    } else if (RegExp(r'^-?\d{1,3}(\.\d{3})+$').hasMatch(text) ||
        RegExp(r'^-?\d{1,3}(,\d{3})+$').hasMatch(text)) {
      text = text.replaceAll('.', '').replaceAll(',', '');
    } else if (text.contains(',')) {
      text = text.replaceAll(',', '.');
    }

    return double.tryParse(text)?.round() ?? 0;
  }


  List<Invoice> get _filteredInvoices {
    final keyword = _searchController.text.trim().toLowerCase();

    return _invoices.where((invoice) {
      return invoice.id.toLowerCase().contains(keyword) ||
          invoice.description.toLowerCase().contains(keyword) ||
          invoice.department.toLowerCase().contains(keyword);
    }).toList()
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
  }

  int get _totalPaid =>
      _invoices.fold(0, (total, invoice) => total + invoice.amount);

  String _formatMoney(int amount) {
    final value = amount.toString();
    final result = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      result.write(value[i]);

      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        result.write('.');
      }
    }

    return '${result.toString()} đ';
  }

  String _formatDate(DateTime date) {
    if (date.year == 2000) return 'Chưa cập nhật';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDateTime(DateTime date) {
    if (date.year == 2000) return 'Chưa cập nhật';
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoices = _filteredInvoices;

    return Scaffold(
    backgroundColor: backgroundColor,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: textColor,
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Hóa đơn',
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: _isLoading ? null : _loadInvoices,
          icon: const Icon(Icons.refresh),
          color: textColor,
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_off_outlined,
                                size: 52,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Không thể tải hóa đơn',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _loadInvoices,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadInvoices,
                        child: ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            24,
                          ),
                          children: [
                            _buildSummaryCard(),
                            const SizedBox(height: 20),
                            _buildSearchField(),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Lịch sử thanh toán',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${invoices.length} hóa đơn',
                                  style: const TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (invoices.isEmpty)
                              _buildEmptyState()
                            else
                              ...invoices.map(
                                (invoice) => Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child: _buildInvoiceCard(invoice),
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Thông tin hóa đơn được cung cấp bởi MedCare.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF0EA5E9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const Icon(
                Icons.verified_user_outlined,
                color: Colors.white70,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Hóa đơn của bạn',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Theo dõi lịch sử thanh toán tại MedCare.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  value: '${_invoices.length}',
                  label: 'Hóa đơn đã trả',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  value: _formatMoney(_totalPaid),
                  label: 'Tổng đã thanh toán',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Tìm theo mã hóa đơn, dịch vụ...',
        hintStyle: const TextStyle(
          color: secondaryTextColor,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: secondaryTextColor,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showInvoiceDetails(invoice),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: successColor,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hóa đơn ${invoice.id}',
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Ngày tạo ${_formatDate(invoice.createdAt)}',
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ngày khám: ${_formatDate(invoice.appointmentDate)}',
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      'Đã thanh toán',
                      style: TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                invoice.description,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      invoice.department,
                      style: const TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: borderColor),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    _formatMoney(invoice.amount),
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 35,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có hóa đơn phù hợp',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các hóa đơn đã thanh toán sẽ hiển thị tại đây.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Chi tiết hóa đơn',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: successColor,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Thanh toán thành công',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      _formatMoney(invoice.amount),
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _detailRow('Mã hóa đơn', invoice.id),
                  _detailRow('Nội dung', invoice.description),
                  _detailRow('Khoa / bộ phận', invoice.department),
                  _detailRow(
                    'Ngày tạo',
                    _formatDateTime(invoice.createdAt),
                  ),
                  _detailRow(
                    'Ngày thanh toán',
                    _formatDateTime(invoice.paidAt),
                  ),
                  _detailRow(
                    'Phương thức',
                    invoice.paymentMethod,
                  ),
                  _detailRow(
                    'Mã giao dịch',
                    invoice.transactionId,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
