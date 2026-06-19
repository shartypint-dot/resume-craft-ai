import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../providers/resume_provider.dart';

class SummaryStep extends StatefulWidget {
  final VoidCallback onNext;

  const SummaryStep({super.key, required this.onNext});

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep> {
  final _summaryController = TextEditingController();
  final _yearsController = TextEditingController();
  final _roleController = TextEditingController();
  final _industryController = TextEditingController();
  String _selectedType = 'ats';
  final List<String> _achievements = [];
  final _achievementController = TextEditingController();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final resume = context.read<ResumeProvider>().currentResume;
    if (resume != null) {
      _summaryController.text = resume.professionalSummary;
      _roleController.text = resume.personalInfo.jobTitle;
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _yearsController.dispose();
    _roleController.dispose();
    _industryController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  Future<void> _generateSummary() async {
    if (_roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your role first')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final provider = context.read<ResumeProvider>();
      final summary = await provider.generateSummary(
        yearsExperience: _yearsController.text.isEmpty ? '3' : _yearsController.text,
        industry: _industryController.text.isEmpty ? 'Technology' : _industryController.text,
        role: _roleController.text,
        achievements: _achievements,
        careerGoal: 'grow professionally',
        type: _selectedType,
      );

      setState(() => _summaryController.text = summary);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Professional Summary', style: AppTypography.headlineSmall)
              .animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 6),
          Text(
            'A powerful summary can increase your interview chances by 3x.',
            style: AppTypography.bodyMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          // AI Generation card
          GlassCard(
            enableGlow: true,
            glowColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text('AI Summary Generator', style: AppTypography.titleSmall),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _roleController,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Your Role',
                          hintText: 'Software Engineer',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Years',
                          hintText: '5',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _industryController,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Industry',
                    hintText: 'Technology, Finance, Healthcare...',
                  ),
                ),
                const SizedBox(height: 16),

                // Key achievements input
                Text('Key Achievements (optional)', style: AppTypography.labelMedium),
                const SizedBox(height: 8),
                ..._achievements.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(a, style: AppTypography.bodySmall)),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _achievements.remove(a)),
                        color: AppColors.textTertiary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _achievementController,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Add an achievement...',
                          isDense: true,
                        ),
                        onFieldSubmitted: (v) {
                          if (v.trim().isNotEmpty) {
                            setState(() {
                              _achievements.add(v.trim());
                              _achievementController.clear();
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 22),
                      onPressed: () {
                        final v = _achievementController.text.trim();
                        if (v.isNotEmpty) {
                          setState(() {
                            _achievements.add(v);
                            _achievementController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Summary type selector
                Text('Summary Style', style: AppTypography.labelMedium),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final type in [('ats', 'ATS Optimized'), ('modern', 'Modern'), ('executive', 'Executive')])
                        GestureDetector(
                          onTap: () => setState(() => _selectedType = type.$1),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedType == type.$1
                                  ? AppColors.primaryGlow
                                  : AppColors.backgroundTertiary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedType == type.$1
                                    ? AppColors.primary
                                    : AppColors.surfaceBorderLight,
                              ),
                            ),
                            child: Text(
                              type.$2,
                              style: AppTypography.labelSmall.copyWith(
                                color: _selectedType == type.$1
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateSummary,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_fix_high, size: 18),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate AI Summary'),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 20),

          // Manual edit area
          Text('Your Professional Summary', style: AppTypography.titleSmall)
              .animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          TextFormField(
            controller: _summaryController,
            maxLines: 6,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Write or generate your professional summary...',
              alignLabelWithHint: true,
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
          const SizedBox(height: 8),

          // Character count
          Consumer<ResumeProvider>(
            builder: (_, provider, __) {
              final count = _summaryController.text.length;
              return Text(
                '$count characters • ${(count / 5).round()} words',
                style: AppTypography.caption,
              );
            },
          ),
          const SizedBox(height: 24),

          // Tips
          _buildTip(
            'ATS Tip',
            'Keep your summary between 50-150 words for best ATS performance.',
            Icons.lightbulb_outline,
            AppColors.accentGold,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTip(String title, String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium.copyWith(color: color)),
                const SizedBox(height: 3),
                Text(message, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
