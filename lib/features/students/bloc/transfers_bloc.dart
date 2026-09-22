import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transfers_event.dart';
import 'transfers_state.dart';

class TransfersBloc extends Bloc<TransfersEvent, TransfersState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  TransfersBloc() : super(TransfersInitial()) {
    on<LoadIncomingTransfers>(_onLoadIncoming);
    on<AcceptTransferRequested>(_onAccept);
    on<RejectTransferRequested>(_onReject);
  }

  Future<void> _logAction(String actionType, String details) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('audit_logs').insert({
      'coach_id': userId,
      'action_type': actionType,
      'details': details,
    });
  }

  Future<void> _onLoadIncoming(
    LoadIncomingTransfers event,
    Emitter<TransfersState> emit,
  ) async {
    emit(TransfersLoading());
    try {
      final userId = _supabase.auth.currentUser!.id;
      // Подтягиваем заявки ВМЕСТЕ с данными учеников
      final data = await _supabase
          .from('student_transfers')
          .select('*, students(*)')
          .eq('to_coach_id', userId)
          .eq('status', 'pending');
      emit(TransfersLoaded(data));
    } catch (e) {
      emit(TransfersError('Ошибка загрузки заявок: $e'));
    }
  }

  Future<void> _onAccept(
    AcceptTransferRequested event,
    Emitter<TransfersState> emit,
  ) async {
    emit(TransfersLoading());
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase
          .from('students')
          .update({'coach_id': userId, 'group_id': event.newGroupId})
          .eq('id', event.studentId);
      await _supabase
          .from('student_transfers')
          .update({'status': 'accepted'})
          .eq('id', event.transferId);

      await _logAction(
        'Перевод принят',
        'Зачислен ученик: ${event.studentName}',
      );
      emit(const TransferActionSuccess('Ученик успешно зачислен в группу!'));
      add(LoadIncomingTransfers());
    } catch (e) {
      emit(TransfersError('Ошибка принятия: $e'));
    }
  }

  Future<void> _onReject(
    RejectTransferRequested event,
    Emitter<TransfersState> emit,
  ) async {
    emit(TransfersLoading());
    try {
      await _supabase
          .from('student_transfers')
          .update({'status': 'rejected'})
          .eq('id', event.transferId);
      await _logAction(
        'Перевод отклонен',
        'Отклонен ученик: ${event.studentName}',
      );
      emit(const TransferActionSuccess('Заявка отклонена.'));
      add(LoadIncomingTransfers());
    } catch (e) {
      emit(TransfersError('Ошибка отклонения: $e'));
    }
  }
}
