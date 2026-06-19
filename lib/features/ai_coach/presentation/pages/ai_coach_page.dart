import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../services/ai/openai_service.dart';

class AiCoachPage extends StatefulWidget {
  const AiCoachPage({super.key});

  @override
  State<AiCoachPage> createState() => _AiCoachPageState();
}

class _AiCoachPageState extends State<AiCoachPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _ai = OpenAIService();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  static const String _systemPrompt = '''
You are ResumeCraft AI, an expert career coach and resume specialist with 15+ years of experience.
You help users with:
- Resume writing and optimization
- Career advice and growth strategies
- Job search strategies
- Interview preparation tips
- Salary negotiation advice
- LinkedIn profile optimization
- Cover letter writing
- Skills development recommendations
- Industry insights and trends

Be friendly, professional, encouraging, and specific. Give actionable advice.
Keep responses concise but comprehensive. Use bullet points for lists.
''';

  @override
  void initState() {
    super.initState();
    _addBotMessage('Hello! I\'m your AI Career Coach. I can help you with resume writing, career advice, interview tips, and much more. What would you like to work on today?');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: false));
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final history = _messages.take(_messages.length - 1).map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}).toList();
      history.add({'role': 'user', 'content': text});

      final response = await _ai.streamChatResponse(
        systemPrompt: _systemPrompt,
        messages: history,
      ).join();

      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(text: 'Sorry, I encountered an error. Please try again.', isUser: false));
        _isTyping = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'AI Career Coach',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
            onPressed: () => setState(() {
              _messages.clear();
              _addBotMessage('Chat cleared. How can I help you with your career today?');
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickPrompts(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                return _buildMessage(_messages[index], index);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      'How do I improve my ATS score?',
      'What skills should I learn in 2025?',
      'How to negotiate salary?',
      'LinkedIn profile tips',
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            _messageController.text = prompts[index];
            _sendMessage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              prompts[index],
              style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(_ChatMessage message, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: message.isUser ? AppColors.primaryGradient : null,
                color: message.isUser ? null : AppColors.backgroundCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                border: message.isUser ? null : Border.all(color: AppColors.surfaceBorderLight),
              ),
              child: Text(
                message.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: message.isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.backgroundTertiary, shape: BoxShape.circle, border: Border.all(color: AppColors.surfaceBorderLight)),
              child: const Icon(Icons.person, color: AppColors.textSecondary, size: 16),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)), border: Border.all(color: AppColors.surfaceBorderLight)),
          child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => Padding(
            padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(delay: (i * 200).ms, duration: 600.ms),
          ))),
        ),
      ]),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceBorderLight)),
        color: AppColors.backgroundSecondary,
      ),
      child: Row(children: [
        Expanded(
          child: TextFormField(
            controller: _messageController,
            maxLines: 3,
            minLines: 1,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _sendMessage(),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Ask your career coach anything...',
              filled: true,
              fillColor: AppColors.backgroundTertiary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.surfaceBorderLight)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.surfaceBorderLight)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _sendMessage,
          child: Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
