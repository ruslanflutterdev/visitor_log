import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AuthBlocState extends Equatable {
  const AuthBlocState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthBlocState {}

final class AuthLoading extends AuthBlocState {}

final class AuthAuthenticated extends AuthBlocState {
  final User user;
  final String role;
  final String firstName;
  final String lastName;

  const AuthAuthenticated(this.user, this.role, this.firstName, this.lastName);

  @override
  List<Object?> get props => [user, role, firstName, lastName];
}

final class AuthUnauthenticated extends AuthBlocState {}

final class AuthOtpVerificationRequired extends AuthBlocState {
  final String email;

  const AuthOtpVerificationRequired(this.email);

  @override
  List<Object?> get props => [email];
}

final class AuthError extends AuthBlocState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

final class AuthActionSuccess extends AuthBlocState {
  final String message;

  const AuthActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
