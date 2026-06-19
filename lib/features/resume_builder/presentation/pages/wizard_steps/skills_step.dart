import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../providers/resume_provider.dart';
import '../../../domain/entities/resume_entity.dart';

class SkillsStep extends StatefulWidget {
  final VoidCallback onNext;
  const SkillsStep({super.key, required this.onNext});
  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _skillInput = TextEditingController();
  List<String> _technical = [], _soft = [], _tools = [], _frameworks = [];
  List<String> _aiRecommended = [];
  bool _loadingRecommendations = false;
  int _activeTab = 0;

  final _tabs = ['Technical', 'Soft Skills', 'Tools', 'Frameworks'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() => _activeTab = _tabController.index));
    final skills = context.read<ResumeProvider>().currentResume?.skills;
    if (skills != null) {
      _technical = List.from(skills.technicalSkills);
      _soft = List.from(skills.softSkills);
      _tools = List.from(skills.tools);
      _frameworks = List.from(skills.frameworks);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _skillInput.dispose();
    super.dispose();
  }

  List<String> get _activeList {
    switch (_activeTab) {
      case 0: return _technical;
      case 1: return _soft;
      case 2: return _tools;
      case 3: return _frameworks;
      default: return _technical;
    }
  }

  void _addSkill(String skill) {
    if (skill.isEmpty || _activeList.contains(skill)) return;
    setState(() {
      switch (_activeTab) {
        case 0: _technical.add(skill); break;
        case 1: _soft.add(skill); break;
        case 2: _tools.add(skill); break;
        case 3: _frameworks.add(skill); break;
      }
    });
    _saveSkills();
  }

  void _removeSkill(String skill) {
    setState(() {
      _technical.remove(skill);
      _soft.remove(skill);
      _tools.remove(skill);
      _frameworks.remove(skill);
    });
    _saveSkills();
  }

  Future<void> _saveSkills() async {
    await context.read<ResumeProvider>().updateSkills(SkillsSection(
      technicalSkills: _technical, softSkills: _soft, tools: _tools, frameworks: _frameworks,
    ));
  }

  Future<void> _getRecommendations() async {
    setState(() => _loadingRecommendations = true);
    try {
      final provider = context.read<ResumeProvider>();
      final resume = provider.currentResume;
      final recs = await provider.getSkillRecommendations(
        jobTitle: resume?.personalInfo.jobTitle ?? 'Professional',
        industry: 'Technology',
      );
      setState(() => _aiRecommended = recs);
    } finally {
      setState(() => _loadingRecommendations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 6),
          Text('Add your skills. Recruiters scan for keywords—be specific.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Tab bar
          Container(
            decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorderLight)),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
              labelStyle: AppTypography.labelMedium,
              unselectedLabelStyle: AppTypography.labelMedium,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Input
          Row(children: [
            Expanded(child: TextFormField(
              controller: _skillInput,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(labelText: 'Add ${_tabs[_activeTab]} Skill', prefixIcon: const Icon(Icons.add_circle_outline, size: 18)),
              onFieldSubmitted: (v) { _addSkill(v.trim()); _skillInput.clear(); },
            )),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () { _addSkill(_skillInput.text.trim()); _skillInput.clear(); },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), minimumSize: const Size(52, 52)),
              child: const Icon(Icons.add, size: 20),
            ),
          ]).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),

          // Skills chips
          if (_activeList.isNotEmpty) ...[
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _activeList.map((s) => AppTag(label: s, onDelete: () => _removeSkill(s))).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Predefined suggestions
          _buildSuggestions(),
          const SizedBox(height: 20),

          // AI Recommendations
          GlassCard(
            enableGlow: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.psychology, color: Colors.white, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Text('AI Skill Recommendations', style: AppTypography.titleSmall)),
              ]),
              const SizedBox(height: 12),
              Text('Based on your role, here are skills you should add:', style: AppTypography.bodySmall),
              const SizedBox(height: 12),
              if (_loadingRecommendations)
                const Center(child: CircularProgressIndicator(color: AppColors.primary))
              else if (_aiRecommended.isEmpty)
                OutlinedButton.icon(onPressed: _getRecommendations, icon: const Icon(Icons.lightbulb_outline, size: 18), label: const Text('Get AI Recommendations'))
              else
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _aiRecommended.map((s) => GestureDetector(
                    onTap: () { _addSkill(s); setState(() => _aiRecommended.remove(s)); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.surfaceBorderLight)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.add, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(s, style: AppTypography.tagStyle.copyWith(color: AppColors.textSecondary)),
                      ]),
                    ),
                  )).toList(),
                ),
            ]),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = <int, List<String>>{
      0: ['Python', 'JavaScript', 'TypeScript', 'React', 'Node.js', 'SQL', 'AWS', 'Docker', 'Git', 'REST APIs'],
      1: ['Leadership', 'Communication', 'Problem Solving', 'Team Collaboration', 'Time Management', 'Critical Thinking'],
      2: ['VS Code', 'Jira', 'Figma', 'GitHub', 'Postman', 'Slack', 'Notion', 'Excel', 'Tableau'],
      3: ['React', 'Vue.js', 'Angular', 'Django', 'FastAPI', 'Spring Boot', 'Flutter', 'Next.js', 'TensorFlow'],
    };

    final current = suggestions[_activeTab] ?? [];
    final available = current.where((s) => !_activeList.contains(s)).toList();
    if (available.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Suggestions', style: AppTypography.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: available.take(12).map((s) => GestureDetector(
          onTap: () => _addSkill(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.surfaceBorderLight)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.add, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(s, style: AppTypography.tagStyle.copyWith(color: AppColors.textSecondary)),
            ]),
          ),
        )).toList(),
      ),
    ]);
  }
}
