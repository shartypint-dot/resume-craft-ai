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

class CertificationsStep extends StatefulWidget {
  final VoidCallback onNext;
  const CertificationsStep({super.key, required this.onNext});
  @override
  State<CertificationsStep> createState() => _CertificationsStepState();
}

class _CertificationsStepState extends State<CertificationsStep> {
  bool _showForm = false;
  final _uuid = const Uuid();
  final _name = TextEditingController();
  final _org = TextEditingController();
  final _credId = TextEditingController();
  final _url = TextEditingController();
  DateTime? _issueDate;
  bool _doesNotExpire = true;

  @override
  void dispose() {
    _name.dispose(); _org.dispose(); _credId.dispose(); _url.dispose();
    super.dispose();
  }

  void _clearForm() {
    _name.clear(); _org.clear(); _credId.clear(); _url.clear();
    _issueDate = null; _doesNotExpire = true;
  }

  Future<void> _save() async {
    if (_name.text.isEmpty) return;
    final cert = Certification(
      id: _uuid.v4(), name: _name.text.trim(), organization: _org.text.trim(),
      issueDate: _issueDate, doesNotExpire: _doesNotExpire,
      credentialId: _credId.text.trim(), credentialUrl: _url.text.trim(),
    );
    await context.read<ResumeProvider>().addCertification(cert);
    setState(() { _showForm = false; _clearForm(); });
  }

  @override
  Widget build(BuildContext context) {
    final certs = context.watch<ResumeProvider>().currentResume?.certifications ?? [];
    if (_showForm) return _buildForm();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Certifications', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 6),
        Text('Professional certifications increase your ATS score significantly.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 24),
        if (certs.isEmpty)
          EmptyState(title: 'No certifications yet', description: 'Add AWS, Google, Microsoft or other certifications.', buttonText: 'Add Certification', onButtonPressed: () => setState(() => _showForm = true))
        else ...[
          ...certs.asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
            child: Row(children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(gradient: AppColors.premiumGradient, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.verified, color: Colors.white, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value.name, style: AppTypography.titleSmall),
                Text(e.value.organization, style: AppTypography.bodySmall),
              ])),
            ]),
          ).animate().fadeIn(delay: (e.key * 100).ms).slideX(begin: 0.2)),
          const SizedBox(height: 16),
        ],
        OutlinedButton.icon(onPressed: () => setState(() => _showForm = true), icon: const Icon(Icons.add), label: const Text('Add Certification')).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.all(12), child: Text('You can skip this section if you don\'t have certifications.', style: AppTypography.bodySmall, textAlign: TextAlign.center)),
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
          Text('Add Certification', style: AppTypography.titleMedium),
        ]),
        const SizedBox(height: 24),
        _field(_name, 'Certification Name *', Icons.verified_outlined),
        const SizedBox(height: 14),
        _field(_org, 'Issuing Organization *', Icons.business_outlined),
        const SizedBox(height: 14),
        _field(_credId, 'Credential ID', Icons.tag),
        const SizedBox(height: 14),
        _field(_url, 'Credential URL', Icons.link, type: TextInputType.url),
        const SizedBox(height: 14),
        Row(children: [Checkbox(value: _doesNotExpire, onChanged: (v) => setState(() => _doesNotExpire = v ?? true)), Text('This credential does not expire', style: AppTypography.bodyMedium)]),
        const SizedBox(height: 24),
        GradientButton(text: 'Save Certification', onPressed: _save, gradient: AppColors.primaryGradient),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(controller: c, keyboardType: type, style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary), decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18)));
  }
}
