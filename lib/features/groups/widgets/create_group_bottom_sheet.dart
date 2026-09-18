import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import '../models/day_schedule.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  String? _selectedGroupName;
  final Map<String, DaySchedule> _schedule = {};

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(String day, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
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
        TimeOfDay? defaultStart;
        TimeOfDay? defaultEnd;
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

    final isIncomplete = _schedule.values.any(
      (s) => s.startTime == null || s.endTime == null,
    );
    if (isIncomplete) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Укажите время')));
      return;
    }

    final isTooShort = _schedule.values.any((s) {
      final startMin = s.startTime!.hour * 60 + s.startTime!.minute;
      final endMin = s.endTime!.hour * 60 + s.endTime!.minute;
      return (endMin - startMin) < 60;
    });

    if (isTooShort) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Минимальное время тренировки — 1 час. Проверьте правильность времени.',
          ),
        ),
      );
      return;
    }

    final groupsState = context.read<GroupsBloc>().state;
    if (groupsState is GroupsLoaded) {
      for (var existingGroup in groupsState.groups) {
        final existingSchedules =
            existingGroup['group_schedules'] as List<dynamic>? ?? [];
        for (var exSchedule in existingSchedules) {
          final exDay = exSchedule['day_of_week'].toString();

          if (_schedule.containsKey(exDay)) {
            final exStartStr = exSchedule['start_time'].toString();
            final exEndStr = exSchedule['end_time'].toString();

            final exStartMin =
                int.parse(exStartStr.substring(0, 2)) * 60 +
                int.parse(exStartStr.substring(3, 5));
            final exEndMin =
                int.parse(exEndStr.substring(0, 2)) * 60 +
                int.parse(exEndStr.substring(3, 5));

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
              return; // Блокируем создание
            }
          }
        }
      }
    }

    context.read<GroupsBloc>().add(
      CreateGroupRequested(name: _selectedGroupName!, schedule: _schedule),
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
            'Создание группы',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
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
          const Text(
            'Дни занятий:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            children: AppConstants.weekDays.map((day) {
              return FilterChip(
                label: Text(day),
                selected: _schedule.containsKey(day),
                onSelected: (selected) => _toggleDay(day, selected),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_schedule.isNotEmpty) ...[
            const Text(
              'Время занятий:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._schedule.entries.map((entry) {
              final day = entry.key;
              final schedule = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectTime(day, true),
                        child: Text(_formatTime(schedule.startTime)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectTime(day, false),
                        child: Text(_formatTime(schedule.endTime)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _submit, child: const Text('Создать')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
