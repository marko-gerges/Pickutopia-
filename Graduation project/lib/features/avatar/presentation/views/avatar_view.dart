import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/avatar/presentation/views/widgets/register_button.dart';
import 'package:pickutopia/features/avatar/presentation/views/widgets/upload_avatar.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  static String id = "AvatarPage";

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? screenWidth * 0.15 : 24,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableHeight = constraints.maxHeight;
              final bool isSmallScreen = availableHeight < 580;

              if (availableHeight >= 580) {
                return SizedBox(
                  height: availableHeight,
                  child: _AvatarContent(isSmallScreen: isSmallScreen, useSpacers: true),
                );
              }

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: _AvatarContent(isSmallScreen: isSmallScreen, useSpacers: false),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AvatarContent extends StatelessWidget {
  final bool isSmallScreen;
  final bool useSpacers;

  const _AvatarContent({required this.isSmallScreen, required this.useSpacers});

  Widget _gap({required int flex, required double fallbackHeight}) {
    return useSpacers ? Spacer(flex: flex) : SizedBox(height: fallbackHeight);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isSmallScreen ? 8 : 20),

        // ── 1. Title Section ─────────────────────────────────────────────
        Text(
          "Final Step!",
          style: GoogleFonts.lexend(
            color: const Color(0xFF9D50FF),
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 8),
        Text(
          "Upload your avatar",
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontSize: isSmallScreen ? 22 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 12),
        Text(
          "Choose a picture that represents you best.",
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            color: Colors.white54,
            fontSize: isSmallScreen ? 13 : 16,
          ),
        ),

        SizedBox(height: isSmallScreen ? 24 : 36),

        // ── 2. Compact centered avatar card (not full width) ─────────────
        const _AvatarCard(),

        _gap(flex: 1, fallbackHeight: 48),

        // ── 3. Register Button ───────────────────────────────────────────
        const RegisterButton(),

        SizedBox(height: isSmallScreen ? 16 : 30),
      ],
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1437),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ UploadAvatar now handles both pick + re-pick
          UploadAvatar(),
          SizedBox(height: 10),
          Text(
            "Tap to browse gallery",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}