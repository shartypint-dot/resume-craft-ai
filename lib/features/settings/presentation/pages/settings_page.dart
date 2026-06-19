import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppTypography.titleLarge),
              const SizedBox(height: 20),

              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A1A35), Color(0xFF252540)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.surfaceBorderLight)),
                child: Row(children: [
                  Container(width: 64, height: 64, decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle), child: Center(child: Text(user?.firstName.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'U', style: AppTypography.headlineMedium.copyWith(color: Colors.white)))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?.fullName ?? 'User', style: AppTypography.titleMedium),
                    Text(user?.email ?? '', style: AppTypography.bodySmall),
                    const SizedBox(height: 6),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(gradient: user?.isPro == true ? AppColors.premiumGradient : null, color: user?.isPro != true ? AppColors.backgroundTertiary : null, borderRadius: BorderRadius.circular(8)), child: Text(user?.isPro == true ? 'PRO' : 'Free', style: AppTypography.tagStyle.copyWith(color: user?.isPro == true ? Colors.white : AppColors.textTertiary))),
                  ])),
                  IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20), onPressed: () {}),
                ]),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),

              if (user?.isPro != true) ...[
                GestureDetector(
                  onTap: () => context.push(AppRoutes.subscription),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.accentGold.withValues(alpha: 0.15), AppColors.error.withValues(alpha: 0.15)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3))),
                    child: Row(children: [
                      const Icon(Icons.workspace_premium, color: AppColors.accentGold, size: 24),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Upgrade to Pro', style: AppTypography.titleSmall.copyWith(color: AppColors.accentGold)), Text('Unlock all features', style: AppTypography.bodySmall)])),
                      const Icon(Icons.arrow_forward_ios, color: AppColors.accentGold, size: 14),
                    ]),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 20),
              ],

              _buildSection('Account', [
                _SettingItem(Icons.person_outline, 'Edit Profile', () {}),
                _SettingItem(Icons.lock_outline, 'Change Password', () {}),
                _SettingItem(Icons.notifications_outlined, 'Notifications', () {}),
                _SettingItem(Icons.security_outlined, 'Privacy & Security', () {}),
              ]),
              const SizedBox(height: 16),

              _buildSection('App', [
                _SettingItem(Icons.palette_outlined, 'Appearance', () {}),
                _SettingItem(Icons.language_outlined, 'Language', () {}),
                _SettingItem(Icons.storage_outlined, 'Storage & Cache', () {}),
              ]),
              const SizedBox(height: 16),

              _buildSection('Support', [
                _SettingItem(Icons.help_outline, 'Help Center', () {}),
                _SettingItem(Icons.bug_report_outlined, 'Report a Bug', () {}),
                _SettingItem(Icons.star_outline, 'Rate the App', () {}),
                _SettingItem(Icons.info_outline, 'About', () {}),
              ]),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () => _showSignOutDialog(context),
                icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 52),
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 8),
              Center(child: Text('ResumeCraft AI v1.0.0', style: AppTypography.caption)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_SettingItem> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: AppTypography.labelMedium)),
      Container(
        decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
        child: Column(children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Icon(item.icon, color: AppColors.textSecondary, size: 20),
              title: Text(item.label, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
              onTap: item.onTap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            if (!isLast) const Divider(height: 1, indent: 56, color: AppColors.surfaceBorderLight),
          ]);
        }).toList()),
      ),
    ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingItem(this.icon, this.label, this.onTap);
}
