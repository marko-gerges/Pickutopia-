import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/authentication/presentation/view_models/login_cubit/login_cubit.dart';
import 'package:pickutopia/core/utils/connection_guard.dart';
import 'package:pickutopia/core/ui/awesome_dialogs.dart';
import 'package:pickutopia/features/authentication/presentation/views/register_view.dart';
import 'package:pickutopia/features/home/presentation/view_models/user_cubit/user_cubit.dart';
import 'package:pickutopia/features/home/presentation/views/home_view.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().updateEmail(_emailController.text.trim());
      context
          .read<LoginCubit>()
          .updatePassword(_passwordController.text.trim());
      runWithConnection(context, () async {
        await context.read<LoginCubit>().login();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state.isSuccess) {
          await context.read<UserCubit>().loadUserProfile();

          if (!context.mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
          context.read<LoginCubit>().reset();
        } else if (state.errorMessage != null) {
          showErrorDialog(context,
              title: 'Login failed', description: state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              _buildRoundedField(
                controller: _emailController,
                hintText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password Field
              _buildRoundedField(
                controller: _passwordController,
                hintText: 'Password',
                isObscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 80),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed:
                      state.isLoading ? null : () => _submitForm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF260D3D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Login',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RegisterPage.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    'Create Account',
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
      },
    );
  }

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String hintText,
    bool isObscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.lexend(
            color: Colors.grey[600], fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
