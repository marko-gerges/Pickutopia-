import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:pickutopia/features/authentication/presentation/views/login_view.dart';
import 'package:pickutopia/features/home/presentation/view_models/user_cubit/user_cubit.dart';
import 'package:pickutopia/features/userprofile/presentation/views/widgets/update_name.dart';
import 'package:pickutopia/core/utils/connection_guard.dart';
import 'package:pickutopia/core/ui/awesome_dialogs.dart';
import 'package:pickutopia/core/ui/confirm_dialog.dart';
import 'package:pickutopia/core/utils/error_mapper.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  static String id = "UserProfilePage";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E), // Deep dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 22),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.lexend(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserDeleted || state is UserSignedOut) {
            Navigator.pushNamedAndRemoveUntil(
                context, LoginPage.id, (_) => false);
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF9D50FF)));
          } else if (state is UserLoaded || state is UserUploading) {
            final bool isUploading = state is UserUploading;
            final String name = state is UserLoaded
                ? state.name
                : (state as UserUploading).name;
            final String email = state is UserLoaded
                ? state.email
                : (state as UserUploading).email;
            final String avatarUrl = state is UserLoaded
                ? state.avatarUrl
                : (state as UserUploading).avatarUrl;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF9D50FF),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: const Color(0xFF1B1437),
                            child: CachedNetworkImage(
                              imageUrl: avatarUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 20),
                              errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 40),
                            ),
                          ),
                        ),

                        // Local uploading indicator
                        if (isUploading)
                          Positioned.fill(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                          ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedFile != null && context.mounted) {
                                await runWithConnection(context, () async {
                                  await context
                                      .read<UserCubit>()
                                      .updateUserAvatar(pickedFile);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  color: Color(0xFF0F0B1E), size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Name & Email
                  Text(
                    name,
                    style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    email,
                    style:
                        GoogleFonts.lexend(fontSize: 14, color: Colors.white54),
                  ),
                  const SizedBox(height: 40),

                  // 3. Action Buttons
                  _buildProfileButton(
                    context: context,
                    text: "Edit Name",
                    icon: Icons.edit,
                    onTap: () => _showUpdateNameDialog(context),
                  ),
                  _buildProfileButton(
                    context: context,
                    text: "Contact Us",
                    icon: Icons.mail_outline,
                    onTap: () => _showContactDialog(context),
                  ),
                  _buildProfileButton(
                    context: context,
                    text: "Delete Account",
                    icon: Icons.delete_outline,
                    color: Colors.redAccent.withOpacity(0.1),
                    textColor: Colors.redAccent,
                    onTap: () => _confirmDeleteAccount(context),
                  ),
                  const SizedBox(height: 40),

                  // 4. Logout Button
                  TextButton.icon(
                    onPressed: () => _confirmSignOut(context),
                    icon: const Icon(Icons.logout, color: Color(0xFF9D50FF)),
                    label: Text(
                      "Log Out",
                      style: GoogleFonts.lexend(
                          color: const Color(0xFF9D50FF),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is UserError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off,
                        size: 72, color: Colors.white54),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                          color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await runWithConnection(context, () async {
                          await context.read<UserCubit>().loadUserProfile();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9D50FF)),
                      child: Text('Try again',
                          style: GoogleFonts.lexend(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // UI/UX Safe Button Builder
  Widget _buildProfileButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    Color textColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: color ?? const Color(0xFF1B1437),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 16),
              Text(
                text,
                style: GoogleFonts.lexend(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  color: textColor.withOpacity(0.3), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateNameDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => UpdateName(
        controller: controller,
        onUpdatePressed: () async {
          if (controller.text.trim().isEmpty) return;
          await runWithConnection(context, () async {
            await context
                .read<UserCubit>()
                .updateUserName(controller.text.trim());
          });
          if (context.mounted) Navigator.pop(context);
        },
        isLoading: false,
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      customHeader: Lottie.asset('assets/contact_animation.json'),
      dialogBackgroundColor: const Color(0xFF1B1437),
      title: 'Contact us',
      titleTextStyle: GoogleFonts.lexend(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      desc: 'pickutopia2@gmail.com',
      descTextStyle: GoogleFonts.lexend(fontSize: 16, color: Colors.white70),
    ).show();
  }

  void _confirmSignOut(BuildContext context) {
    showConfirmDialog(
      context,
      title: 'Sign out',
      desc: 'Are you sure you want to sign out?',
      dialogType: DialogType.question,
    ).then((confirmed) {
      if (confirmed) _performSignOut(context);
    });
  }

  Future<void> _performSignOut(BuildContext context) async {
    try {
      await context.read<UserCubit>().signOut();
    } catch (e) {
      final friendly = friendlyErrorMessage(e);
      showErrorDialog(context, title: 'Sign out failed', description: friendly);
    }
  }

  void _confirmDeleteAccount(BuildContext context) {
    showConfirmDialog(
      context,
      title: 'Delete account',
      desc:
          'This will permanently delete your account and cannot be undone. Continue?',
      dialogType: DialogType.warning,
    ).then((confirmed) {
      if (confirmed) _performDeleteAccount(context);
    });
  }

  Future<void> _performDeleteAccount(BuildContext context) async {
    await runWithConnection(context, () async {
      await context.read<UserCubit>().deleteAccount();
    });
  }
}
