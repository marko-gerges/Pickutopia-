import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/movie_chatbot_cubit/movie_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/movie_chatbot_cubit/movie_chatbot_state.dart';
import 'package:pickutopia/features/chatbot/presentation/views/widgets/hanafy_loading_bubble.dart';

class MoviesChatBotPage extends StatefulWidget {
  const MoviesChatBotPage({super.key});

  static String id = "MoviesChatBotPage";

  @override
  State<MoviesChatBotPage> createState() => _MoviesChatBotPageState();
}

class _MoviesChatBotPageState extends State<MoviesChatBotPage> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieChatbotCubit>();

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
              backgroundColor: Colors.black26, // Subtle glass overlay
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
                    'Movie Critic Mode',
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
                // Inside your BlocBuilder in MoviesChatBotPage
                Expanded(
                  child: BlocBuilder<MovieChatbotCubit, MovieChatbotState>(
                    builder: (context, state) {
                      List<Map<String, String>> currentMessages = [];
                      bool isLoading = false;

                      if (state is MovieChatbotUpdated) {
                        currentMessages = state.messages;
                      } else if (state is MovieChatbotLoading) {
                        currentMessages = state.messages;
                        isLoading = true; // Bot is currently thinking
                      }

                      if (currentMessages.isEmpty && !isLoading) {
                        return _buildMoviePlaceholder();
                      }

                      return ListView(
                        reverse: true, // Keep latest messages at bottom
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        children: [
                          // If loading, the bubble appears at the very bottom (latest)
                          if (isLoading)
                            const EchoLoadingBubble(
                                statusText:
                                    "Echo is picking the best seats..."),

                          // The actual message history
                          ...currentMessages.reversed.map((msg) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 12),
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
                _buildMessageInput(cubit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_filter,
              size: 70, color: kMainColor.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            "What's on the big screen today?\nTell me your mood!",
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(MovieChatbotCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
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

// class _TypingHint extends StatelessWidget {
//   const _TypingHint();
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 24, bottom: 12),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           "Echo is picking the best seats...",
//           style: GoogleFonts.lexend(
//               color: kMainColor.withOpacity(0.8),
//               fontSize: 12,
//               fontStyle: FontStyle.italic),
//         ),
//       ),
//     );
//   }
// }
