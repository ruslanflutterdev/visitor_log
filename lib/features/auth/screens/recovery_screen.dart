import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onRecoverPressed() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      context.read<AuthBloc>().add(AuthResetPasswordRequested(email));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Восстановление пароля')),
      body: BlocConsumer<AuthBloc, AuthBlocState>(
        listener: (context, state) {
          if (state is AuthActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is AuthError) {
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

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Введите ваш email, и мы отправим ссылку для сброса пароля.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _onRecoverPressed,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Отправить', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
