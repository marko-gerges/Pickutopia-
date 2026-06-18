import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../login_view.dart';
import '../custom_button.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomButton(
        child: Text(
          'Login',
          style: GoogleFonts.lexend(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, LoginPage.id),
      ),
    );
  }
}
