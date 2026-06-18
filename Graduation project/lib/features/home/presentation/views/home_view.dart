import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/chatbot/presentation/views/anime_chatbot_view.dart';
import 'package:pickutopia/features/chatbot/presentation/views/books_chatbot_view.dart';
import 'package:pickutopia/features/chatbot/presentation/views/games_chatbot_view.dart';
import 'package:pickutopia/features/chatbot/presentation/views/music_chatbot_view.dart';
import 'package:pickutopia/features/chatbot/presentation/views/tvshows_chatbot_view.dart';
import 'package:pickutopia/features/home/presentation/view_models/quote_cubit/quote_cubit.dart';
import 'package:pickutopia/features/home/presentation/view_models/user_cubit/user_cubit.dart';
import 'package:pickutopia/features/home/presentation/views/quote_view.dart';
import 'package:pickutopia/features/home/presentation/views/widgets/category.dart';
import 'widgets/custom_appbar.dart';
import 'package:pickutopia/features/chatbot/presentation/views/movies_chatbot_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static String id = "HomePage";

  Future<void> _onRefresh(BuildContext context) async {
    await Future.wait([
      context.read<UserCubit>().loadUserProfile(),
      context.read<QuoteCubit>().loadQuotes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          color: const Color(0xFF9D50FF),
          backgroundColor: const Color(0xFF1B1437),
          child: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              print("Current UI State: ${state.runtimeType}");

              if (state is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is UserError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Error: ${state.message}",
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _onRefresh(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Try Again"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9D50FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              String displayName = "User";
              String? avatar;
              int userAge = 0;

              if (state is UserLoaded) {
                displayName = state.name;
                avatar = state.avatarUrl;
                print("Name: $displayName, Age: $userAge");
                userAge = int.tryParse(state.age) ?? 0;
                print("✅ Success! Name: $displayName, Age: $userAge");
              }

              final bool isRestricted = userAge < 18;
              print("is restricted : $isRestricted");
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(userAvatarUrl: avatar),
                    const SizedBox(height: 30),

                    _buildWelcomeText(displayName),
                    const SizedBox(height: 30),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      children: [
                        _buildRestrictedCategory(
                          context,
                          name: "Movies",
                          icon: Icons.movie,
                          color: Colors.blueAccent,
                          isRestricted: isRestricted,
                          onTap: () => Navigator.pushNamed(
                              context, MoviesChatBotPage.id),
                        ),
                        _buildRestrictedCategory(
                          context,
                          name: "TV Shows",
                          icon: Icons.tv,
                          color: Colors.purpleAccent,
                          isRestricted: isRestricted,
                          onTap: () => Navigator.pushNamed(
                              context, TvShowsChatBotPage.id),
                        ),
                        _buildCategory(context, "Books", Icons.book,
                            Colors.greenAccent, BooksChatBotPage.id),
                        _buildCategory(context, "Music", Icons.music_note,
                            Colors.pinkAccent, MusicChatBotPage.id),
                        _buildCategory(context, "Anime", Icons.adb,
                            Colors.orangeAccent, AnimeChatBotPage.id),
                        _buildCategory(context, "Games", Icons.videogame_asset,
                            Colors.indigoAccent, GamesChatBotPage.id),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // 4. Quote Widget
                    _buildQuoteSection(context),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildWelcomeText(String name) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.lexend(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        children: [
          const TextSpan(text: "What's your mood\ntoday, "),
          TextSpan(
            text: "$name?",
            style: const TextStyle(color: Color(0xFF9D50FF)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String name, IconData icon,
      Color color, String route) {
    return CategoryCard(
      name: name,
      icon: icon,
      color: color,
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildRestrictedCategory(
    BuildContext context, {
    required String name,
    required IconData icon,
    required Color color,
    required bool isRestricted,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        Opacity(
          opacity: isRestricted ? 0.4 : 1.0,
          child: CategoryCard(
            name: name,
            icon: icon,
            color: isRestricted ? Colors.grey : color,
            onTap: isRestricted
                ? () => _showLockedSnackBar(context)
                : onTap, // Handled by parent GestureDetector
          ),
        ),
        if (isRestricted)
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.lock_outline_rounded,
                color: Colors.white54, size: 16),
          ),
      ],
    );
  }

  void _showLockedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B1437),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content:
            Text("🔞 Restricted to 18+ users", style: GoogleFonts.lexend()),
      ),
    );
  }

  Widget _buildQuoteSection(BuildContext context) {
    return BlocBuilder<QuoteCubit, QuoteState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (state is QuoteLoaded) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (innerContext) => BlocProvider.value(
                    value: context.read<QuoteCubit>(),
                    child: const QuotePage(),
                  ),
                ),
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF7B2CBF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote_rounded,
                    color: Colors.white54, size: 30),
                const SizedBox(height: 10),
                if (state is QuoteLoading)
                  const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                else if (state is QuoteLoaded) ...[
                  Text(
                    state.quote.quote,
                    style: GoogleFonts.lexend(
                        color: Colors.white, fontSize: 18, height: 1.4),
                  ),
                  const SizedBox(height: 15),
                  Text("- ${state.quote.author}",
                      style: GoogleFonts.lexend(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ] else
                  Text("Pull to refresh for inspiration",
                      style: GoogleFonts.lexend(color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }
}
