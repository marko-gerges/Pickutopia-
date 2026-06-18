part of 'register_cubit.dart';

class RegisterState {
  final String? name;
  final String? email;
  final String? phone;
  final String? password;
  final String? age;
  final XFile? avatar;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  RegisterState({
    this.name,
    this.email,
    this.phone,
    this.password,
    this.avatar,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.age
  });

  RegisterState copyWith({
    String? name,
    String? email,
    String? phone,
    String? password,
    XFile? avatar,
    String? age,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      age: age?? this.age,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}
