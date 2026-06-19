enum ResumeStatus { draft, complete, archived }

class ResumeEntity {
  final String id;
  final String userId;
  final String title;
  final PersonalInfo personalInfo;
  final String professionalSummary;
  final List<WorkExperience> workExperiences;
  final List<Education> educations;
  final SkillsSection skills;
  final List<Project> projects;
  final List<Certification> certifications;
  final List<Award> awards;
  final List<VolunteerExperience> volunteerExperiences;
  final List<Reference> references;
  final String templateId;
  final ResumeStatus status;
  final int atsScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final String? publicUrl;

  const ResumeEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.personalInfo,
    this.professionalSummary = '',
    this.workExperiences = const [],
    this.educations = const [],
    required this.skills,
    this.projects = const [],
    this.certifications = const [],
    this.awards = const [],
    this.volunteerExperiences = const [],
    this.references = const [],
    this.templateId = 'classic_ats',
    this.status = ResumeStatus.draft,
    this.atsScore = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.publicUrl,
  });

  int get completionPercentage {
    int score = 0;
    int total = 7;
    if (personalInfo.firstName.isNotEmpty) score++;
    if (professionalSummary.isNotEmpty) score++;
    if (workExperiences.isNotEmpty) score++;
    if (educations.isNotEmpty) score++;
    if (skills.technicalSkills.isNotEmpty || skills.softSkills.isNotEmpty) score++;
    if (projects.isNotEmpty) score++;
    if (certifications.isNotEmpty) score++;
    return ((score / total) * 100).round();
  }

  ResumeEntity copyWith({
    String? id,
    String? userId,
    String? title,
    PersonalInfo? personalInfo,
    String? professionalSummary,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    SkillsSection? skills,
    List<Project>? projects,
    List<Certification>? certifications,
    List<Award>? awards,
    List<VolunteerExperience>? volunteerExperiences,
    List<Reference>? references,
    String? templateId,
    ResumeStatus? status,
    int? atsScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    String? publicUrl,
  }) {
    return ResumeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      personalInfo: personalInfo ?? this.personalInfo,
      professionalSummary: professionalSummary ?? this.professionalSummary,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      awards: awards ?? this.awards,
      volunteerExperiences: volunteerExperiences ?? this.volunteerExperiences,
      references: references ?? this.references,
      templateId: templateId ?? this.templateId,
      status: status ?? this.status,
      atsScore: atsScore ?? this.atsScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      publicUrl: publicUrl ?? this.publicUrl,
    );
  }
}

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String linkedIn;
  final String portfolio;
  final String website;
  final String github;
  final String profileImageUrl;
  final String jobTitle;

  const PersonalInfo({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.zipCode = '',
    this.linkedIn = '',
    this.portfolio = '',
    this.website = '',
    this.github = '',
    this.profileImageUrl = '',
    this.jobTitle = '',
  });

  String get fullName => '$firstName $lastName'.trim();

  PersonalInfo copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? linkedIn,
    String? portfolio,
    String? website,
    String? github,
    String? profileImageUrl,
    String? jobTitle,
  }) {
    return PersonalInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      linkedIn: linkedIn ?? this.linkedIn,
      portfolio: portfolio ?? this.portfolio,
      website: website ?? this.website,
      github: github ?? this.github,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }
}

class WorkExperience {
  final String id;
  final String company;
  final String position;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final List<String> responsibilities;
  final List<String> achievements;
  final String? companyLogoUrl;
  final String employmentType;

  const WorkExperience({
    required this.id,
    required this.company,
    required this.position,
    this.location = '',
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.responsibilities = const [],
    this.achievements = const [],
    this.companyLogoUrl,
    this.employmentType = 'Full-time',
  });

  WorkExperience copyWith({
    String? id,
    String? company,
    String? position,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    List<String>? responsibilities,
    List<String>? achievements,
    String? companyLogoUrl,
    String? employmentType,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      responsibilities: responsibilities ?? this.responsibilities,
      achievements: achievements ?? this.achievements,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      employmentType: employmentType ?? this.employmentType,
    );
  }
}

class Education {
  final String id;
  final String institution;
  final String degree;
  final String major;
  final String minor;
  final double? gpa;
  final double? maxGpa;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final List<String> achievements;
  final List<String> relevantCourses;

  const Education({
    required this.id,
    required this.institution,
    required this.degree,
    this.major = '',
    this.minor = '',
    this.gpa,
    this.maxGpa = 4.0,
    this.startDate,
    this.endDate,
    this.isOngoing = false,
    this.achievements = const [],
    this.relevantCourses = const [],
  });

  Education copyWith({
    String? id,
    String? institution,
    String? degree,
    String? major,
    String? minor,
    double? gpa,
    double? maxGpa,
    DateTime? startDate,
    DateTime? endDate,
    bool? isOngoing,
    List<String>? achievements,
    List<String>? relevantCourses,
  }) {
    return Education(
      id: id ?? this.id,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      major: major ?? this.major,
      minor: minor ?? this.minor,
      gpa: gpa ?? this.gpa,
      maxGpa: maxGpa ?? this.maxGpa,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isOngoing: isOngoing ?? this.isOngoing,
      achievements: achievements ?? this.achievements,
      relevantCourses: relevantCourses ?? this.relevantCourses,
    );
  }
}

class SkillsSection {
  final List<String> technicalSkills;
  final List<String> softSkills;
  final List<LanguageSkill> languages;
  final List<String> tools;
  final List<String> frameworks;
  final List<String> aiRecommended;

  const SkillsSection({
    this.technicalSkills = const [],
    this.softSkills = const [],
    this.languages = const [],
    this.tools = const [],
    this.frameworks = const [],
    this.aiRecommended = const [],
  });

  List<String> get allSkills => [
    ...technicalSkills,
    ...softSkills,
    ...tools,
    ...frameworks,
  ];

  SkillsSection copyWith({
    List<String>? technicalSkills,
    List<String>? softSkills,
    List<LanguageSkill>? languages,
    List<String>? tools,
    List<String>? frameworks,
    List<String>? aiRecommended,
  }) {
    return SkillsSection(
      technicalSkills: technicalSkills ?? this.technicalSkills,
      softSkills: softSkills ?? this.softSkills,
      languages: languages ?? this.languages,
      tools: tools ?? this.tools,
      frameworks: frameworks ?? this.frameworks,
      aiRecommended: aiRecommended ?? this.aiRecommended,
    );
  }
}

class LanguageSkill {
  final String language;
  final String proficiency;

  const LanguageSkill({required this.language, required this.proficiency});

  static const List<String> proficiencyLevels = [
    'Basic',
    'Conversational',
    'Professional',
    'Fluent',
    'Native',
  ];
}

class Project {
  final String id;
  final String name;
  final String description;
  final List<String> technologies;
  final String results;
  final String url;
  final String githubUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isOngoing;

  const Project({
    required this.id,
    required this.name,
    this.description = '',
    this.technologies = const [],
    this.results = '',
    this.url = '',
    this.githubUrl = '',
    this.startDate,
    this.endDate,
    this.isOngoing = false,
  });

  Project copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? technologies,
    String? results,
    String? url,
    String? githubUrl,
    DateTime? startDate,
    DateTime? endDate,
    bool? isOngoing,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      results: results ?? this.results,
      url: url ?? this.url,
      githubUrl: githubUrl ?? this.githubUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isOngoing: isOngoing ?? this.isOngoing,
    );
  }
}

class Certification {
  final String id;
  final String name;
  final String organization;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final bool doesNotExpire;
  final String credentialId;
  final String credentialUrl;

  const Certification({
    required this.id,
    required this.name,
    required this.organization,
    this.issueDate,
    this.expiryDate,
    this.doesNotExpire = false,
    this.credentialId = '',
    this.credentialUrl = '',
  });
}

class Award {
  final String id;
  final String title;
  final String organization;
  final DateTime? date;
  final String description;

  const Award({
    required this.id,
    required this.title,
    required this.organization,
    this.date,
    this.description = '',
  });
}

class VolunteerExperience {
  final String id;
  final String organization;
  final String role;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final String description;

  const VolunteerExperience({
    required this.id,
    required this.organization,
    required this.role,
    this.startDate,
    this.endDate,
    this.isOngoing = false,
    this.description = '',
  });
}

class Reference {
  final String id;
  final String name;
  final String position;
  final String company;
  final String email;
  final String phone;
  final String relationship;

  const Reference({
    required this.id,
    required this.name,
    required this.position,
    required this.company,
    this.email = '',
    this.phone = '',
    this.relationship = '',
  });
}

class AtsScore {
  final int overall;
  final int keywordScore;
  final int formattingScore;
  final int structureScore;
  final int readabilityScore;
  final int skillsScore;
  final List<AtsSuggestion> suggestions;
  final List<String> missingKeywords;
  final List<String> foundKeywords;
  final DateTime analyzedAt;

  const AtsScore({
    required this.overall,
    required this.keywordScore,
    required this.formattingScore,
    required this.structureScore,
    required this.readabilityScore,
    required this.skillsScore,
    this.suggestions = const [],
    this.missingKeywords = const [],
    this.foundKeywords = const [],
    required this.analyzedAt,
  });
}

class AtsSuggestion {
  final String title;
  final String description;
  final AtsSuggestionPriority priority;
  final AtsCategory category;

  const AtsSuggestion({
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
  });
}

enum AtsSuggestionPriority { critical, high, medium, low }
enum AtsCategory { keyword, formatting, structure, skill, readability }
