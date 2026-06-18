import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';

class CustomButtonWithEmoji extends StatelessWidget {
  const CustomButtonWithEmoji({
    super.key,
    this.onPressed,
    required this.text,
    required this.emoji,
    // required this.buttonWidth,
  });

  final void Function()? onPressed;
  final String text;
  final AnimatedEmojiData emoji;

  // final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 15,
            backgroundColor: kMainColor,
            minimumSize: Size(constraints.maxWidth, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.all(
              kMainColor,
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: GoogleFonts.lexend(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              AnimatedEmoji(
                emoji,
                size: 35,
              ),
            ],
          ),
        );
      },
    );
  }
}
