import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/anime_chatbot_cubit/anime_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/anime_chatbot_cubit/anime_chatbot_state.dart';
import 'package:pickutopia/features/chatbot/presentation/views/widgets/hanafy_loading_bubble.dart';

class AnimeChatBotPage extends StatefulWidget {
  const AnimeChatBotPage({super.key});

  static String id = "AnimeChatBotPage";

  @override
  State<AnimeChatBotPage> createState() => _AnimeChatBotPageState();
}

class _AnimeChatBotPageState extends State<AnimeChatBotPage> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AnimeChatbotCubit>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          cubit.clearMessages();
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          // AppBackgrounds.chatBotBackground,
          _buildGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.black26,
              title: Column(
                children: [
                  Text(
                    'Echo The Bot',
                    style: GoogleFonts.lexend(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Otaku Expert',
                    style: GoogleFonts.lexend(
                      color: kMainColor,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                onPressed: () {
                  cubit.clearMessages();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 22),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: BlocBuilder<AnimeChatbotCubit, AnimeChatbotState>(
                    builder: (context, state) {
                      List<Map<String, String>> currentMessages = [];
                      bool isLoading = false;

                      if (state is AnimeChatbotUpdated) {
                        currentMessages = state.messages;
                      } else if (state is AnimeChatbotLoading) {
                        currentMessages = state.messages;
                        isLoading = true;
                      }

                      if (currentMessages.isEmpty && !isLoading) {
                        return _buildEmptyState();
                      }

                      return ListView(
                        reverse:
                            true, // Crucial: keeps latest messages and bubbles at the bottom
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 12),
                        children: [
                          // 1. Echo's thinking bubble appears at the "bottom" (start of list when reversed)
                          if (isLoading)
                            const EchoLoadingBubble(
                              statusText: "Echo is checking the watch-list...",
                            ),

                          // 2. Chat history mapped to bubbles
                          ...currentMessages.reversed.map((msg) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: BubbleSpecialThree(
                                  text: msg["message"] ?? "",
                                  isSender: msg["sender"] == "user",
                                  color: msg["sender"] == "user"
                                      ? kMainColor
                                      : Colors.white.withOpacity(0.9),
                                  textStyle: GoogleFonts.lexend(
                                    color: msg["sender"] == "user"
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              )),
                        ],
                      );
                    },
                  ),
                ),
                _buildInputArea(cubit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome,
              size: 80, color: kMainColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "What anime are we\nlooking for today?",
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AnimeChatbotCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: MessageBar(
        messageBarColor: Colors.transparent,
        sendButtonColor: kMainColor,
        messageBarHintStyle:
            GoogleFonts.lexend(color: Colors.white54, fontSize: 14),
        onSend: (message) {
          if (message.trim().isNotEmpty) {
            cubit.sendMessage(message);
          }
        },
      ),
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0C29), // Deep Midnight
            Color(0xFF302B63), // Royal Purple
            Color(0xFF24243E), // Dark Slate
          ],
        ),
      ),
    );
  }
}
