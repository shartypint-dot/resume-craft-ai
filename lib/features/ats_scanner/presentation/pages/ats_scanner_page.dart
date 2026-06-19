import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../services/ai/openai_service.dart';
import '../../../resume_builder/presentation/providers/resume_provider.dart';
import '../../../resume_builder/domain/entities/resume_entity.dart';

class AtsScannerPage extends StatefulWidget {
  final String? resumeId;
  const AtsScannerPage({super.key, this.resumeId});

  @override
  State<AtsScannerPage> createState() => _AtsScannerPageState();
}

class _AtsScannerPageState extends State<AtsScannerPage> {
  final OpenAIService _ai = OpenAIService();
  Map<String, dynamic>? _atsResult;
  bool _isScanning = false;
  bool _hasScanned = false;

  Future<void> _runScan() async {
    final resume = context.read<ResumeProvider>().currentResume;
    if (resume == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a resume first')),
      );
      return;
    }

    setState(() => _isScanning = true);
    try {
      final resumeText = _buildResumeText(resume);
      final result = await _ai.analyzeResumeForAts(resumeText: resumeText);
      setState(() {
        _atsResult = result;
        _hasScanned = true;
      });

      if (!mounted) return;
      final score = (result['overall_score'] as num?)?.toInt() ?? 0;
      await context.read<ResumeProvider>().updateAtsScore(score);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  String _buildResumeText(ResumeEntity resume) {
    final buffer = StringBuffer();
    buffer.writeln(resume.personalInfo.fullName);
    buffer.writeln('${resume.personalInfo.email} | ${resume.personalInfo.phone}');
    buffer.writeln('${resume.personalInfo.city}, ${resume.personalInfo.country}');
    buffer.writeln('\nSUMMARY\n${resume.professionalSummary}');
    buffer.writeln('\nEXPERIENCE');
    for (final exp in resume.workExperiences) {
      buffer.writeln('${exp.position} at ${exp.company}');
      for (final r in exp.responsibilities) {
        buffer.writeln('• $r');
      }
    }
    buffer.writeln('\nEDUCATION');
    for (final edu in resume.educations) {
      buffer.writeln('${edu.degree} - ${edu.institution}');
    }
    buffer.writeln('\nSKILLS');
    buffer.writeln(resume.skills.allSkills.join(', '));
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'ATS Scanner'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasScanned) _buildScanIntro(),
            if (_hasScanned && _atsResult != null) _buildResults(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildScanIntro() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 120, height: 120,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle, boxShadow: AppColors.primaryGlowShadow),
            child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 60),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('ATS Resume Scanner', style: AppTypography.headlineMedium, textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
        const SizedBox(height: 8),
        Text('Our AI analyzes your resume against 50+ ATS criteria used by major companies.', style: AppTypography.bodyLarge, textAlign: TextAlign.center).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 40),
        _buildFeatureList(),
        const SizedBox(height: 40),
        GradientButton(
          text: _isScanning ? 'Scanning...' : 'Run ATS Scan',
          onPressed: _isScanning ? null : _runScan,
          isLoading: _isScanning,
          gradient: AppColors.primaryGradient,
          prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildFeatureList() {
    final features = [
      ('Keyword Analysis', 'Checks 200+ industry keywords', Icons.text_fields, AppColors.primary),
      ('Format Check', 'Validates ATS-friendly formatting', Icons.format_align_left, AppColors.secondary),
      ('Structure Score', 'Reviews section structure', Icons.account_tree_outlined, AppColors.accentGold),
      ('Skills Gap', 'Identifies missing key skills', Icons.psychology_outlined, AppColors.accentGreen),
    ];
    return Column(
      children: features.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: e.value.$4.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(e.value.$3, color: e.value.$4, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.value.$1, style: AppTypography.titleSmall),
            Text(e.value.$2, style: AppTypography.bodySmall),
          ])),
        ]),
      ).animate().fadeIn(delay: (200 + e.key * 100).ms).slideX(begin: 0.2)).toList(),
    );
  }

  Widget _buildResults() {
    final overall = (_atsResult!['overall_score'] as num?)?.toInt() ?? 0;
    final keyword = (_atsResult!['keyword_score'] as num?)?.toInt() ?? 0;
    final formatting = (_atsResult!['formatting_score'] as num?)?.toInt() ?? 0;
    final structure = (_atsResult!['structure_score'] as num?)?.toInt() ?? 0;
    final readability = (_atsResult!['readability_score'] as num?)?.toInt() ?? 0;
    final skillsScore = (_atsResult!['skills_score'] as num?)?.toInt() ?? 0;
    final suggestions = _atsResult!['suggestions'] as List? ?? [];
    final missing = _atsResult!['missing_keywords'] as List? ?? [];
    final found = _atsResult!['found_keywords'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall score hero
        Center(
          child: GlassCard(
            enableGlow: true,
            glowColor: AppColors.atsScoreColor(overall),
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Text('Your ATS Score', style: AppTypography.titleMedium),
              const SizedBox(height: 16),
              ScoreRing(score: overall, size: 120, strokeWidth: 10, label: 'ATS Score',
                scoreStyle: AppTypography.scoreDisplay.copyWith(color: AppColors.atsScoreColor(overall))),
              const SizedBox(height: 16),
              Text(_getScoreLabel(overall), style: AppTypography.titleSmall.copyWith(color: AppColors.atsScoreColor(overall))),
              const SizedBox(height: 8),
              Text(_getScoreDescription(overall), style: AppTypography.bodySmall, textAlign: TextAlign.center),
            ]),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),

        // Breakdown
        Text('Score Breakdown', style: AppTypography.titleMedium),
        const SizedBox(height: 12),
        _buildScoreRow('Keywords', keyword, AppColors.primary),
        _buildScoreRow('Formatting', formatting, AppColors.secondary),
        _buildScoreRow('Structure', structure, AppColors.accentGold),
        _buildScoreRow('Readability', readability, AppColors.accentGreen),
        _buildScoreRow('Skills Match', skillsScore, AppColors.accentTeal),
        const SizedBox(height: 24),

        // Missing keywords
        if (missing.isNotEmpty) ...[
          Text('Missing Keywords', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text('Add these high-value keywords to improve your score:', style: AppTypography.bodySmall),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: missing.take(15).map((k) => AppTag(label: k.toString(), color: AppColors.error, backgroundColor: AppColors.errorBackground)).toList()),
          const SizedBox(height: 20),
        ],

        // Found keywords
        if (found.isNotEmpty) ...[
          Text('Found Keywords', style: AppTypography.titleMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: found.take(12).map((k) => AppTag(label: k.toString(), color: AppColors.success, backgroundColor: AppColors.successBackground)).toList()),
          const SizedBox(height: 24),
        ],

        // Suggestions
        if (suggestions.isNotEmpty) ...[
          Text('Improvement Suggestions', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          ...suggestions.take(6).toList().asMap().entries.map((e) {
            final s = e.value as Map<String, dynamic>;
            final priority = s['priority'] as String? ?? 'medium';
            final priorityColor = priority == 'critical' ? AppColors.error :
                priority == 'high' ? AppColors.warning :
                priority == 'medium' ? AppColors.primary : AppColors.success;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.surfaceBorderLight)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Text(priority.toUpperCase(), style: AppTypography.tagStyle.copyWith(color: priorityColor))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s['title'] ?? '', style: AppTypography.titleSmall)),
                ]),
                const SizedBox(height: 6),
                Text(s['description'] ?? '', style: AppTypography.bodySmall),
              ]),
            ).animate().fadeIn(delay: (e.key * 80).ms).slideX(begin: 0.1);
          }),
        ],
        const SizedBox(height: 24),

        // Re-scan button
        OutlinedButton.icon(
          onPressed: _runScan,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Re-scan Resume'),
        ),
        const SizedBox(height: 12),
        GradientButton(text: 'Download Report', onPressed: () {}, gradient: AppColors.primaryGradient, prefixIcon: const Icon(Icons.download, color: Colors.white, size: 18)),
      ],
    );
  }

  Widget _buildScoreRow(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: AppTypography.bodyMedium)),
        Expanded(child: LinearProgressIndicator(value: score / 100, backgroundColor: AppColors.backgroundTertiary, valueColor: AlwaysStoppedAnimation<Color>(color), borderRadius: BorderRadius.circular(4), minHeight: 8)),
        const SizedBox(width: 8),
        SizedBox(width: 36, child: Text('$score%', style: AppTypography.labelSmall.copyWith(color: color))),
      ]),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  String _getScoreLabel(int score) {
    if (score >= 85) return 'Excellent - ATS Ready!';
    if (score >= 70) return 'Good - Minor Improvements Needed';
    if (score >= 55) return 'Average - Needs Improvement';
    if (score >= 40) return 'Poor - Major Revisions Needed';
    return 'Critical - Complete Overhaul Required';
  }

  String _getScoreDescription(int score) {
    if (score >= 85) return 'Your resume will pass most ATS systems. Ready to apply!';
    if (score >= 70) return 'Good foundation. A few tweaks will maximize your visibility.';
    if (score >= 55) return 'Your resume needs work to pass ATS filters effectively.';
    return 'Your resume needs significant improvements to pass ATS screening.';
  }
}
