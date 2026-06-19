import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/main_shell_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/resume_builder/presentation/pages/resume_builder_page.dart';
import '../../features/resume_builder/presentation/pages/resume_wizard_page.dart';
import '../../features/resume_builder/presentation/pages/resume_preview_page.dart';
import '../../features/resume_upload/presentation/pages/resume_upload_page.dart';
import '../../features/ats_scanner/presentation/pages/ats_scanner_page.dart';
import '../../features/job_matcher/presentation/pages/job_matcher_page.dart';
import '../../features/cover_letter/presentation/pages/cover_letter_page.dart';
import '../../features/interview_prep/presentation/pages/interview_prep_page.dart';
import '../../features/application_tracker/presentation/pages/application_tracker_page.dart';
import '../../features/ai_coach/presentation/pages/ai_coach_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/portfolio/presentation/pages/portfolio_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String resumeBuilder = '/resume-builder';
  static const String resumeWizard = '/resume-wizard';
  static const String resumePreview = '/resume-preview';
  static const String resumeUpload = '/resume-upload';
  static const String atsScanner = '/ats-scanner';
  static const String jobMatcher = '/job-matcher';
  static const String coverLetter = '/cover-letter';
  static const String interviewPrep = '/interview-prep';
  static const String applicationTracker = '/application-tracker';
  static const String aiCoach = '/ai-coach';
  static const String subscription = '/subscription';
  static const String settings = '/settings';
  static const String portfolio = '/portfolio';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isOnboarded = authProvider.isOnboarded;
      final location = state.matchedLocation;

      final authRoutes = [
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.otpVerification,
      ];

      if (location == AppRoutes.splash) return null;

      if (!isLoggedIn && !authRoutes.contains(location)) {
        return AppRoutes.welcome;
      }

      if (isLoggedIn && !isOnboarded && location != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      if (isLoggedIn && authRoutes.contains(location)) {
        return AppRoutes.home;
      }

      return null;
    },
    refreshListenable: authProvider,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) => OtpVerificationPage(
          email: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionPage(),
      ),
      GoRoute(
        path: AppRoutes.resumeWizard,
        builder: (context, state) => ResumeWizardPage(
          resumeId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.resumePreview,
        builder: (context, state) => ResumePreviewPage(
          resumeId: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.resumeUpload,
        builder: (context, state) => const ResumeUploadPage(),
      ),
      GoRoute(
        path: AppRoutes.atsScanner,
        builder: (context, state) => AtsScannerPage(
          resumeId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.jobMatcher,
        builder: (context, state) => JobMatcherPage(
          resumeId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: AppRoutes.coverLetter,
        builder: (context, state) => const CoverLetterPage(),
      ),
      GoRoute(
        path: AppRoutes.interviewPrep,
        builder: (context, state) => const InterviewPrepPage(),
      ),
      GoRoute(
        path: AppRoutes.applicationTracker,
        builder: (context, state) => const ApplicationTrackerPage(),
      ),
      GoRoute(
        path: AppRoutes.aiCoach,
        builder: (context, state) => const AiCoachPage(),
      ),
      GoRoute(
        path: AppRoutes.portfolio,
        builder: (context, state) => const PortfolioPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.resumeBuilder,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ResumeBuilderPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsPage(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
