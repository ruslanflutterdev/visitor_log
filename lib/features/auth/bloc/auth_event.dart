import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthInitialize extends AuthEvent {}

final class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime birthDate;
  final String gender;
  final String? phone;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.birthDate,
    required this.gender,
    this.phone,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    firstName,
    lastName,
    middleName,
    birthDate,
    gender,
    phone,
  ];
}

final class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String code;
  final bool isRecovery;

  const AuthVerifyOtpRequested(
    this.email,
    this.code, {
    this.isRecovery = false,
  });

  @override
  List<Object?> get props => [email, code, isRecovery];
}

final class AuthSignOutRequested extends AuthEvent {}

final class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

final class AuthUpdatePasswordRequested extends AuthEvent {
  final String newPassword;
  const AuthUpdatePasswordRequested(this.newPassword);
  @override
  List<Object?> get props => [newPassword];
}
