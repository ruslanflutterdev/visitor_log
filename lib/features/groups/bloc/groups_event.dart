import 'package:equatable/equatable.dart';
import '../models/day_schedule.dart';

sealed class GroupsEvent extends Equatable {
  const GroupsEvent();
  @override
  List<Object?> get props => [];
}

final class LoadGroups extends GroupsEvent {}

final class CreateGroupRequested extends GroupsEvent {
  final String name;
  final Map<String, DaySchedule> schedule;

  const CreateGroupRequested({required this.name, required this.schedule});

  @override
  List<Object?> get props => [name, schedule];
}
