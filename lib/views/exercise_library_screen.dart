import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterMuscleGroup = 'All';
  final List<String> _muscleGroups = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

  @override
  Widget build(BuildContext context) {
    final workoutVM = Provider.of<WorkoutViewModel>(context);

    final filteredExercises = workoutVM.exercises.where((ex) {
      final matchesSearch = ex.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesFilter = _filterMuscleGroup == 'All' || ex.muscleGroup == _filterMuscleGroup;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('EXERCISE CLOUD', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final ex = filteredExercises[index];
                  return _buildExerciseCard(ex);
                },
              ),
            ),
          ],
        ),
      ),
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
            hintText: 'SCANNING LIBRARY...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1),
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

  Widget _buildExerciseCard(Exercise ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontStyle: FontStyle.italic)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                child: Text(ex.muscleGroup.toUpperCase(), style: const TextStyle(color: AppTheme.limeAccent, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ],
          ),
          if (ex.description != null) ...[
            const SizedBox(height: 12),
            Text(ex.description!, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
