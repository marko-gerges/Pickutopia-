import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';

class SignUpSuggestion extends StatelessWidget {
  const SignUpSuggestion({super.key, this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have account?',
          style: GoogleFonts.lexend(
            fontSize: 18,
            color: kMainColor,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            ' Sign up',
            style: GoogleFonts.lexend(
              decoration: TextDecoration.underline,
              fontSize: 18,
              color: kMainColor,
            ),
          ),
        )
      ],
    );
  }
}
