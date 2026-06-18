import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../register_view.dart';
import '../custom_button.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomButton(
        child: Text(
          'Create a new account',
          style: GoogleFonts.lexend(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, RegisterPage.id),
      ),
    );
  }
}
