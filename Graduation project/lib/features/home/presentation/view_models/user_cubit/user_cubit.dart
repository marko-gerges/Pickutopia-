import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickutopia/features/authentication/services/supabase_auth_service.dart';
import 'package:pickutopia/core/utils/error_mapper.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final SupabaseAuthService _authService;

  UserCubit(this._authService) : super(UserInitial());
  void emitLoaded(Map<String, dynamic> profile) {
    emit(UserLoaded(
      name: profile['name'] ?? '',
      age: profile['age']?.toString() ?? '0',
      avatarUrl: profile['avatarUrl'] ?? '',
      email: profile['email'] ?? '',
    ));
  }

  void clearUser() => emit(UserInitial());

  Future<void> loadUserProfile() async {
    emit(UserLoading());

    try {
      int retryCount = 0;
      while (_authService.getCurrentUser() == null && retryCount < 5) {
        print("Session not ready, retrying... ($retryCount)");
        await Future.delayed(const Duration(milliseconds: 500));
        retryCount++;
      }

      final userData = await _authService.getUserProfile();

      emit(UserLoaded(
        name: userData['name'] ?? "User",
        avatarUrl: userData['avatarUrl'],
        email: userData['email'],
        age: (userData['age'] ?? "0").toString(),
      ));
    } catch (e) {
      // If it still fails, we show a friendly error
      final friendly = friendlyErrorMessage(e);
      emit(UserError(message: friendly));
    }
  }

// Add a reset method to clear state on logout/error
  void reset() => emit(UserInitial());

  Future<void> deleteAccount() async {
    emit(UserLoading());
    try {
      await _authService.deleteAccount();
      emit(UserDeleted());
    } catch (e) {
      final friendly = friendlyErrorMessage(e);
      emit(UserError(message: 'Failed to delete account: $friendly'));
    }
  }

  Future<void> signOut() async {
    emit(UserLoading());
    try {
      await _authService.signOut();
      emit(UserSignedOut());
    } catch (e) {
      final friendly = friendlyErrorMessage(e);
      emit(UserError(message: 'Failed to sign out: $friendly'));
    }
  }

  Future<void> updateUserName(String newName) async {
    emit(UserLoading());
    try {
      await _authService.updateUserName(newName);
      await loadUserProfile();
    } catch (e) {
      final friendly = friendlyErrorMessage(e);
      emit(UserError(message: 'Failed to update name: $friendly'));
    }
  }

  Future<void> updateUserAvatar(XFile image) async {
    // If we already have a profile loaded, emit an uploading state
    if (state is UserLoaded) {
      final s = state as UserLoaded;
      emit(UserUploading(
          name: s.name, avatarUrl: s.avatarUrl, email: s.email, age: s.age));
    } else {
      emit(UserLoading());
    }

    try {
      await _authService.updateUserAvatar(image);
      await loadUserProfile();
    } catch (e) {
      final friendly = friendlyErrorMessage(e);
      emit(UserError(message: 'Failed to update avatar: $friendly'));
    }
  }
}
