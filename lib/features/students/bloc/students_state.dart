import 'package:equatable/equatable.dart';

sealed class StudentsState extends Equatable {
  const StudentsState();
  @override
  List<Object?> get props => [];
}

final class StudentsInitial extends StudentsState {}

final class StudentsLoading extends StudentsState {}

final class StudentsLoaded extends StudentsState {
  final List<dynamic> students;
  const StudentsLoaded(this.students);
  @override
  List<Object?> get props => [students];
}

final class StudentsError extends StudentsState {
  final String message;
  const StudentsError(this.message);
  @override
  List<Object?> get props => [message];
}

final class StudentActionSuccess extends StudentsState {
  final String message;
  const StudentActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
