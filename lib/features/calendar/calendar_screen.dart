import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/event.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final monthEvents = events.where((e) =>
        e.startTime.month == _currentMonth.month &&
        e.startTime.year == _currentMonth.year).toList();
    final dayEvents = events.where((e) =>
        DateFormat('yyyy-MM-dd').format(e.startTime) ==
        DateFormat('yyyy-MM-dd').format(_selectedDate)).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Calendar', style: AppTypography.displayMedium(context)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateEventDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Event'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar grid
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        // Month navigation
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setState(() =>
                                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
                              icon: const Icon(Icons.chevron_left_rounded),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  DateFormat('MMMM yyyy').format(_currentMonth),
                                  style: AppTypography.heading2(context),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() =>
                                  _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Weekday headers
                        Row(
                          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              .map((d) => Expanded(
                                    child: Center(
                                      child: Text(d, style: AppTypography.caption(context)),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        // Days grid
                        ..._buildCalendarGrid(monthEvents),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Selected day events
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, MMM d').format(_selectedDate),
                          style: AppTypography.heading2(context),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: dayEvents.isEmpty
                              ? Center(
                                  child: Text('No events', style: AppTypography.bodySmall(context)),
                                )
                              : ListView.builder(
                                  itemCount: dayEvents.length,
                                  itemBuilder: (context, i) =>
                                      _buildEventCard(dayEvents[i]),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarGrid(List<CalendarEvent> monthEvents) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;

    final rows = <Widget>[];
    int day = 1;

    for (int week = 0; week < 6 && day <= daysInMonth; week++) {
      final cells = <Widget>[];
      for (int dow = 1; dow <= 7; dow++) {
        if ((week == 0 && dow < startWeekday) || day > daysInMonth) {
          cells.add(Expanded(child: Container()));
        } else {
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final isToday = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(DateTime.now());
          final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);
          final hasEvents = monthEvents.any((e) =>
              DateFormat('yyyy-MM-dd').format(e.startTime) ==
              DateFormat('yyyy-MM-dd').format(date));

          cells.add(Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isToday
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? AppColors.primary
                                : AppColors.textSecondary,
                      ),
                    ),
                    if (hasEvents)
                      Container(
                        width: 4, height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ));
          day++;
        }
      }
      rows.add(Row(children: cells));
    }
    return rows;
  }

  void _showCreateEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String eventType = 'meeting';
    DateTime startDate = _selectedDate;
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('New Event', style: AppTypography.heading2(context)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: eventType,
                    decoration: const InputDecoration(labelText: 'Event Type'),
                    dropdownColor: AppColors.bgCard,
                    items: const [
                      DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
                      DropdownMenuItem(value: 'deadline', child: Text('Deadline')),
                      DropdownMenuItem(value: 'call', child: Text('Call')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setDialogState(() => eventType = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Start', style: AppTypography.bodySmall(context)),
                          subtitle: Text(
                            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                            style: AppTypography.heading2(context),
                          ),
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: startTime);
                            if (t != null) setDialogState(() => startTime = t);
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('End', style: AppTypography.bodySmall(context)),
                          subtitle: Text(
                            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                            style: AppTypography.heading2(context),
                          ),
                          onTap: () async {
                            final t = await showTimePicker(context: context, initialTime: endTime);
                            if (t != null) setDialogState(() => endTime = t);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                final start = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);
                final end = DateTime(startDate.year, startDate.month, startDate.day, endTime.hour, endTime.minute);
                final event = CalendarEvent(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  type: EventType.values.firstWhere((e) => e.name == eventType, orElse: () => EventType.meeting),
                  startTime: start,
                  endTime: end,
                );
                ref.read(eventsProvider.notifier).addEvent(event);
                Navigator.pop(ctx);
              },
              child: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final color = event.type == EventType.meeting
        ? AppColors.primary
        : event.type == EventType.deadline
            ? AppColors.danger
            : event.type == EventType.call
                ? AppColors.success
                : AppColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 32, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTypography.body(context).copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13,
                )),
                Text(
                  '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
