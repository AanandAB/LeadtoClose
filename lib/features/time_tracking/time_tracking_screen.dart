import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/time_entry.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class TimeTrackingScreen extends ConsumerStatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  ConsumerState<TimeTrackingScreen> createState() =>
      _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends ConsumerState<TimeTrackingScreen> {
  bool _isRunning = false;
  DateTime _selectedDate = DateTime.now();
  String _description = '';
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _stopwatch.elapsed;
      });
    });
    setState(() => _isRunning = true);
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopwatch.reset();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsed = Duration.zero;
    });
  }

  void _saveEntry() {
    if (_elapsed.inSeconds < 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timer must run for at least 1 minute')),
      );
      return;
    }

    final hours = _elapsed.inMinutes / 60.0;
    final entry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectId: 'default',
      description: _description.isNotEmpty
          ? _description
          : 'Timer session',
      hours: double.parse(hours.toStringAsFixed(2)),
      isBillable: true,
      date: _selectedDate,
    );
    ref.read(timeEntriesProvider.notifier).addTimeEntry(entry);
    _resetTimer();
    _description = '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${hours.toStringAsFixed(1)}h entry'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(timeEntriesProvider);
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekEntries = entries
        .where((e) =>
            e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            e.date.isBefore(weekEnd.add(const Duration(days: 1))))
        .toList();
    final todayEntries = entries
        .where((e) =>
            DateFormat('yyyy-MM-dd').format(e.date) ==
            DateFormat('yyyy-MM-dd').format(today))
        .toList();
    final totalWeekHours =
        weekEntries.fold(0.0, (sum, e) => sum + e.hours);
    final billableWeekHours = weekEntries
        .where((e) => e.isBillable)
        .fold(0.0, (sum, e) => sum + e.hours);
    final todayHours =
        todayEntries.fold(0.0, (s, e) => s + e.hours);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Time Tracking',
                  style: AppTypography.displayMedium(context)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showManualEntryDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Manual Entry'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timer card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isRunning
                    ? [
                        AppColors.success.withOpacity(0.15),
                        AppColors.success.withOpacity(0.05),
                      ]
                    : [AppColors.bgCard, AppColors.bgCard],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isRunning
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                // Start/Stop button
                GestureDetector(
                  onTap: () {
                    if (_isRunning) {
                      _stopTimer();
                    } else {
                      _startTimer();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRunning
                          ? AppColors.danger.withOpacity(0.15)
                          : AppColors.success.withOpacity(0.12),
                      border: Border.all(
                        color: _isRunning
                            ? AppColors.danger
                            : AppColors.success,
                        width: 3,
                      ),
                      boxShadow: _isRunning
                          ? [
                              BoxShadow(
                                color: AppColors.danger.withOpacity(0.2),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _isRunning
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 40,
                      color: _isRunning
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 28),

                // Timer display & input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time display
                      Text(
                        _formatDuration(_elapsed),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: _isRunning
                              ? AppColors.success
                              : AppColors.textPrimary,
                          letterSpacing: -2,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description input
                      SizedBox(
                        width: 340,
                        child: TextField(
                          onChanged: (v) => _description = v,
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'What are you working on?',
                            hintStyle: AppTypography.body(context),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppColors.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    if (_isRunning || _elapsed.inSeconds > 0) ...[
                      SizedBox(
                        width: 140,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _isRunning ? _saveEntry : null,
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Save Entry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 140,
                        height: 36,
                        child: OutlinedButton.icon(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              StatCard(
                label: 'Today',
                value: '${todayHours.toStringAsFixed(1)}h',
                color: AppColors.info,
                icon: Icons.today_rounded,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'This Week',
                value: '${totalWeekHours.toStringAsFixed(1)}h',
                color: AppColors.primary,
                icon: Icons.date_range_rounded,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Billable',
                value: '${billableWeekHours.toStringAsFixed(1)}h',
                color: AppColors.success,
                icon: Icons.attach_money_rounded,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Entries',
                value: '${entries.length}',
                color: AppColors.warning,
                icon: Icons.list_alt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today's entries
          Text('Today\'s Entries',
              style: AppTypography.heading2(context)),
          const SizedBox(height: 12),
          Expanded(
            child: todayEntries.isEmpty
                ? Center(
                    child: Text(
                      'No time entries today. Start the timer or add a manual entry.',
                      style: AppTypography.bodySmall(context),
                    ),
                  )
                : ListView.builder(
                    itemCount: todayEntries.length,
                    itemBuilder: (context, i) =>
                        _buildEntryCard(todayEntries[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(TimeEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: entry.isBillable
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.textMuted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              entry.isBillable
                  ? Icons.attach_money_rounded
                  : Icons.money_off_rounded,
              size: 16,
              color: entry.isBillable
                  ? AppColors.success
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description.isNotEmpty
                      ? entry.description
                      : 'Time entry',
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(entry.createdAt),
                  style: AppTypography.caption(context),
                ),
              ],
            ),
          ),
          Text(
            '${entry.hours.toStringAsFixed(1)}h',
            style: AppTypography.heading3(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () async {
              final confirm = await showConfirmDialog(
                context,
                title: 'Delete Entry',
                message: 'Delete this time entry?',
              );
              if (confirm) {
                ref
                    .read(timeEntriesProvider.notifier)
                    .deleteTimeEntry(entry.id);
              }
            },
            icon: Icon(Icons.delete_outline,
                size: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    final descCtrl = TextEditingController();
    final hoursCtrl = TextEditingController(text: '1.0');
    bool isBillable = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Add Time Entry',
              style: AppTypography.heading2(context)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon:
                        Icon(Icons.description_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: hoursCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    prefixIcon: Icon(Icons.schedule, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      isBillable
                          ? Icons.attach_money_rounded
                          : Icons.money_off_rounded,
                      size: 20,
                      color: isBillable
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Text('Billable',
                        style: AppTypography.body(context)),
                    const Spacer(),
                    Switch(
                      value: isBillable,
                      onChanged: (v) =>
                          setDialogState(() => isBillable = v),
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final entry = TimeEntry(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  projectId: 'default',
                  description: descCtrl.text.trim(),
                  hours: double.tryParse(hoursCtrl.text) ?? 1.0,
                  isBillable: isBillable,
                  date: _selectedDate,
                );
                ref
                    .read(timeEntriesProvider.notifier)
                    .addTimeEntry(entry);
                Navigator.pop(ctx);
              },
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
