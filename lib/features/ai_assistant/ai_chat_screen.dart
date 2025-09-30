import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';

/// AI chat screen for health assistant
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addMessage(
      'Hello! I\'m your AI Health Assistant. I can help you with:\n\n'
      '• Understanding symptoms\n'
      '• Medication reminders\n'
      '• Health tips and advice\n'
      '• Emergency guidance\n\n'
      'How can I help you today?',
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.aiAssistant),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _showInfo,
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'clear') {
                _clearChat();
              } else if (value == 'export') {
                _exportChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickActions(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionChip('Symptom Checker', Icons.healing, () {
              _sendQuickMessage('I have some symptoms I\'d like to check');
            }),
            const SizedBox(width: 8),
            _buildQuickActionChip('Medication Help', Icons.medication, () {
              _sendQuickMessage('I need help with my medications');
            }),
            const SizedBox(width: 8),
            _buildQuickActionChip('First Aid', Icons.emergency, () {
              _sendQuickMessage('I need first aid guidance');
            }),
            const SizedBox(width: 8),
            _buildQuickActionChip('Health Tips', Icons.tips_and_updates, () {
              _sendQuickMessage('Give me some health tips');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.blue.shade50,
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ..[
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.smart_toy, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppUtils.formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser
                          ? Colors.white70
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ..[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: const Icon(Icons.person, color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.smart_toy, color: Colors.blue),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI is typing...',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your health question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: _messageController.text.trim().isEmpty ? null : _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addMessage(text, true);
    _messageController.clear();
    _generateAIResponse(text);
  }

  void _sendQuickMessage(String message) {
    _addMessage(message, true);
    _generateAIResponse(message);
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _generateAIResponse(String userMessage) {
    setState(() => _isTyping = true);
    
    // Simulate AI processing time
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = false);
        
        String response = _getAIResponse(userMessage.toLowerCase());
        _addMessage(response, false);
      }
    });
  }

  String _getAIResponse(String message) {
    // Simple rule-based responses for demonstration
    if (message.contains('symptom') || message.contains('pain') || message.contains('hurt')) {
      return 'I understand you\'re experiencing symptoms. While I can provide general information, it\'s important to consult with a healthcare professional for proper diagnosis and treatment.\n\n'
          'For immediate concerns:\n'
          '• Severe pain: Contact emergency services\n'
          '• Persistent symptoms: Schedule an appointment\n'
          '• Minor issues: Monitor and rest\n\n'
          'Would you like me to help you find nearby medical services?';
    }
    
    if (message.contains('medication') || message.contains('medicine') || message.contains('pill')) {
      return 'I can help you with medication management! Here are some general guidelines:\n\n'
          '• Always take medications as prescribed\n'
          '• Set up reminders for medication times\n'
          '• Keep a list of all your medications\n'
          '• Check for drug interactions\n\n'
          'Would you like me to set up a medication reminder for you?';
    }
    
    if (message.contains('first aid') || message.contains('emergency') || message.contains('accident')) {
      return '🆘 EMERGENCY FIRST AID GUIDANCE 🆘\n\n'
          'For life-threatening emergencies, call 911 immediately!\n\n'
          'Basic First Aid Steps:\n'
          '1. Ensure scene safety\n'
          '2. Check for responsiveness\n'
          '3. Call for help if needed\n'
          '4. Provide appropriate care\n\n'
          'Common situations:\n'
          '• Cuts: Apply pressure, elevate if possible\n'
          '• Burns: Cool with water, don\'t use ice\n'
          '• Choking: Back blows, abdominal thrusts\n\n'
          'Would you like specific guidance for a particular situation?';
    }
    
    if (message.contains('health tip') || message.contains('advice') || message.contains('healthy')) {
      return '🌱 DAILY HEALTH TIPS 🌱\n\n'
          '• Drink 8 glasses of water daily\n'
          '• Get 7-9 hours of sleep\n'
          '• Exercise for 30 minutes daily\n'
          '• Eat 5 servings of fruits & vegetables\n'
          '• Practice stress management\n'
          '• Regular health check-ups\n\n'
          'Remember: Small consistent changes lead to big health improvements!\n\n'
          'What specific area of health would you like to focus on?';
    }
    
    // Default response
    return 'Thank you for your question! I\'m here to provide general health information and guidance. However, please remember that I cannot replace professional medical advice.\n\n'
        'For specific medical concerns, always consult with a qualified healthcare provider.\n\n'
        'Is there a particular health topic you\'d like to know more about? I can help with:\n'
        '• General health information\n'
        '• Wellness tips\n'
        '• First aid guidance\n'
        '• Finding healthcare services';
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

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Health Assistant'),
        content: const Text(
          'This AI assistant provides general health information and guidance. '
          'It is not a substitute for professional medical advice, diagnosis, or treatment. '
          'Always consult with qualified healthcare professionals for medical concerns.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addMessage(
                  'Chat cleared. How can I help you today?',
                  false,
                );
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    AppUtils.showSuccessSnackBar(context, 'Chat exported successfully!');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}