import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import '../models/day_schedule.dart';

class EditGroupBottomSheet extends StatefulWidget {
  final Map<String, dynamic> group; // Принимаем текущую группу

  const EditGroupBottomSheet({super.key, required this.group});

  @override
  State<EditGroupBottomSheet> createState() => _EditGroupBottomSheetState();
}

class _EditGroupBottomSheetState extends State<EditGroupBottomSheet> {
  String? _selectedGroupName;
  final Map<String, DaySchedule> _schedule = {};

  @override
  void initState() {
    super.initState();
    _selectedGroupName = widget.group['name'];
    final schedules = widget.group['group_schedules'] as List<dynamic>? ?? [];

    for (var s in schedules) {
      final day = s['day_of_week'].toString();
      final startStr = s['start_time'].toString();
      final endStr = s['end_time'].toString();

      _schedule[day] = DaySchedule(
        startTime: TimeOfDay(
          hour: int.parse(startStr.substring(0, 2)),
          minute: int.parse(startStr.substring(3, 5)),
        ),
        endTime: TimeOfDay(
          hour: int.parse(endStr.substring(0, 2)),
          minute: int.parse(endStr.substring(3, 5)),
        ),
      );
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(String day, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_schedule[day]?.startTime ?? TimeOfDay.now())
          : (_schedule[day]?.endTime ?? TimeOfDay.now()),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _schedule[day]!.startTime = picked;
        } else {
          _schedule[day]!.endTime = picked;
        }
      });
    }
  }

  void _toggleDay(String day, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_schedule.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Максимум 3 дня для одной группы')),
          );
          return;
        }
        TimeOfDay? defaultStart, defaultEnd;
        if (_schedule.isNotEmpty) {
          defaultStart = _schedule.values.last.startTime;
          defaultEnd = _schedule.values.last.endTime;
        }
        _schedule[day] = DaySchedule(
          startTime: defaultStart,
          endTime: defaultEnd,
        );
      } else {
        _schedule.remove(day);
      }
    });
  }

  void _submit() {
    if (_selectedGroupName == null || _schedule.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все данные')));
      return;
    }

    if (_schedule.values.any((s) => s.startTime == null || s.endTime == null)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Укажите время')));
      return;
    }

    if (_schedule.values.any(
      (s) =>
          (s.endTime!.hour * 60 + s.endTime!.minute) -
              (s.startTime!.hour * 60 + s.startTime!.minute) <
          60,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Минимальное время тренировки — 1 час.')),
      );
      return;
    }

    final groupsState = context.read<GroupsBloc>().state;
    if (groupsState is GroupsLoaded) {
      for (var existingGroup in groupsState.groups) {
        if (existingGroup['id'] == widget.group['id']) continue;

        final existingSchedules =
            existingGroup['group_schedules'] as List<dynamic>? ?? [];
        for (var exSchedule in existingSchedules) {
          final exDay = exSchedule['day_of_week'].toString();
          if (_schedule.containsKey(exDay)) {
            final exStartMin =
                int.parse(exSchedule['start_time'].toString().substring(0, 2)) *
                    60 +
                int.parse(exSchedule['start_time'].toString().substring(3, 5));
            final exEndMin =
                int.parse(exSchedule['end_time'].toString().substring(0, 2)) *
                    60 +
                int.parse(exSchedule['end_time'].toString().substring(3, 5));

            final newStartMin =
                _schedule[exDay]!.startTime!.hour * 60 +
                _schedule[exDay]!.startTime!.minute;
            final newEndMin =
                _schedule[exDay]!.endTime!.hour * 60 +
                _schedule[exDay]!.endTime!.minute;

            if (newStartMin < exEndMin && exStartMin < newEndMin) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Наложение! Вы уже ведете "${existingGroup['name']}" в $exDay в это время.',
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
          }
        }
      }
    }

    context.read<GroupsBloc>().add(
      UpdateGroupRequested(
        groupId: widget.group['id'],
        name: _selectedGroupName!,
        schedule: _schedule,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Редактирование группы',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _selectedGroupName,
            decoration: InputDecoration(
              labelText: 'Название группы',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: AppConstants.groupNames
                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                .toList(),
            onChanged: (val) => setState(() => _selectedGroupName = val),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: AppConstants.weekDays
                .map(
                  (day) => FilterChip(
                    label: Text(day),
                    selected: _schedule.containsKey(day),
                    onSelected: (s) => _toggleDay(day, s),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (_schedule.isNotEmpty) ...[
            ..._schedule.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectTime(entry.key, true),
                        child: Text(_formatTime(entry.value.startTime)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectTime(entry.key, false),
                        child: Text(_formatTime(entry.value.endTime)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Сохранить изменения'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
