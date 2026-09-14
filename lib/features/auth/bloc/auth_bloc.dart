import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    on<AuthInitialize>(_onInitialize);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);

    _supabaseClient.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        add(AuthInitialize());
      } else {
        add(AuthInitialize());
      }
    });
  }

  void _onInitialize(AuthInitialize event, Emitter<AuthBlocState> emit) {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      emit(AuthAuthenticated(session.user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        emit(AuthAuthenticated(response.user!));
      } else {
        emit(const AuthError('Пользователь не найден'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: {
          'first_name': event.firstName,
          'last_name': event.lastName,
          'middle_name': event.middleName ?? '',
          'birth_date': event.birthDate.toIso8601String().split('T')[0],
          'gender': event.gender,
          'phone': event.phone ?? '',
        },
      );
      emit(AuthOtpVerificationRequired(event.email));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _supabaseClient.auth.verifyOTP(
        email: event.email,
        token: event.code,
        type: OtpType.signup,
      );
      if (response.user != null) {
        emit(AuthAuthenticated(response.user!));
      } else {
        emit(const AuthError('Неверный код'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    await _supabaseClient.auth.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthBlocState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _supabaseClient.auth.resetPasswordForEmail(event.email);
      emit(const AuthActionSuccess('Код восстановления отправлен на почту.'));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
