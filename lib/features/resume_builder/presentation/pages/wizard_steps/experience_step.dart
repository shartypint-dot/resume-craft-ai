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

class ExperienceStep extends StatefulWidget {
  final VoidCallback onNext;

  const ExperienceStep({super.key, required this.onNext});

  @override
  State<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends State<ExperienceStep> {
  bool _showForm = false;
  WorkExperience? _editingExp;
  final _uuid = const Uuid();

  // Form fields
  final _company = TextEditingController();
  final _position = TextEditingController();
  final _location = TextEditingController();
  final _respController = TextEditingController();
  List<String> _responsibilities = [];
  bool _isCurrent = false;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGeneratingBullets = false;
  String _employmentType = 'Full-time';

  @override
  void dispose() {
    _company.dispose();
    _position.dispose();
    _location.dispose();
    _respController.dispose();
    super.dispose();
  }

  void _startAdding() {
    _clearForm();
    setState(() {
      _showForm = true;
      _editingExp = null;
    });
  }

  void _editExperience(WorkExperience exp) {
    _company.text = exp.company;
    _position.text = exp.position;
    _location.text = exp.location;
    _responsibilities = List.from(exp.responsibilities);
    _isCurrent = exp.isCurrent;
    _startDate = exp.startDate;
    _endDate = exp.endDate;
    _employmentType = exp.employmentType;
    setState(() {
      _showForm = true;
      _editingExp = exp;
    });
  }

  void _clearForm() {
    _company.clear();
    _position.clear();
    _location.clear();
    _respController.clear();
    _responsibilities = [];
    _isCurrent = false;
    _startDate = null;
    _endDate = null;
    _employmentType = 'Full-time';
  }

  Future<void> _saveExperience() async {
    if (_company.text.isEmpty || _position.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company and position are required')),
      );
      return;
    }

    final exp = WorkExperience(
      id: _editingExp?.id ?? _uuid.v4(),
      company: _company.text.trim(),
      position: _position.text.trim(),
      location: _location.text.trim(),
      isCurrent: _isCurrent,
      startDate: _startDate,
      endDate: _isCurrent ? null : _endDate,
      responsibilities: _responsibilities,
      employmentType: _employmentType,
    );

    final provider = context.read<ResumeProvider>();
    if (_editingExp != null) {
      await provider.updateWorkExperience(exp);
    } else {
      await provider.addWorkExperience(exp);
    }

    setState(() => _showForm = false);
    _clearForm();
  }

  Future<void> _generateBullets() async {
    if (_position.text.isEmpty || _company.text.isEmpty) return;

    final rawResponsibilities = _respController.text
        .split('\n')
        .where((r) => r.trim().isNotEmpty)
        .toList();

    if (rawResponsibilities.isEmpty) {
      setState(() {
        _responsibilities.add('Add raw responsibilities in the text area first');
      });
      return;
    }

    setState(() => _isGeneratingBullets = true);
    try {
      final provider = context.read<ResumeProvider>();
      final bullets = await provider.transformResponsibilities(
        position: _position.text,
        company: _company.text,
        rawResponsibilities: rawResponsibilities,
        industry: 'Technology',
      );
      setState(() {
        _responsibilities = bullets;
        _respController.clear();
      });
    } finally {
      setState(() => _isGeneratingBullets = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResumeProvider>(
      builder: (context, provider, _) {
        final experiences = provider.currentResume?.workExperiences ?? [];

        if (_showForm) {
          return _buildForm();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Work Experience', style: AppTypography.headlineSmall)
                  .animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: 6),
              Text(
                'Add your work history, starting with the most recent.',
                style: AppTypography.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 24),

              if (experiences.isEmpty)
                EmptyState(
                  title: 'No experience added',
                  description: 'Add your work history to make your resume stronger.',
                  buttonText: 'Add Experience',
                  onButtonPressed: _startAdding,
                )
              else ...[
                ...experiences.asMap().entries.map((entry) {
                  final exp = entry.value;
                  return _buildExpCard(exp, entry.key);
                }),
                const SizedBox(height: 16),
              ],

              OutlinedButton.icon(
                onPressed: _startAdding,
                icon: const Icon(Icons.add),
                label: const Text('Add Work Experience'),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpCard(WorkExperience exp, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryGlow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.business, color: AppColors.primary, size: 22),
        ),
        title: Text(exp.position, style: AppTypography.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exp.company, style: AppTypography.bodySmall),
            Text(
              exp.isCurrent ? 'Present' : _formatDate(exp.endDate),
              style: AppTypography.caption,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _editExperience(exp),
              color: AppColors.textSecondary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () =>
                  context.read<ResumeProvider>().removeWorkExperience(exp.id),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms)
        .slideX(begin: 0.2);
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _showForm = false;
                  _clearForm();
                }),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorderLight),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 14),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _editingExp != null ? 'Edit Experience' : 'Add Experience',
                style: AppTypography.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildFormField(_company, 'Company Name *', Icons.business_outlined),
          const SizedBox(height: 14),
          _buildFormField(_position, 'Job Title / Position *', Icons.work_outline),
          const SizedBox(height: 14),
          _buildFormField(_location, 'Location (City, Country)', Icons.location_on_outlined),
          const SizedBox(height: 14),

          // Employment type
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _employmentType,
            decoration: const InputDecoration(
              labelText: 'Employment Type',
              prefixIcon: Icon(Icons.schedule_outlined, size: 18),
            ),
            dropdownColor: AppColors.backgroundCard,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            items: ['Full-time', 'Part-time', 'Contract', 'Freelance', 'Internship', 'Remote']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _employmentType = v!),
          ),
          const SizedBox(height: 14),

          // Date range
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Text(
                          _startDate != null
                              ? '${_startDate!.month}/${_startDate!.year}'
                              : 'Start Date',
                          style: AppTypography.bodyMedium.copyWith(
                            color: _startDate != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (!_isCurrent)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(isStart: false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Text(
                            _endDate != null
                                ? '${_endDate!.month}/${_endDate!.year}'
                                : 'End Date',
                            style: AppTypography.bodyMedium.copyWith(
                              color: _endDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Currently working here
          Row(
            children: [
              Checkbox(
                value: _isCurrent,
                onChanged: (v) => setState(() => _isCurrent = v ?? false),
              ),
              Text('I currently work here', style: AppTypography.bodyMedium),
            ],
          ),
          const SizedBox(height: 20),

          // Responsibilities section with AI
          Row(
            children: [
              Text('Responsibilities & Achievements', style: AppTypography.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enter raw responsibilities and let AI transform them into ATS-optimized bullet points.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _respController,
            maxLines: 5,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Managed social media accounts\nLed team of 5 developers\nBuilt customer dashboard...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingBullets ? null : _generateBullets,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundTertiary,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: _isGeneratingBullets
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.auto_fix_high, size: 18),
              label: Text(_isGeneratingBullets ? 'Transforming...' : 'Transform with AI'),
            ),
          ),
          const SizedBox(height: 14),

          // Generated bullets
          if (_responsibilities.isNotEmpty) ...[
            Text('AI-Generated Bullet Points', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorderLight),
              ),
              child: Column(
                children: _responsibilities.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.value, style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          )),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          onPressed: () => setState(() => _responsibilities.removeAt(e.key)),
                          color: AppColors.textTertiary,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 24),

          GradientButton(
            text: _editingExp != null ? 'Update Experience' : 'Save Experience',
            onPressed: _saveExperience,
            gradient: AppColors.primaryGradient,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}
