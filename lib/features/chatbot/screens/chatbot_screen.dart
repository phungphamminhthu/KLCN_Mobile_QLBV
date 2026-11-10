
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../controllers/chatbot_controller.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController = ScrollController();

  late final ChatbotController _chatbotController;

  static const Color primaryColor = Color(0xFF0284C7);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryColor = Color(0xFF64748B);

  final List<String> _suggestions = [
    'Bệnh viện có những chuyên khoa nào?',
    'Các dịch vụ y tế hiện có?',
    'Xét nghiệm công thức máu gồm những gì?',
    'Quy trình đăng ký khám bệnh?',
  ];

  @override
  void initState() {
    super.initState();

    _chatbotController = ChatbotController();
    _chatbotController.addListener(_onChatbotChanged);

    _chatbotController.initialize();
  }

  @override
  void dispose() {
    _chatbotController.removeListener(_onChatbotChanged);
    _chatbotController.dispose();

    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onChatbotChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Chưa xác định thời gian';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year ${_formatTime(date)}';
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

    Future<void> _sendMessage([String? suggestedMessage]) async {
        final message =
            (suggestedMessage ?? _messageController.text).trim();

        if (message.isEmpty || _chatbotController.isSending) {
        return;
        }

        if (!_chatbotController.initialized) {
        _showSnackBar(
            _chatbotController.errorMessage ??
                'Chatbot chưa sẵn sàng. Vui lòng thử lại.',
        );
        return;
        }

        FocusScope.of(context).unfocus();

        final success = await _chatbotController.sendMessage(message);

        if (!mounted) return;

        if (success) {
        if (suggestedMessage == null) {
            _messageController.clear();
        }

        _scrollToBottom();
        } else {
        _showSnackBar(
            _chatbotController.errorMessage ??
                'Không thể gửi tin nhắn. Vui lòng thử lại.',
        );
        }
    }

  // =====================================================
  // CREATE NEW CONVERSATION
  // =====================================================

  Future<void> _createNewConversation() async {
    if (_chatbotController.isSending) {
      _showSnackBar(
        'Vui lòng đợi AI trả lời xong trước khi tạo cuộc trò chuyện mới.',
      );
      return;
    }

    final success =
        await _chatbotController.createNewConversation();

    if (!mounted) return;

    if (success) {
      _messageController.clear();
      _scrollToBottom();

      _showSnackBar('Đã tạo cuộc trò chuyện mới.');
    } else {
      _showSnackBar(
        _chatbotController.errorMessage ??
            'Không thể tạo cuộc trò chuyện mới.',
      );
    }
  }

  // =====================================================
  // OPEN CONVERSATION
  // =====================================================

  Future<void> _openConversation(
    int sessionId,
    BuildContext sheetContext,
  ) async {
    if (_chatbotController.isSending) {
      _showSnackBar(
        'Vui lòng đợi AI trả lời xong trước khi chuyển cuộc trò chuyện.',
      );
      return;
    }

    Navigator.pop(sheetContext);

    final success =
        await _chatbotController.openConversation(sessionId);

    if (!mounted) return;

    if (success) {
      _messageController.clear();
      _scrollToBottom();
    } else {
      _showSnackBar(
        _chatbotController.errorMessage ??
            'Không thể mở cuộc trò chuyện.',
      );
    }
  }

  // =====================================================
  // DELETE CONVERSATION
  // =====================================================

  Future<void> _deleteConversation(
    ChatbotConversation conversation,
    BuildContext sheetContext,
    StateSetter setModalState,
  ) async {
    if (_chatbotController.isSending) {
      _showSnackBar(
        'Không thể xóa cuộc trò chuyện khi AI đang trả lời.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa cuộc trò chuyện'),
          content: Text(
            'Bạn có chắc chắn muốn xóa cuộc trò chuyện '
            '"${conversation.tieuDe}" không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final success = await _chatbotController
        .deleteConversationById(conversation.maPhien);

    if (!mounted) return;

    if (!success) {
      _showSnackBar(
        _chatbotController.errorMessage ??
            'Không thể xóa cuộc trò chuyện.',
      );
      return;
    }

    // Nếu cuộc trò chuyện đang mở vừa bị xóa,
    // tạo một cuộc trò chuyện mới để người dùng tiếp tục.
    if (!_chatbotController.initialized) {
      final created =
          await _chatbotController.createNewConversation();

      if (!mounted) return;

      if (!created) {
        _showSnackBar(
          _chatbotController.errorMessage ??
              'Đã xóa nhưng không thể tạo cuộc trò chuyện mới.',
        );
      }
    }

    await _chatbotController.loadConversations();

    if (!mounted) return;

    setModalState(() {});

    _messageController.clear();

    if (_chatbotController.initialized) {
      _scrollToBottom();
    }

    _showSnackBar('Đã xóa cuộc trò chuyện.');
  }

  // =====================================================
  // CONVERSATION HISTORY
  // =====================================================

  Future<void> _showConversationHistory() async {
    if (_chatbotController.isSending) {
      _showSnackBar(
        'Vui lòng đợi AI trả lời xong trước khi xem lịch sử.',
      );
      return;
    }

    await _chatbotController.loadConversations();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final conversations =
                _chatbotController.conversations;

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  children: [
                    // Thanh kéo
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        18,
                        12,
                        14,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Lịch sử trò chuyện',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      color: Color(0xFFE2E8F0),
                    ),

                    // Danh sách
                    Expanded(
                      child: _chatbotController
                              .isLoadingConversations
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                          : conversations.isEmpty
                              ? _buildEmptyHistory()
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: conversations.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final conversation =
                                        conversations[index];

                                    return _buildConversationItem(
                                      conversation,
                                      sheetContext,
                                      setModalState,
                                    );
                                  },
                                ),
                    ),

                    // Nút tạo cuộc trò chuyện mới
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        10,
                        16,
                        16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(sheetContext);
                            await _createNewConversation();
                          },
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Cuộc trò chuyện mới',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_outlined,
                color: primaryColor,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử trò chuyện',
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Các cuộc trò chuyện của bạn sẽ được lưu tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(
    ChatbotConversation conversation,
    BuildContext sheetContext,
    StateSetter setModalState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _openConversation(
                  conversation.maPhien,
                  sheetContext,
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: primaryColor,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.tieuDe,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                            ),
                            ),
                          const SizedBox(height: 5),
                          Text(
                            _formatDate(
                              conversation.thoiGianBatDau,
                            ),
                            style: const TextStyle(
                              color: secondaryColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Xóa cuộc trò chuyện',
            onPressed: () {
              _deleteConversation(
                conversation,
                sheetContext,
                setModalState,
              );
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFEF4444),
              size: 21,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  // =====================================================
  // SNACK BAR
  // =====================================================

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // =====================================================
  // SCROLL
  // =====================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildNotice(),
            Expanded(
              child: _buildMessageList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // APP BAR
  // =====================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textColor,
          size: 20,
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: primaryColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý AI bệnh viện',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF22C55E),
                      size: 8,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Trợ lý tư vấn trực tuyến',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Lịch sử trò chuyện',
          onPressed: _showConversationHistory,
          icon: const Icon(
            Icons.history_rounded,
            color: secondaryColor,
          ),
        ),
        IconButton(
          tooltip: 'Cuộc trò chuyện mới',
          onPressed: _createNewConversation,
          icon: const Icon(
            Icons.add_comment_outlined,
            color: primaryColor,
          ),
        ),
        IconButton(
          tooltip: 'Thông tin',
          onPressed: _showChatInfo,
          icon: const Icon(
            Icons.info_outline_rounded,
            color: secondaryColor,
          ),
        ),
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  // =====================================================
  // NOTICE
  // =====================================================

  Widget _buildNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      color: const Color(0xFFEFF6FF),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: primaryColor,
            size: 17,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Thông tin AI cung cấp chỉ mang tính tham khảo, '
              'không thay thế tư vấn trực tiếp từ bác sĩ.',
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MESSAGE LIST
  // =====================================================

  Widget _buildMessageList() {
    final messages = _chatbotController.messages;

    final showWelcome = messages.isEmpty;
    final showTyping = _chatbotController.isSending;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: messages.length +
          (showTyping ? 1 : 0) +
          (showWelcome ? 1 : 0),
      itemBuilder: (context, index) {
        if (showWelcome && index == 0) {
          return _buildWelcomeMessage();
        }

        if (index < messages.length) {
          return _buildMessageItem(messages[index]);
        }

        return _buildTypingIndicator();
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return _buildAiMessage(
      ChatbotMessage(
        noiDung:
            'Xin chào! Tôi là trợ lý AI của bệnh viện. '
            'Tôi có thể hỗ trợ bạn tìm hiểu thông tin chuyên khoa, '
            'dịch vụ y tế, xét nghiệm và quy trình khám bệnh.\n\n'
            'Bạn cần tôi hỗ trợ thông tin gì hôm nay?',
        nguoiGui: 'AI',
        thoiGianTao: DateTime.now(),
      ),
    );
  }

  Widget _buildMessageItem(ChatbotMessage message) {
    if (message.isUser) {
      return _buildUserMessage(message);
    }

    return _buildAiMessage(message);
  }

  // =====================================================
  // USER MESSAGE
  // =====================================================

  Widget _buildUserMessage(ChatbotMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.noiDung,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _formatTime(message.thoiGianTao),
            style: const TextStyle(
              color: secondaryColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  // ====================================================
  // BUILD BẢNG
  // ===================================================
    // =====================================================
  // MARKDOWN STYLE
  // =====================================================

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      p: const TextStyle(
        color: textColor,
        fontSize: 14,
        height: 1.55,
      ),
      strong: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.w700,
      ),
      em: const TextStyle(
        color: textColor,
        fontStyle: FontStyle.italic,
      ),
      listBullet: const TextStyle(
        color: primaryColor,
        fontSize: 14,
      ),
      h1: const TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      h2: const TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      h3: const TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      code: const TextStyle(
        color: Color(0xFF0369A1),
        fontSize: 13,
        backgroundColor: Color(0xFFF1F5F9),
      ),
      blockquote: const TextStyle(
        color: secondaryColor,
        fontSize: 13,
        height: 1.5,
      ),
      tableHead: const TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      tableBody: const TextStyle(
        color: textColor,
        fontSize: 12,
        height: 1.4,
      ),
      tableBorder: TableBorder.all(
        color: const Color(0xFFCBD5E1),
        width: 0.7,
      ),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
    );
  }

  // =====================================================
  // KIỂM TRA DÒNG THUỘC BẢNG MARKDOWN
  // =====================================================

  bool _isMarkdownTableLine(String line) {
    final trimmed = line.trim();

    return trimmed.startsWith('|') &&
        trimmed.endsWith('|');
  }
  // =====================================================
  // TÁCH NỘI DUNG Ô BẢNG MARKDOWN
  // =====================================================

  List<String> _parseMarkdownTableRow(String line) {
    var value = line.trim();

    if (value.startsWith('|')) {
      value = value.substring(1);
    }

    if (value.endsWith('|')) {
      value = value.substring(0, value.length - 1);
    }

    return value.split('|').map((cell) {
      return cell
          .trim()
          .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
          .replaceAll('`', '');
    }).toList();
  }

  bool _isMarkdownTableSeparator(String line) {
    final cells = _parseMarkdownTableRow(line);

    return cells.isNotEmpty &&
        cells.every(
          (cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell.trim()),
        );
  }

  // =====================================================
  // RENDER BẢNG BẰNG FLUTTER TABLE
  // =====================================================
  
Widget _buildMarkdownTable(List<String> lines) {
  final rows = <List<String>>[];

  for (final line in lines) {
    if (_isMarkdownTableSeparator(line)) continue;

    final cells = _parseMarkdownTableRow(line);

    if (cells.isNotEmpty) {
      rows.add(cells);
    }
  }

  if (rows.isEmpty) {
    return const SizedBox.shrink();
  }

  const columnWidths = <double>[
    55,  // STT
    190, // Tên dịch vụ
    145, // Loại dịch vụ
    115, // Giá
    280, // Mô tả
  ];

  final columnCount = rows.first.length;

  final widths = List<double>.generate(
    columnCount,
    (index) => index < columnWidths.length
        ? columnWidths[index]
        : 180,
  );

  final totalWidth = widths.fold<double>(
    0,
    (total, width) => total + width,
  );

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: const Color(0xFFE2E8F0),
      ),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(9),
          ),
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: totalWidth,
                child: Table(
                  defaultVerticalAlignment:
                      TableCellVerticalAlignment.middle,
                  border: TableBorder.all(
                    color: const Color(0xFFCBD5E1),
                    width: 0.7,
                  ),
                  columnWidths: {
                    for (int i = 0; i < widths.length; i++)
                      i: FixedColumnWidth(widths[i]),
                  },
                  children: List.generate(rows.length, (rowIndex) {
                    final row = rows[rowIndex];
                    final isHeader = rowIndex == 0;

                    return TableRow(
                      decoration: BoxDecoration(
                        color: isHeader
                            ? const Color(0xFFEFF6FF)
                            : rowIndex.isEven
                                ? Colors.white
                                : const Color(0xFFF8FAFC),
                      ),
                      children: List.generate(columnCount, (colIndex) {
                        final cellText = colIndex < row.length
                            ? row[colIndex]
                            : '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 11,
                          ),
                          child: Text(
                            cellText,
                            softWrap: true,
                            textAlign:
                                colIndex == 0 || colIndex == 3
                                    ? TextAlign.center
                                    : TextAlign.left,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              height: 1.45,
                              fontWeight: isHeader
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),

        // Hướng dẫn người dùng vuốt ngang
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_rounded,
                size: 15,
                color: secondaryColor,
              ),
              SizedBox(width: 5),
              Text(
                'Vuốt ngang để xem đầy đủ các cột',
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  // =====================================================
  // RENDER MARKDOWN CONTENT
  // =====================================================

  Widget _buildMarkdownContent(String content) {
    final lines = content.split('\n');

    final widgets = <Widget>[];
    final normalLines = <String>[];
    final tableLines = <String>[];

    void addNormalContent() {
      if (normalLines.isEmpty) return;

      final text = normalLines.join('\n').trim();

      if (text.isNotEmpty) {
        widgets.add(
          MarkdownBody(
            data: text,
            selectable: true,
            styleSheet: _buildMarkdownStyleSheet(),
          ),
        );
      }

      normalLines.clear();
    }

    void addTableContent() {
      if (tableLines.isEmpty) return;

      widgets.add(
        _buildMarkdownTable(tableLines),
      );

      tableLines.clear();
    }

    for (final line in lines) {
      if (_isMarkdownTableLine(line)) {
        addNormalContent();
        tableLines.add(line);
      } else {
        addTableContent();
        normalLines.add(line);
      }
    }

    addTableContent();
    addNormalContent();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }


  // =====================================================
  // AI MESSAGE - MARKDOWN
  // =====================================================
  Widget _buildAiMessage(ChatbotMessage message) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nội dung tin nhắn AI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: _buildMarkdownContent(message.noiDung),
              ),

              // Nút điều hướng đặt lịch khám
              if (message.action == 'BOOK_APPOINTMENT') ...[
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/booking');
                    },
                    icon: const Icon(
                      Icons.calendar_month_rounded,
                      size: 19,
                    ),
                    label: const Text(
                      'Đặt lịch khám ngay',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 5),

              // Thời gian gửi tin nhắn
              Text(
                _formatTime(message.thoiGianTao),
                style: const TextStyle(
                  color: secondaryColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  // =====================================================
  // TYPING INDICATOR
  // =====================================================

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFE0F2FE),
            child: Icon(
              Icons.smart_toy_rounded,
              color: primaryColor,
              size: 19,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'AI đang trả lời...',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // INPUT AREA
  // =====================================================

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSuggestions(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 46,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    enabled: !_chatbotController.isSending,
                    textCapitalization:
                        TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Nhập câu hỏi của bạn...',
                      hintStyle: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              GestureDetector(
                onTap: _chatbotController.isSending
                    ? null
                    : _sendMessage,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _chatbotController.isSending
                        ? const Color(0xFF94A3B8)
                        : primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _chatbotController.isSending
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Text(
            'Trợ lý AI có thể đưa ra thông tin chưa chính xác.',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SUGGESTED QUESTIONS
  // =====================================================

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gợi ý câu hỏi',
          style: TextStyle(
            color: secondaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 35,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: _chatbotController.isSending
                    ? null
                    : () => _sendMessage(_suggestions[index]),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                    ),
                  ),
                  child: Text(
                    _suggestions[index],
                    style: const TextStyle(
                      color: Color(0xFF0369A1),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =====================================================
  // CHAT INFO
  // =====================================================

  void _showChatInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Về trợ lý AI',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Trợ lý AI hỗ trợ bệnh nhân tìm hiểu thông tin '
                  'chuyên khoa, dịch vụ y tế, danh mục xét nghiệm '
                  'và các thông tin của bệnh viện.',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thông tin chỉ mang tính tham khảo, không thay '
                  'thế việc thăm khám và tư vấn của bác sĩ.',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
