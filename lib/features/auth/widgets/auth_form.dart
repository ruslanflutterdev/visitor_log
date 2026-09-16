import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class AuthForm extends StatefulWidget {
  final bool isLoading;

  const AuthForm({super.key, required this.isLoading});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignInPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthBloc>().add(AuthSignInRequested(email, password));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.sports_tennis, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 32),
        const Text(
          'Вход в систему',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          labelText: 'Пароль',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: widget.isLoading ? null : _onSignInPressed,
          child: widget.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Войти', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.push('/recovery'),
          child: const Text('Забыли пароль?'),
        ),
        TextButton(
          onPressed: () => context.push('/register'),
          child: const Text('Зарегистрироваться'),
        ),
      ],
    );
  }
}
