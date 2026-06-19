import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/auth_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _googleLoading = false;
  bool _appleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 60),
                  _buildFeatureHighlights(),
                  const SizedBox(height: 40),
                  _buildAuthOptions(),
                  const SizedBox(height: 24),
                  _buildTermsText(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.primaryGlowShadow,
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 38,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          Text(
            'Build Your\nDream Resume',
            style: AppTypography.displaySmall.copyWith(height: 1.1),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            'AI-powered resume builder that helps you land\nyour dream job with ATS-optimized resumes.',
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      (Icons.auto_awesome, 'AI-Powered', AppColors.primary),
      (Icons.check_circle_outline, 'ATS-Optimized', AppColors.success),
      (Icons.style, '20 Templates', AppColors.accentGold),
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final feature = features[index];
          return GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(feature.$1, color: feature.$3, size: 20),
                const SizedBox(width: 8),
                Text(
                  feature.$2,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (300 + index * 100).ms, duration: 400.ms)
              .slideX(begin: 0.2);
        },
      ),
    );
  }

  Widget _buildAuthOptions() {
    final authProvider = context.watch<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Google Sign In
          SocialAuthButton(
            text: 'Continue with Google',
            icon: _googleIcon(),
            isLoading: _googleLoading,
            onPressed: () async {
              setState(() => _googleLoading = true);
              await authProvider.signInWithGoogle();
              if (mounted) setState(() => _googleLoading = false);
              if (authProvider.errorMessage != null) {
                _showError(authProvider.errorMessage!);
                authProvider.clearError();
              }
            },
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(begin: 0.3),
          const SizedBox(height: 12),

          // Apple Sign In
          SocialAuthButton(
            text: 'Continue with Apple',
            icon: const Icon(Icons.apple, color: Colors.white, size: 22),
            isLoading: _appleLoading,
            onPressed: () async {
              setState(() => _appleLoading = true);
              await authProvider.signInWithApple();
              if (mounted) setState(() => _appleLoading = false);
              if (authProvider.errorMessage != null) {
                _showError(authProvider.errorMessage!);
                authProvider.clearError();
              }
            },
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 400.ms)
              .slideY(begin: 0.3),
          const SizedBox(height: 12),

          // LinkedIn Sign In
          SocialAuthButton(
            text: 'Continue with LinkedIn',
            icon: _linkedinIcon(),
            onPressed: () => context.push(AppRoutes.login),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 400.ms)
              .slideY(begin: 0.3),
          const SizedBox(height: 20),

          // Divider
          Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.surfaceBorderLight),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or', style: AppTypography.bodySmall),
              ),
              const Expanded(
                child: Divider(color: AppColors.surfaceBorderLight),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Email Sign In
          GradientButton(
            text: 'Continue with Email',
            onPressed: () => context.push(AppRoutes.login),
            gradient: AppColors.primaryGradient,
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white, size: 20),
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 400.ms)
              .slideY(begin: 0.3),
          const SizedBox(height: 16),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: AppTypography.bodyMedium),
              TextButton(
                onPressed: () => context.push(AppRoutes.register),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Sign up free',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'By continuing, you agree to our Terms of Service and Privacy Policy',
        style: AppTypography.caption,
        textAlign: TextAlign.center,
      ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
    );
  }

  Widget _googleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'G',
          style: AppTypography.labelMedium.copyWith(
            color: const Color(0xFF4285F4),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _linkedinIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
