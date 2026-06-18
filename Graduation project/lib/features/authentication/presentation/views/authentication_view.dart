import 'package:flutter/material.dart';
import 'package:pickutopia/core/utils/app_backgrounds.dart';
import 'package:pickutopia/features/authentication/presentation/views/widgets/auth_widgets/auth_logo.dart';
import 'package:pickutopia/features/authentication/presentation/views/widgets/auth_widgets/register_button.dart';
import 'widgets/auth_widgets/login_button.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  static String id = "AuthenticationPage";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBackgrounds.authBackground,
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(
              flex: 2,
            ),
            AuthLogo(),
            Spacer(
              flex: 1,
            ),
            LoginButton(),
            Spacer(
              flex: 1,
            ),
            RegisterButton(),
            Spacer(
              flex: 4,
            ),
          ],
        ),
      ],
    );
  }
}
