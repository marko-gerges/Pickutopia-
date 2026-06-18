import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickutopia/features/authentication/presentation/view_models/register_cubit/register_cubit.dart';
import 'package:pickutopia/core/utils/connection_guard.dart';
import 'package:pickutopia/core/ui/awesome_dialogs.dart';
import 'package:pickutopia/features/authentication/presentation/views/widgets/custom_button.dart';
import 'package:pickutopia/features/home/presentation/view_models/user_cubit/user_cubit.dart';
import 'package:pickutopia/features/home/presentation/views/home_view.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) async {
        if (state.isSuccess) {
          await context.read<UserCubit>().loadUserProfile();

          if (!context.mounted) return;
          await Future.delayed(const Duration(milliseconds: 300));
          if (!context.mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
          );
          context.read<RegisterCubit>().reset();
        } else if (state.errorMessage != null) {
          showErrorDialog(context,
              title: 'Registration failed',
              description: state.errorMessage ?? 'An unknown error occurred');
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: CustomButton(
            onPressed: state.isLoading
                ? null
                : () => runWithConnection(context, () async {
                      await context.read<RegisterCubit>().register();
                    }),
            child: state.isLoading
                ? const CircularProgressIndicator(color: Colors.red)
                : Text(
                    "Register",
                    style: GoogleFonts.lexend(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
