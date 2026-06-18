import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatBubbles extends StatelessWidget {
  final List<Map<String, String>> messages;

  const ChatBubbles({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        final isUser = message["sender"] == "user";
        final messageText = message["message"] ?? "";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4), // Tighter spacing
          child: BubbleSpecialThree(
            text: messageText,
            isSender: isUser,
            // User: Main accent color | Bot: Soft transparent white/grey
            color: isUser ? kMainColor : Colors.white.withOpacity(0.9),
            tail: true,
            textStyle: GoogleFonts.lexend(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}
