class AppConstants {
  AppConstants._();

  static const String appName = 'ResumeCraft AI';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Build Your Dream Career';

  // API Keys (replace with actual keys via env)
  static const String openAiApiKey = String.fromEnvironment('here add open ai key ');
  static const String revenueCatApiKeyAndroid = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const String revenueCatApiKeyIos = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const String stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  // OpenAI Models
  static const String gpt4oModel = 'gpt-4o';
  static const String gpt4oMiniModel = 'gpt-4o-mini';
  static const String gpt35TurboModel = 'gpt-3.5-turbo';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String resumesCollection = 'resumes';
  static const String coverLettersCollection = 'cover_letters';
  static const String jobApplicationsCollection = 'job_applications';
  static const String templatesCollection = 'templates';
  static const String chatMessagesCollection = 'chat_messages';
  static const String subscriptionsCollection = 'subscriptions';
  static const String analyticsCollection = 'analytics';
  static const String portfoliosCollection = 'portfolios';

  // RevenueCat Products
  static const String proMonthlyId = 'resume_craft_pro_monthly';
  static const String proYearlyId = 'resume_craft_pro_yearly';
  static const String entitlementPro = 'pro';
  static const String revenueCatEntitlementId = 'pro';

  // Shared Preferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingComplete = 'onboarding_complete';
  static const String userToken = 'user_token';
  static const String themeMode = 'theme_mode';
  static const String lastResumeId = 'last_resume_id';

  // Hive Boxes
  static const String resumeBox = 'resumes_box';
  static const String userBox = 'user_box';
  static const String cacheBox = 'cache_box';

  // Limits
  static const int freeResumesLimit = 2;
  static const int freeTemplatesCount = 8;
  static const int maxImageSizeMb = 5;
  static const int maxFileSizeMb = 10;

  // Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration toastDuration = Duration(seconds: 3);

  // AI Prompts base
  static const String systemPromptResume = '''
You are an expert ATS resume writer and career coach with 15+ years of experience
helping professionals land jobs at Fortune 500 companies. You specialize in:
- Writing ATS-optimized resumes that pass automated screening systems
- Crafting compelling achievement-focused bullet points using the STAR method
- Identifying and incorporating relevant industry keywords
- Creating professional summaries that capture attention
- Quantifying accomplishments to demonstrate impact

Always write in first-person perspective (without using "I"), use active voice,
start bullet points with strong action verbs, quantify achievements when possible,
and ensure all content is ATS-friendly.
''';

  // ATS Scoring Weights
  static const double atsKeywordWeight = 0.35;
  static const double atsFormattingWeight = 0.25;
  static const double atsStructureWeight = 0.20;
  static const double atsReadabilityWeight = 0.10;
  static const double atsSkillsWeight = 0.10;

  // Template IDs
  static const List<String> freeTemplateIds = [
    'classic_ats',
    'modern_ats',
    'student',
    'minimal',
    'graduate',
    'corporate',
    'elegant',
    'professional',
  ];

  static const List<String> proTemplateIds = [
    'executive_premium',
    'luxury_black',
    'startup_modern',
    'silicon_valley',
    'product_manager',
    'data_scientist',
    'software_engineer',
    'creative_designer',
    'marketing_expert',
    'healthcare_professional',
    'international_cv',
    'elite_professional',
  ];

  // Supported file types for upload
  static const List<String> allowedFileExtensions = ['pdf', 'docx', 'doc', 'txt'];

  // Industries
  static const List<String> industries = [
    'Technology',
    'Finance & Banking',
    'Healthcare & Medical',
    'Education',
    'Marketing & Advertising',
    'Sales & Business Development',
    'Engineering',
    'Design & Creative',
    'Human Resources',
    'Legal',
    'Consulting',
    'Retail & E-commerce',
    'Manufacturing',
    'Real Estate',
    'Hospitality & Tourism',
    'Media & Entertainment',
    'Non-Profit',
    'Government & Public Sector',
    'Automotive',
    'Logistics & Supply Chain',
    'Other',
  ];

  // Experience Levels
  static const List<String> experienceLevels = [
    'Student',
    'Fresh Graduate (0-1 years)',
    'Junior (1-3 years)',
    'Mid-Level (3-6 years)',
    'Senior (6-10 years)',
    'Lead / Principal (10-15 years)',
    'Executive (15+ years)',
  ];

  // Career Goals
  static const List<String> careerGoals = [
    'Get my first job',
    'Switch careers',
    'Get a promotion',
    'Find a remote job',
    'Work at a top tech company',
    'Start a business',
    'Freelance / Contract work',
    'Work abroad / Relocate',
    'Executive role',
    'Academic / Research position',
  ];
}
