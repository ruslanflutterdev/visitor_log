import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_event.dart';
import 'auth_state.dart' hide AuthState;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  AuthBloc() : super(AuthInitial() as AuthState) {
    on<AuthInitialize>(_onInitialize);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);

    // Слушаем изменения состояния авторизации Supabase
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        add(AuthInitialize()); // Перепроверяем состояние при изменении
      } else {
        add(AuthSignOutRequested());
      }
    });
  }

  void _onInitialize(AuthInitialize event, Emitter<AuthState> emit) {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      emit(AuthAuthenticated(session.user) as AuthState);
    } else {
      emit(AuthUnauthenticated() as AuthState);
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading() as AuthState);
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        emit(AuthAuthenticated(response.user!) as AuthState);
      } else {
        emit(
          const AuthError('Ошибка входа: пользователь не найден') as AuthState,
        );
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message) as AuthState);
    } catch (e) {
      emit(AuthError(e.toString()) as AuthState);
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading() as AuthState);
    try {
      await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: {
          'first_name': event.firstName,
          'last_name': event.lastName,
          'middle_name': event.middleName ?? '',
          'birth_date': event.birthDate.toIso8601String().split('T')[0],
          // Форматируем дату
          'gender': event.gender,
          'phone': event.phone ?? '',
        },
      );
      // Supabase по умолчанию отправляет письмо с подтверждением
      emit(
        const AuthActionSuccess(
              'Регистрация успешна! Пожалуйста, проверьте вашу почту для подтверждения.',
            )
            as AuthState,
      );
    } on AuthException catch (e) {
      emit(AuthError(e.message) as AuthState);
    } catch (e) {
      emit(AuthError(e.toString()) as AuthState);
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading() as AuthState);
    await _supabaseClient.auth.signOut();
    emit(AuthUnauthenticated() as AuthState);
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading() as AuthState);
    try {
      await _supabaseClient.auth.resetPasswordForEmail(event.email);
      emit(
        const AuthActionSuccess(
              'Ссылка для сброса пароля отправлена на вашу почту.',
            )
            as AuthState,
      );
    } on AuthException catch (e) {
      emit(AuthError(e.message) as AuthState);
    } catch (e) {
      emit(AuthError(e.toString()) as AuthState);
    }
  }
}
