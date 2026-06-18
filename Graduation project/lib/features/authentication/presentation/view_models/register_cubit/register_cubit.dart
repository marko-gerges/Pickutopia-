// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pickutopia/features/authentication/services/supabase_auth_service.dart';

// part 'register_state.dart';

// class RegisterCubit extends Cubit<RegisterState> {
//   final SupabaseAuthService _authService;

//   RegisterCubit(this._authService) : super(RegisterState());

//   void updateUserInfo({
//     required String name,
//     required String email,
//     required String phone,
//     required String password,
//     required String age,
//   }) {
//     emit(state.copyWith(
//       name: name,
//       email: email,
//       phone: phone,
//       password: password,
//       age: age
//     ));
//   }

//   void setAvatar(XFile avatar) {
//     emit(state.copyWith(avatar: avatar));
//   }

//   Future<void> register() async {
//     try {
//       emit(state.copyWith(isLoading: true));
//       await _authService.registerUser(
//         email: state.email!,
//         password: state.password!,
//         name: state.name!,
//         phone: state.phone!,
//         age: state.age!,
//         avatar: state.avatar,
//       );
//       emit(state.copyWith(isSuccess: true, isLoading: false));
//     } catch (e) {
//       emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
//     }
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickutopia/features/authentication/services/supabase_auth_service.dart';
import 'package:pickutopia/core/utils/error_mapper.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final SupabaseAuthService _authService;

  RegisterCubit(this._authService) : super(RegisterState());

  // 1. Reset method to clear old images/data when navigating back or logging out
  void reset() {
    emit(RegisterState());
  }

  void updateUserInfo({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String age,
  }) {
    emit(state.copyWith(
      name: name,
      email: email,
      phone: phone,
      password: password,
      age: age,
    ));
  }

  void setAvatar(XFile avatar) {
    emit(state.copyWith(avatar: avatar));
  }

  void removeAvatar() {
    emit(state.copyWith(avatar: null));
  }

  Future<void> register() async {
    if (state.email == null || state.password == null || state.name == null) {
      emit(state.copyWith(errorMessage: "Please fill in all required fields."));
      return;
    }
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      await _authService.registerUser(
        email: state.email!,
        password: state.password!,
        name: state.name!,
        phone: state.phone ?? '', // Fallback to empty string if null
        age: state.age ?? '0', // Fallback to 0 if null
        avatar: state.avatar,
      );

      // Success
      emit(state.copyWith(isSuccess: true, isLoading: false));
    } catch (e) {
      final friendly = friendlyErrorMessage(e);
      emit(state.copyWith(errorMessage: friendly, isLoading: false));
    }
  }
}
