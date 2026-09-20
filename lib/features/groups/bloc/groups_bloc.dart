import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'groups_event.dart';
import 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  GroupsBloc() : super(GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<CreateGroupRequested>(_onCreateGroup);
    on<DeleteGroupRequested>(_onDeleteGroup);
    on<UpdateGroupRequested>(_onUpdateGroup);
  }

  Future<void> _logAction(String actionType, String details) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('audit_logs').insert({
      'coach_id': userId,
      'action_type': actionType,
      'details': details,
    });
  }

  Future<void> _onLoadGroups(
    LoadGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('groups')
          .select('*, group_schedules(*)')
          .eq('coach_id', userId);
      emit(GroupsLoaded(data));
    } catch (e) {
      emit(GroupsError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onCreateGroup(
    CreateGroupRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      final userId = _supabase.auth.currentUser!.id;
      final groupResponse = await _supabase
          .from('groups')
          .insert({'coach_id': userId, 'name': event.name})
          .select('id')
          .single();
      final String groupId = groupResponse['id'];

      final schedulesData = event.schedule.entries.map((e) {
        final start =
            '${e.value.startTime!.hour.toString().padLeft(2, '0')}:${e.value.startTime!.minute.toString().padLeft(2, '0')}:00';
        final end =
            '${e.value.endTime!.hour.toString().padLeft(2, '0')}:${e.value.endTime!.minute.toString().padLeft(2, '0')}:00';
        return {
          'group_id': groupId,
          'day_of_week': e.key,
          'start_time': start,
          'end_time': end,
        };
      }).toList();

      await _supabase.from('group_schedules').insert(schedulesData);

      await _logAction('Создание', 'Создана группа "${event.name}"');

      emit(const GroupActionSuccess('Группа создана!'));
      add(LoadGroups());
    } catch (e) {
      emit(GroupsError('Ошибка создания: $e'));
    }
  }

  Future<void> _onDeleteGroup(
    DeleteGroupRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      await _supabase.from('groups').delete().eq('id', event.groupId);

      await _logAction('Удаление', 'Удалена группа "${event.groupName}"');

      emit(const GroupActionSuccess('Группа удалена'));
      add(LoadGroups());
    } catch (e) {
      emit(GroupsError('Ошибка удаления: $e'));
    }
  }

  Future<void> _onUpdateGroup(
    UpdateGroupRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      await _supabase
          .from('groups')
          .update({'name': event.name})
          .eq('id', event.groupId);

      await _supabase
          .from('group_schedules')
          .delete()
          .eq('group_id', event.groupId);
      final schedulesData = event.schedule.entries.map((e) {
        final start =
            '${e.value.startTime!.hour.toString().padLeft(2, '0')}:${e.value.startTime!.minute.toString().padLeft(2, '0')}:00';
        final end =
            '${e.value.endTime!.hour.toString().padLeft(2, '0')}:${e.value.endTime!.minute.toString().padLeft(2, '0')}:00';
        return {
          'group_id': event.groupId,
          'day_of_week': e.key,
          'start_time': start,
          'end_time': end,
        };
      }).toList();

      await _supabase.from('group_schedules').insert(schedulesData);
      await _logAction('Редактирование', 'Изменена группа "${event.name}"');
      emit(const GroupActionSuccess('Группа успешно обновлена!'));
      add(LoadGroups());
    } catch (e) {
      emit(GroupsError('Ошибка обновления: $e'));
    }
  }
}
