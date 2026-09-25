import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class AdminCoachDetailsScreen extends StatelessWidget {
  final Map coach;

  const AdminCoachDetailsScreen({super.key, required this.coach});

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

  @override
  Widget build(BuildContext context) {
    final String lastName = coach['last_name'] ?? '';
    final String firstName = coach['first_name'] ?? '';
    final String middleName = coach['middle_name'] ?? '';
    final String fullName = ('$lastName $firstName $middleName').trim();

    final int age = _calculateAge(coach['birth_date']);
    final List groups = coach['groups'] as List? ?? [];
    final List allStudents = coach['students'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль тренера', style: TextStyle(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueAccent.withAlpha(32),
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Возраст: $age лет',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    Icons.email_outlined,
                    'Email',
                    coach['email'] ?? 'Не указан',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.phone_outlined,
                    'Телефон',
                    coach['phone'] ?? 'Не указан',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.people_outline,
                    'Всего учеников',
                    '${allStudents.length} чел.',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Группы',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (groups.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('У тренера нет групп'),
              ),
            ),

          ...groups.map((group) {
            final List schedules = group['group_schedules'] as List? ?? [];
            final int studentsInGroup = allStudents
                .where((s) => s['group_id'] == group['id'])
                .length;

            final Map timeGroups = {};
            for (var s in schedules) {
              final String startTime = s['start_time'].toString().substring(
                0,
                5,
              );
              final String endTime = s['end_time'].toString().substring(0, 5);
              final String time = '$startTime - $endTime';
              final String day = s['day_of_week'].toString();

              if (timeGroups[time] == null) {
                timeGroups[time] = [];
              }
              (timeGroups[time] as List).add(day);
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  context.push('/group/${group['id']}', extra: group['name']);
                },
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  group['name'].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: timeGroups.entries.map((entry) {
                    final List days = entry.value as List;
                    days.sort(
                      (a, b) => AppConstants.weekDays
                          .indexOf(a)
                          .compareTo(AppConstants.weekDays.indexOf(b)),
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${days.join(', ')}: ${entry.key}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.groups, color: Colors.blueAccent),
                    Text(
                      '$studentsInGroup чел',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
