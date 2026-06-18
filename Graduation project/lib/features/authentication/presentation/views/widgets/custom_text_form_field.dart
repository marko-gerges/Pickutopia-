import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/core/utils/constants.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.obscureText,
    this.keyboardType,
    required this.hintText,
    required this.preIcon,
    this.onChanged,
    this.errorText,
    this.onSaved,
    this.validator,
    this.controller,
  });

  final bool obscureText;
  final TextInputType? keyboardType;
  final String hintText;
  final Icon preIcon;
  final void Function(String)? onChanged;
  final String? errorText;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.lexend(color: kSecondaryColor),
      keyboardType: keyboardType,
      cursorColor: kSecondaryColor,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        errorText: errorText,
        filled: true,
        fillColor: kMainColor,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: kThirdColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.lexend(
          color: kSecondaryColor,
        ),
        prefixIcon: Align(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: preIcon,
        ),
        prefixIconColor: kSecondaryColor,
      ),
    );
  }
}
