import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_coaches_bloc.dart';
import '../bloc/admin_coaches_event.dart';
import '../bloc/admin_coaches_state.dart';

class AdminCoachesScreen extends StatelessWidget {
  const AdminCoachesScreen({super.key});

  int _calculateAge(String? birthDateStr) {
    if (birthDateStr == null) return 0;
    final birthDate = DateTime.parse(birthDateStr);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatGroupsSummary(List<dynamic> groups) {
    if (groups.isEmpty) return 'Нет групп';
    final counts = <String, int>{};
    for (var g in groups) {
      final name = g['name'].toString();
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts.entries.map((e) => '${e.key} - ${e.value} гр').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренеры', style: TextStyle(fontSize: 18)),
      ),
      body: BlocBuilder<AdminCoachesBloc, AdminCoachesState>(
        builder: (context, state) {
          if (state is AdminCoachesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminCoachesError) {
            return Center(child: Text(state.message));
          }
          if (state is AdminCoachesLoaded) {
            final pending = state.coaches
                .where((c) => c['role'] == 'pending')
                .toList();
            final active = state.coaches
                .where((c) => c['role'] != 'pending')
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pending.isNotEmpty) ...[
                  const Text(
                    'Ожидают подтверждения',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...pending.map(
                    (coach) => _buildCoachCard(context, coach, true),
                  ),
                  const Divider(height: 32, thickness: 1),
                ],
                const Text(
                  'Действующий персонал',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...active.map(
                  (coach) => _buildCoachCard(context, coach, false),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCoachCard(BuildContext context, dynamic coach, bool isPending) {
    final fullName =
        '${coach['last_name']} ${coach['first_name']} ${coach['middle_name'] ?? ''}'
            .trim();
    final age = _calculateAge(coach['birth_date']);
    final groups = coach['groups'] as List<dynamic>? ?? [];
    final students = coach['students'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: isPending
            ? null
            : () => context.push('/admin/coach/${coach['id']}', extra: coach),
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$fullName, $age лет',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isPending)
              Text(
                'Учеников: ${students.length}',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Тел: ${coach['phone']}'),
            if (!isPending) ...[
              const SizedBox(height: 4),
              Text(
                'Группы: ${_formatGroupsSummary(groups)}',
                style: const TextStyle(color: Colors.black87),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<AdminCoachesBloc>().add(
                  ApproveCoachRequested(coach['id']),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Одобрить аккаунт',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
