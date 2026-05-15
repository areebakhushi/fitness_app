import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/ai_viewmodel.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

class AIScreen extends StatefulWidget {
  final VoidCallback? onCommitSuccess;
  const AIScreen({super.key, this.onCommitSuccess});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _timeframeController = TextEditingController(text: '90 days');
  String _gender = 'Male';
  final List<String> _preferredDays = [];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.userProfile != null) {
        _goalController.text = authVM.userProfile!.goal;
        _weightController.text = authVM.userProfile!.weight.toString();
        _heightController.text = authVM.userProfile!.height.toString();
        _gender = authVM.userProfile!.gender;
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiVM = Provider.of<AIViewModel>(context);
    final workoutVM = Provider.of<WorkoutViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    bool hasResults = aiVM.generatedPlans != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: hasResults 
            ? IconButton(
                icon: const Icon(LucideIcons.chevronLeft), 
                onPressed: aiVM.reset
              ) 
            : null,
        title: Text('AI ARCHITECT', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (aiVM.errorMessage != null) ...[
              _errorCard(aiVM.errorMessage!),
              const SizedBox(height: 24),
            ],
            if (!hasResults) ...[
              _buildIntro(),
              const SizedBox(height: 32),
              _buildInputs(aiVM),
            ] else ...[
              _buildGeneratedHeader(aiVM),
              const SizedBox(height: 24),
              _buildDietAndTips(aiVM),
              const SizedBox(height: 32),
              const Text('ARCHITECTED WORKOUTS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 16),
              ...List.generate(aiVM.generatedPlans!.length, (index) => _buildPlanCard(
                aiVM.generatedPlans![index],
              )),
              const SizedBox(height: 40),
              _CommitButton(
                onCommit: () async {
                  await aiVM.commitFullArchitecture(
                    userId: authVM.user!.uid,
                    profile: authVM.userProfile!,
                    newGoal: _goalController.text,
                    library: workoutVM.exercises,
                    addRoutine: workoutVM.createRoutine,
                    addCustomExercise: (name, mg, desc) => workoutVM.addCustomExercise(authVM.user!.uid, name, mg, desc),
                    saveProfile: authVM.completeOnboarding,
                    onSuccess: () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Architecture committed to core system.'))
                        );
                        if (widget.onCommitSuccess != null) {
                          widget.onCommitSuccess!();
                        }
                      }
                    }
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedHeader(AIViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('PROTOCOL GENERATED', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        TextButton(onPressed: vm.reset, child: const Text('NEW ANALYSIS', style: TextStyle(color: AppTheme.limeAccent, fontSize: 10, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildDietAndTips(AIViewModel vm) {
    return Column(
      children: [
        if (vm.generatedDiet != null && vm.generatedDiet!.isNotEmpty)
          _infoCard(LucideIcons.utensils, 'NUTRITION PROTOCOL', vm.generatedDiet!),
        const SizedBox(height: 16),
        if (vm.generatedTips != null && vm.generatedTips!.isNotEmpty)
          _infoCard(LucideIcons.zap, 'TACTICAL STRATEGY', vm.generatedTips!),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, List<dynamic> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.limeAccent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.limeAccent, size: 18),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.limeAccent, fontWeight: FontWeight.bold)),
                Expanded(child: Text(item.toString(), style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.red, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.limeAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppTheme.limeAccent.withOpacity(0.2)),
          ),
          child: const Icon(LucideIcons.sparkles, color: AppTheme.limeAccent, size: 40),
        ),
        const SizedBox(height: 24),
        Text('Elite Bio-Sync.', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -1)),
        const Text(
          'Synchronize your data to generate a dedicated training protocol.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInputs(AIViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('PRIMARY OBJECTIVE'),
        TextField(
          controller: _goalController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDeco('e.g. Hypertrophy...'),
        ),
        const SizedBox(height: 20),
        _label('TARGET TIMEFRAME (DAYS)'),
        TextField(
          controller: _timeframeController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: _inputDeco('e.g. 90 days or 3 months'),
        ),
        const SizedBox(height: 20),
        _label('GENDER'),
        DropdownButtonFormField<String>(
          value: _gender,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: _inputDeco(''),
          items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) => setState(() => _gender = val!),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('WEIGHT (KG)'),
                  TextField(
                    controller: _weightController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('85'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('HEIGHT (CM)'),
                  TextField(
                    controller: _heightController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _inputDeco('180'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _label('PREFERRED SESSIONS'),
        Wrap(
          spacing: 8,
          children: _days.map((day) {
            bool selected = _preferredDays.contains(day);
            return FilterChip(
              label: Text(day.substring(0, 3).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: selected ? Colors.black : Colors.white)),
              selected: selected,
              selectedColor: AppTheme.limeAccent,
              onSelected: (val) {
                setState(() {
                  if (val) _preferredDays.add(day);
                  else _preferredDays.remove(day);
                });
              },
              showCheckmark: false,
              backgroundColor: AppTheme.surface,
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : () {
              FocusScope.of(context).unfocus();
              vm.generatePlan(
                goal: _goalController.text,
                weight: double.tryParse(_weightController.text) ?? 70,
                height: double.tryParse(_heightController.text) ?? 170,
                gender: _gender,
                preferredDays: _preferredDays,
                timeframe: _timeframeController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.limeAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              disabledBackgroundColor: AppTheme.limeAccent.withOpacity(0.3),
            ),
            child: vm.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                  )
                : const Text('INITIATE ARCHITECTURE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2)),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
    fillColor: AppTheme.surface,
    filled: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.all(20),
  );

  Widget _buildPlanCard(dynamic plan) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.limeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(plan['day'].toUpperCase(), style: const TextStyle(color: AppTheme.limeAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              Expanded(
                child: Text(
                  plan['routineName'], 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(plan['exercises'].length, (i) {
            final ex = plan['exercises'][i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), overflow: TextOverflow.ellipsis),
                        Text(ex['muscleGroup'].toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 9, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  Text('${ex['sets']}x${ex['reps']}', style: GoogleFonts.spaceMono(color: AppTheme.limeAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CommitButton extends StatefulWidget {
  final Future<void> Function() onCommit;
  const _CommitButton({required this.onCommit});

  @override
  State<_CommitButton> createState() => _CommitButtonState();
}

class _CommitButtonState extends State<_CommitButton> {
  bool _isCommitting = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _isCommitting ? null : () async {
          setState(() => _isCommitting = true);
          try {
            await widget.onCommit();
          } finally {
            if (mounted) setState(() => _isCommitting = false);
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: AppTheme.limeAccent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: _isCommitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
            : const Text('COMMIT ARCHITECTURE TO CORE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
      ),
    );
  }
}
