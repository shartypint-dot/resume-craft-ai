import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/resume_provider.dart';

class PersonalInfoStep extends StatefulWidget {
  final VoidCallback onNext;

  const PersonalInfoStep({super.key, required this.onNext});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _email;
  late TextEditingController _phone;
  late TextEditingController _jobTitle;
  late TextEditingController _city;
  late TextEditingController _country;
  late TextEditingController _linkedIn;
  late TextEditingController _github;
  late TextEditingController _portfolio;
  late TextEditingController _website;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _jobTitle = TextEditingController();
    _city = TextEditingController();
    _country = TextEditingController();
    _linkedIn = TextEditingController();
    _github = TextEditingController();
    _portfolio = TextEditingController();
    _website = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final resume = context.read<ResumeProvider>().currentResume;
      if (resume != null) {
        final info = resume.personalInfo;
        _firstName.text = info.firstName;
        _lastName.text = info.lastName;
        _email.text = info.email;
        _phone.text = info.phone;
        _jobTitle.text = info.jobTitle;
        _city.text = info.city;
        _country.text = info.country;
        _linkedIn.text = info.linkedIn;
        _github.text = info.github;
        _portfolio.text = info.portfolio;
        _website.text = info.website;
      }
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _jobTitle.dispose();
    _city.dispose();
    _country.dispose();
    _linkedIn.dispose();
    _github.dispose();
    _portfolio.dispose();
    _website.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: AppTypography.headlineSmall,
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 6),
          Text(
            'This information will appear at the top of your resume.',
            style: AppTypography.bodyMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          // Profile Image placeholder
          Center(
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 44),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 14),
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),

          // Name row
          Row(
            children: [
              Expanded(child: _buildField(_firstName, 'First Name *', Icons.person_outline)),
              const SizedBox(width: 12),
              Expanded(child: _buildField(_lastName, 'Last Name *', Icons.person_outline)),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),

          _buildField(_jobTitle, 'Job Title / Current Role', Icons.work_outline)
              .animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _buildField(_email, 'Email *', Icons.email_outlined, type: TextInputType.emailAddress)),
              const SizedBox(width: 12),
              Expanded(child: _buildField(_phone, 'Phone', Icons.phone_outlined, type: TextInputType.phone)),
            ],
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _buildField(_city, 'City', Icons.location_city_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildField(_country, 'Country', Icons.flag_outlined)),
            ],
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),
          const SizedBox(height: 20),

          // Social/Online presence section
          Row(
            children: [
              const Icon(Icons.link, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('Online Presence', style: AppTypography.titleSmall),
              const SizedBox(width: 8),
              Text('(optional)', style: AppTypography.bodySmall),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 14),

          _buildField(_linkedIn, 'LinkedIn URL', Icons.business_center_outlined)
              .animate().fadeIn(delay: 420.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),

          _buildField(_github, 'GitHub URL', Icons.code)
              .animate().fadeIn(delay: 440.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),

          _buildField(_portfolio, 'Portfolio URL', Icons.web)
              .animate().fadeIn(delay: 460.ms).slideY(begin: 0.2),
          const SizedBox(height: 14),

          _buildField(_website, 'Personal Website', Icons.language)
              .animate().fadeIn(delay: 480.ms).slideY(begin: 0.2),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
      ),
    );
  }
}
