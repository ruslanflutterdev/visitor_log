import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_app_bar.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String adminName;

  const AdminDashboardScreen({super.key, required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: Text(adminName, style: const TextStyle(fontSize: 18)),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.0, // Делает карточки идеальными квадратами
        children: [
          _AdminCard(
            title: 'Тренеры',
            icon: Icons.sports,
            color: Colors.blueAccent,
            onTap: () => context.push('/admin/coaches'),
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
    );
  }
}

// Переиспользуемый виджет карточки
class _AdminCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(38),
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
    );
  }
}
