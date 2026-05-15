import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/models.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _showWeightEditDialog(BuildContext context, AuthViewModel authVM) {
    final controller = TextEditingController(text: authVM.userProfile?.weight.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('UPDATE WEIGHT', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Weight (kg)',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.limeAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              final newWeight = double.tryParse(controller.text);
              if (newWeight != null) {
                authVM.updateWeight(newWeight);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.limeAccent),
            child: const Text('UPDATE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutVM = Provider.of<WorkoutViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final profile = authVM.userProfile;

    // Logic for today's tasks
    final today = DateFormat('EEEE').format(DateTime.now());
    final todayRoutines = workoutVM.routines.where((r) => r.day == today).toList();
    final todayLogs = workoutVM.workoutLogs.where((log) {
      final now = DateTime.now();
      return log.completedAt.year == now.year &&
             log.completedAt.month == now.month &&
             log.completedAt.day == now.day;
    }).toList();

    final completedRoutineIds = todayLogs.map((l) => l.routineId).toSet();
    final remainingRoutines = todayRoutines.where((r) => !completedRoutineIds.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('PERFORMANCE ANALYTICS',
            style: TextStyle(letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
      body: workoutVM.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.limeAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeightCard(context, authVM),
                  const SizedBox(height: 32),
                  _buildSectionHeader('TODAY\'S TASK STATUS'),
                  const SizedBox(height: 16),
                  _buildTaskTable(todayLogs, remainingRoutines),
                  const SizedBox(height: 32),
                  _buildSectionHeader('VOLUME PERFORMANCE TREND'),
                  const SizedBox(height: 16),
                  _buildVolumeChart(workoutVM.workoutLogs),
                  const SizedBox(height: 32),
                  _buildHistoryList(workoutVM.workoutLogs),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2));
  }

  Widget _buildTaskTable(List<WorkoutLog> completed, List<Routine> remaining) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            children: [
              _buildTableCell('TASK / ROUTINE', isHeader: true),
              _buildTableCell('STATUS', isHeader: true),
            ],
          ),
          ...completed.map((log) => TableRow(
            children: [
              _buildTableCell(log.routineName),
              _buildTableCell('COMPLETED', color: AppTheme.limeAccent),
            ],
          )),
          ...remaining.map((routine) => TableRow(
            children: [
              _buildTableCell(routine.name),
              _buildTableCell('REMAINING', color: Colors.orangeAccent),
            ],
          )),
          if (completed.isEmpty && remaining.isEmpty)
            TableRow(
              children: [
                _buildTableCell('No routines scheduled for today'),
                _buildTableCell('-'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: isHeader ? 9 : 11,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.grey : Colors.white),
          letterSpacing: isHeader ? 1 : 0,
        ),
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, AuthViewModel authVM) {
    final profile = authVM.userProfile;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT WEIGHT',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(profile?.weight.toString() ?? '0',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic)),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4),
                        child: Text('KG',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showWeightEditDialog(context, authVM),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: AppTheme.limeAccent, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.white10,
              color: AppTheme.limeAccent,
              minHeight: 2),
        ],
      ),
    );
  }

  Widget _buildVolumeChart(List<WorkoutLog> logs) {
    if (logs.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(32)),
        child: const Center(child: Text('LOG SESSIONS TO SEE PERFORMANCE DATA', style: TextStyle(color: Colors.grey, fontSize: 10))),
      );
    }

    final List<FlSpot> spots = [];
    final sortedLogs = logs.reversed.toList();
    for (int i = 0; i < sortedLogs.length; i++) {
      double volume = 0;
      for (var ex in sortedLogs[i].exercises) {
        for (var set in ex.sets) {
          volume += (set.reps * set.weight);
        }
      }
      spots.add(FlSpot(i.toDouble(), volume));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 24, bottom: 12, right: 24, left: 12),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(32)),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.limeAccent,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true, color: AppTheme.limeAccent.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<WorkoutLog> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('RECENT SESSIONS'),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          const Text('No workout history found.', style: TextStyle(color: Colors.grey, fontSize: 12))
        else
          ...logs.take(10).map((log) => _buildHistoryItem(log)),
      ],
    );
  }

  Widget _buildHistoryItem(WorkoutLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.routineName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd').format(log.completedAt).toUpperCase()} • ${log.durationMinutes} MIN',
                  style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
