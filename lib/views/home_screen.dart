import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../viewmodels/ai_viewmodel.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'ai_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'workout_execution_screen.dart';
import 'create_routine_screen.dart';
import 'exercise_library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ExerciseLibraryScreen(),
    const AIScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildNavBar(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        backgroundColor: AppTheme.limeAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateRoutineScreen()),
        ),
        child: const Icon(LucideIcons.plus),
      )
          : null,
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(LucideIcons.home, "Home", 0),
            _navItem(LucideIcons.dumbbell, "Workout", 1),
            _navItem(LucideIcons.sparkles, "AI Architect", 2),
            _navItem(LucideIcons.user, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool active = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppTheme.limeAccent : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: active ? AppTheme.limeAccent : Colors.grey,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _insightsTriggered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_insightsTriggered) {
      final authVM = Provider.of<AuthViewModel>(context);
      final workoutVM = Provider.of<WorkoutViewModel>(context);
      final aiVM = Provider.of<AIViewModel>(context, listen: false);

      if (authVM.userProfile != null && !workoutVM.isLoading) {
        _insightsTriggered = true;
        // ✅ FIX: use Future.microtask to avoid setState during build
        Future.microtask(() => aiVM.fetchInsights(authVM.userProfile!, workoutVM.workoutLogs));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final workoutVM = Provider.of<WorkoutViewModel>(context);
    final aiVM = Provider.of<AIViewModel>(context);
    final profile = authVM.userProfile;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildTopBar(profile),
          const SizedBox(height: 24),
          _buildGoalSection(profile),
          const SizedBox(height: 24),
          // ✅ Insights section (no tips shown here)
          _buildInsightsSection(aiVM),
          const SizedBox(height: 24),
          _buildSectionHeader("TODAY'S PROTOCOL"),
          const SizedBox(height: 16),
          _buildTodayWorkout(workoutVM),
          const SizedBox(height: 32),
          _buildSectionHeader("ALL ARCHITECTED PROTOCOLS"),
          const SizedBox(height: 16),
          _buildAllRoutines(workoutVM),
          const SizedBox(height: 32),
          _buildDietSection(profile),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTopBar(UserProfile? profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SYSTEM ACTIVE',
                style: TextStyle(
                    color: AppTheme.limeAccent,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            Text(profile?.name ?? 'Athlete',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
        IconButton(
          icon: const Icon(LucideIcons.barChart2, color: AppTheme.limeAccent),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const ProgressScreen())),
        ),
      ],
    );
  }

  Widget _buildGoalSection(UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PRIMARY OBJECTIVE',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(profile?.goal.toUpperCase() ?? 'INITIALIZING...',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 16),
          const LinearProgressIndicator(
              value: 0.45,
              backgroundColor: Colors.white10,
              color: AppTheme.limeAccent,
              minHeight: 2),
        ],
      ),
    );
  }

  // ✅ Insights — no tips shown, only AI feedback
  Widget _buildInsightsSection(AIViewModel vm) {
    if (vm.isFetchingInsights) {
      return Container(
        height: 120,
        decoration:
        BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(32)),
        child: const Center(
            child: CircularProgressIndicator(color: AppTheme.limeAccent, strokeWidth: 2)),
      );
    }

    if (vm.insights == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("NEURAL FEEDBACK & ANALYSIS"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.limeAccent.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              _insightRow(LucideIcons.zap, 'SMART INSIGHT', vm.insights!['smartInsight']),
              const Divider(color: Colors.white10, height: 24),
              _insightRow(LucideIcons.activity, 'PLATEAU DETECTION', vm.insights!['plateauStatus']),
              const Divider(color: Colors.white10, height: 24),
              _insightRow(LucideIcons.target, 'ADAPTIVE TARGET', vm.insights!['personalizedSuggestion']),
              const Divider(color: Colors.white10, height: 24),
              _insightRow(LucideIcons.alertTriangle, 'INJURY PREVENTION',
                  vm.insights!['injuryAlert'],
                  isWarning: true),
              const Divider(color: Colors.white10, height: 24),
              _insightRow(LucideIcons.utensils, 'NUTRITION SYNC', vm.insights!['dietInsight']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _insightRow(IconData icon, String label, String? value,
      {bool isWarning = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: isWarning
                  ? Colors.orangeAccent.withOpacity(0.1)
                  : AppTheme.limeAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon,
              color: isWarning ? Colors.orangeAccent : AppTheme.limeAccent, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(value ?? 'Processing data...',
                  style: TextStyle(
                      color: isWarning ? Colors.orangeAccent : Colors.white,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayWorkout(WorkoutViewModel vm) {
    if (vm.routines.isEmpty) return _buildEmptyWorkout();
    final today = _getWeekday();
    final routine =
    vm.routines.firstWhere((r) => r.day == today, orElse: () => vm.routines.first);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => WorkoutExecutionScreen(routine: routine))),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration:
        BoxDecoration(color: AppTheme.limeAccent, borderRadius: BorderRadius.circular(32)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routine.name,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${routine.exercises.length} Movements • ${routine.day}',
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(LucideIcons.playCircle, color: Colors.black, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRoutines(WorkoutViewModel vm) {
    if (vm.routines.isEmpty) return const SizedBox();
    return Column(
      children: vm.routines
          .map((routine) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ListTile(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkoutExecutionScreen(routine: routine))),
          title: Text(routine.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('${routine.exercises.length} Exercises • ${routine.day}',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          trailing: const Icon(LucideIcons.play, color: AppTheme.limeAccent, size: 16),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildDietSection(UserProfile? profile) {
    if (profile == null || profile.diet.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("ACTIVE NUTRITION PLAN"),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration:
          BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: profile.diet
                .map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(LucideIcons.check, color: AppTheme.limeAccent, size: 16),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) => Text(title,
      style: const TextStyle(
          color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2));

  Widget _buildEmptyWorkout() => Container(
      padding: const EdgeInsets.all(32),
      decoration:
      BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
      child: const Center(
          child: Text('NO WORKOUT SCHEDULED TODAY',
              style: TextStyle(color: Colors.grey, fontSize: 10))));

  String _getWeekday() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[DateTime.now().weekday - 1];
  }
}