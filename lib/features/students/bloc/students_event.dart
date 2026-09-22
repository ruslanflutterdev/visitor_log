import 'package:equatable/equatable.dart';
import '../models/student_form_model.dart';

sealed class StudentsEvent extends Equatable {
  const StudentsEvent();
  @override
  List<Object?> get props => [];
}

final class LoadStudents extends StudentsEvent {
  final String groupId;
  const LoadStudents(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

final class AddStudentsRequested extends StudentsEvent {
  final String groupId;
  final List<StudentFormModel> students;
  const AddStudentsRequested(this.groupId, this.students);
  @override
  List<Object?> get props => [groupId, students];
}

final class DeleteStudentRequested extends StudentsEvent {
  final String studentId;
  final String groupId;
  final String studentName;
  const DeleteStudentRequested(this.studentId, this.groupId, this.studentName);
  @override
  List<Object?> get props => [studentId, groupId, studentName];
}

final class InitiateTransferRequested extends StudentsEvent {
  final String studentId;
  final String toCoachId;
  final String studentName;
  final String groupId;

  const InitiateTransferRequested(
    this.studentId,
    this.toCoachId,
    this.studentName,
    this.groupId,
  );

  @override
  List<Object?> get props => [studentId, toCoachId, studentName, groupId];
}
