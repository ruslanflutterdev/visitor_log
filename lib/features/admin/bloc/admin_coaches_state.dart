import 'package:equatable/equatable.dart';

sealed class AdminCoachesState extends Equatable {
  const AdminCoachesState();
  @override
  List<Object?> get props => [];
}

final class AdminCoachesInitial extends AdminCoachesState {}

final class AdminCoachesLoading extends AdminCoachesState {}

final class AdminCoachesLoaded extends AdminCoachesState {
  final List<dynamic> coaches;
  const AdminCoachesLoaded(this.coaches);
  @override
  List<Object?> get props => [coaches];
}

final class AdminCoachesError extends AdminCoachesState {
  final String message;
  const AdminCoachesError(this.message);
  @override
  List<Object?> get props => [message];
}
