import 'package:equatable/equatable.dart';

sealed class TransfersEvent extends Equatable {
  const TransfersEvent();
  @override
  List<Object?> get props => [];
}

final class LoadIncomingTransfers extends TransfersEvent {}

final class AcceptTransferRequested extends TransfersEvent {
  final String transferId;
  final String studentId;
  final String newGroupId;
  final String studentName;

  const AcceptTransferRequested(
    this.transferId,
    this.studentId,
    this.newGroupId,
    this.studentName,
  );
  @override
  List<Object?> get props => [transferId, studentId, newGroupId, studentName];
}

final class RejectTransferRequested extends TransfersEvent {
  final String transferId;
  final String studentName;

  const RejectTransferRequested(this.transferId, this.studentName);
  @override
  List<Object?> get props => [transferId, studentName];
}
