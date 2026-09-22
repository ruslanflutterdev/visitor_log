import 'package:equatable/equatable.dart';

sealed class TransfersState extends Equatable {
  const TransfersState();
  @override
  List<Object?> get props => [];
}

final class TransfersInitial extends TransfersState {}

final class TransfersLoading extends TransfersState {}

final class TransfersLoaded extends TransfersState {
  final List<dynamic> transfers;
  const TransfersLoaded(this.transfers);
  @override
  List<Object?> get props => [transfers];
}

final class TransfersError extends TransfersState {
  final String message;
  const TransfersError(this.message);
  @override
  List<Object?> get props => [message];
}

final class TransferActionSuccess extends TransfersState {
  final String message;
  const TransferActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
