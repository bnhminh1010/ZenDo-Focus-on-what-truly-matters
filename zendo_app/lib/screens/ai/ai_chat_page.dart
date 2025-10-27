/*
 * Tên: screens/ai/ai_chat_page.dart
 * Tác dụng: Màn hình chat với AI Gemini để hỗ trợ quản lý task và tư vấn productivity
 * Khi nào dùng: Người dùng cần hỗ trợ AI để tạo task, lên kế hoạch hoặc tư vấn làm việc hiệu quả
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/ai_message.dart';
import '../../services/gemini_ai_service.dart';
import '../../providers/auth_model.dart';
import '../../theme.dart';
import '../../models/task.dart';
import '../../providers/task_model.dart';
import '../../../services/supabase_database_service.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';

class AIChatPage extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const AIChatPage({super.key, this.extra});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GeminiAIService _aiService = GeminiAIService();

  List<AIMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  late AnimationController _typingAnimationController;
  File? _selectedFile; // Thêm biến để lưu file đã chọn

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _initializeAI();
    _addWelcomeMessage();

    // Xử lý initial message từ task context
    if (widget.extra != null && widget.extra!['initialMessage'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageController.text = widget.extra!['initialMessage'];
        _sendMessage();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _initializeAI() {
    try {
      _aiService.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _addErrorMessage(
        'Không thể khởi tạo AI. Vui lòng kiểm tra kết nối mạng.',
      );
    }
  }

  void _addWelcomeMessage() {
    // Kiểm tra nếu có task được truyền vào
    String welcomeContent =
        '''Xin chào! 🐬 Tôi là BilyBily - trợ lý AI của ZenDo.

Tôi có thể giúp bạn:
• 📝 Tạo task từ mô tả tự nhiên
• 🎯 Phân tích độ ưu tiên công việc  
• 📊 Đánh giá thói quen focus session
• 💡 Đưa ra gợi ý cải thiện năng suất

Hãy chat trực tiếp với tôi về bất cứ điều gì bạn cần!''';

    // Nếu có task được truyền vào, thêm thông tin task vào welcome message
    if (widget.extra != null && widget.extra!['initialTask'] != null) {
      final task = widget.extra!['initialTask'] as Task;
      welcomeContent +=
          '''

📋 **Thông tin task hiện tại:**
• **Tiêu đề:** ${task.title}
• **Mô tả:** ${task.description ?? 'Không có mô tả'}
• **Ưu tiên:** ${task.priority.displayName}
• **Danh mục:** ${task.category.displayName}
• **Trạng thái:** ${task.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành'}
• **Thời gian ước tính:** ${task.estimatedMinutes} phút
• **Deadline:** ${task.dueDate != null ? task.dueDate.toString().split(' ')[0] : 'Không có'}

Tôi có thể giúp bạn phân tích, cải thiện hoặc thảo luận về task này! 🚀''';
    }

    final welcomeMessage = AIMessage.fromAI(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: welcomeContent,
    );

    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _addErrorMessage(String error) {
    final errorMessage = AIMessage.error(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: error,
      errorMessage: error,
    );

    setState(() {
      _messages.add(errorMessage);
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final authModel = Provider.of<AuthModel>(context, listen: false);
    final userId = authModel.userEmail ?? 'anonymous';

    // Tạo tin nhắn từ user
    final userMessage = AIMessage.fromUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      userId: userId,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Kiểm tra nếu là yêu cầu tạo task
      if (text.toLowerCase().contains('tạo task') ||
          text.toLowerCase().contains('tạo một task')) {
        await _handleTaskCreation(text);
      }
      // Kiểm tra nếu là yêu cầu phân tích ưu tiên
      else if (text.toLowerCase().contains('phân tích ưu tiên') ||
          text.toLowerCase().contains('sắp xếp ưu tiên')) {
        await _handlePriorityAnalysis();
      }
      // Kiểm tra nếu là yêu cầu phân tích thói quen focus
      else if (text.toLowerCase().contains('phân tích thói quen') ||
          text.toLowerCase().contains('focus session') ||
          text.toLowerCase().contains('thói quen tập trung')) {
        await _handleFocusHabitsAnalysis(text);
      }
      // Kiểm tra nếu là yêu cầu gợi ý
      else if (text.toLowerCase().contains('gợi ý') ||
          text.toLowerCase().contains('cải thiện năng suất')) {
        await _handleProductivityTips();
      }
      // Tin nhắn thông thường
      else {
        // Lấy context từ tasks hiện tại để đính kèm
        final taskModel = Provider.of<TaskModel>(context, listen: false);
        final currentTasks = taskModel.tasks
            .where((task) => !task.isCompleted)
            .take(5)
            .toList();

        String contextMessage = text;

        // Nếu có task được truyền từ task detail page, thêm thông tin chi tiết
        if (widget.extra != null && widget.extra!['initialTask'] != null) {
          final currentTask = widget.extra!['initialTask'] as Task;
          contextMessage += '\n\n[Context - Task hiện tại đang thảo luận:\n';
          contextMessage += '- Tiêu đề: ${currentTask.title}\n';
          contextMessage +=
              '- Mô tả: ${currentTask.description ?? 'Không có mô tả'}\n';
          contextMessage += '- Ưu tiên: ${currentTask.priority.displayName}\n';
          contextMessage += '- Danh mục: ${currentTask.category.displayName}\n';
          contextMessage +=
              '- Trạng thái: ${currentTask.isCompleted ? 'Đã hoàn thành' : 'Chưa hoàn thành'}\n';
          contextMessage +=
              '- Thời gian ước tính: ${currentTask.estimatedMinutes} phút\n';
          contextMessage +=
              '- Deadline: ${currentTask.dueDate != null ? currentTask.dueDate.toString().split(' ')[0] : 'Không có'}\n';
          contextMessage += ']\n\n';
        }

        // Thêm context từ các tasks khác nếu có
        if (currentTasks.isNotEmpty) {
          contextMessage += '[Context - Tasks khác hiện tại của user:\n';
          for (var task in currentTasks) {
            contextMessage += '- ${task.title} (${task.priority.name})\n';
          }
          contextMessage += ']';
        }

        // Gửi tin nhắn với file nếu có
        final response = _selectedFile != null
            ? await _aiService.sendMessageWithFile(
                contextMessage,
                _selectedFile!,
              )
            : await _aiService.sendMessage(contextMessage);

        // Reset file sau khi gửi
        _selectedFile = null;

        // Cập nhật UI để ẩn trạng thái file đã chọn
        setState(() {});

        // Tạo tin nhắn phản hồi từ AI
        // Reset file sau khi tạo task thành công
        _selectedFile = null;

        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response,
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
      }
    } catch (e) {
      _addErrorMessage(
        'Xin lỗi, tôi không thể trả lời lúc này. Vui lòng thử lại sau.',
      );
      setState(() {
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _handleTaskCreation(String message) async {
    try {
      // Kiểm tra xem user đã cung cấp đủ thông tin chưa
      final hasTitle =
          message.toLowerCase().contains('tiêu đề:') ||
          message.toLowerCase().contains('tên:') ||
          message.toLowerCase().contains('title:');
      final hasDescription =
          message.toLowerCase().contains('mô tả:') ||
          message.toLowerCase().contains('description:');
      final hasPriority =
          message.toLowerCase().contains('ưu tiên:') ||
          message.toLowerCase().contains('priority:');
      final hasCategory =
          message.toLowerCase().contains('danh mục:') ||
          message.toLowerCase().contains('category:');
      final hasTime =
          message.toLowerCase().contains('thời gian:') ||
          message.toLowerCase().contains('time:') ||
          message.toLowerCase().contains('phút') ||
          message.toLowerCase().contains('giờ');

      // Nếu chưa đủ thông tin, hỏi chi tiết
      if (!hasTitle ||
          !hasDescription ||
          !hasPriority ||
          !hasCategory ||
          !hasTime) {
        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              '📝 Tôi sẽ giúp bạn tạo task chi tiết! Vui lòng cung cấp thông tin sau:\n\n'
              '🎯 **Tiêu đề:** Tên ngắn gọn cho task\n'
              '📄 **Mô tả:** Chi tiết về công việc cần làm\n'
              '⚡ **Ưu tiên:** Cao/Trung bình/Thấp\n'
              '📂 **Danh mục:** Công việc/Học tập/Cá nhân/Sức khỏe/Khác\n'
              '⏰ **Thời gian ước tính:** Số phút hoặc giờ cần thiết\n'
              '📎 **File đính kèm:** (tùy chọn)\n\n'
              'Ví dụ:\n'
              'Tiêu đề: Hoàn thành báo cáo tháng\n'
              'Mô tả: Viết báo cáo tổng kết công việc tháng 12\n'
              'Ưu tiên: Cao\n'
              'Danh mục: Công việc\n'
              'Thời gian: 120 phút',
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
        return;
      }

      // Nếu đã có đủ thông tin, tạo task
      final task = await _aiService.createTaskFromDescription(
        message,
        imageFile: _selectedFile,
      );
      if (task != null) {
        final taskModel = Provider.of<TaskModel>(context, listen: false);
        await taskModel.addTask(task);

        // Reset file sau khi tạo task thành công
        _selectedFile = null;

        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              '✅ Đã tạo task thành công!\n\n'
              '📝 **${task.title}**\n'
              '📄 ${task.description}\n'
              '⏰ Thời gian ước tính: ${task.estimatedMinutes} phút\n'
              '🎯 Ưu tiên: ${task.priority.displayName}\n'
              '📂 Danh mục: ${task.category.displayName}\n\n'
              'Task đã được thêm vào danh sách của bạn!',
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
      } else {
        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              'Xin lỗi, tôi không thể tạo task từ thông tin này. Vui lòng kiểm tra lại định dạng và thử lại.',
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
      }
    } catch (e) {
      _addErrorMessage('Lỗi khi tạo task: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePriorityAnalysis() async {
    try {
      final taskModel = Provider.of<TaskModel>(context, listen: false);
      final tasks = taskModel.tasks.where((task) => !task.isCompleted).toList();

      if (tasks.isEmpty) {
        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              'Bạn chưa có task nào để phân tích. Hãy tạo một số task trước nhé!',
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
        return;
      }

      final analysis = await _aiService.analyzePriorities(tasks);
      if (analysis != null) {
        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: analysis,
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
      }
    } catch (e) {
      _addErrorMessage('Lỗi khi phân tích ưu tiên: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleProductivityTips() async {
    try {
      final tips = await _aiService.getProductivityTips();
      if (tips != null) {
        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: tips,
        );

        setState(() {
          _messages.add(aiMessage);
          _isLoading = false;
        });
      }
    } catch (e) {
      _addErrorMessage('Lỗi khi lấy gợi ý: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Xử lý phân tích thói quen focus session
  Future<void> _handleFocusHabitsAnalysis(String userMessage) async {
    try {
      // Lấy dữ liệu focus sessions từ database
      final databaseService = SupabaseDatabaseService();
      final focusSessions = await databaseService
          .getFocusSessions(); // Lấy tất cả sessions gần nhất

      if (focusSessions.isEmpty) {
        final aiMessage = AIMessage.fromAI(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content:
              'Bạn chưa có dữ liệu focus session nào. Hãy thực hiện một vài phiên tập trung trước để tôi có thể phân tích thói quen của bạn! 🎯',
        );

        setState(() {
          _messages.add(aiMessage);
        });
        return;
      }

      // Chuyển đổi dữ liệu focus sessions thành format phù hợp
      final sessionsData = focusSessions
          .map(
            (session) => {
              'startedAt': session.startedAt.toString(),
              'duration': session.actualDurationMinutes,
              'distractionCount': session.distractionCount,
              'status': session.status.name,
              'productivityRating': session.productivityRating,
            },
          )
          .toList();

      // Gọi AI để phân tích
      final analysisResult = await _aiService.analyzeFocusHabits(sessionsData);

      final aiMessage = AIMessage.fromAI(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: analysisResult,
      );

      setState(() {
        _messages.add(aiMessage);
      });
    } catch (e) {
      final errorMessage = AIMessage.fromAI(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Có lỗi xảy ra khi phân tích thói quen focus: ${e.toString()}',
      );

      setState(() {
        _messages.add(errorMessage);
      });
    }
  }

  Widget _buildErrorHandling() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: context.errorColor),
              const SizedBox(width: 8),
              Text(
                'Lỗi kết nối AI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Không thể kết nối với dịch vụ AI. Vui lòng kiểm tra:\n'
            '• Kết nối internet\n'
            '• Cấu hình API key trong file .env\n'
            '• Khởi động lại ứng dụng sau khi cập nhật',
            style: TextStyle(color: context.errorColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          GlassElevatedButton.icon(
            onPressed: _initializeAI,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            backgroundColor: context.errorColor,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép tin nhắn'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: GlassIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/icons/bot.png',
                width: 18,
                height: 18,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BilyBily',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isInitialized ? 'Đã sẵn sàng' : 'Đang khởi tạo...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _isInitialized
                        ? context.successColor
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          GlassIconButton(
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
            tooltip: 'Làm mới cuộc trò chuyện',
          ),
        ],
      ),
      body: Column(
        children: [
          // Hiển thị lỗi nếu AI chưa được khởi tạo
          if (!_isInitialized) _buildErrorHandling(),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    final isUser = message.isFromUser;
    final isError = message.hasError;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isError
                      ? [Colors.red, Colors.redAccent]
                      : [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isError
                  ? Icon(Icons.error_outline, color: Colors.white, size: 18)
                  : Image.asset(
                      'assets/icons/bot.png',
                      width: 18,
                      height: 18,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyMessage(message.content),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                blur: isUser ? 8 : 12,
                opacity: isUser ? 0.2 : 0.1,
                color: isUser
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3)
                    : isError
                    ? context.errorColor.withOpacity(0.1)
                    : Theme.of(
                        context,
                      ).colorScheme.surfaceContainer.withOpacity(0.5),
                border: isError
                    ? Border.all(
                        color: context.errorColor.withOpacity(0.3),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? Colors.white
                            : isError
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.displayTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isUser
                            ? Colors.white.withOpacity(0.7)
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(bottomLeft: const Radius.circular(4)),
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue =
                        (_typingAnimationController.value - delay).clamp(
                          0.0,
                          1.0,
                        );
                    final opacity = (animationValue * 2).clamp(0.0, 1.0);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: opacity > 1 ? 2 - opacity : opacity,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 8),

            // Input Row
            Row(
              children: [
                // File attachment button
                Container(
                  decoration: BoxDecoration(
                    color: _selectedFile != null
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _selectedFile != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: GlassIconButton(
                    onPressed: _pickFile,
                    icon: _selectedFile != null
                        ? Icons.attach_file
                        : Icons.attach_file_rounded,
                    iconColor: _selectedFile != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                    tooltip: _selectedFile != null
                        ? 'File đã chọn: ${_selectedFile!.path.split('/').last}'
                        : 'Đính kèm file',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: GlassIconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading
                        ? Icons.hourglass_empty
                        : Icons.send_rounded,
                    iconColor: Theme.of(context).colorScheme.onPrimary,
                    tooltip: 'Gửi tin nhắn',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickActionChip(
            icon: Icons.add_task,
            label: 'Tạo task',
            onTap: () => _sendQuickMessage('Tôi muốn tạo một task mới'),
          ),
          const SizedBox(width: 8),
          _buildQuickActionChip(
            icon: Icons.analytics_outlined,
            label: 'Phân tích thói quen',
            onTap: () =>
                _sendQuickMessage('Phân tích thói quen focus session của tôi'),
          ),
          const SizedBox(width: 8),
          _buildQuickActionChip(
            icon: Icons.analytics,
            label: 'Phân tích thói quen',
            onTap: () =>
                _sendQuickMessage('Phân tích thói quen focus session của tôi'),
          ),
          const SizedBox(width: 8),
          _buildQuickActionChip(
            icon: Icons.tips_and_updates,
            label: 'Gợi ý',
            onTap: () => _sendQuickMessage(
              'Cho tôi một số gợi ý để cải thiện năng suất',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  Future<void> _createTaskFromAI(String taskDescription) async {
    try {
      final taskModel = Provider.of<TaskModel>(context, listen: false);

      // Sử dụng AI để phân tích và tạo task
      final aiResponse = await _aiService.createTaskFromDescription(
        taskDescription,
      );

      if (aiResponse != null) {
        await taskModel.addTask(aiResponse);

        // Thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tạo task: ${aiResponse.title}'),
              backgroundColor: context.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo task: $e'),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        // Lưu file đã chọn
        if (file.path != null) {
          _selectedFile = File(file.path!);
        }

        // Hiển thị thông báo file đã chọn
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn file: ${file.name}'),
            duration: const Duration(seconds: 2),
          ),
        );

        // Thêm tin nhắn về file đã đính kèm
        final fileMessage =
            'Tôi đã đính kèm file: ${file.name}. Bạn có thể giúp tôi phân tích hoặc tạo task từ file này không?';
        _messageController.text = fileMessage;

        // Cập nhật UI để hiển thị file đã chọn
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn file: $e'),
          backgroundColor: context.errorColor,
        ),
      );
    }
  }
}

