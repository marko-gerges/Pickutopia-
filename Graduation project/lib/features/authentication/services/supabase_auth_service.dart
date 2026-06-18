import 'dart:developer';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class SupabaseAuthService {
  final _supabase = Supabase.instance.client;
  User? getCurrentUser() => _supabase.auth.currentUser;

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String age,
    XFile? avatar,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'age': age,
      },
    );

    final registeredUser = response.user;
    if (registeredUser == null) {
      throw Exception('Registration failed. No user returned.');
    }

    final userId = registeredUser.id;
    log('User registered. Profile automatically created by Database Trigger for id=$userId');

    // Handle avatar upload if provided (use bytes fallback + compression)
    if (avatar != null) {
      try {
        final avatarPath = '$userId/avatar.png';
        final file = await _prepareFileForUpload(avatar, '$userId-avatar.png');

        await _supabase.storage.from('avatars').upload(
              avatarPath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );
        log('Avatar uploaded successfully to: $avatarPath');

        // attempt to delete the temporary file (best-effort)
        try {
          await file.delete();
        } catch (_) {}
      } catch (e) {
        log('Error uploading avatar: $e');
        rethrow;
      }
    }

    // Automatically sign the user in
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> deleteAccount() async {
    final user = _supabase.auth.currentUser;
    final userId = user?.id;

    if (userId == null) {
      throw Exception("No user logged in");
    }

    try {
      await _supabase.storage.from('avatars').remove(['$userId/avatar.png']);
      log("Avatar deleted successfully from storage");
    } catch (e) {
      log("Error deleting avatar: $e");
    }

    try {
      final response = await _supabase.functions.invoke(
        'delete-user',
        body: {'user_id': userId},
      );

      if (response.status != 200) {
        log('Edge function failed: ${response.data}');
        throw Exception('Failed to delete account via server');
      }

      log('Account deleted successfully via Edge Function');
    } catch (e) {
      log("Error deleting account: $e");
      rethrow;
    }

    try {
      await signOut();
      log("User signed out successfully");
    } catch (e) {
      log("Error during sign-out: $e");
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String getAvatarUrl(String userId) {
    return _supabase.storage.from('avatars').getPublicUrl('$userId/avatar.png');
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    final userId = user?.id;

    if (userId == null) throw Exception("No user logged in");

    log('getUserProfile: Fetching profile for userId: $userId');

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    log('getUserProfile: Raw response from DB: $response');

    final String? name =
        response != null ? (response['name'] as String?) : null;
    final String? phone =
        response != null ? (response['phone'] as String?) : null;
    final int? age = response != null ? (response['age'] as int?) : null;

    log('getUserProfile: Extracted name=$name, phone=$phone, age=$age');

    final result = {
      'id': userId,
      'name': name ?? '',
      'phone': phone ?? '',
      'age': age ?? 0,
      // Cache-bust avatar URL so UI refreshes after uploads
      'avatarUrl':
          '${getAvatarUrl(userId)}?v=${DateTime.now().millisecondsSinceEpoch}',
      'email': user?.email,
    };

    log('getUserProfile: Final result: $result');
    return result;
  }

  Future<void> updateUserName(String newName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("No user logged in");

    await _supabase.from('profiles').update({'name': newName}).eq('id', userId);
  }

  Future<void> updateUserAvatar(XFile image) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("No user logged in");

    final avatarPath = '$userId/avatar.png';

    // Prepare file (read bytes, compress when beneficial, write to temp file)
    final file = await _prepareFileForUpload(image, '$userId-avatar.png');

    try {
      final response = await _supabase.storage.from('avatars').upload(
          avatarPath, file,
          fileOptions: const FileOptions(upsert: true));

      log('Upload response: $response'); // See exact success/fail from Supabase
    } catch (e) {
      log('Upload error TYPE: ${e.runtimeType}');
      log('Upload error DETAIL: $e');
      rethrow; // Bubble up so cubit/UI can handle it
    } finally {
      // Best-effort cleanup of temp file
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  // Reads XFile bytes, compresses if large, and writes a temp file for upload
  Future<File> _prepareFileForUpload(XFile image, String filename) async {
    final bytes = await image.readAsBytes();
    if (bytes.isEmpty) throw Exception('Image file is empty or does not exist');

    List<int> uploadBytes = bytes;
    const int threshold = 200 * 1024; // 200KB
    if (bytes.length > threshold) {
      try {
        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 800,
          minHeight: 800,
          quality: 80,
        );
        if (compressed.isNotEmpty) {
          uploadBytes = compressed;
          log('Image compressed: original=${bytes.length}, compressed=${uploadBytes.length}');
        }
      } catch (e) {
        log('Image compression failed: $e');
      }
    }

    final tmpDir = await getTemporaryDirectory();
    final tmpFile = File('${tmpDir.path}/$filename');
    await tmpFile.writeAsBytes(uploadBytes, flush: true);
    return tmpFile;
  }
}
