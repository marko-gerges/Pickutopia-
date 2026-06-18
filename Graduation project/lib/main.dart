import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/authentication/presentation/view_models/login_cubit/login_cubit.dart';
import 'package:pickutopia/features/authentication/presentation/view_models/register_cubit/register_cubit.dart';
import 'package:pickutopia/features/authentication/presentation/views/authentication_view.dart';
import 'package:pickutopia/features/authentication/services/supabase_auth_service.dart';
import 'package:pickutopia/features/avatar/presentation/views/avatar_view.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/books_chatbot_cubit/books_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/games_chatbot_cubit/games_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/movie_chatbot_cubit/movie_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/view_models/music_chatbot_cubit/music_chatbot_cubit.dart';
import 'package:pickutopia/features/chatbot/presentation/views/movies_chatbot_view.dart';
import 'package:pickutopia/features/chatbot/presentation/views/tvshows_chatbot_view.dart';
import 'package:pickutopia/features/chatbot/services/anime_chatbot_service.dart';
import 'package:pickutopia/features/chatbot/services/books_chatbot_service.dart';
import 'package:pickutopia/features/chatbot/services/games_chatbot_service.dart';
import 'package:pickutopia/features/chatbot/services/movie_chatbot_service.dart';
import 'package:pickutopia/features/chatbot/services/music_chatbot_service.dart';
import 'package:pickutopia/features/home/presentation/view_models/user_cubit/user_cubit.dart';
import 'package:pickutopia/features/home/presentation/views/home_view.dart';
import 'package:pickutopia/features/authentication/presentation/views/login_view.dart';
import 'package:pickutopia/features/authentication/presentation/views/register_view.dart';
import 'package:pickutopia/features/userprofile/presentation/views/userprofile_view.dart';
// import 'core/utils/supabase_config.dart';
import 'features/chatbot/presentation/view_models/anime_chatbot_cubit/anime_chatbot_cubit.dart';
import 'features/chatbot/presentation/view_models/series_chatbot_cubit/series_chatbot_cubit.dart';
import 'features/chatbot/presentation/views/anime_chatbot_view.dart';
import 'features/chatbot/presentation/views/books_chatbot_view.dart';
import 'features/chatbot/presentation/views/games_chatbot_view.dart';
import 'features/chatbot/presentation/views/music_chatbot_view.dart';
import 'features/chatbot/services/series_chatbot_service.dart';
import 'features/home/presentation/view_models/quote_cubit/quote_cubit.dart';
import 'features/home/presentation/views/quote_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pickutopia/core/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await ConnectivityService().init();
  await Supabase.initialize(
    url: "https://zdnmywttumsobujjpqxp.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpkbm15d3R0dW1zb2J1ampwcXhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MDczNjIsImV4cCI6MjA5NTM4MzM2Mn0.E7P227Y7fLCsNxXKQLg5XPyuYOEskgPkMB2erX5nC54",
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  final bool isLoggedIn = Supabase.instance.client.auth.currentSession != null;
  debugPrint('✅ Session check: isLoggedIn=$isLoggedIn');
  Map<String, dynamic>? preloadedProfile;
  if (isLoggedIn) {
    try {
      preloadedProfile = await SupabaseAuthService().getUserProfile();
    } catch (e) {
      debugPrint('⚠️ Failed to preload profile: $e');
    }
  }
  runApp(MyApp(
    isLoggedIn: isLoggedIn,
    preloadedProfile: preloadedProfile,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, dynamic>? preloadedProfile;
  const MyApp(
      {super.key, required this.isLoggedIn, required this.preloadedProfile});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuoteCubit>(
            create: (context) => QuoteCubit()..loadQuotes()),
        BlocProvider<RegisterCubit>(
            create: (context) => RegisterCubit(SupabaseAuthService())),
        BlocProvider<LoginCubit>(
            create: (context) => LoginCubit(SupabaseAuthService())),
        BlocProvider<UserCubit>(
          create: (context) {
            final cubit = UserCubit(SupabaseAuthService());

            if (preloadedProfile != null) {
              cubit.emitLoaded(preloadedProfile!);
            } else if (isLoggedIn) {
              cubit.loadUserProfile();
            }

            Supabase.instance.client.auth.onAuthStateChange.listen((data) {
              if (data.session != null) {
                cubit.loadUserProfile();
              } else {
                cubit.clearUser();
              }
            });

            return cubit;
          },
        ),
        BlocProvider<MusicChatbotCubit>(
            create: (context) => MusicChatbotCubit(MusicChatbotService())),
        BlocProvider<MovieChatbotCubit>(
            create: (context) => MovieChatbotCubit(MovieChatbotService())),
        BlocProvider<TvShowsChatbotCubit>(
            create: (context) => TvShowsChatbotCubit(SeriesChatbotService())),
        BlocProvider<AnimeChatbotCubit>(
            create: (context) => AnimeChatbotCubit(AnimeChatbotService())),
        BlocProvider<GameChatbotCubit>(
            create: (context) => GameChatbotCubit(GameChatbotService())),
        BlocProvider<BookChatbotCubit>(
            create: (context) => BookChatbotCubit(BookChatbotService())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? const HomePage() : const LoginPage(),
        routes: {
          AuthenticationPage.id: (context) => const AuthenticationPage(),
          LoginPage.id: (context) => const LoginPage(),
          RegisterPage.id: (context) => const RegisterPage(),
          AvatarPage.id: (context) => const AvatarPage(),
          HomePage.id: (context) => const HomePage(),
          MoviesChatBotPage.id: (context) => const MoviesChatBotPage(),
          TvShowsChatBotPage.id: (context) => const TvShowsChatBotPage(),
          MusicChatBotPage.id: (context) => const MusicChatBotPage(),
          GamesChatBotPage.id: (context) => const GamesChatBotPage(),
          BooksChatBotPage.id: (context) => const BooksChatBotPage(),
          AnimeChatBotPage.id: (context) => const AnimeChatBotPage(),
          UserProfilePage.id: (context) => const UserProfilePage(),
          QuotePage.id: (context) => const QuotePage(),
        },
      ),
    );
  }
}
