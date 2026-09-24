import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transfers_bloc.dart';
import '../bloc/transfers_state.dart';
import '../widgets/accept_transfer_bottom_sheet.dart';
import '../bloc/transfers_event.dart';

class IncomingTransfersScreen extends StatelessWidget {
  const IncomingTransfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Входящие переводы', style: TextStyle(fontSize: 18)),
      ),
      body: BlocBuilder<TransfersBloc, TransfersState>(
        builder: (context, state) {
          if (state is TransfersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransfersError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is TransfersLoaded) {
            final transfers = state.transfers;
            if (transfers.isEmpty) {
              return const Center(
                child: Text('Нет входящих заявок на перевод.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];

                final student = transfer['students'] as Map<String, dynamic>?;

                if (student == null) {
                  return const SizedBox.shrink();
                }

                final fullName =
                    '${student['last_name']} ${student['first_name']}'.trim();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.swap_horiz, color: Colors.white),
                    ),
                    title: Text(
                      fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Ожидает зачисления в группу'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => context.read<TransfersBloc>().add(
                            RejectTransferRequested(transfer['id'], fullName),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => AcceptTransferBottomSheet(
                                transferId: transfer['id'],
                                studentId: student['id'],
                                studentName: fullName,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
