import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthBlocState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.sports_tennis,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Журнал посещений',
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
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _onSignInPressed,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Войти', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.push('/recovery');
                    },
                    child: const Text('Забыли пароль?'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    child: const Text('Регистрация'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
