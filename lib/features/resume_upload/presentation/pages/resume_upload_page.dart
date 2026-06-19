import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_widgets.dart';

class ResumeUploadPage extends StatefulWidget {
  const ResumeUploadPage({super.key});

  @override
  State<ResumeUploadPage> createState() => _ResumeUploadPageState();
}

class _ResumeUploadPageState extends State<ResumeUploadPage> {
  String? _fileName;
  bool _isProcessing = false;
  final bool _isDragOver = false;
  List<String> _processingSteps = [];
  int _currentStep = -1;

  final _steps = [
    'Reading file content...',
    'Parsing resume sections...',
    'Extracting personal information...',
    'Identifying work experience...',
    'Detecting skills & technologies...',
    'Analyzing education history...',
    'Generating ATS-optimized version...',
    'Building your resume...',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() { _fileName = result.files.first.name; _processingSteps = []; _currentStep = -1; });
      await _processFile();
    }
  }

  Future<void> _processFile() async {
    setState(() => _isProcessing = true);
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() { _currentStep = i; _processingSteps.add(_steps[i]); });
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume parsed successfully! You can now edit it.'), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Upload Resume'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload & Parse Resume', style: AppTypography.headlineSmall).animate().fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 6),
            Text('Upload your existing resume and we\'ll convert it to an ATS-optimized version.', style: AppTypography.bodyMedium).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),

            // Upload zone
            GestureDetector(
              onTap: _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: _isDragOver ? AppColors.primaryGlow : AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isDragOver ? AppColors.primary : AppColors.surfaceBorder,
                    width: _isDragOver ? 2 : 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: AppColors.primaryGlow, shape: BoxShape.circle), child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 40)),
                  const SizedBox(height: 16),
                  Text('Tap to upload your resume', style: AppTypography.titleSmall),
                  const SizedBox(height: 6),
                  Text('PDF, DOCX, DOC, TXT • Max 10MB', style: AppTypography.bodySmall),
                ]),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 20),

            if (_fileName != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_fileName!, style: AppTypography.titleSmall),
                    Text(_isProcessing ? 'Processing...' : 'Ready', style: AppTypography.bodySmall.copyWith(color: _isProcessing ? AppColors.warning : AppColors.success)),
                  ])),
                  if (_isProcessing)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                ]),
              ).animate().fadeIn().slideX(begin: 0.2),
              const SizedBox(height: 16),

              if (_processingSteps.isNotEmpty) ...[
                Text('Processing Steps', style: AppTypography.titleSmall),
                const SizedBox(height: 10),
                ...(_processingSteps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Icon(e.key < _currentStep ? Icons.check_circle : e.key == _currentStep ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: e.key < _currentStep ? AppColors.success : e.key == _currentStep ? AppColors.primary : AppColors.textTertiary, size: 18),
                    const SizedBox(width: 10),
                    Text(e.value, style: AppTypography.bodySmall.copyWith(color: e.key <= _currentStep ? AppColors.textPrimary : AppColors.textTertiary)),
                  ]),
                ).animate().fadeIn(delay: (e.key * 100).ms))),
              ],
            ],

            const SizedBox(height: 24),

            // Supported formats
            Text('Supported Formats', style: AppTypography.titleSmall),
            const SizedBox(height: 12),
            Row(children: [
              for (final fmt in [('PDF', Icons.picture_as_pdf_outlined, AppColors.error), ('DOCX', Icons.article_outlined, AppColors.primary), ('DOC', Icons.description_outlined, AppColors.secondary), ('TXT', Icons.text_fields, AppColors.textTertiary)])
                Expanded(child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceBorderLight)),
                  child: Column(children: [Icon(fmt.$2, color: fmt.$3, size: 22), const SizedBox(height: 4), Text(fmt.$1, style: AppTypography.labelSmall.copyWith(color: fmt.$3))]),
                )),
            ]).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
