import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_coaches_event.dart';
import 'admin_coaches_state.dart';

class AdminCoachesBloc extends Bloc<AdminCoachesEvent, AdminCoachesState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AdminCoachesBloc() : super(AdminCoachesInitial()) {
    on<LoadAdminCoaches>(_onLoadCoaches);
    on<ApproveCoachRequested>(_onApproveCoach);
  }

  Future _onLoadCoaches(LoadAdminCoaches event, Emitter emit) async {
    emit(AdminCoachesLoading());
    try {
      final data = await _supabase
          .from('profiles')
          .select('''
            id, email, first_name, last_name, middle_name, birth_date, phone, role,
            groups(id, name, group_schedules(*)),
            students(id, group_id) 
          ''')
          .inFilter('role', ['pending', 'coach', 'senior_coach'])
          .order('last_name', ascending: true);

      emit(AdminCoachesLoaded(data));
    } catch (e) {
      emit(AdminCoachesError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onApproveCoach(
    ApproveCoachRequested event,
    Emitter<AdminCoachesState> emit,
  ) async {
    emit(AdminCoachesLoading());
    try {
      await _supabase
          .from('profiles')
          .update({'role': 'coach'})
          .eq('id', event.coachId);
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('audit_logs').insert({
        'coach_id': userId,
        'action_type': 'Одобрение',
        'details': 'Одобрен аккаунт тренера',
      });
      add(LoadAdminCoaches());
    } catch (e) {
      emit(AdminCoachesError('Ошибка одобрения: $e'));
    }
  }
}
