import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/workout_viewmodel.dart';
import 'viewmodels/ai_viewmodel.dart';
import 'views/home_screen.dart';
import 'utils/seed_data.dart';
import 'firebase_options.dart';

// IMPORTANT: Replace this with your actual API Key from https://openrouter.ai/
const String GEMINI_API_KEY = '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';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SeedData.seedDatabase();
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
        ChangeNotifierProvider(create: (_) => AIViewModel()),
      ],
      child: MaterialApp(
        title: 'WorkoutPlanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    if (authVM.user == null) {
      return const LoginScreen();
    }

    final workoutVM = Provider.of<WorkoutViewModel>(context, listen: false);
    final aiVM = Provider.of<AIViewModel>(context, listen: false);

    SeedData.seedUserData(authVM.user!.uid).then((_) {
      workoutVM.init(authVM.user!.uid);
    });

    // Using the constant defined above
    aiVM.init(GEMINI_API_KEY);

    return const HomeScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  void _submit() {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    if (_isLogin) {
      authVM.signIn(_emailController.text, _passwordController.text);
    } else {
      authVM.signUp(_emailController.text, _passwordController.text);
    }
  }

  void _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first.')),
      );
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    try {
      await authVM.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent to your email.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 80, color: AppTheme.limeAccent),
              const SizedBox(height: 24),
              const Text('Workout Architect.',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ),
              if (authVM.error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(authVM.error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
              const SizedBox(height: 32),
              authVM.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.limeAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50)),
                child: Text(_isLogin ? 'LOGIN' : 'SIGN UP'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? "Don't have an account? Signup" : 'Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
