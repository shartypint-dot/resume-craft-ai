enum AuthProvider { google, apple, linkedin, email }
enum SubscriptionTier { free, pro }
enum ExperienceLevel { student, freshGraduate, junior, midLevel, senior, lead, executive }

class UserEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? phoneNumber;
  final String profession;
  final ExperienceLevel experienceLevel;
  final String industry;
  final String careerGoal;
  final AuthProvider authProvider;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiry;
  final bool isEmailVerified;
  final bool isOnboardingComplete;
  final DateTime createdAt;
  final DateTime lastActive;
  final int resumesCreated;
  final int atsScansCount;
  final List<String> savedTemplates;
  final Map<String, dynamic> preferences;

  const UserEntity({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.photoUrl,
    this.phoneNumber,
    this.profession = '',
    this.experienceLevel = ExperienceLevel.junior,
    this.industry = '',
    this.careerGoal = '',
    this.authProvider = AuthProvider.email,
    this.subscriptionTier = SubscriptionTier.free,
    this.subscriptionExpiry,
    this.isEmailVerified = false,
    this.isOnboardingComplete = false,
    required this.createdAt,
    required this.lastActive,
    this.resumesCreated = 0,
    this.atsScansCount = 0,
    this.savedTemplates = const [],
    this.preferences = const {},
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isPro => subscriptionTier == SubscriptionTier.pro;
  bool get isSubscriptionActive =>
      isPro &&
      (subscriptionExpiry == null || subscriptionExpiry!.isAfter(DateTime.now()));

  UserEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phoneNumber,
    String? profession,
    ExperienceLevel? experienceLevel,
    String? industry,
    String? careerGoal,
    AuthProvider? authProvider,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiry,
    bool? isEmailVerified,
    bool? isOnboardingComplete,
    DateTime? createdAt,
    DateTime? lastActive,
    int? resumesCreated,
    int? atsScansCount,
    List<String>? savedTemplates,
    Map<String, dynamic>? preferences,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profession: profession ?? this.profession,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      industry: industry ?? this.industry,
      careerGoal: careerGoal ?? this.careerGoal,
      authProvider: authProvider ?? this.authProvider,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      resumesCreated: resumesCreated ?? this.resumesCreated,
      atsScansCount: atsScansCount ?? this.atsScansCount,
      savedTemplates: savedTemplates ?? this.savedTemplates,
      preferences: preferences ?? this.preferences,
    );
  }
}
