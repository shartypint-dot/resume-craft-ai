import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../providers/subscription_provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isYearly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger package load if not already done
      final sub = context.read<SubscriptionProvider>();
      if (sub.packages.isEmpty && !sub.isLoading) {
        sub.refresh();
      }
    });
  }

  Future<void> _purchase() async {
    final sub = context.read<SubscriptionProvider>();
    final package = _isYearly ? sub.annualPackage : sub.monthlyPackage;

    if (package == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Packages not available. Try again.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final result = await sub.purchase(package);

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome to ResumeCraft Pro!'), backgroundColor: AppColors.success),
      );
      context.pop();
    } else if (result.isCancelled) {
      // User cancelled — no message needed
    } else if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _restore() async {
    final sub = context.read<SubscriptionProvider>();
    final result = await sub.restore();

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase restored!'), backgroundColor: AppColors.success),
      );
      context.pop();
    } else if (result.isNoPurchasesFound) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No previous purchases found.'), backgroundColor: AppColors.warning),
      );
    } else if (result.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage!), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -100, left: -80,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.accentGold.withValues(alpha: 0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorderLight),
                        ),
                        child: const Icon(Icons.close, size: 18, color: AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(gradient: AppColors.premiumGradient, borderRadius: BorderRadius.circular(8)),
                      child: Text('LIMITED OFFER', style: AppTypography.tagStyle.copyWith(color: Colors.white)),
                    ),
                    const SizedBox(width: 40),
                  ]),
                  const SizedBox(height: 24),

                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.premiumGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: -5)],
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),

                  Text('Unlock Your Full Potential', style: AppTypography.headlineMedium.copyWith(height: 1.2), textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: 8),
                  Text('Join 50,000+ professionals building better careers with ResumeCraft Pro', style: AppTypography.bodyLarge, textAlign: TextAlign.center).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 24),

                  // Billing toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorderLight),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isYearly = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isYearly ? AppColors.backgroundCard : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Monthly', style: AppTypography.labelMedium.copyWith(color: !_isYearly ? AppColors.textPrimary : AppColors.textTertiary), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isYearly = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: _isYearly ? AppColors.premiumGradient : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('Yearly', style: AppTypography.labelMedium.copyWith(color: _isYearly ? Colors.white : AppColors.textTertiary)),
                              if (_isYearly) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                  child: Text('SAVE 50%', style: AppTypography.tagStyle.copyWith(color: Colors.white, fontSize: 9)),
                                ),
                              ],
                            ]),
                          ),
                        ),
                      ),
                    ]),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),

                  _buildPricingCard(sub),
                  const SizedBox(height: 20),
                  _buildFeaturesList(),
                  const SizedBox(height: 24),
                  _buildSocialProof(),
                  const SizedBox(height: 24),

                  GradientButton(
                    text: sub.isPurchasing
                        ? 'Processing...'
                        : (_isYearly ? 'Start 7-Day Free Trial' : 'Subscribe Monthly'),
                    onPressed: (sub.isPurchasing || sub.isLoading) ? null : _purchase,
                    gradient: AppColors.premiumGradient,
                    prefixIcon: sub.isPurchasing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  const SizedBox(height: 12),
                  Text('Cancel anytime • No commitment', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: sub.isRestoring ? null : _restore,
                    child: Text(
                      sub.isRestoring ? 'Restoring...' : 'Restore Purchases',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                  Text('Secure payment powered by Stripe & RevenueCat', style: AppTypography.caption, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(SubscriptionProvider sub) {
    final monthlyPkg = sub.monthlyPackage;
    final annualPkg = sub.annualPackage;
    final activePackage = _isYearly ? annualPkg : monthlyPkg;
    final priceStr = activePackage?.storeProduct.priceString ?? (_isYearly ? '\$59.99/yr' : '\$9.99/mo');

    return GlassCard(
      enableGlow: true,
      glowColor: AppColors.accentGold,
      borderColor: AppColors.accentGold.withValues(alpha: 0.4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isYearly ? 'Pro Yearly' : 'Pro Monthly', style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          Text(_isYearly ? 'Best value – save 50%' : 'Flexible monthly billing', style: AppTypography.bodySmall.copyWith(color: AppColors.accentGold)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (_isYearly)
            Text('\$119/yr', style: AppTypography.bodySmall.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textTertiary)),
          Text(priceStr, style: AppTypography.headlineMedium.copyWith(color: AppColors.accentGold, fontWeight: FontWeight.w800)),
          if (_isYearly)
            Text('\$5/month billed annually', style: AppTypography.caption),
        ]),
      ]),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFeaturesList() {
    final features = [
      ('Unlimited Resumes', AppColors.success),
      ('All 20 Premium Templates', AppColors.success),
      ('Full ATS Scanner & Reports', AppColors.primary),
      ('Cover Letter Generator', AppColors.primary),
      ('Job Description Matcher', AppColors.primary),
      ('Interview Preparation + Mock AI', AppColors.primary),
      ('AI Career Coach Chat', AppColors.secondary),
      ('No Watermarks on PDF Exports', AppColors.success),
      ('PDF & DOCX Export', AppColors.success),
      ('Portfolio Builder', AppColors.accentGold),
      ('Priority Support', AppColors.accentGold),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: Column(
        children: features.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Icon(Icons.check_circle, color: e.value.$2, size: 18),
            const SizedBox(width: 12),
            Text(e.value.$1, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
          ]),
        ).animate().fadeIn(delay: (600 + e.key * 40).ms).slideX(begin: 0.1)).toList(),
      ),
    );
  }

  Widget _buildSocialProof() {
    return Row(children: [
      Expanded(child: _statCard('50K+', 'Users')),
      const SizedBox(width: 12),
      Expanded(child: _statCard('4.8★', 'Rating')),
      const SizedBox(width: 12),
      Expanded(child: _statCard('85%', 'Interview Rate')),
    ]).animate().fadeIn(delay: 700.ms);
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorderLight),
      ),
      child: Column(children: [
        Text(value, style: AppTypography.headlineSmall.copyWith(color: AppColors.primary)),
        Text(label, style: AppTypography.labelSmall),
      ]),
    );
  }
}
