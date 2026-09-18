import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'groups_event.dart';
import 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  GroupsBloc() : super(GroupsInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<CreateGroupRequested>(_onCreateGroup);
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

      emit(const GroupActionSuccess('Группа успешно создана!'));
      add(LoadGroups()); // Автоматически перезагружаем список групп
    } catch (e) {
      emit(GroupsError('Ошибка создания: $e'));
    }
  }
}
