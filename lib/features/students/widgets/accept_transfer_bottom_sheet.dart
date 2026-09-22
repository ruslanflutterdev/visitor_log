import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../groups/bloc/groups_bloc.dart';
import '../../groups/bloc/groups_state.dart';
import '../bloc/transfers_bloc.dart';
import '../bloc/transfers_event.dart';

class AcceptTransferBottomSheet extends StatefulWidget {
  final String transferId;
  final String studentId;
  final String studentName;

  const AcceptTransferBottomSheet({
    super.key,
    required this.transferId,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<AcceptTransferBottomSheet> createState() =>
      _AcceptTransferBottomSheetState();
}

class _AcceptTransferBottomSheetState extends State<AcceptTransferBottomSheet> {
  String? _selectedGroupId;

  void _submit() {
    if (_selectedGroupId == null) return;
    context.read<TransfersBloc>().add(
      AcceptTransferRequested(
        widget.transferId,
        widget.studentId,
        _selectedGroupId!,
        widget.studentName,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Зачислить: ${widget.studentName}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          BlocBuilder<GroupsBloc, GroupsState>(
            builder: (context, state) {
              if (state is GroupsLoaded) {
                if (state.groups.isEmpty)
                  return const Text('У вас нет созданных групп!');
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Выберите группу',
                    border: OutlineInputBorder(),
                  ),
                  items: state.groups
                      .map(
                        (g) => DropdownMenuItem(
                          value: g['id'].toString(),
                          child: Text(g['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGroupId = val),
                );
              }
              return const CircularProgressIndicator();
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _selectedGroupId == null ? null : _submit,
            child: const Text('Принять ученика'),
          ),
        ],
      ),
    );
  }
}
