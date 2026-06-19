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

class JobMatcherPage extends StatefulWidget {
  final String? resumeId;
  const JobMatcherPage({super.key, this.resumeId});

  @override
  State<JobMatcherPage> createState() => _JobMatcherPageState();
}

class _JobMatcherPageState extends State<JobMatcherPage> {
  final _jobDescController = TextEditingController();
  final _ai = OpenAIService();
  Map<String, dynamic>? _matchResult;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _jobDescController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_jobDescController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please paste a job description')));
      return;
    }

    final resume = context.read<ResumeProvider>().currentResume;
    if (resume == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create a resume first')));
      return;
    }

    setState(() => _isAnalyzing = true);
    try {
      final resumeText = _buildResumeText(resume);
      final result = await _ai.matchResumeToJob(resumeText: resumeText, jobDescription: _jobDescController.text.trim());
      setState(() => _matchResult = result);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  String _buildResumeText(ResumeEntity r) {
    final buf = StringBuffer();
    buf.writeln(r.personalInfo.fullName);
    buf.writeln(r.professionalSummary);
    for (final e in r.workExperiences) {
      buf.writeln('${e.position} at ${e.company}');
      buf.writeln(e.responsibilities.join('\n'));
    }
    buf.writeln(r.skills.allSkills.join(', '));
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Job Matcher'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJobInput(),
            if (_matchResult != null) ...[
              const SizedBox(height: 24),
              _buildMatchResults(),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildJobInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Paste Job Description', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 6),
        Text('We\'ll analyze how well your resume matches the job requirements.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 20),
        TextFormField(
          controller: _jobDescController,
          maxLines: 10,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Paste the full job description here...\n\nInclude job requirements, responsibilities, and qualifications for the best analysis.',
            alignLabelWithHint: true,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        GradientButton(
          text: _isAnalyzing ? 'Analyzing...' : 'Analyze Match',
          onPressed: _isAnalyzing ? null : _analyze,
          isLoading: _isAnalyzing,
          gradient: AppColors.primaryGradient,
          prefixIcon: const Icon(Icons.compare_arrows, color: Colors.white, size: 20),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildMatchResults() {
    final score = (_matchResult!['match_score'] as num?)?.toInt() ?? 0;
    final matched = _matchResult!['matched_keywords'] as List? ?? [];
    final missing = _matchResult!['missing_keywords'] as List? ?? [];
    final missingSkills = _matchResult!['missing_skills'] as List? ?? [];
    final recs = _matchResult!['recommendations'] as List? ?? [];
    final optimizedSummary = _matchResult!['optimized_summary'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match score
        GlassCard(
          enableGlow: true,
          glowColor: AppColors.atsScoreColor(score),
          child: Row(children: [
            ScoreRing(score: score, size: 90, strokeWidth: 8, label: 'Match',
              scoreStyle: AppTypography.headlineMedium.copyWith(color: AppColors.atsScoreColor(score), fontWeight: FontWeight.w800)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Job Match Score', style: AppTypography.titleSmall),
              const SizedBox(height: 4),
              Text(_getMatchLabel(score), style: AppTypography.bodyMedium.copyWith(color: AppColors.atsScoreColor(score))),
              const SizedBox(height: 8),
              Text('${matched.length} keywords matched • ${missing.length} missing', style: AppTypography.bodySmall),
            ])),
          ]),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),

        // Two columns: Matched vs Missing keywords
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _keywordColumn('Matched Keywords', matched, AppColors.success, AppColors.successBackground)),
          const SizedBox(width: 12),
          Expanded(child: _keywordColumn('Missing Keywords', missing, AppColors.error, AppColors.errorBackground)),
        ]),
        const SizedBox(height: 20),

        if (missingSkills.isNotEmpty) ...[
          Text('Skills Gap', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Text('Add these skills to improve your match:', style: AppTypography.bodySmall),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: missingSkills.take(10).map((s) => AppTag(label: s.toString(), color: AppColors.warning, backgroundColor: AppColors.warningBackground)).toList()),
          const SizedBox(height: 20),
        ],

        // Recommendations
        if (recs.isNotEmpty) ...[
          Text('Optimization Suggestions', style: AppTypography.titleMedium),
          const SizedBox(height: 12),
          ...recs.take(5).toList().asMap().entries.map((e) {
            final r = e.value as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.surfaceBorderLight)),
              child: Row(children: [
                const Icon(Icons.tips_and_updates_outlined, color: AppColors.accentGold, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r['action'] ?? '', style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                  if (r['section'] != null) Text('Section: ${r['section']}', style: AppTypography.caption),
                ])),
              ]),
            ).animate().fadeIn(delay: (e.key * 80).ms).slideX(begin: 0.1);
          }),
          const SizedBox(height: 20),
        ],

        // Optimized summary
        if (optimizedSummary.isNotEmpty) ...[
          Text('Optimized Summary for This Role', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text('AI-Optimized', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
              ]),
              const SizedBox(height: 8),
              Text(optimizedSummary, style: AppTypography.bodyMedium),
            ]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Optimized Summary'),
          ),
        ],
      ],
    );
  }

  Widget _keywordColumn(String title, List keywords, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.surfaceBorderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(title.contains('Match') ? Icons.check_circle : Icons.cancel, color: color, size: 16),
          const SizedBox(width: 6),
          Text(title, style: AppTypography.labelMedium.copyWith(color: color)),
        ]),
        const SizedBox(height: 8),
        if (keywords.isEmpty)
          Text('None found', style: AppTypography.bodySmall)
        else
          ...keywords.take(8).map((k) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(k.toString(), style: AppTypography.tagStyle.copyWith(color: color))),
          )),
      ]),
    );
  }

  String _getMatchLabel(int score) {
    if (score >= 85) return 'Excellent Match!';
    if (score >= 70) return 'Good Match';
    if (score >= 50) return 'Partial Match';
    return 'Low Match';
  }
}
