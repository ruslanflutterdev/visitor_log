import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';

class TransferStudentBottomSheet extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String groupId;

  const TransferStudentBottomSheet({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.groupId,
  });

  @override
  State<TransferStudentBottomSheet> createState() =>
      _TransferStudentBottomSheetState();
}

class _TransferStudentBottomSheetState
    extends State<TransferStudentBottomSheet> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _coaches = [];
  String? _selectedCoachId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    try {
      final currentUserId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('profiles')
          .select('id, first_name, last_name, role')
          .neq('id', currentUserId)
          .inFilter('role', ['coach', 'senior_coach']);

      setState(() {
        _coaches = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _submit() {
    if (_selectedCoachId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите тренера')));
      return;
    }

    context.read<StudentsBloc>().add(
      InitiateTransferRequested(
        widget.studentId,
        _selectedCoachId!,
        widget.studentName,
        widget.groupId,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Перевод ученика',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ученик: ${widget.studentName}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_coaches.isEmpty)
            const Text('В системе нет других доступных тренеров.')
          else
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Выберите тренера для перевода',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _coaches.map((coach) {
                final name = '${coach['last_name']} ${coach['first_name']}';
                return DropdownMenuItem(
                  value: coach['id'].toString(),
                  child: Text(name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCoachId = val),
            ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading || _coaches.isEmpty ? null : _submit,
            child: const Text('Отправить заявку'),
          ),
        ],
      ),
    );
  }
}
