import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/students/bloc/transfers_bloc.dart';
import '../../features/students/bloc/transfers_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget titleWidget;

  const CustomAppBar({super.key, required this.titleWidget});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget,
      actions: [
        BlocBuilder<AuthBloc, AuthBlocState>(
          builder: (context, authState) {
            bool isAdmin = false;
            if (authState is AuthAuthenticated) {
              isAdmin =
                  authState.role == 'admin' || authState.role == 'senior_coach';
            }

            if (isAdmin) return const SizedBox.shrink();

            return BlocBuilder<TransfersBloc, TransfersState>(
              builder: (context, state) {
                int pendingCount = 0;
                if (state is TransfersLoaded) {
                  pendingCount = state.transfers.length;
                }
                return IconButton(
                  icon: Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text(pendingCount.toString()),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  onPressed: () => context.push('/incoming-transfers'),
                );
              },
            );
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'settings') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Настройки в разработке')),
              );
            } else if (value == 'logout') {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.black87),
                  SizedBox(width: 8),
                  Text('Настройки', style: TextStyle(color: Colors.black87)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text('Выйти', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
