import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'exercise_library_screen.dart';
import 'ai_screen.dart';
import 'create_routine_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'workout_execution_screen.dart';

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
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildNavBar(),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRoutineScreen())),
        backgroundColor: AppTheme.limeAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(LucideIcons.plus, color: Colors.black),
      ) : null,
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(LucideIcons.home, 0),
          _navItem(LucideIcons.dumbbell, 1),
          _navItem(LucideIcons.sparkles, 2),
          _navItem(LucideIcons.user, 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool active = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Icon(icon, color: active ? AppTheme.limeAccent : Colors.grey),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final workoutVM = Provider.of<WorkoutViewModel>(context);

    String displayName = 'Athlete';
    if (authVM.user?.displayName != null && authVM.user!.displayName!.isNotEmpty) {
      displayName = authVM.user!.displayName!.split(' ')[0];
    } else if (authVM.user?.email != null) {
      displayName = authVM.user!.email!.split('@')[0];
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $displayName.',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'PRIME CONDITION REQUIRED FOR SESSION.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgressScreen())),
                  child: CircleAvatar(
                    backgroundColor: AppTheme.surface,
                    backgroundImage: (authVM.user?.photoURL != null && authVM.user!.photoURL!.isNotEmpty)
                        ? NetworkImage(authVM.user!.photoURL!)
                        : null,
                    radius: 24,
                    child: (authVM.user?.photoURL == null || authVM.user!.photoURL!.isEmpty)
                        ? const Icon(LucideIcons.user, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                _buildStatCard('Workouts', workoutVM.routines.length.toString(), LucideIcons.activity),
                const SizedBox(width: 16),
                _buildStatCard('Goal', 'Mass', LucideIcons.target),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'ACTIVITY LOGS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: workoutVM.routines.length,
                itemBuilder: (context, index) {
                  final routine = workoutVM.routines[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutExecutionScreen(routine: routine))),
                    child: _buildRoutineCard(routine),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.limeAccent, size: 24),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.spaceMono(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 8, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Routine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis),
                Text('${routine.exercises.length} MOVEMENTS', style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          const Icon(LucideIcons.play, color: AppTheme.limeAccent),
        ],
      ),
    );
  }
}
