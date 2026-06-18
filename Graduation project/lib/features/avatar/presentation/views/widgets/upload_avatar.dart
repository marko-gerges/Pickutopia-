import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickutopia/core/utils/constants.dart';
import 'package:pickutopia/features/authentication/presentation/view_models/register_cubit/register_cubit.dart';

class UploadAvatar extends StatelessWidget {
  const UploadAvatar({super.key});

  static bool _isPickerActive = false;

  Future<void> _pickImage(BuildContext context) async {
    if (_isPickerActive) return;
    _isPickerActive = true;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && context.mounted) {
        context.read<RegisterCubit>().setAvatar(image);
      }
    } finally {
      _isPickerActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<RegisterCubit>().state.avatar;

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── Avatar circle ──────────────────────────────────────────────
          CircleAvatar(
            radius: 45,
            backgroundImage: avatar != null
                ? FileImage(File(avatar.path))
                : const AssetImage("assets/default_avatar2.png") as ImageProvider,
          ),

          // ── Upload icon: shown when no image chosen ────────────────────
          if (avatar == null)
            const Icon(Icons.upload, color: kMainColor, size: 30),

          if (avatar != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: kMainColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1B1437), width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 13),
              ),
            ),
        ],
      ),
    );
  }
}