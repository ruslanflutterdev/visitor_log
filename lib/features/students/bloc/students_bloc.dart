import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'students_event.dart';
import 'students_state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  StudentsBloc() : super(StudentsInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<AddStudentsRequested>(_onAddStudents);
    on<DeleteStudentRequested>(_onDeleteStudent);
    on<InitiateTransferRequested>(_onInitiateTransfer);
  }

  Future<void> _logAction(String actionType, String details) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('audit_logs').insert({
      'coach_id': userId,
      'action_type': actionType,
      'details': details,
    });
  }

  Future<void> _onLoadStudents(
    LoadStudents event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      final data = await _supabase
          .from('students')
          .select('*, student_transfers(status)')
          .eq('group_id', event.groupId)
          .order('last_name', ascending: true);
      emit(StudentsLoaded(data));
    } catch (e) {
      emit(StudentsError('Ошибка загрузки учеников: $e'));
    }
  }

  Future<void> _onAddStudents(
    AddStudentsRequested event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      final userId = _supabase.auth.currentUser!.id;

      final studentsData = event.students
          .map(
            (s) => {
              'coach_id': userId,
              'group_id': event.groupId,
              'first_name': s.firstName.text.trim(),
              'last_name': s.lastName.text.trim(),
              'middle_name': s.middleName.text.trim(),
              'birth_date': s.birthDate!.toIso8601String().split('T')[0],
              'phone': s.phone.text.trim(),
            },
          )
          .toList();

      await _supabase.from('students').insert(studentsData);

      await _logAction(
        'Добавление учеников',
        'Добавлено ${studentsData.length} учеников',
      );

      emit(const StudentActionSuccess('Ученики успешно добавлены!'));
      add(LoadStudents(event.groupId));
    } catch (e) {
      emit(StudentsError('Ошибка добавления: $e'));
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudentRequested event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      await _supabase.from('students').delete().eq('id', event.studentId);
      await _logAction(
        'Удаление ученика',
        'Удален ученик: ${event.studentName}',
      );

      emit(const StudentActionSuccess('Ученик удален'));
      add(LoadStudents(event.groupId));
    } catch (e) {
      emit(StudentsError('Ошибка удаления: $e'));
    }
  }

  Future<void> _onInitiateTransfer(
    InitiateTransferRequested event,
    Emitter<StudentsState> emit,
  ) async {
    emit(StudentsLoading());
    try {
      final userId = _supabase.auth.currentUser!.id;

      final existing = await _supabase
          .from('student_transfers')
          .select()
          .eq('student_id', event.studentId)
          .eq('status', 'pending');

      if (existing.isNotEmpty) {
        emit(
          const StudentsError('Для этого ученика уже есть активная заявка.'),
        );
        add(LoadStudents(event.groupId));
        return;
      }

      await _supabase.from('student_transfers').insert({
        'student_id': event.studentId,
        'from_coach_id': userId,
        'to_coach_id': event.toCoachId,
      });

      await _logAction(
        'Перевод',
        'Создана заявка на перевод ученика: ${event.studentName}',
      );

      emit(const StudentActionSuccess('Заявка на перевод успешно отправлена!'));
      add(LoadStudents(event.groupId)); // Обновляем список (появится статус)
    } catch (e) {
      emit(StudentsError('Ошибка перевода: $e'));
    }
  }
}
