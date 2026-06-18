import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/authentication/forms/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static String id = "LoginPage";

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
                const SizedBox(height: 100),
                Image.asset(
                  'assets/logos/app_logo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Sign In',
                  style: GoogleFonts.lexend(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 60),
                const LoginForm(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
