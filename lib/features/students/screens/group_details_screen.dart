import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../admin/bloc/admin_coaches_bloc.dart';
import '../../admin/bloc/admin_coaches_event.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../groups/bloc/groups_bloc.dart';
import '../../groups/bloc/groups_event.dart';

import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';
import '../widgets/add_students_bottom_sheet.dart';
import '../widgets/transfer_student_bottom_sheet.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentsBloc>().add(LoadStudents(widget.groupId));
  }

  void _showAddStudentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddStudentsBottomSheet(groupId: widget.groupId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName, style: const TextStyle(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentsSheet(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Добавить учеников'),
      ),
      body: BlocConsumer<StudentsBloc, StudentsState>(
        listener: (context, state) {
          if (state is StudentActionSuccess) {
            context.read<GroupsBloc>().add(LoadGroups());

            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated &&
                (authState.role == 'admin' ||
                    authState.role == 'senior_coach')) {
              // ЗАМЕНИТЬ [] НА <>
              context.read<AdminCoachesBloc>().add(LoadAdminCoaches());
            }
          }
        },
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is StudentsLoaded) {
            final students = state.students;
            if (students.isEmpty) {
              return const Center(
                child: Text('В этой группе пока нет учеников.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                final String lastName = student['last_name'] ?? '';
                final String firstName = student['first_name'] ?? '';
                final String middleName = student['middle_name'] ?? '';
                final String fullName = '$lastName $firstName $middleName'
                    .trim();

                final List transfers =
                    student['student_transfers'] as List? ?? [];
                final isPendingTransfer = transfers.any(
                  (t) => t['status'] == 'pending',
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPendingTransfer
                          ? Colors.orange.shade200
                          : Colors.blueAccent.shade100,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isPendingTransfer)
                          const Text(
                            ' В переводе',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('Тел: ${student['phone']}'),
                    trailing: isPendingTransfer
                        ? null
                        // ЗАМЕНИТЬ [] НА <>
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                // ЗАМЕНИТЬ [] НА <>
                                context.read<StudentsBloc>().add(
                                  DeleteStudentRequested(
                                    student['id'],
                                    widget.groupId,
                                    fullName,
                                  ),
                                );
                              } else if (value == 'transfer') {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) =>
                                      TransferStudentBottomSheet(
                                        studentId: student['id'],
                                        studentName: fullName,
                                        groupId: widget.groupId,
                                      ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'transfer',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.swap_horiz,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Перевести'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
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
