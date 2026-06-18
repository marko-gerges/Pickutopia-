import 'package:flutter/material.dart';

abstract class AppBackgrounds {
  static final homeBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/home_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  static final chatBotBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/chatbot_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  static final userProfileBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/user_profile_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  static final authBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/auth_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  static final avatarBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/avatar_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  static final loginBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/login_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  static final registerBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/register_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  static final quoteBackground = Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("assets/backgrounds/quote_background.png"),
        fit: BoxFit.cover,
      ),
    ),
  );
}
