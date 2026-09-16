import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../auth/screens/pending_screen.dart';
import '../groups/groups_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthBlocState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.role == 'pending') {
            return const PendingScreen();
          } else if (state.role == 'admin' || state.role == 'senior_coach') {
            return const Scaffold(
              appBar: CustomAppBar(title: 'Панель администратора'),
              body: Center(
                child: Text('Здесь будет панель администратора'),
              ),
            );
          } else {
            // Обычный подтвержденный тренер
            return const GroupsScreen();
          }
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
