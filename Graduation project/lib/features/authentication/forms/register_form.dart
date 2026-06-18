import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/avatar/presentation/views/avatar_view.dart';
import '../presentation/view_models/register_cubit/register_cubit.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<RegisterCubit>().updateUserInfo(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          age: _ageController.text,
          phone: _phoneController.text);
      Navigator.pushNamed(context, AvatarPage.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildRoundedField(
            controller: _nameController,
            hintText: 'Name',
            validator: (value) =>
                value == null || value.length < 2 ? 'Invalid name' : null,
          ),
          const SizedBox(height: 15),
          _buildRoundedField(
            controller: _emailController,
            hintText: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email required';
              final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              return !regex.hasMatch(value) ? 'Invalid email' : null;
            },
          ),
          const SizedBox(height: 15),
          _buildRoundedField(
            controller: _phoneController,
            hintText: 'Phone Number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return "Phone is required";
              // Regex for: optional +, followed by 10-15 digits
              final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
              if (!phoneRegex.hasMatch(value)) {
                return "Enter a valid phone number";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildRoundedField(
            controller: _ageController,
            hintText: 'Age',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return "Age is required";
              final int? age = int.tryParse(value);
              if (age == null || age <= 0 || age > 90) {
                return "Enter a valid age";
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildRoundedField(
            controller: _passwordController,
            hintText: 'Password',
            isObscure: true,
            validator: (value) =>
                value == null || value.length < 8 ? 'Min 8 characters' : null,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF260D3D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Sign Up',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String hintText,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text, // Added this
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      keyboardType: keyboardType, // Set the keyboard type
      style: GoogleFonts.lexend(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.lexend(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        // Error styling for better UX
        errorStyle: GoogleFonts.lexend(color: Colors.red[200]),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
