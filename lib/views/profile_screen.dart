import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, centerTitle: true, title: const Text('BIOLOGICAL PROFILE', style: TextStyle(letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(authVM.user?.photoURL ?? ''),
                    backgroundColor: AppTheme.surface,
                  ),
                  const SizedBox(height: 24),
                  Text(authVM.user?.displayName ?? 'Athlete', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                  Text(authVM.user?.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildSettingsSection('METRICS', [
              _buildSettingItem('Target Weight', '84.5 KG', LucideIcons.scale),
              _buildSettingItem('Goal', 'Mass Gain', LucideIcons.target),
            ]),
            const SizedBox(height: 32),
            _buildSettingsSection('SYSTEM', [
              _buildSettingItem('Units', 'Metric', LucideIcons.settings),
              _buildSettingItem('Notifications', 'On', LucideIcons.bell),
            ]),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: authVM.signOut,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('TERMINATE SESSION', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: AppTheme.limeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
