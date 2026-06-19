import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../../../core/widgets/gradient_button.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../providers/resume_provider.dart';

class ReviewStep extends StatelessWidget {
  final VoidCallback onFinish;

  const ReviewStep({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final resume = context.watch<ResumeProvider>().currentResume;
    if (resume == null) return const SizedBox.shrink();

    final checks = [
      _ReviewCheck('Personal Information', resume.personalInfo.firstName.isNotEmpty && resume.personalInfo.email.isNotEmpty, 'Add your name and email address'),
      _ReviewCheck('Professional Summary', resume.professionalSummary.isNotEmpty, 'Add a compelling professional summary'),
      _ReviewCheck('Work Experience', resume.workExperiences.isNotEmpty, 'Add at least one work experience'),
      _ReviewCheck('Education', resume.educations.isNotEmpty, 'Add your educational background'),
      _ReviewCheck('Skills', resume.skills.allSkills.isNotEmpty, 'Add technical and soft skills'),
      _ReviewCheck('Projects', resume.projects.isNotEmpty, 'Projects are optional but improve your score'),
      _ReviewCheck('Certifications', resume.certifications.isNotEmpty, 'Certifications are optional'),
    ];

    final completedCount = checks.where((c) => c.isComplete).length;
    final completion = (completedCount / checks.length * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Final Review', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 6),
          Text('Let\'s make sure your resume is complete and optimized.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          // Completion overview card
          GlassCard(
            enableGlow: true,
            glowColor: AppColors.atsScoreColor(completion),
            child: Row(children: [
              ScoreRing(score: completion, size: 80, strokeWidth: 7, label: 'Complete'),
              const SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Resume Completion', style: AppTypography.titleSmall),
                const SizedBox(height: 4),
                Text('$completedCount of ${checks.length} sections complete', style: AppTypography.bodySmall),
                const SizedBox(height: 8),
                if (completion < 100)
                  Text('Complete all sections for maximum ATS score', style: AppTypography.bodySmall.copyWith(color: AppColors.accentGold)),
                if (completion == 100)
                  Text('Your resume is 100% complete! 🎉', style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
              ])),
            ]),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),

          Text('Section Checklist', style: AppTypography.titleSmall).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),

          ...checks.asMap().entries.map((e) => _buildCheckItem(e.value, e.key)),
          const SizedBox(height: 24),

          // Resume info summary
          Text('Resume Details', style: AppTypography.titleSmall).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
            child: Column(children: [
              _summaryRow(Icons.person, 'Name', resume.personalInfo.fullName),
              _summaryRow(Icons.email, 'Email', resume.personalInfo.email),
              _summaryRow(Icons.work, 'Experience', '${resume.workExperiences.length} positions'),
              _summaryRow(Icons.school, 'Education', '${resume.educations.length} entries'),
              _summaryRow(Icons.star, 'Skills', '${resume.skills.allSkills.length} skills'),
              _summaryRow(Icons.style, 'Template', resume.templateId.replaceAll('_', ' ').toUpperCase()),
            ]),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 28),

          GradientButton(
            text: 'Preview My Resume',
            onPressed: onFinish,
            gradient: AppColors.primaryGradient,
            prefixIcon: const Icon(Icons.preview, color: Colors.white, size: 20),
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
          const SizedBox(height: 12),
          Center(
            child: Text('You can always come back and edit your resume', style: AppTypography.bodySmall),
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCheckItem(_ReviewCheck check, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: check.isComplete ? AppColors.successBackground : AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: check.isComplete ? AppColors.success.withValues(alpha: 0.3) : AppColors.surfaceBorderLight),
      ),
      child: Row(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: check.isComplete ? AppColors.success : AppColors.backgroundTertiary, border: Border.all(color: check.isComplete ? AppColors.success : AppColors.surfaceBorder, width: 1.5)),
          child: check.isComplete ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(check.section, style: AppTypography.bodyLarge.copyWith(color: check.isComplete ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: check.isComplete ? FontWeight.w600 : FontWeight.w400)),
          if (!check.isComplete) Text(check.hint, style: AppTypography.caption),
        ])),
        if (!check.isComplete) const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
      ]),
    ).animate().fadeIn(delay: (300 + index * 50).ms).slideX(begin: 0.1);
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Text('$label:', style: AppTypography.labelSmall),
        const Spacer(),
        Text(value.isEmpty ? '—' : value, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
      ]),
    );
  }
}

class _ReviewCheck {
  final String section;
  final bool isComplete;
  final String hint;
  const _ReviewCheck(this.section, this.isComplete, this.hint);
}
