import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/gradient_button.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../providers/resume_provider.dart';
import '../../../domain/entities/resume_entity.dart';

class EducationStep extends StatefulWidget {
  final VoidCallback onNext;
  const EducationStep({super.key, required this.onNext});
  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  bool _showForm = false;
  Education? _editingEdu;
  final _uuid = const Uuid();
  final _institution = TextEditingController();
  final _degree = TextEditingController();
  final _major = TextEditingController();
  final _gpa = TextEditingController();
  bool _isOngoing = false;
  DateTime? _startDate, _endDate;

  @override
  void dispose() {
    _institution.dispose(); _degree.dispose(); _major.dispose(); _gpa.dispose();
    super.dispose();
  }

  void _clearForm() {
    _institution.clear(); _degree.clear(); _major.clear(); _gpa.clear();
    _isOngoing = false; _startDate = null; _endDate = null; _editingEdu = null;
  }

  Future<void> _save() async {
    if (_institution.text.isEmpty || _degree.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Institution and degree are required')),
      );
      return;
    }
    final edu = Education(
      id: _editingEdu?.id ?? _uuid.v4(),
      institution: _institution.text.trim(),
      degree: _degree.text.trim(),
      major: _major.text.trim(),
      gpa: double.tryParse(_gpa.text),
      isOngoing: _isOngoing,
      startDate: _startDate,
      endDate: _isOngoing ? null : _endDate,
    );
    await context.read<ResumeProvider>().addEducation(edu);
    setState(() { _showForm = false; _clearForm(); });
  }

  @override
  Widget build(BuildContext context) {
    final educations = context.watch<ResumeProvider>().currentResume?.educations ?? [];
    if (_showForm) return _buildForm();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Education', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 6),
          Text('Add your academic qualifications.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          if (educations.isEmpty)
            EmptyState(title: 'No education added', description: 'Add your degrees and certifications.', buttonText: 'Add Education', onButtonPressed: () => setState(() => _showForm = true))
          else ...[
            ...educations.asMap().entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.school, color: AppColors.primary, size: 22)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.value.institution, style: AppTypography.titleSmall),
                  Text('${e.value.degree} • ${e.value.major}', style: AppTypography.bodySmall),
                  if (e.value.gpa != null) Text('GPA: ${e.value.gpa}', style: AppTypography.caption),
                ])),
              ]),
            ).animate().fadeIn(delay: (e.key * 100).ms).slideX(begin: 0.2)),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(onPressed: () => setState(() => _showForm = true), icon: const Icon(Icons.add), label: const Text('Add Education')).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => setState(() { _showForm = false; _clearForm(); }), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.surfaceBorderLight)), child: const Icon(Icons.arrow_back_ios_new, size: 14))),
          const SizedBox(width: 12),
          Text('Add Education', style: AppTypography.titleMedium),
        ]),
        const SizedBox(height: 24),
        _field(_institution, 'Institution Name *', Icons.school_outlined),
        const SizedBox(height: 14),
        _field(_degree, 'Degree *', Icons.workspace_premium_outlined),
        const SizedBox(height: 14),
        _field(_major, 'Field of Study / Major', Icons.book_outlined),
        const SizedBox(height: 14),
        _field(_gpa, 'GPA (optional)', Icons.grade_outlined, type: TextInputType.number),
        const SizedBox(height: 14),
        Row(children: [Checkbox(value: _isOngoing, onChanged: (v) => setState(() => _isOngoing = v ?? false)), Text('I\'m currently studying here', style: AppTypography.bodyMedium)]),
        const SizedBox(height: 24),
        GradientButton(text: 'Save Education', onPressed: _save, gradient: AppColors.primaryGradient),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(controller: c, keyboardType: type, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18)));
  }
}
