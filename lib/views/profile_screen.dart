import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showChangePasswordDialog(BuildContext context, AuthViewModel authVM) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('CHANGE PASSWORD', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New Password',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.limeAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters.')));
                return;
              }
              try {
                await authVM.updatePassword(passwordController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully.')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.limeAccent),
            child: const Text('UPDATE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final profile = authVM.userProfile;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        centerTitle: true, 
        title: const Text('BIOLOGICAL PROFILE', style: TextStyle(letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold))
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.limeAccent, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: (authVM.user?.photoURL != null && authVM.user!.photoURL!.isNotEmpty)
                          ? NetworkImage(authVM.user!.photoURL!)
                          : null,
                      backgroundColor: AppTheme.surface,
                      child: (authVM.user?.photoURL == null || authVM.user!.photoURL!.isEmpty)
                          ? const Icon(LucideIcons.user, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    profile?.name ?? authVM.user?.displayName ?? 'Athlete', 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)
                  ),
                  Text(authVM.user?.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildSettingsSection('BIO-METRICS', [
              _buildSettingItem('Gender', profile?.gender ?? 'Not Set', LucideIcons.user),
              _buildSettingItem('Weight', '${profile?.weight ?? "--"} KG', LucideIcons.scale),
              _buildSettingItem('Height', '${profile?.height ?? "--"} CM', LucideIcons.ruler),
              _buildSettingItem('Primary Goal', profile?.goal ?? 'Not Set', LucideIcons.target),
            ]),
            const SizedBox(height: 32),
            _buildSettingsSection('SECURITY', [
              ListTile(
                onTap: () => _showChangePasswordDialog(context, authVM),
                leading: const Icon(LucideIcons.lock, color: Colors.grey, size: 20),
                title: const Text('Change Password', style: TextStyle(fontSize: 14)),
                trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ]),
            const SizedBox(height: 32),
            _buildSettingsSection('SYSTEM', [
              _buildSettingItem('Units', 'Metric', LucideIcons.settings),
              _buildSettingItem('Notifications', 'Active', LucideIcons.bell),
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
            border: Border.all(color: Colors.white.withOpacity(0.05)),
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
