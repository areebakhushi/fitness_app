import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/ai_viewmodel.dart';
import '../viewmodels/workout_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final List<String> _preferredDays = [];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context) {
    final aiVM = Provider.of<AIViewModel>(context);
    final workoutVM = Provider.of<WorkoutViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('AI ARCHITECT', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (aiVM.generatedPlans == null) ...[
              _buildIntro(),
              const SizedBox(height: 32),
              _buildInputs(aiVM),
              if (aiVM.errorMessage != null) ...[
                const SizedBox(height: 24),
                Container(
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
                      Expanded(
                        child: Text(
                          aiVM.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GENERATED PROTOCOLS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  TextButton(onPressed: aiVM.reset, child: const Text('RESET SYSTEM', style: TextStyle(color: AppTheme.limeAccent, fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(aiVM.generatedPlans!.length, (index) => _buildPlanCard(
                aiVM.generatedPlans![index],
                index,
                aiVM,
                authVM.user!.uid,
                workoutVM,
              )),
            ],
          ],
        ),
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
          'Input your biological parameters. The architect will synchronize a dedicated training protocol.',
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
          decoration: _inputDeco('e.g. Muscle hypertrophy with focus on upper body...'),
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
                preferredDays: _preferredDays,
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

  Widget _buildPlanCard(dynamic plan, int idx, AIViewModel vm, String userId, WorkoutViewModel workoutVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
          const SizedBox(height: 24),
          ...List.generate(plan['exercises'].length, (i) {
            final ex = plan['exercises'][i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
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
                            Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
                            Text(ex['muscleGroup'].toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${ex['sets']} x ${ex['reps']}', style: GoogleFonts.spaceMono(color: AppTheme.limeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  if (ex['description'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(ex['description'], style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4)),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          _CommitButton(
            plan: plan,
            userId: userId,
            workoutVM: workoutVM,
            aiVM: vm,
          ),
        ],
      ),
    );
  }
}

class _CommitButton extends StatefulWidget {
  final dynamic plan;
  final String userId;
  final WorkoutViewModel workoutVM;
  final AIViewModel aiVM;

  const _CommitButton({required this.plan, required this.userId, required this.workoutVM, required this.aiVM});

  @override
  State<_CommitButton> createState() => _CommitButtonState();
}

class _CommitButtonState extends State<_CommitButton> {
  bool _isCommitting = false;
  bool _isCommitted = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: (_isCommitting || _isCommitted) ? null : () async {
          setState(() => _isCommitting = true);
          try {
            await widget.aiVM.commitRoutine(
              plan: widget.plan,
              userId: widget.userId,
              library: widget.workoutVM.exercises,
              addRoutine: widget.workoutVM.createRoutine,
              addCustomExercise: (name, mg, desc) => widget.workoutVM.addCustomExercise(widget.userId, name, mg, desc),
            );
            setState(() => _isCommitted = true);
          } catch (e) {
            debugPrint('Commit Error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving routine: $e')),
            );
          } finally {
            setState(() => _isCommitting = false);
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: _isCommitted ? AppTheme.limeAccent : Colors.white.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isCommitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
          _isCommitted ? 'INTEGRATED' : 'COMMIT TO CORE',
          style: TextStyle(
              color: _isCommitted ? Colors.black : Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 2
          ),
        ),
      ),
    );
  }
}
