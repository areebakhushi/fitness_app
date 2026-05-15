import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final Routine routine;
  const WorkoutExecutionScreen({super.key, required this.routine});

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  final Stopwatch _stopwatch = Stopwatch();
  
  final List<LoggedExercise> _loggedExercises = [];
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    for (var re in widget.routine.exercises) {
      _loggedExercises.add(LoggedExercise(
        exerciseId: re.exerciseId,
        name: '', 
        sets: [],
      ));
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _completeSet() {
    final re = widget.routine.exercises[_currentExerciseIndex];
    final reps = int.tryParse(_repsController.text) ?? re.reps;
    final weight = double.tryParse(_weightController.text) ?? 0.0;

    setState(() {
      _loggedExercises[_currentExerciseIndex].sets.add(
        LoggedSet(reps: reps, weight: weight),
      );

      if (_currentSetIndex < re.sets - 1) {
        _currentSetIndex++;
      } else if (_currentExerciseIndex < widget.routine.exercises.length - 1) {
        _currentExerciseIndex++;
        _currentSetIndex = 0;
      } else {
        _finishWorkout();
      }
      
      _repsController.clear();
    });
  }

  Future<void> _finishWorkout() async {
    _stopwatch.stop();
    final workoutVM = Provider.of<WorkoutViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    double totalVolume = 0;
    for (var i = 0; i < _loggedExercises.length; i++) {
      final id = _loggedExercises[i].exerciseId;
      final details = workoutVM.exercises.firstWhere((e) => e.id == id);
      _loggedExercises[i] = LoggedExercise(
        exerciseId: id,
        name: details.name,
        sets: _loggedExercises[i].sets,
      );
      for (var s in _loggedExercises[i].sets) {
        totalVolume += (s.reps * s.weight);
      }
    }

    await workoutVM.logWorkout(
      userId: authVM.user!.uid,
      routineId: widget.routine.id,
      routineName: widget.routine.name,
      duration: _stopwatch.elapsed.inMinutes,
      exercises: _loggedExercises,
    );

    if (mounted) {
      _showCompletionDialog(totalVolume, _stopwatch.elapsed.inMinutes);
    }
  }

  void _showCompletionDialog(double volume, int minutes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.checkCircle, color: AppTheme.limeAccent, size: 64),
            const SizedBox(height: 24),
            Text('PROTOCOL COMPLETED', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 18)),
            const SizedBox(height: 16),
            _summaryRow('Volume', '${volume.toInt()} KG'),
            _summaryRow('Duration', '$minutes MIN'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit session
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.limeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(val, style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold, color: AppTheme.limeAccent)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final workoutVM = Provider.of<WorkoutViewModel>(context);
    final currentRoutineEx = widget.routine.exercises[_currentExerciseIndex];

    final exerciseDetails = workoutVM.exercises.firstWhere(
      (e) => e.id == currentRoutineEx.exerciseId,
      orElse: () => Exercise(id: '?', name: 'Unknown', muscleGroup: 'Unknown'),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        'EXERCISE ${_currentExerciseIndex + 1} OF ${widget.routine.exercises.length}',
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        exerciseDetails.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TARGET: ${currentRoutineEx.sets} SETS X ${currentRoutineEx.reps} REPS',
                        style: const TextStyle(color: AppTheme.limeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      _buildSetIndicator(currentRoutineEx.sets),
                      const SizedBox(height: 40),
                      _buildPerformanceInput(),
                      const SizedBox(height: 40),
                      _buildTimer(),
                    ],
                  ),
                ),
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceInput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: widget.routine.exercises[_currentExerciseIndex].reps.toString(),
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WEIGHT (KG)', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          Text(widget.routine.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10)),
          const Icon(Icons.more_horiz),
        ],
      ),
    );
  }

  Widget _buildSetIndicator(int totalSets) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSets, (index) {
        bool active = index <= _currentSetIndex;
        return Container(
          width: 30,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppTheme.limeAccent : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildTimer() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final duration = _stopwatch.elapsed;
        String twoDigits(int n) => n.toString().padLeft(2, '0');
        final minutes = twoDigits(duration.inMinutes.remainder(60));
        final seconds = twoDigits(duration.inSeconds.remainder(60));
        return Text(
          '$minutes:$seconds',
          style: GoogleFonts.spaceMono(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildControls() {
    bool isLast = _currentExerciseIndex == widget.routine.exercises.length - 1 && 
                 _currentSetIndex == widget.routine.exercises[_currentExerciseIndex].sets - 1;

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton('REST', Colors.white10, Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: _buildActionButton(
              isLast ? 'FINISH' : 'COMPLETE SET',
              AppTheme.limeAccent,
              Colors.black,
              onPressed: _completeSet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color bg, Color text, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
        child: Center(
          child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
        ),
      ),
    );
  }
}
