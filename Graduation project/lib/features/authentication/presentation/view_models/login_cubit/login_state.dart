part of 'login_cubit.dart';

class LoginState {
  final String? email;
  final String? password;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  LoginState({
    this.email,
    this.password,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}
