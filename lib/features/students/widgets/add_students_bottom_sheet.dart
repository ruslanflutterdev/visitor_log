import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../models/student_form_model.dart';
import 'student_form_item.dart';

class AddStudentsBottomSheet extends StatefulWidget {
  final String groupId;

  const AddStudentsBottomSheet({super.key, required this.groupId});

  @override
  State<AddStudentsBottomSheet> createState() => _AddStudentsBottomSheetState();
}

class _AddStudentsBottomSheetState extends State<AddStudentsBottomSheet> {
  final List<StudentFormModel> _forms = [StudentFormModel()];

  void _addAnotherForm() {
    setState(() {
      _forms.add(StudentFormModel());
    });
  }

  void _removeForm(int index) {
    setState(() {
      _forms[index].dispose();
      _forms.removeAt(index);
    });
  }

  void _submit() {
    final hasErrors = _forms.any(
      (f) =>
          f.firstName.text.trim().isEmpty ||
          f.lastName.text.trim().isEmpty ||
          f.phone.text.trim().isEmpty ||
          f.birthDate == null,
    );

    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните обязательные поля (*) для всех учеников'),
        ),
      );
      return;
    }

    context.read<StudentsBloc>().add(
      AddStudentsRequested(widget.groupId, _forms),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (var form in _forms) {
      form.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Добавление учеников',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _forms.length,
                    itemBuilder: (context, index) {
                      return StudentFormItem(
                        index: index,
                        model: _forms[index],
                        onRemove: () => _removeForm(index),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: _addAnotherForm,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Добавить еще одного ученика'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Сохранить в группу'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
