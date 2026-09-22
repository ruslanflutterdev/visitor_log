import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import '../widgets/create_group_bottom_sheet.dart';
import '../widgets/edit_group_bottom_sheet.dart';

class GroupsScreen extends StatelessWidget {
  final String coachName;

  const GroupsScreen({super.key, required this.coachName});

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateGroupBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: Text(coachName, style: const TextStyle(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Создать группу'),
      ),
      body: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          if (state is GroupsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is GroupsLoaded) {
            final groups = state.groups;

            if (groups.isEmpty) {
              return const Center(
                child: Text('У вас пока нет созданных групп.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final schedules =
                    group['group_schedules'] as List<dynamic>? ?? [];

                final Map<String, List<String>> timeGroups = {};
                for (var s in schedules) {
                  final start = s['start_time'].toString().substring(0, 5);
                  final end = s['end_time'].toString().substring(0, 5);
                  final timeKey = '$start - $end';
                  final day = s['day_of_week'].toString();

                  timeGroups.putIfAbsent(timeKey, () => []).add(day);
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      context.push(
                        '/group/${group['id']}',
                        extra: group['name'],
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      group['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: timeGroups.entries.map((entry) {
                        final time = entry.key;
                        final daysList = entry.value;

                        daysList.sort(
                          (a, b) => AppConstants.weekDays
                              .indexOf(a)
                              .compareTo(AppConstants.weekDays.indexOf(b)),
                        );
                        final daysStr = daysList.join(', ');

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
                                '$daysStr: $time',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: Colors.blueAccent,
                            ),
                            Text(
                              '0 чел',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              context.read<GroupsBloc>().add(
                                DeleteGroupRequested(
                                  group['id'],
                                  group['name'],
                                ),
                              );
                            } else if (value == 'edit') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) =>
                                    EditGroupBottomSheet(group: group),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Редактировать'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Удалить',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Инициализация...'));
        },
      ),
    );
  }
}
