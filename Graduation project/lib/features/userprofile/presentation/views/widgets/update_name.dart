import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';

class UpdateName extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onUpdatePressed;
  final bool isLoading;

  const UpdateName({
    super.key,
    required this.controller,
    required this.onUpdatePressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;
    final isVerySmallScreen = screenSize.height < 600;

    return Dialog(
      backgroundColor: kMainColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: isVerySmallScreen ? 8 : screenSize.height * 0.02,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.width * 0.9,
            minWidth: 200,
            maxHeight: screenSize.height * 0.9,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Update name',
                    style: GoogleFonts.lexend(
                      fontSize: isSmallScreen ? 16 : 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 18),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: isSmallScreen ? 50 : 55,
                    ),
                    child: TextFormField(
                      controller: controller,
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 15,
                      ),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10 : 12,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        labelText: "Your new name",
                        labelStyle: GoogleFonts.lexend(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 8,
                            vertical: isSmallScreen ? 1 : 2,
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      ElevatedButton(
                        onPressed: isLoading ? null : onUpdatePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 10 : 12,
                            vertical: isSmallScreen ? 4 : 6,
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: kMainColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Update",
                                style: GoogleFonts.lexend(
                                  color: kMainColor,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
