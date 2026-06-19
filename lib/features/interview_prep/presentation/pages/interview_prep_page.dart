import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../services/ai/openai_service.dart';

class InterviewPrepPage extends StatefulWidget {
  const InterviewPrepPage({super.key});

  @override
  State<InterviewPrepPage> createState() => _InterviewPrepPageState();
}

class _InterviewPrepPageState extends State<InterviewPrepPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ai = OpenAIService();
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;
  String _selectedJobTitle = 'Software Engineer';
  String _selectedLevel = 'Mid-Level (3-6 years)';
  String _selectedType = 'all';
  int? _expandedIndex;
  bool _inMockInterview = false;
  int _currentMockQ = 0;
  final _answerController = TextEditingController();
  Map<String, dynamic>? _answerScore;
  bool _scoringAnswer = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _ai.generateInterviewQuestions(
        jobTitle: _selectedJobTitle,
        industry: 'Technology',
        experienceLevel: _selectedLevel,
        questionType: _selectedType,
        count: 15,
      );
      setState(() => _questions = questions);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scoreAnswer() async {
    if (_answerController.text.trim().isEmpty) return;
    setState(() => _scoringAnswer = true);
    try {
      final q = _questions[_currentMockQ];
      final score = await _ai.scoreInterviewAnswer(
        question: q['question'] ?? '',
        answer: _answerController.text.trim(),
        jobTitle: _selectedJobTitle,
      );
      setState(() => _answerScore = score);
    } finally {
      setState(() => _scoringAnswer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Interview Prep'),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSetupTab(),
                _buildQuestionsTab(),
                _inMockInterview ? _buildMockInterviewTab() : _buildMockIntroTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(12)),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
          tabs: const [Tab(text: 'Setup'), Tab(text: 'Questions'), Tab(text: 'Mock Interview')],
        ),
      ),
    );
  }

  Widget _buildSetupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Prepare for Your Interview', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 6),
        Text('Get AI-generated interview questions tailored to your role and experience.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),

        TextFormField(
          initialValue: _selectedJobTitle,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Job Title', prefixIcon: Icon(Icons.work_outline)),
          onChanged: (v) => setState(() => _selectedJobTitle = v),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: _selectedLevel,
          dropdownColor: AppColors.backgroundCard,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(labelText: 'Experience Level', prefixIcon: Icon(Icons.trending_up)),
          items: ['Student', 'Fresh Graduate (0-1 years)', 'Junior (1-3 years)', 'Mid-Level (3-6 years)', 'Senior (6-10 years)', 'Lead / Principal (10-15 years)', 'Executive (15+ years)']
              .map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
          onChanged: (v) => setState(() => _selectedLevel = v!),
        ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
        const SizedBox(height: 20),

        Text('Question Types', style: AppTypography.titleSmall).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in [('all', 'All Types'), ('hr', 'HR Questions'), ('behavioral', 'Behavioral'), ('technical', 'Technical')])
            GestureDetector(
              onTap: () => setState(() => _selectedType = t.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: _selectedType == t.$1 ? AppColors.primaryGlow : AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(10), border: Border.all(color: _selectedType == t.$1 ? AppColors.primary : AppColors.surfaceBorderLight)),
                child: Text(t.$2, style: AppTypography.labelMedium.copyWith(color: _selectedType == t.$1 ? AppColors.primary : AppColors.textSecondary)),
              ),
            ),
        ]).animate().fadeIn(delay: 350.ms),
        const SizedBox(height: 32),

        GradientButton(
          text: _isLoading ? 'Generating...' : 'Generate Questions',
          onPressed: _isLoading ? null : () async { await _generateQuestions(); _tabController.animateTo(1); },
          isLoading: _isLoading,
          gradient: AppColors.primaryGradient,
          prefixIcon: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
      ]),
    );
  }

  Widget _buildQuestionsTab() {
    if (_questions.isEmpty) {
      return EmptyState(title: 'No questions yet', description: 'Go to Setup tab and generate interview questions.', buttonText: 'Go to Setup', onButtonPressed: () => _tabController.animateTo(0));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final q = _questions[index];
        final isExpanded = _expandedIndex == index;
        final type = q['type'] as String? ?? 'hr';
        final difficulty = q['difficulty'] as String? ?? 'medium';
        final typeColor = type == 'technical' ? AppColors.primary : type == 'behavioral' ? AppColors.accentGold : AppColors.accentGreen;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
          child: Column(children: [
            InkWell(
              onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)), child: Text(type.toUpperCase(), style: AppTypography.tagStyle.copyWith(color: typeColor))),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(6)), child: Text(difficulty, style: AppTypography.tagStyle.copyWith(color: AppColors.textTertiary))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(q['question'] ?? '', style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), maxLines: isExpanded ? null : 2, overflow: isExpanded ? null : TextOverflow.ellipsis)),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.textTertiary, size: 20),
                ]),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1, color: AppColors.surfaceBorderLight),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (q['tips'] != null) ...[
                    Row(children: [const Icon(Icons.lightbulb_outline, color: AppColors.accentGold, size: 16), const SizedBox(width: 6), Text('Answer Tips', style: AppTypography.labelMedium.copyWith(color: AppColors.accentGold))]),
                    const SizedBox(height: 6),
                    Text(q['tips'], style: AppTypography.bodySmall, ),
                  ],
                  if (q['example_answer_structure'] != null) ...[
                    const SizedBox(height: 12),
                    Row(children: [const Icon(Icons.format_list_bulleted, color: AppColors.primary, size: 16), const SizedBox(width: 6), Text('Answer Structure', style: AppTypography.labelMedium.copyWith(color: AppColors.primary))]),
                    const SizedBox(height: 6),
                    Text(q['example_answer_structure'], style: AppTypography.bodySmall),
                  ],
                ]),
              ),
            ],
          ]),
        ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildMockIntroTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80, decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle), child: const Icon(Icons.record_voice_over_outlined, color: Colors.white, size: 40)).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text('Mock Interview', style: AppTypography.headlineMedium, textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text('Practice with AI-generated questions. Your answers will be scored and you\'ll receive detailed feedback.', style: AppTypography.bodyLarge, textAlign: TextAlign.center).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          GradientButton(
            text: 'Start Mock Interview',
            onPressed: _questions.isEmpty ? null : () => setState(() { _inMockInterview = true; _currentMockQ = 0; _answerScore = null; _answerController.clear(); }),
            gradient: AppColors.primaryGradient,
            prefixIcon: const Icon(Icons.play_arrow, color: Colors.white),
          ).animate().fadeIn(delay: 600.ms),
          if (_questions.isEmpty) ...[
            const SizedBox(height: 12),
            Text('Generate questions first in the Setup tab', style: AppTypography.bodySmall, textAlign: TextAlign.center),
          ],
        ]),
      ),
    );
  }

  Widget _buildMockInterviewTab() {
    if (_questions.isEmpty) return _buildMockIntroTab();
    final q = _questions[_currentMockQ];
    final isLast = _currentMockQ == _questions.length - 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Progress
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Question ${_currentMockQ + 1}/${_questions.length}', style: AppTypography.labelMedium),
          TextButton(onPressed: () => setState(() => _inMockInterview = false), child: const Text('End Session')),
        ]),
        LinearProgressIndicator(value: (_currentMockQ + 1) / _questions.length, backgroundColor: AppColors.backgroundTertiary, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), borderRadius: BorderRadius.circular(4), minHeight: 4),
        const SizedBox(height: 24),

        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A1A35), Color(0xFF252540)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.surfaceBorderLight)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Question', style: AppTypography.overline),
            const SizedBox(height: 8),
            Text(q['question'] ?? '', style: AppTypography.titleMedium),
          ]),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 20),

        if (_answerScore == null) ...[
          Text('Your Answer', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: _answerController,
            maxLines: 7,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Type your answer here...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 16),
          GradientButton(
            text: _scoringAnswer ? 'Scoring...' : 'Submit Answer',
            onPressed: _scoringAnswer ? null : _scoreAnswer,
            isLoading: _scoringAnswer,
            gradient: AppColors.primaryGradient,
          ),
        ] else ...[
          // Score display
          GlassCard(
            enableGlow: true,
            glowColor: AppColors.atsScoreColor((_answerScore!['score'] as num?)?.toInt() ?? 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                ScoreRing(score: (_answerScore!['score'] as num?)?.toInt() ?? 0, size: 70, strokeWidth: 6),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Grade: ${_answerScore!['grade'] ?? 'B'}', style: AppTypography.titleMedium),
                  Text('Score: ${_answerScore!['score']}%', style: AppTypography.bodySmall),
                ]),
              ]),
              const SizedBox(height: 16),
              if ((_answerScore!['strengths'] as List?)?.isNotEmpty == true) ...[
                Text('Strengths:', style: AppTypography.labelMedium.copyWith(color: AppColors.success)),
                ...(_answerScore!['strengths'] as List).map((s) => Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.check_circle, size: 14, color: AppColors.success), const SizedBox(width: 6), Expanded(child: Text(s.toString(), style: AppTypography.bodySmall))]))),
                const SizedBox(height: 10),
              ],
              if ((_answerScore!['improvements'] as List?)?.isNotEmpty == true) ...[
                Text('Improvements:', style: AppTypography.labelMedium.copyWith(color: AppColors.warning)),
                ...(_answerScore!['improvements'] as List).map((s) => Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.tips_and_updates_outlined, size: 14, color: AppColors.warning), const SizedBox(width: 6), Expanded(child: Text(s.toString(), style: AppTypography.bodySmall))]))),
              ],
            ]),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() { _answerScore = null; _answerController.clear(); }), child: const Text('Retry'))),
            const SizedBox(width: 12),
            Expanded(child: GradientButton(
              text: isLast ? 'Finish' : 'Next Question',
              onPressed: () => setState(() {
                if (!isLast) { _currentMockQ++; _answerScore = null; _answerController.clear(); }
                else { _inMockInterview = false; }
              }),
              gradient: AppColors.primaryGradient,
            )),
          ]),
        ],
        const SizedBox(height: 32),
      ]),
    );
  }
}
