import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../bloc/admin_coaches_bloc.dart';
import '../bloc/admin_coaches_event.dart';
import '../bloc/admin_coaches_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminName;

  const AdminDashboardScreen({super.key, required this.adminName});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCoachesBloc>().add(LoadAdminCoaches());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: Text(
          widget.adminName,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: GridView.extent(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            maxCrossAxisExtent: 200,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.0,
            children: [
              BlocBuilder<AdminCoachesBloc, AdminCoachesState>(
                builder: (context, state) {
                  int pendingCount = 0;
                  if (state is AdminCoachesLoaded) {
                    pendingCount = state.coaches
                        .where((c) => c['role'] == 'pending')
                        .length;
                  }
                  return _AdminCard(
                    title: 'Тренеры',
                    icon: Icons.sports,
                    color: Colors.blueAccent,
                    badgeCount: pendingCount,
                    onTap: () => context.push('/admin/coaches'),
                  );
                },
              ),
              _AdminCard(
                title: 'Все ученики',
                icon: Icons.people_alt_outlined,
                color: Colors.orange,
                onTap: () => context.push('/admin/students'),
              ),
              _AdminCard(
                title: 'Статистика',
                icon: Icons.bar_chart,
                color: Colors.green,
                onTap: () => context.push('/admin/statistics'),
              ),
              _AdminCard(
                title: 'Журнал действий',
                icon: Icons.history,
                color: Colors.purple,
                onTap: () => context.push('/admin/audit-logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  const _AdminCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withAlpha(32),
                      radius: 32,
                      child: Icon(icon, size: 32, color: color),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
