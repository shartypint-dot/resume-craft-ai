import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/gradient_button.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Portfolio Builder'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 80, height: 80, decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle), child: const Icon(Icons.web_outlined, color: Colors.white, size: 40)),
              const SizedBox(height: 24),
              Text('Portfolio Builder', style: AppTypography.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('Generate a beautiful personal portfolio website from your resume data.', style: AppTypography.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              GradientButton(text: 'Generate Portfolio (Pro)', onPressed: () {}, gradient: AppColors.primaryGradient),
            ],
          ),
        ),
      ),
    );
  }
}
