import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/music_chatbot_cubit/music_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/music_chatbot_cubit/music_chatbot_state.dart';
import 'package:pickutopia/features/chatbot/presentation/views/widgets/hanafy_loading_bubble.dart';

class MusicChatBotPage extends StatefulWidget {
  const MusicChatBotPage({super.key});

  static String id = "MusicChatBotPage";

  @override
  State<MusicChatBotPage> createState() => _MusicChatBotPageState();
}

class _MusicChatBotPageState extends State<MusicChatBotPage> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicChatbotCubit>();

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
                    'Music Curator',
                    style: GoogleFonts.lexend(
                      color: kMainColor,
                      fontSize: 11,
                      letterSpacing: 1.1,
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
                  child: BlocBuilder<MusicChatbotCubit, MusicChatbotState>(
                    builder: (context, state) {
                      List<Map<String, String>> currentMessages = [];
                      bool isLoading = false;

                      if (state is MusicChatbotUpdated) {
                        currentMessages = state.messages;
                      } else if (state is MusicChatbotLoading) {
                        currentMessages = state.messages;
                        isLoading = true;
                      }

                      if (currentMessages.isEmpty && !isLoading) {
                        return _buildMusicPlaceholder();
                      }

                      return ListView(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 12),
                        children: [
                          if (isLoading)
                            const EchoLoadingBubble(
                              statusText: "Echo is mixing your playlist...",
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

  Widget _buildMusicPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_music,
              size: 70, color: kMainColor.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            "What's your vibe today?\nTell me a genre or a mood!",
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

  Widget _buildInputArea(MusicChatbotCubit cubit) {
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
