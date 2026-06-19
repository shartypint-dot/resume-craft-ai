import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../services/ai/openai_service.dart';
import '../../../resume_builder/presentation/providers/resume_provider.dart';

class CoverLetterPage extends StatefulWidget {
  const CoverLetterPage({super.key});

  @override
  State<CoverLetterPage> createState() => _CoverLetterPageState();
}

class _CoverLetterPageState extends State<CoverLetterPage> {
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _industryController = TextEditingController();
  final _ai = OpenAIService();
  String? _generatedLetter;
  bool _isGenerating = false;
  String _selectedStyle = 'professional';
  bool _isEditing = false;
  final _editController = TextEditingController();

  final _styles = [
    ('professional', 'Professional', Icons.business_center_outlined),
    ('modern', 'Modern', Icons.trending_up),
    ('startup', 'Startup', Icons.rocket_launch_outlined),
    ('executive', 'Executive', Icons.workspace_premium_outlined),
  ];

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _industryController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_companyController.text.isEmpty || _jobTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company and job title are required')));
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final resume = context.read<ResumeProvider>().currentResume;
      final letter = await _ai.generateCoverLetter(
        candidateName: resume?.personalInfo.fullName ?? 'Professional',
        jobTitle: _jobTitleController.text.trim(),
        companyName: _companyController.text.trim(),
        industry: _industryController.text.trim().isEmpty ? 'Technology' : _industryController.text.trim(),
        professionalSummary: resume?.professionalSummary ?? '',
        topSkills: resume?.skills.allSkills.take(5).toList() ?? [],
        experiences: resume?.workExperiences ?? [],
        style: _selectedStyle,
      );
      setState(() {
        _generatedLetter = letter;
        _editController.text = letter;
      });
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Cover Letter',
        actions: _generatedLetter != null ? [
          IconButton(
            icon: const Icon(Icons.copy_outlined, color: AppColors.textSecondary),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _generatedLetter!));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
            },
          ),
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_generatedLetter == null) _buildForm(),
            if (_generatedLetter != null) _buildResult(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Generate Cover Letter', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 6),
        Text('AI crafts a personalized cover letter tailored to the role.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        TextFormField(controller: _companyController, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Company Name *', prefixIcon: Icon(Icons.business_outlined))).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 14),
        TextFormField(controller: _jobTitleController, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Job Title *', prefixIcon: Icon(Icons.work_outline))).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
        const SizedBox(height: 14),
        TextFormField(controller: _industryController, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Industry', hintText: 'Technology, Finance, Healthcare...', prefixIcon: Icon(Icons.category_outlined))).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        const SizedBox(height: 20),

        Text('Cover Letter Style', style: AppTypography.titleSmall).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 10),
        Row(children: _styles.map((s) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedStyle = s.$1),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _selectedStyle == s.$1 ? AppColors.primaryGlow : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedStyle == s.$1 ? AppColors.primary : AppColors.surfaceBorderLight),
              ),
              child: Column(children: [
                Icon(s.$3, color: _selectedStyle == s.$1 ? AppColors.primary : AppColors.textTertiary, size: 20),
                const SizedBox(height: 4),
                Text(s.$2, style: AppTypography.labelSmall.copyWith(color: _selectedStyle == s.$1 ? AppColors.primary : AppColors.textTertiary), textAlign: TextAlign.center),
              ]),
            ),
          ),
        )).toList()).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 32),

        GradientButton(
          text: _isGenerating ? 'Generating...' : 'Generate Cover Letter',
          onPressed: _isGenerating ? null : _generate,
          isLoading: _isGenerating,
          gradient: AppColors.primaryGradient,
          prefixIcon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          child: Row(children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cover letter generated!', style: AppTypography.titleSmall.copyWith(color: AppColors.success)),
              Text('For ${_jobTitleController.text} at ${_companyController.text}', style: AppTypography.bodySmall),
            ])),
          ]),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),

        if (_isEditing)
          TextFormField(controller: _editController, maxLines: 20, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.6))
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
            child: Text(_generatedLetter!, style: AppTypography.bodyMedium.copyWith(height: 1.8)),
          ),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => setState(() { _isEditing = !_isEditing; if (!_isEditing) _generatedLetter = _editController.text; }), icon: Icon(_isEditing ? Icons.save : Icons.edit_outlined, size: 16), label: Text(_isEditing ? 'Save Edits' : 'Edit'))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(onPressed: () { setState(() => _generatedLetter = null); }, icon: const Icon(Icons.refresh, size: 16), label: const Text('Regenerate'))),
        ]),
        const SizedBox(height: 12),
        GradientButton(
          text: 'Download as PDF',
          onPressed: () {},
          gradient: AppColors.primaryGradient,
          prefixIcon: const Icon(Icons.download, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}
