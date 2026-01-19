part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserModel? user;

  const AuthUserChanged({this.user});

  @override
  List<Object?> get props => [user];
}

class AuthErrorOccurred extends AuthEvent {
  final String message;

  const AuthErrorOccurred({required this.message});

  @override
  List<Object?> get props => [message];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const SignUpRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}
