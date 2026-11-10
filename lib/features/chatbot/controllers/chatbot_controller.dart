
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';

// =====================================================
// MODEL: CHATBOT MESSAGE
// =====================================================

class ChatbotMessage {
  final int? maTinNhan;
  final String noiDung;
  final String nguoiGui;
  final DateTime thoiGianTao;
  final String? action;

  const ChatbotMessage({
    this.maTinNhan,
    required this.noiDung,
    required this.nguoiGui,
    required this.thoiGianTao,
    this.action,
  });

  bool get isUser {
    final sender = nguoiGui.toLowerCase();

    return sender == 'nguoidung' ||
        sender == 'nguoi_dung' ||
        sender == 'user';
  }

  factory ChatbotMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatbotMessage(
      maTinNhan: _toInt(json['maTinNhan']),
      noiDung: json['noiDung']?.toString() ?? '',
      nguoiGui: json['nguoiGui']?.toString() ?? 'AI',
      thoiGianTao: _parseDate(json['thoiGianTao']),
      action: json['action']?.toString(),
    );
  }
}

// =====================================================
// MODEL: CHATBOT CONVERSATION
// =====================================================

class ChatbotConversation {
  final int maPhien;
  final DateTime? thoiGianBatDau;
  final DateTime? thoiGianKetThuc;
  final String trangThai;
  final String tieuDe;

  const ChatbotConversation({
    required this.maPhien,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.trangThai = '',
    this.tieuDe = 'Cuộc trò chuyện mới',
  });

  
factory ChatbotConversation.fromJson(
  Map<String, dynamic> json,
) {
  return ChatbotConversation(
    maPhien: _toInt(json['maPhien']) ?? 0,
    thoiGianBatDau: _tryParseDate(
      json['thoiGianBatDau'],
    ),
    thoiGianKetThuc: _tryParseDate(
      json['thoiGianKetThuc'],
    ),
    trangThai: json['trangThai']?.toString() ?? '',

    // Backend trả về tenPhien.
    // Flutter sử dụng tieuDe để hiển thị.
    tieuDe: json['tenPhien']?.toString() ??
        json['tieuDe']?.toString() ??
        'Cuộc trò chuyện mới',
  );
}


  ChatbotConversation copyWith({
    String? tieuDe,
  }) {
    return ChatbotConversation(
      maPhien: maPhien,
      thoiGianBatDau: thoiGianBatDau,
      thoiGianKetThuc: thoiGianKetThuc,
      trangThai: trangThai,
      tieuDe: tieuDe ?? this.tieuDe,
    );
  }
}

// =====================================================
// CHATBOT CONTROLLER
// =====================================================

class ChatbotController extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  // -----------------------------------------------------
  // STATE: MESSAGES
  // -----------------------------------------------------

  final List<ChatbotMessage> _messages = [];

  List<ChatbotMessage> get messages =>
      List.unmodifiable(_messages);

  // -----------------------------------------------------
  // STATE: CONVERSATIONS
  // -----------------------------------------------------

  final List<ChatbotConversation> _conversations = [];

  List<ChatbotConversation> get conversations =>
      List.unmodifiable(_conversations);

  // -----------------------------------------------------
  // STATE: LOADING
  // -----------------------------------------------------

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoadingConversations = false;

  bool get isLoadingConversations =>
      _isLoadingConversations;

  bool _isSending = false;

  bool get isSending => _isSending;

  // -----------------------------------------------------
  // STATE: CURRENT SESSION
  // -----------------------------------------------------

  int? _maPhien;

  int? get maPhien => _maPhien;

  bool _initialized = false;

  bool get initialized => _initialized;

  // -----------------------------------------------------
  // STATE: ERROR
  // -----------------------------------------------------

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // =====================================================
  // 1. INITIALIZE CHATBOT
  // =====================================================
  
Future<void> initialize() async {
  if (_initialized || _isLoading) return;

  if (!_api.hasToken) {
    _errorMessage =
        'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';

    notifyListeners();
    return;
  }

  _isLoading = true;
  _errorMessage = null;

  // Đảm bảo màn hình bắt đầu với trạng thái trống.
  _maPhien = null;
  _messages.clear();

  notifyListeners();

  try {
    // Mỗi lần khởi tạo Chatbot sẽ tạo một phiên mới.
    // Không tải và không tự động mở lại lịch sử cũ.
    await _createInitialConversation();

  } catch (e) {
    _errorMessage = _getErrorMessage(e);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // =====================================================
  // TẠO PHIÊN ĐẦU TIÊN KHI KHỞI TẠO
  // =====================================================

  Future<bool> _createInitialConversation() async {
    try {
      final result = await _api.post(
        '/api/chatbot/conversations',
      );

      if (result is! Map) {
        throw const ApiException(
          'Dữ liệu tạo phiên trò chuyện không hợp lệ.',
        );
      }

      final data = Map<String, dynamic>.from(result);

      final conversation =
          ChatbotConversation.fromJson(data);

      if (conversation.maPhien <= 0) {
        throw const ApiException(
          'Máy chủ chưa trả về mã phiên trò chuyện.',
        );
      }

      _maPhien = conversation.maPhien;

      _messages.clear();

      _initialized = true;

      _conversations.insert(0, conversation);

      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);

      return false;
    }
  }

  // =====================================================
  // 2. LOAD CONVERSATIONS
  // =====================================================

  Future<void> loadConversations() async {
    if (_isLoadingConversations) return;

    _isLoadingConversations = true;

    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _api.get(
        '/api/chatbot/conversations',
      );

      if (result is! List) {
        throw const ApiException(
          'Danh sách phiên trò chuyện không hợp lệ.',
        );
      }

      final loadedConversations =
          <ChatbotConversation>[];

      for (final item in result) {
        if (item is Map) {
          final conversation =
              ChatbotConversation.fromJson(
            Map<String, dynamic>.from(item),
          );

          if (conversation.maPhien > 0) {
            loadedConversations.add(conversation);
          }
        }
      }

      // Sắp xếp phiên mới nhất lên đầu.
      loadedConversations.sort((a, b) {
        final dateA = a.thoiGianBatDau;
        final dateB = b.thoiGianBatDau;

        if (dateA == null && dateB == null) {
          return b.maPhien.compareTo(a.maPhien);
        }

        if (dateA == null) return 1;
        if (dateB == null) return -1;

        final comparison = dateB.compareTo(dateA);

        if (comparison == 0) {
          return b.maPhien.compareTo(a.maPhien);
        }

        return comparison;
      });

      // Lấy tiêu đề của các cuộc trò chuyện.
      _conversations
        ..clear()
        ..addAll(loadedConversations);

      _errorMessage = null;
    } catch (e) {
      // Giữ danh sách cũ nếu tải dữ liệu thất bại.
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoadingConversations = false;

      notifyListeners();
    }
  }

  // =====================================================
  // 3. LOAD CONVERSATION TITLE
  // =====================================================

  Future<String> _loadConversationTitle(
    int sessionId,
  ) async {
    try {
      final result = await _api.get(
        '/api/chatbot/conversations/$sessionId/messages',
      );

      if (result is! List) {
        return 'Cuộc trò chuyện #$sessionId';
      }

      final userMessages = <ChatbotMessage>[];

      for (final item in result) {
        if (item is Map) {
          final message = ChatbotMessage.fromJson(
            Map<String, dynamic>.from(item),
          );

          if (message.isUser &&
              message.noiDung.trim().isNotEmpty) {
            userMessages.add(message);
          }
        }
      }

      if (userMessages.isEmpty) {
        return 'Cuộc trò chuyện mới';
      }

      // Sắp xếp theo thời gian để lấy câu hỏi đầu tiên.
      userMessages.sort(
        (a, b) => a.thoiGianTao.compareTo(
          b.thoiGianTao,
        ),
      );

      return userMessages.first.noiDung.trim();
    } catch (_) {
      return 'Cuộc trò chuyện #$sessionId';
    }
  }

  // =====================================================
  // 4. CREATE NEW CONVERSATION
  // =====================================================

  Future<bool> createNewConversation() async {
    if (_isSending || _isLoading) {
      _errorMessage =
          'Vui lòng đợi thao tác hiện tại hoàn tất.';

      notifyListeners();

      return false;
    }

    if (!_api.hasToken) {
      _errorMessage =
          'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';

      notifyListeners();

      return false;
    }

    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _api.post(
        '/api/chatbot/conversations',
      );

      if (result is! Map) {
        throw const ApiException(
          'Dữ liệu tạo phiên trò chuyện không hợp lệ.',
        );
      }

      final data = Map<String, dynamic>.from(result);

      final conversation =
          ChatbotConversation.fromJson(data);

      if (conversation.maPhien <= 0) {
        throw const ApiException(
          'Không nhận được mã phiên trò chuyện.',
        );
      }

      // Chuyển sang phiên mới.
      _maPhien = conversation.maPhien;

      _messages.clear();

      _initialized = true;

      // Thêm phiên mới lên đầu danh sách.
      _conversations.removeWhere(
        (item) => item.maPhien == conversation.maPhien,
      );

      _conversations.insert(0, conversation);

      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // 5. OPEN CONVERSATION
  // =====================================================

  Future<bool> openConversation(int sessionId) async {
  if (_isSending) {
    _errorMessage =
        'Vui lòng đợi AI trả lời xong trước khi chuyển phiên.';

    notifyListeners();
    return false;
  }

  if (_isLoading) {
    return false;
  }

  if (sessionId <= 0) {
    _errorMessage = 'Mã phiên trò chuyện không hợp lệ.';

    notifyListeners();
    return false;
  }

  _isLoading = true;
  _errorMessage = null;

  notifyListeners();

  try {
    return await _openConversationInternal(sessionId);
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

// ==========================================
//
// =========================================
Future<bool> _openConversationInternal(int sessionId) async {
  if (sessionId <= 0) {
    _errorMessage = 'Mã phiên trò chuyện không hợp lệ.';
    return false;
  }

  try {
    // Tải tin nhắn của phiên được chọn.
    final result = await _api.get(
      '/api/chatbot/conversations/$sessionId/messages',
    );

    if (result is! List) {
      throw const ApiException(
        'Lịch sử trò chuyện không hợp lệ.',
      );
    }

    final loadedMessages = <ChatbotMessage>[];

    for (final item in result) {
      if (item is Map) {
        loadedMessages.add(
          ChatbotMessage.fromJson(
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    // Chỉ cập nhật phiên hiện tại sau khi tải thành công.
    _messages
      ..clear()
      ..addAll(loadedMessages);

    _maPhien = sessionId;
    _initialized = true;
    _errorMessage = null;

    return true;
  } catch (e) {
    _errorMessage = _getErrorMessage(e);
    return false;
  }
}

  // =====================================================
  // 6. DELETE CONVERSATION BY ID
  // =====================================================

  Future<bool> deleteConversationById(
    int sessionId,
  ) async {
    if (_isSending || _isLoading) {
      _errorMessage =
          'Vui lòng đợi thao tác hiện tại hoàn tất.';

      notifyListeners();

      return false;
    }

    try {
      await _api.delete(
        '/api/chatbot/conversations/$sessionId',
      );

      // Xóa khỏi danh sách lịch sử.
      _conversations.removeWhere(
        (item) => item.maPhien == sessionId,
      );

      // Nếu đang mở phiên bị xóa thì làm sạch trạng thái.
      if (_maPhien == sessionId) {
        _maPhien = null;

        _messages.clear();

        _initialized = false;
      }

      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // 7. SEND MESSAGE
  // =====================================================

  Future<bool> sendMessage(String content) async {
    final question = content.trim();

    if (question.isEmpty || _isSending) {
      return false;
    }

    if (_maPhien == null || !_initialized) {
      _errorMessage =
          'Chưa có phiên trò chuyện. Vui lòng thử lại.';

      notifyListeners();

      return false;
    }

    final sessionId = _maPhien!;

    _isSending = true;

    _errorMessage = null;

    // Tạo tin nhắn tạm.
    final optimisticMessage = ChatbotMessage(
      noiDung: question,
      nguoiGui: 'NguoiDung',
      thoiGianTao: DateTime.now(),
    );

    // Hiển thị ngay trên giao diện.
    _messages.add(optimisticMessage);

    notifyListeners();

    try {
      final result = await _api.post(
        '/api/chatbot/conversations/$sessionId/messages',
        body: {
          'noiDung': question,
        },
      );

      if (result is! Map) {
        throw const ApiException(
          'Dữ liệu phản hồi chatbot không hợp lệ.',
        );
      }

      final data = Map<String, dynamic>.from(result);

      // Cập nhật tin nhắn người dùng từ server.
      final userMessage = data['tinNhanNguoiDung'];

      if (userMessage is Map) {
        final serverMessage = ChatbotMessage.fromJson(
          Map<String, dynamic>.from(userMessage),
        );

        final index = _messages.indexOf(
          optimisticMessage,
        );

        if (index != -1) {
          _messages[index] = serverMessage;
        }
      }

      // Thêm câu trả lời AI.
      final aiMessage = data['tinNhanAI'];

    if (aiMessage is Map) {
        final aiData = Map<String, dynamic>.from(aiMessage);

        // Action được Backend trả về ở cấp độ response.
        final action = data['action']?.toString();

        if (action != null && action.isNotEmpty) {
            aiData['action'] = action;
        }

        _messages.add(
            ChatbotMessage.fromJson(aiData),
        );
    }

      // Đồng bộ mã phiên từ backend.
      final responseSessionId = _toInt(
        data['maPhien'],
      );

      if (responseSessionId != null) {
        _maPhien = responseSessionId;
      }

      // Cập nhật tiêu đề phiên hiện tại bằng câu hỏi đầu tiên.
      final conversationIndex = _conversations.indexWhere(
        (item) => item.maPhien == sessionId,
      );

      if (conversationIndex != -1) {
        final current = _conversations[conversationIndex];

        final title = current.tieuDe == 'Cuộc trò chuyện mới'
            ? question
            : current.tieuDe;

        _conversations[conversationIndex] =
            current.copyWith(tieuDe: title);
      }

      return true;
    } catch (e) {
      // Xóa tin nhắn tạm khi gửi thất bại.
      _messages.remove(optimisticMessage);

      _errorMessage = _getErrorMessage(e);

      return false;
    } finally {
      _isSending = false;

      notifyListeners();
    }
  }

  // =====================================================
  // 8. LOAD MESSAGES
  // =====================================================

  Future<void> loadMessages() async {
    final sessionId = _maPhien;

    if (sessionId == null || _isLoading) return;

    _isLoading = true;

    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _api.get(
        '/api/chatbot/conversations/$sessionId/messages',
      );

      if (result is! List) {
        throw const ApiException(
          'Dữ liệu lịch sử trò chuyện không hợp lệ.',
        );
      }

      final loadedMessages = <ChatbotMessage>[];

      for (final item in result) {
        if (item is Map) {
          loadedMessages.add(
            ChatbotMessage.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }

      _messages
        ..clear()
        ..addAll(loadedMessages);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================================
  // 9. DELETE CURRENT CONVERSATION
  // =====================================================

  Future<bool> deleteConversation() async {
    final sessionId = _maPhien;

    if (sessionId == null) return false;

    return deleteConversationById(sessionId);
  }

  // =====================================================
  // 10. CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // =====================================================
  // 11. ERROR HANDLING
  // =====================================================

  String _getErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401 ||
          error.statusCode == 403) {
        return 'Bạn không có quyền sử dụng chatbot '
            'hoặc phiên đăng nhập đã hết hạn.';
      }

      return error.message;
    }

    return 'Đã xảy ra lỗi khi kết nối chatbot. Vui lòng thử lại.';
  }
}

// =====================================================
// COMMON HELPERS
// =====================================================

int? _toInt(dynamic value) {
  if (value is int) return value;

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '');
}

DateTime _parseDate(dynamic value) {
  if (value == null) {
    return DateTime.now();
  }

  return DateTime.tryParse(value.toString()) ??
      DateTime.now();
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;

  return DateTime.tryParse(value.toString());
}
