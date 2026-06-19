import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../resume_builder/presentation/providers/resume_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeProvider>().loadResumes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final resumeProvider = context.watch<ResumeProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(user?.firstName ?? 'there'),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resume Strength Card
                _buildStrengthCard(resumeProvider).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                // Quick Actions
                _buildQuickActions(),
                // Recent Resumes
                _buildRecentResumes(resumeProvider),
                // Career Insights
                _buildCareerInsights(user?.industry),
                // Premium Upsell (if free)
                if (!(user?.isPro ?? false)) _buildPremiumUpsell(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String firstName) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      snap: true,
      elevation: 0,
      expandedHeight: 80,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTypography.bodyMedium,
                    ),
                    Text(
                      firstName.isNotEmpty ? firstName : 'Welcome back',
                      style: AppTypography.titleLarge,
                    ),
                  ],
                ),
              ),
              // Notification bell
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorderLight),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Profile avatar
              GestureDetector(
                onTap: () => context.go(AppRoutes.settings),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      context.read<AuthProvider>().currentUser?.firstName.isNotEmpty == true
                          ? context.read<AuthProvider>().currentUser!.firstName[0].toUpperCase()
                          : 'U',
                      style: AppTypography.titleSmall.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthCard(ResumeProvider resumeProvider) {
    final latestResume = resumeProvider.resumes.isNotEmpty
        ? resumeProvider.resumes.first
        : null;
    final atsScore = latestResume?.atsScore ?? 0;
    final completion = latestResume?.completionPercentage ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A35), Color(0xFF252540)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceBorderLight),
          boxShadow: AppColors.cardShadow,
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resume Strength',
                            style: AppTypography.overline,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            latestResume?.title ?? 'No resume yet',
                            style: AppTypography.titleMedium,
                          ),
                        ],
                      ),
                      ScoreRing(
                        score: atsScore,
                        size: 70,
                        strokeWidth: 6,
                        label: 'ATS',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress indicators
                  Row(
                    children: [
                      Expanded(
                        child: _buildScoreItem(
                          'Completion',
                          completion,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildScoreItem(
                          'ATS Score',
                          atsScore,
                          AppColors.atsScoreColor(atsScore),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (latestResume != null) ...[
                    GestureDetector(
                      onTap: () => context.push(
                        AppRoutes.atsScanner,
                        extra: latestResume.id,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGlow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_fix_high,
                                color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Improve ATS Score',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    GradientButton(
                      text: 'Create Your First Resume',
                      onPressed: () => context.push(AppRoutes.resumeWizard),
                      height: 44,
                      gradient: AppColors.primaryGradient,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.labelSmall),
            Text('$score%',
                style:
                    AppTypography.labelSmall.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: AppColors.backgroundTertiary,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.add_circle_outline,
        label: 'Create\nResume',
        gradient: AppColors.primaryGradient,
        onTap: () => context.push(AppRoutes.resumeWizard),
      ),
      _QuickAction(
        icon: Icons.upload_file_outlined,
        label: 'Upload\nResume',
        gradient: const LinearGradient(
            colors: [Color(0xFF00BFA5), Color(0xFF00D4FF)]),
        onTap: () => context.push(AppRoutes.resumeUpload),
      ),
      _QuickAction(
        icon: Icons.analytics_outlined,
        label: 'ATS\nScan',
        gradient: const LinearGradient(
            colors: [Color(0xFFFFB347), Color(0xFFFF6B6B)]),
        onTap: () => context.push(AppRoutes.atsScanner),
      ),
      _QuickAction(
        icon: Icons.mail_outline,
        label: 'Cover\nLetter',
        gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF6C63FF)]),
        onTap: () => context.push(AppRoutes.coverLetter),
      ),
      _QuickAction(
        icon: Icons.work_outline,
        label: 'Job\nMatch',
        gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF00BCD4)]),
        onTap: () => context.push(AppRoutes.jobMatcher),
      ),
      _QuickAction(
        icon: Icons.record_voice_over_outlined,
        label: 'Interview\nPrep',
        gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)]),
        onTap: () => context.push(AppRoutes.interviewPrep),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Quick Actions',
          subtitle: 'What would you like to do?',
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: action.onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: action.gradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: (action.gradient.colors.first)
                                .withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(action.icon,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (index * 80).ms, duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentResumes(ResumeProvider resumeProvider) {
    return Column(
      children: [
        SectionHeader(
          title: 'My Resumes',
          action: TextButton(
            onPressed: () => context.go(AppRoutes.resumeBuilder),
            child: Text(
              'View all',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        if (resumeProvider.isLoading)
          ...List.generate(2, (_) => const SkeletonCard())
        else if (resumeProvider.resumes.isEmpty)
          EmptyState(
            title: 'No resumes yet',
            description: 'Create your first AI-powered resume in minutes.',
            buttonText: 'Create Resume',
            onButtonPressed: () => context.push(AppRoutes.resumeWizard),
          )
        else
          ...resumeProvider.resumes.take(3).map((resume) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.resumePreview, extra: resume.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.surfaceBorderLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(resume.title,
                                style: AppTypography.titleSmall),
                            const SizedBox(height: 4),
                            Text(
                              '${resume.completionPercentage}% complete • ${resume.templateId.replaceAll('_', ' ')}',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: resume.completionPercentage / 100,
                              backgroundColor: AppColors.backgroundTertiary,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.atsScoreColor(resume.atsScore),
                              ),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.atsScoreColor(resume.atsScore)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${resume.atsScore}',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.atsScoreColor(resume.atsScore),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('ATS', style: AppTypography.labelSmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
          }),
      ],
    );
  }

  Widget _buildCareerInsights(String? industry) {
    final trendingSkills = _getTrendingSkills(industry);
    return Column(
      children: [
        SectionHeader(
          title: 'Career Insights',
          subtitle: industry != null ? 'For $industry' : null,
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: trendingSkills.length,
            itemBuilder: (context, index) {
              final skill = trendingSkills[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.surfaceBorderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: skill.$3.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(skill.$2, color: skill.$3, size: 20),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skill.$1, style: AppTypography.titleSmall),
                        Text(skill.$4, style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                  .slideX(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumUpsell() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.subscription),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFB347).withValues(alpha: 0.15),
                const Color(0xFFFF6B6B).withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Pro Features',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.accentGold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unlimited resumes, all templates, ATS scanner',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.accentGold,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  List<(String, IconData, Color, String)> _getTrendingSkills(String? industry) {
    if (industry == 'Technology') {
      return [
        ('AI/ML', Icons.psychology_outlined, AppColors.primary, 'Trending +45%'),
        ('Cloud', Icons.cloud_outlined, AppColors.secondary, 'High demand'),
        ('React', Icons.code, AppColors.accentGold, 'Top skill'),
        ('DevOps', Icons.settings_outlined, AppColors.accentGreen, 'Growing fast'),
      ];
    }
    return [
      ('Leadership', Icons.star_outline, AppColors.primary, 'Top skill'),
      ('Analytics', Icons.analytics_outlined, AppColors.secondary, 'Growing'),
      ('Strategy', Icons.lightbulb_outline, AppColors.accentGold, 'High demand'),
      ('Communication', Icons.forum_outlined, AppColors.accentGreen, 'Essential'),
    ];
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });
}
