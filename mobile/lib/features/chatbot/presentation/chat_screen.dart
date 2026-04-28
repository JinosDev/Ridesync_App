import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text': "Hello! I'm your RideSync Assistant. How can I help you with your journey today?",
      'time': '09:41 AM'
    },
    {
      'isBot': false,
      'text': "I need to check my bus status.",
      'time': '09:42 AM'
    },
    {
      'isBot': true,
      'text': "Sure! Please provide your ticket number or the route ID you are traveling on.",
      'time': '09:42 AM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A5568)),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RideSync Assistant',
              style: TextStyle(color: Color(0xFF2D3748), fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF48BB78), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Online',
                  style: TextStyle(color: Color(0xFF718096), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF4A5568)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF718096)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ..._messages.map((m) => _ChatBubble(
                      isBot: m['isBot'],
                      text: m['text'],
                      time: m['time'],
                    )),
              ],
            ),
          ),
          
          // Quick actions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _QuickChip(label: 'Where is my bus?', onTap: () {}),
                _QuickChip(label: 'How to book?', onTap: () {}),
                _QuickChip(label: 'Refund status', onTap: () {}),
              ],
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF718096)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        _messages.add({
                          'isBot': false,
                          'text': _controller.text,
                          'time': 'Now',
                        });
                        _controller.clear();
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFED8936),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.isBot, required this.text, required this.time});

  final bool isBot;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFFFF5F5),
              child: Icon(Icons.smart_toy_outlined, color: Color(0xFFED8936), size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isBot ? Colors.white : const Color(0xFF4A5568),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isBot ? 4 : 20),
                      bottomRight: Radius.circular(isBot ? 20 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isBot ? const Color(0xFF2D3748) : Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(fontSize: 10, color: Color(0xFFA0AEC0)),
                ),
              ],
            ),
          ),
          if (!isBot) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person, color: Color(0xFF718096), size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFED7D7)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFF9B2C2C), fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

