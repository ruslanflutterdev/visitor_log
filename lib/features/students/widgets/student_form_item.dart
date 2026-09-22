import 'package:flutter/material.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/student_form_model.dart';

class StudentFormItem extends StatefulWidget {
  final int index;
  final StudentFormModel model;
  final VoidCallback onRemove;

  const StudentFormItem({
    super.key,
    required this.index,
    required this.model,
    required this.onRemove,
  });

  @override
  State<StudentFormItem> createState() => _StudentFormItemState();
}

class _StudentFormItemState extends State<StudentFormItem> {
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        widget.model.birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ученик #${widget.index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.index > 0)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: widget.model.lastName,
                    labelText: 'Фамилия *',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: widget.model.firstName,
                    labelText: 'Имя *',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: widget.model.middleName,
              labelText: 'Отчество (если есть)',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: TextEditingController(
                      text: widget.model.birthDate != null
                          ? "${widget.model.birthDate!.day.toString().padLeft(2, '0')}.${widget.model.birthDate!.month.toString().padLeft(2, '0')}.${widget.model.birthDate!.year}"
                          : '',
                    ),
                    labelText: 'Дата рождения *',
                    readOnly: true,
                    prefixIcon: Icons.calendar_today,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: widget.model.phone,
                    labelText: 'Телефон *',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
