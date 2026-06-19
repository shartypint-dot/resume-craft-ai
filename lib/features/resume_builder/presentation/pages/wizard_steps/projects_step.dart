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

class ProjectsStep extends StatefulWidget {
  final VoidCallback onNext;
  const ProjectsStep({super.key, required this.onNext});
  @override
  State<ProjectsStep> createState() => _ProjectsStepState();
}

class _ProjectsStepState extends State<ProjectsStep> {
  bool _showForm = false;
  final _uuid = const Uuid();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _results = TextEditingController();
  final _url = TextEditingController();
  final _techInput = TextEditingController();
  List<String> _technologies = [];

  @override
  void dispose() {
    _name.dispose(); _description.dispose(); _results.dispose(); _url.dispose(); _techInput.dispose();
    super.dispose();
  }

  void _clearForm() {
    _name.clear(); _description.clear(); _results.clear(); _url.clear(); _techInput.clear();
    _technologies = [];
  }

  Future<void> _save() async {
    if (_name.text.isEmpty) return;
    final project = Project(
      id: _uuid.v4(), name: _name.text.trim(), description: _description.text.trim(),
      technologies: _technologies, results: _results.text.trim(), url: _url.text.trim(),
    );
    await context.read<ResumeProvider>().addProject(project);
    setState(() { _showForm = false; _clearForm(); });
  }

  @override
  Widget build(BuildContext context) {
    final projects = context.watch<ResumeProvider>().currentResume?.projects ?? [];
    if (_showForm) return _buildForm();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Projects', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 6),
        Text('Showcase your best work. Projects demonstrate practical skills.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),
        if (projects.isEmpty)
          EmptyState(title: 'No projects yet', description: 'Add personal, academic, or professional projects.', buttonText: 'Add Project', onButtonPressed: () => setState(() => _showForm = true))
        else ...[
          ...projects.asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.value.name, style: AppTypography.titleSmall),
              const SizedBox(height: 4),
              Text(e.value.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: e.value.technologies.take(4).map((t) => AppTag(label: t)).toList()),
            ]),
          ).animate().fadeIn(delay: (e.key * 100).ms).slideX(begin: 0.2)),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(onPressed: () => setState(() => _showForm = true), icon: const Icon(Icons.add), label: const Text('Add Project')).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('You can skip this section if you don\'t have relevant projects.', style: AppTypography.bodySmall, textAlign: TextAlign.center),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: () => setState(() { _showForm = false; _clearForm(); }), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.backgroundTertiary, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.surfaceBorderLight)), child: const Icon(Icons.arrow_back_ios_new, size: 14))),
          const SizedBox(width: 12),
          Text('Add Project', style: AppTypography.titleMedium),
        ]),
        const SizedBox(height: 24),
        _field(_name, 'Project Name *', Icons.folder_outlined),
        const SizedBox(height: 14),
        TextFormField(controller: _description, maxLines: 3, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined, size: 18), alignLabelWithHint: true)),
        const SizedBox(height: 14),
        // Technologies
        Row(children: [
          Expanded(child: TextFormField(controller: _techInput, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Technologies Used', prefixIcon: Icon(Icons.code, size: 18)), onFieldSubmitted: (v) { if (v.isNotEmpty) { setState(() { _technologies.add(v.trim()); _techInput.clear(); }); } })),
          IconButton(icon: const Icon(Icons.add_circle, color: AppColors.primary), onPressed: () { if (_techInput.text.isNotEmpty) { setState(() { _technologies.add(_techInput.text.trim()); _techInput.clear(); }); } }),
        ]),
        if (_technologies.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: _technologies.map((t) => AppTag(label: t, onDelete: () => setState(() => _technologies.remove(t)))).toList()),
        ],
        const SizedBox(height: 14),
        _field(_results, 'Key Results / Impact', Icons.trending_up),
        const SizedBox(height: 14),
        _field(_url, 'Project URL / GitHub Link', Icons.link, type: TextInputType.url),
        const SizedBox(height: 24),
        GradientButton(text: 'Save Project', onPressed: _save, gradient: AppColors.primaryGradient),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(controller: c, keyboardType: type, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18)));
  }
}
