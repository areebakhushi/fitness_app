import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedDay = 'Monday';
  String _filterMuscleGroup = 'All';
  List<RoutineExercise> _selectedExercises = [];

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _muscleGroups = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

  @override
  Widget build(BuildContext context) {
    final workoutVM = Provider.of<WorkoutViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    // Search and Filter Logic
    final filteredExercises = workoutVM.exercises.where((ex) {
      final matchesSearch = ex.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesFilter = _filterMuscleGroup == 'All' || ex.muscleGroup == _filterMuscleGroup;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('ARCHITECT ROUTINE', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 14, letterSpacing: 2)),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && _selectedExercises.isNotEmpty) {
                await workoutVM.createRoutine(
                  authVM.user!.uid,
                  _nameController.text,
                  _selectedDay,
                  _selectedExercises,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE', style: TextStyle(color: AppTheme.limeAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 32),
            const Text('EXERCISE CLOUD', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 24),
            _buildExerciseLibrary(filteredExercises),
            const SizedBox(height: 32),
            if (_selectedExercises.isNotEmpty) ...[
              const Text('SELECTED PROTOCOL', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              _buildSelectedList(workoutVM.exercises),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'ROUTINE NAME (E.G. PUSH A)',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            fillColor: AppTheme.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDay,
              isExpanded: true,
              dropdownColor: AppTheme.surface,
              items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
              onChanged: (val) => setState(() => _selectedDay = val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.search, size: 18, color: Colors.grey),
            hintText: 'SEARCH MOVEMENTS...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            fillColor: AppTheme.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _muscleGroups.map((group) {
              bool selected = _filterMuscleGroup == group;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(group.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: selected ? Colors.black : Colors.white)),
                  selected: selected,
                  selectedColor: AppTheme.limeAccent,
                  backgroundColor: AppTheme.surface,
                  onSelected: (val) => setState(() => _filterMuscleGroup = group),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseLibrary(List<Exercise> exercises) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final ex = exercises[index];
          final isSelected = _selectedExercises.any((e) => e.exerciseId == ex.id);

          return ListTile(
            onTap: () {
              setState(() {
                if (!isSelected) {
                  _selectedExercises.add(RoutineExercise(exerciseId: ex.id, sets: 3, reps: 12));
                } else {
                  _selectedExercises.removeWhere((e) => e.exerciseId == ex.id);
                }
              });
            },
            title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(ex.muscleGroup.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            trailing: Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.plusCircle,
              color: isSelected ? AppTheme.limeAccent : Colors.white10,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedList(List<Exercise> allExercises) {
    return Column(
      children: _selectedExercises.map((se) {
        final ex = allExercises.firstWhere((e) => e.id == se.exerciseId);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  Text(ex.muscleGroup.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
              Row(
                children: [
                  _buildIncrementer(se.sets, (v) => setState(() {
                    final idx = _selectedExercises.indexOf(se);
                    _selectedExercises[idx] = RoutineExercise(exerciseId: se.exerciseId, sets: v, reps: se.reps);
                  }), 'SETS'),
                  const SizedBox(width: 16),
                  _buildIncrementer(se.reps, (v) => setState(() {
                    final idx = _selectedExercises.indexOf(se);
                    _selectedExercises[idx] = RoutineExercise(exerciseId: se.exerciseId, sets: se.sets, reps: v);
                  }), 'REPS'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncrementer(int val, Function(int) onChanged, String label) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(onTap: () => onChanged(val > 1 ? val - 1 : 1), child: const Icon(LucideIcons.minus, size: 14, color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(val.toString(), style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold, color: AppTheme.limeAccent)),
            ),
            GestureDetector(onTap: () => onChanged(val + 1), child: const Icon(LucideIcons.plus, size: 14, color: Colors.grey)),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }
}
