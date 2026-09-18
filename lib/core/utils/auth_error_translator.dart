import 'package:supabase_flutter/supabase_flutter.dart';

String translateAuthError(AuthException e) {
  final msg = e.message.toLowerCase();
  if (msg.contains('invalid login credentials')) {
    return 'Неверный email или пароль. Проверьте данные.';
  } else if (msg.contains('user already registered')) {
    return 'Пользователь с таким email уже существует.';
  } else if (msg.contains('password should be at least')) {
    return 'Пароль слишком простой или короткий.';
  } else if (msg.contains('rate limit exceeded')) {
    return 'Слишком много попыток отправки. Попробуйте позже.';
  } else if (msg.contains('token has expired or is invalid') ||
      msg.contains('invalid otp')) {
    return 'Неверный или устаревший код подтверждения.';
  }
  return 'Ошибка: ${e.message}';
}
