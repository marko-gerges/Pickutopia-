import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/games_chatbot_cubit/games_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/games_chatbot_cubit/games_chatbot_state.dart';
import 'package:pickutopia/features/chatbot/presentation/views/widgets/hanafy_loading_bubble.dart';

class GamesChatBotPage extends StatefulWidget {
  const GamesChatBotPage({super.key});

  static String id = "GamesChatBotPage";

  @override
  State<GamesChatBotPage> createState() => _GamesChatBotPageState();
}

class _GamesChatBotPageState extends State<GamesChatBotPage> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameChatbotCubit>();

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
                    'Pro Gamer Mode',
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
                  child: BlocBuilder<GameChatbotCubit, GameChatbotState>(
                    builder: (context, state) {
                      List<Map<String, String>> currentMessages = [];
                      bool isLoading = false;

                      if (state is GameChatbotUpdated) {
                        currentMessages = state.messages;
                      } else if (state is GameChatbotLoading) {
                        currentMessages = state.messages;
                        isLoading = true;
                      }

                      if (currentMessages.isEmpty && !isLoading) {
                        return _buildGamesPlaceholder();
                      }

                      return ListView(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 12),
                        children: [
                          if (isLoading)
                            const EchoLoadingBubble(
                              statusText: "Echo is loading your next quest...",
                            ),
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

  Widget _buildGamesPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_esports,
              size: 70, color: kMainColor.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            "Ready for a new adventure?\nAsk me for a recommendation!",
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(GameChatbotCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: MessageBar(
        messageBarColor: Colors.transparent,
        sendButtonColor: kMainColor,
        messageBarHintStyle:
            GoogleFonts.lexend(color: Colors.white38, fontSize: 14),
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
