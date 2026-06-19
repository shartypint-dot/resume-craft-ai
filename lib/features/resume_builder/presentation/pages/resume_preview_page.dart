import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../providers/resume_provider.dart';
import '../../domain/entities/resume_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../../services/pdf/resume_pdf_service.dart';

class ResumePreviewPage extends StatefulWidget {
  final String resumeId;
  const ResumePreviewPage({super.key, required this.resumeId});

  @override
  State<ResumePreviewPage> createState() => _ResumePreviewPageState();
}

class _ResumePreviewPageState extends State<ResumePreviewPage> {
  String _selectedTemplate = 'classic_ats';
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await context.read<ResumeProvider>().loadResume(widget.resumeId);
    if (!mounted) return;
    final resume = context.read<ResumeProvider>().currentResume;
    if (resume != null) {
      setState(() { _selectedTemplate = resume.templateId; _isLoading = false; });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resume = context.watch<ResumeProvider>().currentResume;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Preview',
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download_outlined, color: AppColors.primary), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : resume == null
              ? const EmptyState(title: 'Resume not found', description: 'The resume could not be loaded.')
              : Column(children: [
                  _buildTemplateSelector(resume),
                  Expanded(child: _buildResumePreview(resume)),
                  _buildBottomActions(resume),
                ]),
    );
  }

  Widget _buildTemplateSelector(ResumeEntity resume) {
    final allTemplates = [...AppConstants.freeTemplateIds, ...AppConstants.proTemplateIds];
    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: allTemplates.length,
        itemBuilder: (context, i) {
          final t = allTemplates[i];
          final isSelected = _selectedTemplate == t;
          final isPro = AppConstants.proTemplateIds.contains(t);
          return GestureDetector(
            onTap: () async {
              setState(() => _selectedTemplate = t);
              await context.read<ResumeProvider>().updateTemplate(t);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGlow : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceBorderLight),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(t.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '), style: AppTypography.labelSmall.copyWith(color: isSelected ? AppColors.primary : AppColors.textSecondary)),
                if (isPro) ...[const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(gradient: AppColors.premiumGradient, borderRadius: BorderRadius.circular(4)), child: Text('PRO', style: AppTypography.tagStyle.copyWith(color: Colors.white, fontSize: 8)))],
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResumePreview(ResumeEntity resume) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: AppColors.cardShadow),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Text(resume.personalInfo.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text(resume.personalInfo.jobTitle, style: const TextStyle(fontSize: 14, color: Color(0xFF6C63FF), fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text([resume.personalInfo.email, resume.personalInfo.phone, resume.personalInfo.city].where((s) => s.isNotEmpty).join(' • '), style: const TextStyle(fontSize: 11, color: Color(0xFF555555))),
            if (resume.personalInfo.linkedIn.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(resume.personalInfo.linkedIn, style: const TextStyle(fontSize: 11, color: Color(0xFF6C63FF))),
            ],
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFE0E0E0)),

            // Summary
            if (resume.professionalSummary.isNotEmpty) ...[
              const SizedBox(height: 14),
              _sectionTitle('Professional Summary'),
              const SizedBox(height: 6),
              Text(resume.professionalSummary, style: const TextStyle(fontSize: 11, color: Color(0xFF333333), height: 1.6)),
            ],

            // Experience
            if (resume.workExperiences.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Work Experience'),
              ...resume.workExperiences.map((exp) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(exp.position, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                    Text(exp.isCurrent ? 'Present' : 'Past', style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
                  ]),
                  Text('${exp.company} • ${exp.location}', style: const TextStyle(fontSize: 11, color: Color(0xFF6C63FF))),
                  const SizedBox(height: 4),
                  ...exp.responsibilities.map((r) => Padding(padding: const EdgeInsets.only(bottom: 2), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontSize: 11, color: Color(0xFF6C63FF))), Expanded(child: Text(r, style: const TextStyle(fontSize: 11, color: Color(0xFF333333), height: 1.5)))]))),
                ]),
              )),
            ],

            // Education
            if (resume.educations.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Education'),
              ...resume.educations.map((edu) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${edu.degree} - ${edu.major}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                  Text(edu.institution, style: const TextStyle(fontSize: 11, color: Color(0xFF6C63FF))),
                  if (edu.gpa != null) Text('GPA: ${edu.gpa}', style: const TextStyle(fontSize: 10, color: Color(0xFF888888))),
                ]),
              )),
            ],

            // Skills
            if (resume.skills.allSkills.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Skills'),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: resume.skills.allSkills.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEEECFF), borderRadius: BorderRadius.circular(6)), child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF6C63FF), fontWeight: FontWeight.w500)))).toList()),
            ],

            // Certifications
            if (resume.certifications.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Certifications'),
              ...resume.certifications.map((cert) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(children: [const Icon(Icons.verified, color: Color(0xFF6C63FF), size: 14), const SizedBox(width: 6), Expanded(child: Text('${cert.name} • ${cert.organization}', style: const TextStyle(fontSize: 11, color: Color(0xFF333333))))]),
              )),
            ],
          ]),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _sectionTitle(String title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Color(0xFF6C63FF))),
      const SizedBox(height: 3),
      Container(height: 2, width: 40, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)]))),
    ]);
  }

  Future<void> _downloadPdf(ResumeEntity resume) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final isPro = context.read<SubscriptionProvider>().isPro;
      final bytes = await ResumePdfService.generatePdf(
        resume: resume,
        isPro: isPro,
        templateId: _selectedTemplate,
      );
      final name = '${resume.personalInfo.firstName}_${resume.personalInfo.lastName}_Resume'
          .replaceAll(' ', '_');
      await ResumePdfService.printOrShare(bytes, name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Widget _buildBottomActions(ResumeEntity resume) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.surfaceBorderLight))),
      child: Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: () => context.push(AppRoutes.resumeWizard, extra: resume.id), icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'))),
        const SizedBox(width: 12),
        Expanded(child: GradientButton(
          text: _isDownloading ? 'Generating...' : 'Download PDF',
          onPressed: _isDownloading ? null : () => _downloadPdf(resume),
          gradient: AppColors.primaryGradient,
          prefixIcon: _isDownloading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.download, color: Colors.white, size: 16),
          height: 48,
        )),
        const SizedBox(width: 12),
        Expanded(child: OutlinedButton.icon(onPressed: () => context.push(AppRoutes.atsScanner, extra: resume.id), icon: const Icon(Icons.analytics_outlined, size: 16), label: const Text('ATS Scan'))),
      ]),
    );
  }
}
