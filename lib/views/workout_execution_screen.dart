import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../viewmodels/workout_viewmodel.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final Routine routine;
  const WorkoutExecutionScreen({super.key, required this.routine});

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  Widget build(BuildContext context) {
    final workoutVM = Provider.of<WorkoutViewModel>(context);
    final currentRoutineEx = widget.routine.exercises[_currentExerciseIndex];

    // Find exercise details in library
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EXERCISE ${_currentExerciseIndex + 1} OF ${widget.routine.exercises.length}',
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        exerciseDetails.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 48, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -2),
                      ),
                      const SizedBox(height: 8),
                      if (exerciseDetails.description != null)
                        Text(
                          exerciseDetails.description!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSetIndicator(currentRoutineEx.sets),
                        ],
                      ),
                      const SizedBox(height: 60),
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
      children: List.generate(totalSets, (index) {
        bool active = index + 1 <= _currentSet;
        return Container(
          width: 40,
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
          style: GoogleFonts.spaceMono(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton('REST', Colors.white10, Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: _buildActionButton(
                'NEXT SET',
                AppTheme.limeAccent,
                Colors.black,
                onPressed: () {
                  setState(() {
                    if (_currentSet < widget.routine.exercises[_currentExerciseIndex].sets) {
                      _currentSet++;
                    } else if (_currentExerciseIndex < widget.routine.exercises.length - 1) {
                      _currentExerciseIndex++;
                      _currentSet = 1;
                    } else {
                      // Workout Complete
                      Navigator.pop(context);
                    }
                  });
                }
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
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
        child: Center(
          child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 10)),
        ),
      ),
    );
  }
}
