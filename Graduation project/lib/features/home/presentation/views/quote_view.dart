import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/quote_cubit/quote_cubit.dart';

class QuotePage extends StatelessWidget {
  const QuotePage({super.key});

  static String id = "QuotePage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Deep purple background matching your new theme
      backgroundColor: const Color(0xFF0F0B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 22),
        ),
      ),
      body: BlocBuilder<QuoteCubit, QuoteState>(
        builder: (context, state) {
          if (state is QuoteLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9D50FF)),
            );
          } else if (state is QuoteLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    // Purple glassmorphism effect
                    color: const Color(0xFF1B1437).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        color: Color(0xFF9D50FF),
                        size: 50,
                      ),
                      const SizedBox(height: 20),
                      AutoSizeText(
                        state.quote.quote,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        maxLines: 10,
                      ),
                      const SizedBox(height: 30),
                      Divider(
                          color: Colors.white.withOpacity(0.1), thickness: 1),
                      const SizedBox(height: 20),
                      Text(
                        state.quote.author,
                        style: GoogleFonts.lexend(
                          color: const Color(0xFF9D50FF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'from: ${state.quote.source}',
                        style: GoogleFonts.lexend(
                          color: Colors.white54,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is QuoteError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
