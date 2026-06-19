import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  String? _selectedIndustry;
  String? _selectedExperienceLevel;
  String? _selectedCareerGoal;
  final _professionController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.completeOnboarding(
      profession: _professionController.text.trim(),
      industry: _selectedIndustry ?? '',
      careerGoal: _selectedCareerGoal ?? '',
      experienceLevel: _selectedExperienceLevel ?? '',
    );
    if (mounted) context.go(AppRoutes.home);
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return true;
      case 1:
        return _professionController.text.trim().isNotEmpty;
      case 2:
        return _selectedExperienceLevel != null;
      case 3:
        return _selectedIndustry != null;
      case 4:
        return _selectedCareerGoal != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _buildWelcomePage(),
                      _buildProfessionPage(),
                      _buildExperiencePage(),
                      _buildIndustryPage(),
                      _buildCareerGoalPage(),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned(
      top: -100,
      right: -80,
      child: Container(
        width: 350,
        height: 350,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmoothPageIndicator(
            controller: _pageController,
            count: 5,
            effect: const ExpandingDotsEffect(
              dotWidth: 8,
              dotHeight: 8,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.backgroundTertiary,
              expansionFactor: 4,
            ),
          ),
          TextButton(
            onPressed: _completeOnboarding,
            child: Text(
              'Skip',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: GradientButton(
        text: _currentPage == 4 ? 'Get Started' : 'Continue',
        onPressed: _canProceed ? _nextPage : null,
        gradient: AppColors.primaryGradient,
        suffixIcon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildWelcomePage() {
    final features = [
      ('AI-Powered Resumes', 'Generate ATS-optimized resumes with one click', Icons.auto_awesome_outlined),
      ('ATS Score Analysis', 'Get real-time feedback to beat automated screening', Icons.analytics_outlined),
      ('Cover Letter Generator', 'Create personalized cover letters instantly', Icons.mail_outline),
      ('Interview Preparation', 'Practice with AI-powered mock interviews', Icons.record_voice_over_outlined),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            '👋 Welcome to\nResumeCraft AI',
            style: AppTypography.headlineLarge.copyWith(height: 1.2),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            'Let\'s personalize your experience so we can help you land your dream job faster.',
            style: AppTypography.bodyLarge,
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 36),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return _buildFeatureItem(
              feature.$3,
              feature.$1,
              feature.$2,
              delay: 300 + index * 100,
            );
          }),
          const SizedBox(height: 24),
          _buildPremiumTeaser(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, {int delay = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGlow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                Text(description, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideX(begin: 0.2);
  }

  Widget _buildPremiumTeaser() {
    return GlassCard(
      enableGlow: true,
      glowColor: AppColors.accentGold,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.premiumGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Try Pro Free for 7 Days', style: AppTypography.titleSmall),
                Text(
                  'Unlimited resumes, all templates, ATS scanner & more',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2);
  }

  Widget _buildProfessionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('What\'s your\ncurrent role?', style: AppTypography.headlineLarge)
              .animate()
              .fadeIn()
              .slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            'Tell us your current job title or what you\'re studying.',
            style: AppTypography.bodyLarge,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 36),
          TextFormField(
            controller: _professionController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Job title / Current role',
              hintText: 'e.g. Software Engineer, Marketing Manager',
              prefixIcon: Icon(Icons.work_outline),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          const SizedBox(height: 24),
          Text('Popular roles:', style: AppTypography.titleSmall)
              .animate()
              .fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Software Engineer',
              'Product Manager',
              'Data Scientist',
              'UX Designer',
              'Marketing Manager',
              'Business Analyst',
              'Fresh Graduate',
              'Student',
            ].asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _professionController.text = entry.value;
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _professionController.text == entry.value
                        ? AppColors.primaryGlow
                        : AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _professionController.text == entry.value
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.surfaceBorderLight,
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: AppTypography.labelMedium.copyWith(
                      color: _professionController.text == entry.value
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (400 + entry.key * 50).ms)
                  .scale(begin: const Offset(0.9, 0.9));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Your experience\nlevel', style: AppTypography.headlineLarge)
              .animate()
              .fadeIn()
              .slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            'This helps us tailor AI suggestions for your career stage.',
            style: AppTypography.bodyLarge,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          ...AppConstants.experienceLevels.asMap().entries.map((entry) {
            final level = entry.value;
            final isSelected = _selectedExperienceLevel == level;
            return GestureDetector(
              onTap: () => setState(() => _selectedExperienceLevel = level),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGlow
                      : AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceBorderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceBorder,
                          width: 2,
                        ),
                        color: isSelected ? AppColors.primary : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      level,
                      style: AppTypography.bodyLarge.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (300 + entry.key * 80).ms)
                .slideX(begin: 0.2);
          }),
        ],
      ),
    );
  }

  Widget _buildIndustryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Your industry', style: AppTypography.headlineLarge)
              .animate()
              .fadeIn()
              .slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            'We\'ll recommend industry-specific keywords and templates.',
            style: AppTypography.bodyLarge,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.industries.asMap().entries.map((entry) {
              final industry = entry.value;
              final isSelected = _selectedIndustry == industry;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndustry = industry),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGlow
                        : AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceBorderLight,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    industry,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (200 + entry.key * 30).ms)
                  .scale(begin: const Offset(0.9, 0.9));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Your career\ngoal', style: AppTypography.headlineLarge)
              .animate()
              .fadeIn()
              .slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            'What are you trying to achieve? This helps us give personalized advice.',
            style: AppTypography.bodyLarge,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          ...AppConstants.careerGoals.asMap().entries.map((entry) {
            final goal = entry.value;
            final isSelected = _selectedCareerGoal == goal;
            return GestureDetector(
              onTap: () => setState(() => _selectedCareerGoal = goal),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGlow
                      : AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceBorderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: (300 + entry.key * 60).ms)
                .slideX(begin: 0.2);
          }),
        ],
      ),
    );
  }
}
