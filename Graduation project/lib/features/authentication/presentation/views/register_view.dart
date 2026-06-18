import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/authentication/forms/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static String id = "RegisterPage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A4C93), // Deep Purple
              Color(0xFF2E1A47), // Darker Navy/Purple
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 80),

                Image.asset(
                  'assets/logos/app_logo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),

                Text(
                  'Sign Up',
                  style: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                const RegisterForm(),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Sign In",
                    style: GoogleFonts.lexend(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
