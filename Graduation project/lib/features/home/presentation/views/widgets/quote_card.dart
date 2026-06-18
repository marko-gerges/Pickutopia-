import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    this.onTap,
  });

  final String quote;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 237,
        width: 323,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 0),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff812929),
              Color(0xff1D1A1A),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: AutoSizeText(
              "❝$quote❞",
              style: GoogleFonts.lexend(
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              minFontSize: 15,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
