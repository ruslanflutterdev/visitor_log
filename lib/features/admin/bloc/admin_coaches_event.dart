import 'package:equatable/equatable.dart';

sealed class AdminCoachesEvent extends Equatable {
  const AdminCoachesEvent();
  @override
  List<Object?> get props => [];
}

final class LoadAdminCoaches extends AdminCoachesEvent {}

final class ApproveCoachRequested extends AdminCoachesEvent {
  final String coachId;
  const ApproveCoachRequested(this.coachId);
  @override
  List<Object?> get props => [coachId];
}
