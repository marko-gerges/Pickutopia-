part of 'user_cubit.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final String name;
  final String avatarUrl;
  final String email;
  final String age;

  UserLoaded(
      {required this.name,
      required this.avatarUrl,
      required this.email,
      required this.age});
}

class UserUploading extends UserState {
  final String name;
  final String avatarUrl;
  final String email;
  final String age;

  UserUploading({
    required this.name,
    required this.avatarUrl,
    required this.email,
    required this.age,
  });
}

class UserDeleted extends UserState {}

class UserSignedOut extends UserState {}

class UserError extends UserState {
  final String message;

  UserError({required this.message});
}
