import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';

enum ApplicationStatus { saved, applied, assessment, interview, offer, rejected }

class JobApplication {
  final String id;
  final String jobTitle;
  final String company;
  final String location;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final String? salary;
  final String? notes;
  final String? jobUrl;

  const JobApplication({
    required this.id, required this.jobTitle, required this.company,
    required this.location, required this.status, required this.appliedDate,
    this.salary, this.notes, this.jobUrl,
  });
}

class ApplicationTrackerPage extends StatefulWidget {
  const ApplicationTrackerPage({super.key});

  @override
  State<ApplicationTrackerPage> createState() => _ApplicationTrackerPageState();
}

class _ApplicationTrackerPageState extends State<ApplicationTrackerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ApplicationStatus _selectedTab = ApplicationStatus.applied;

  final List<JobApplication> _applications = [
    JobApplication(id: '1', jobTitle: 'Senior Flutter Developer', company: 'Google', location: 'Remote', status: ApplicationStatus.interview, appliedDate: DateTime.now().subtract(const Duration(days: 5)), salary: '\$150K - \$200K'),
    JobApplication(id: '2', jobTitle: 'Product Manager', company: 'Meta', location: 'San Francisco', status: ApplicationStatus.applied, appliedDate: DateTime.now().subtract(const Duration(days: 2))),
    JobApplication(id: '3', jobTitle: 'Software Engineer', company: 'Apple', location: 'Cupertino', status: ApplicationStatus.assessment, appliedDate: DateTime.now().subtract(const Duration(days: 7))),
    JobApplication(id: '4', jobTitle: 'Lead Developer', company: 'Startup XYZ', location: 'New York', status: ApplicationStatus.offer, appliedDate: DateTime.now().subtract(const Duration(days: 14)), salary: '\$130K'),
    JobApplication(id: '5', jobTitle: 'Data Scientist', company: 'Netflix', location: 'Los Angeles', status: ApplicationStatus.rejected, appliedDate: DateTime.now().subtract(const Duration(days: 10))),
  ];

  final _statusConfig = {
    ApplicationStatus.saved: (Icons.bookmark_outline, 'Saved', AppColors.textSecondary),
    ApplicationStatus.applied: (Icons.send_outlined, 'Applied', AppColors.primary),
    ApplicationStatus.assessment: (Icons.quiz_outlined, 'Assessment', AppColors.secondary),
    ApplicationStatus.interview: (Icons.record_voice_over_outlined, 'Interview', AppColors.accentGold),
    ApplicationStatus.offer: (Icons.celebration_outlined, 'Offer', AppColors.success),
    ApplicationStatus.rejected: (Icons.cancel_outlined, 'Rejected', AppColors.error),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: ApplicationStatus.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<JobApplication> get _filteredApps => _applications.where((a) => a.status == _selectedTab).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Job Tracker',
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), onPressed: _showAddDialog),
        ],
      ),
      body: Column(
        children: [
          _buildStats(),
          _buildStatusTabs(),
          Expanded(
            child: _filteredApps.isEmpty
                ? EmptyState(title: 'No ${_statusConfig[_selectedTab]?.$2} jobs', description: 'Track your job applications here.', buttonText: 'Add Application', onButtonPressed: _showAddDialog)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, i) => _buildAppCard(_filteredApps[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final stats = [
      (_applications.length.toString(), 'Total', AppColors.primary),
      (_applications.where((a) => a.status == ApplicationStatus.interview).length.toString(), 'Interviews', AppColors.accentGold),
      (_applications.where((a) => a.status == ApplicationStatus.offer).length.toString(), 'Offers', AppColors.success),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: stats.map((s) => Expanded(child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.surfaceBorderLight)),
        child: Column(children: [Text(s.$1, style: AppTypography.titleLarge.copyWith(color: s.$3)), Text(s.$2, style: AppTypography.labelSmall)]),
      ))).toList()),
    );
  }

  Widget _buildStatusTabs() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: ApplicationStatus.values.length,
        itemBuilder: (context, i) {
          final status = ApplicationStatus.values[i];
          final config = _statusConfig[status]!;
          final isSelected = _selectedTab == status;
          final count = _applications.where((a) => a.status == status).length;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = status),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? config.$3.withValues(alpha: 0.15) : AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? config.$3.withValues(alpha: 0.4) : AppColors.surfaceBorderLight),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(config.$1, color: isSelected ? config.$3 : AppColors.textTertiary, size: 16),
                const SizedBox(width: 6),
                Text(config.$2, style: AppTypography.labelSmall.copyWith(color: isSelected ? config.$3 : AppColors.textTertiary)),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: config.$3, borderRadius: BorderRadius.circular(6)), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppCard(JobApplication app, int index) {
    final config = _statusConfig[app.status]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.surfaceBorderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(app.company[0], style: AppTypography.titleSmall.copyWith(color: Colors.white)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.jobTitle, style: AppTypography.titleSmall),
            Text('${app.company} • ${app.location}', style: AppTypography.bodySmall),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: config.$3.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(config.$1, color: config.$3, size: 12), const SizedBox(width: 4), Text(config.$2, style: AppTypography.tagStyle.copyWith(color: config.$3))])),
        ]),
        if (app.salary != null) ...[
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.attach_money, size: 14, color: AppColors.success), const SizedBox(width: 4), Text(app.salary!, style: AppTypography.bodySmall.copyWith(color: AppColors.success))]),
        ],
        const SizedBox(height: 8),
        Text('Applied ${_daysAgo(app.appliedDate)}', style: AppTypography.caption),
      ]),
    ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.1);
  }

  String _daysAgo(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add Job Application', style: AppTypography.titleLarge),
            const SizedBox(height: 20),
            GradientButton(text: 'Coming Soon — Add Manually', onPressed: () => Navigator.pop(context), gradient: AppColors.primaryGradient),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}
