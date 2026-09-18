import 'package:equatable/equatable.dart';

sealed class GroupsState extends Equatable {
  const GroupsState();
  @override
  List<Object?> get props => [];
}

final class GroupsInitial extends GroupsState {}

final class GroupsLoading extends GroupsState {}

final class GroupsLoaded extends GroupsState {
  final List<dynamic> groups;
  const GroupsLoaded(this.groups);
  @override
  List<Object?> get props => [groups];
}

final class GroupsError extends GroupsState {
  final String message;
  const GroupsError(this.message);
  @override
  List<Object?> get props => [message];
}

final class GroupActionSuccess extends GroupsState {
  final String message;
  const GroupActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
