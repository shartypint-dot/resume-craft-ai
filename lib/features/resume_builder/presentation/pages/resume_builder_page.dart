import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../providers/resume_provider.dart';

class ResumeBuilderPage extends StatefulWidget {
  const ResumeBuilderPage({super.key});

  @override
  State<ResumeBuilderPage> createState() => _ResumeBuilderPageState();
}

class _ResumeBuilderPageState extends State<ResumeBuilderPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeProvider>().loadResumes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ResumeProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('My Resumes', style: AppTypography.titleLarge),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.resumeWizard),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text('New', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoading
                  ? Column(children: List.generate(3, (_) => const SkeletonCard()))
                  : provider.resumes.isEmpty
                      ? EmptyState(
                          title: 'No resumes yet',
                          description: 'Create your first AI-powered ATS resume.',
                          buttonText: 'Create Resume',
                          onButtonPressed: () => context.push(AppRoutes.resumeWizard),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.resumes.length,
                          itemBuilder: (context, index) {
                            final resume = provider.resumes[index];
                            return Dismissible(
                              key: Key(resume.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(color: AppColors.errorBackground, borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
                              ),
                              confirmDismiss: (d) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Resume'),
                                    content: Text('Delete "${resume.title}"? This cannot be undone.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) => provider.deleteResume(resume.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.surfaceBorderLight)),
                                child: Row(children: [
                                  Container(width: 52, height: 60, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.description_rounded, color: Colors.white, size: 26)),
                                  const SizedBox(width: 14),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(resume.title, style: AppTypography.titleSmall),
                                    const SizedBox(height: 4),
                                    Text('${resume.completionPercentage}% complete', style: AppTypography.bodySmall),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(value: resume.completionPercentage / 100, backgroundColor: AppColors.backgroundTertiary, valueColor: AlwaysStoppedAnimation<Color>(AppColors.atsScoreColor(resume.atsScore)), borderRadius: BorderRadius.circular(4), minHeight: 4),
                                  ])),
                                  const SizedBox(width: 12),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.atsScoreColor(resume.atsScore).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text('${resume.atsScore}', style: AppTypography.labelMedium.copyWith(color: AppColors.atsScoreColor(resume.atsScore)))),
                                    const SizedBox(height: 4),
                                    Text('ATS', style: AppTypography.caption),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      GestureDetector(onTap: () => context.push(AppRoutes.resumeWizard, extra: resume.id), child: const Icon(Icons.edit_outlined, color: AppColors.textTertiary, size: 18)),
                                      const SizedBox(width: 12),
                                      GestureDetector(onTap: () => context.push(AppRoutes.resumePreview, extra: resume.id), child: const Icon(Icons.preview_outlined, color: AppColors.primary, size: 18)),
                                    ]),
                                  ]),
                                ]),
                              ),
                            ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.1);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
