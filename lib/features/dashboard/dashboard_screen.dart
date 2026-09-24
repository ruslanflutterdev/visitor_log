import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../admin/screens/admin_dashboard_screen.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../auth/screens/pending_screen.dart';
import '../groups/screens/groups_screen.dart';
import '../students/bloc/transfers_bloc.dart';
import '../students/bloc/transfers_event.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransfersBloc>().add(LoadIncomingTransfers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthBlocState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final fullName = '${state.lastName} ${state.firstName}'.trim();

          if (state.role == 'pending') {
            return const PendingScreen();
          } else if (state.role == 'admin' || state.role == 'senior_coach') {
            return AdminDashboardScreen(adminName: fullName);
          } else {
            return GroupsScreen(coachName: fullName);
          }
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
