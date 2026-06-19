import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../providers/resume_provider.dart';
import 'wizard_steps/personal_info_step.dart';
import 'wizard_steps/summary_step.dart';
import 'wizard_steps/experience_step.dart';
import 'wizard_steps/education_step.dart';
import 'wizard_steps/skills_step.dart';
import 'wizard_steps/projects_step.dart';
import 'wizard_steps/certifications_step.dart';
import 'wizard_steps/review_step.dart';

class ResumeWizardPage extends StatefulWidget {
  final String? resumeId;

  const ResumeWizardPage({super.key, this.resumeId});

  @override
  State<ResumeWizardPage> createState() => _ResumeWizardPageState();
}

class _ResumeWizardPageState extends State<ResumeWizardPage> {
  final PageController _pageController = PageController();
  bool _isInitializing = true;

  final List<_WizardStep> _steps = [
    const _WizardStep(icon: Icons.person_outline, title: 'Personal Info', subtitle: 'Your basic information'),
    const _WizardStep(icon: Icons.article_outlined, title: 'Summary', subtitle: 'Professional summary'),
    const _WizardStep(icon: Icons.work_outline, title: 'Experience', subtitle: 'Work history'),
    const _WizardStep(icon: Icons.school_outlined, title: 'Education', subtitle: 'Academic background'),
    const _WizardStep(icon: Icons.star_outline, title: 'Skills', subtitle: 'Your expertise'),
    const _WizardStep(icon: Icons.folder_outlined, title: 'Projects', subtitle: 'Key projects'),
    const _WizardStep(icon: Icons.verified_outlined, title: 'Certifications', subtitle: 'Credentials'),
    const _WizardStep(icon: Icons.check_circle_outline, title: 'Review', subtitle: 'Final check'),
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final provider = context.read<ResumeProvider>();
    if (widget.resumeId != null) {
      await provider.loadResume(widget.resumeId!);
    } else {
      await provider.createNewResume();
    }
    setState(() => _isInitializing = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final provider = context.read<ResumeProvider>();
    final currentStep = provider.currentWizardStep;
    if (currentStep < _steps.length - 1) {
      provider.setWizardStep(currentStep + 1);
      _pageController.animateToPage(
        currentStep + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishWizard();
    }
  }

  void _prevStep() {
    final provider = context.read<ResumeProvider>();
    final currentStep = provider.currentWizardStep;
    if (currentStep > 0) {
      provider.setWizardStep(currentStep - 1);
      _pageController.animateToPage(
        currentStep - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _finishWizard() {
    final resumeId = context.read<ResumeProvider>().currentResume?.id;
    if (resumeId != null) {
      context.go(AppRoutes.resumePreview, extra: resumeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final currentStep = provider.currentWizardStep;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(currentStep),
                _buildProgressBar(currentStep),
                _buildStepIndicator(currentStep),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      PersonalInfoStep(onNext: _nextStep),
                      SummaryStep(onNext: _nextStep),
                      ExperienceStep(onNext: _nextStep),
                      EducationStep(onNext: _nextStep),
                      SkillsStep(onNext: _nextStep),
                      ProjectsStep(onNext: _nextStep),
                      CertificationsStep(onNext: _nextStep),
                      ReviewStep(onFinish: _finishWizard),
                    ],
                  ),
                ),
                _buildNavigationBar(currentStep),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int currentStep) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorderLight),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _steps[currentStep].title,
                  style: AppTypography.titleMedium,
                ),
                Text(
                  'Step ${currentStep + 1} of ${_steps.length}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          // Auto-save indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_done_outlined,
                    color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Saved',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (currentStep + 1) / _steps.length,
          backgroundColor: AppColors.backgroundTertiary,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          final step = _steps[index];

          return GestureDetector(
            onTap: () {
              if (index <= currentStep) {
                context.read<ResumeProvider>().setWizardStep(index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primaryGlow
                    : isCompleted
                        ? AppColors.successBackground
                        : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : isCompleted
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.surfaceBorderLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : step.icon,
                    size: 16,
                    color: isCurrent
                        ? AppColors.primary
                        : isCompleted
                            ? AppColors.success
                            : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    step.title,
                    style: AppTypography.labelSmall.copyWith(
                      color: isCurrent
                          ? AppColors.primary
                          : isCompleted
                              ? AppColors.success
                              : AppColors.textTertiary,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationBar(int currentStep) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorderLight),
        ),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: GradientButton(
              text: currentStep == _steps.length - 1
                  ? 'Preview Resume'
                  : 'Continue',
              onPressed: _nextStep,
              gradient: AppColors.primaryGradient,
              suffixIcon: Icon(
                currentStep == _steps.length - 1
                    ? Icons.preview
                    : Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardStep {
  final IconData icon;
  final String title;
  final String subtitle;

  const _WizardStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
