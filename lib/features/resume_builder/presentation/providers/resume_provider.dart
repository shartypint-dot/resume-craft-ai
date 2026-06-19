import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/resume_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/ai/openai_service.dart';

enum ResumeLoadState { initial, loading, loaded, error }

class ResumeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final OpenAIService _aiService = OpenAIService();
  final _uuid = const Uuid();

  List<ResumeEntity> _resumes = [];
  ResumeEntity? _currentResume;
  ResumeLoadState _loadState = ResumeLoadState.initial;
  String? _errorMessage;
  bool _isGenerating = false;
  int _currentWizardStep = 0;

  List<ResumeEntity> get resumes => _resumes;
  ResumeEntity? get currentResume => _currentResume;
  ResumeLoadState get loadState => _loadState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadState == ResumeLoadState.loading;
  bool get isGenerating => _isGenerating;
  int get currentWizardStep => _currentWizardStep;

  String? get userId => _auth.currentUser?.uid;

  Future<void> loadResumes() async {
    if (userId == null) return;
    _loadState = ResumeLoadState.loading;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(AppConstants.resumesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      _resumes = snapshot.docs.map(_resumeFromFirestore).toList();
      _loadState = ResumeLoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _loadState = ResumeLoadState.error;
    }
    notifyListeners();
  }

  Future<ResumeEntity> createNewResume({String? title}) async {
    final uid = userId;
    if (uid == null) throw Exception('User not logged in');

    final now = DateTime.now();
    final resume = ResumeEntity(
      id: _uuid.v4(),
      userId: uid,
      title: title ?? 'My Resume ${_resumes.length + 1}',
      personalInfo: const PersonalInfo(),
      skills: const SkillsSection(),
      createdAt: now,
      updatedAt: now,
    );

    await _saveResumeToFirestore(resume);
    _currentResume = resume;
    _resumes.insert(0, resume);
    _currentWizardStep = 0;
    notifyListeners();
    return resume;
  }

  Future<void> loadResume(String resumeId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.resumesCollection)
          .doc(resumeId)
          .get();
      if (doc.exists) {
        _currentResume = _resumeFromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePersonalInfo(PersonalInfo info) async {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(
      personalInfo: info,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> updateProfessionalSummary(String summary) async {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(
      professionalSummary: summary,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> addWorkExperience(WorkExperience exp) async {
    if (_currentResume == null) return;
    final updated = [..._currentResume!.workExperiences, exp];
    _currentResume = _currentResume!.copyWith(
      workExperiences: updated,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> updateWorkExperience(WorkExperience exp) async {
    if (_currentResume == null) return;
    final updated = _currentResume!.workExperiences
        .map((e) => e.id == exp.id ? exp : e)
        .toList();
    _currentResume = _currentResume!.copyWith(
      workExperiences: updated,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> removeWorkExperience(String id) async {
    if (_currentResume == null) return;
    final updated = _currentResume!.workExperiences
        .where((e) => e.id != id)
        .toList();
    _currentResume = _currentResume!.copyWith(
      workExperiences: updated,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> addEducation(Education edu) async {
    if (_currentResume == null) return;
    final updated = [..._currentResume!.educations, edu];
    _currentResume = _currentResume!.copyWith(
      educations: updated,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> updateSkills(SkillsSection skills) async {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(
      skills: skills,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    if (_currentResume == null) return;
    final updated = [..._currentResume!.projects, project];
    _currentResume = _currentResume!.copyWith(
      projects: updated,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> addCertification(Certification cert) async {
    if (_currentResume == null) return;
    final updated = [..._currentResume!.certifications, cert];
    _currentResume = _currentResume!.copyWith(
      certifications: updated,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> updateTemplate(String templateId) async {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(
      templateId: templateId,
      updatedAt: DateTime.now(),
    );
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  Future<void> deleteResume(String resumeId) async {
    await _firestore
        .collection(AppConstants.resumesCollection)
        .doc(resumeId)
        .delete();
    _resumes.removeWhere((r) => r.id == resumeId);
    if (_currentResume?.id == resumeId) _currentResume = null;
    notifyListeners();
  }

  Future<void> duplicateResume(String resumeId) async {
    final original = _resumes.firstWhere((r) => r.id == resumeId);
    final now = DateTime.now();
    final copy = original.copyWith(
      id: _uuid.v4(),
      title: '${original.title} (Copy)',
      createdAt: now,
      updatedAt: now,
      atsScore: 0,
    );
    await _saveResumeToFirestore(copy);
    _resumes.insert(0, copy);
    notifyListeners();
  }

  // AI Operations
  Future<String> generateSummary({
    required String yearsExperience,
    required String industry,
    required String role,
    required List<String> achievements,
    required String careerGoal,
    String type = 'ats',
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final summary = await _aiService.generateProfessionalSummary(
        firstName: _currentResume?.personalInfo.firstName ?? '',
        jobTitle: role,
        yearsOfExperience: int.tryParse(yearsExperience) ?? 0,
        industry: industry,
        keyAchievements: achievements,
        careerGoal: careerGoal,
        summaryType: type,
      );
      return summary;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<List<String>> transformResponsibilities({
    required String position,
    required String company,
    required List<String> rawResponsibilities,
    required String industry,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      return await _aiService.transformResponsibilitiesToAts(
        position: position,
        company: company,
        rawResponsibilities: rawResponsibilities,
        industry: industry,
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<List<String>> getSkillRecommendations({
    required String jobTitle,
    required String industry,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final existing = _currentResume?.skills.allSkills ?? [];
      return await _aiService.recommendSkills(
        jobTitle: jobTitle,
        industry: industry,
        existingSkills: existing,
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> updateAtsScore(int score) async {
    if (_currentResume == null) return;
    _currentResume = _currentResume!.copyWith(atsScore: score);
    await _saveResumeToFirestore(_currentResume!);
    _syncToList();
    notifyListeners();
  }

  void setWizardStep(int step) {
    _currentWizardStep = step;
    notifyListeners();
  }

  void setCurrentResume(ResumeEntity? resume) {
    _currentResume = resume;
    notifyListeners();
  }

  Future<void> _saveResumeToFirestore(ResumeEntity resume) async {
    await _firestore
        .collection(AppConstants.resumesCollection)
        .doc(resume.id)
        .set(_resumeToFirestore(resume), SetOptions(merge: true));
  }

  void _syncToList() {
    if (_currentResume == null) return;
    final index = _resumes.indexWhere((r) => r.id == _currentResume!.id);
    if (index != -1) {
      _resumes[index] = _currentResume!;
    }
  }

  ResumeEntity _resumeFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    PersonalInfo parsePersonalInfo() {
      final pi = data['personalInfo'] as Map<String, dynamic>? ?? {};
      return PersonalInfo(
        firstName: pi['firstName'] ?? '',
        lastName: pi['lastName'] ?? '',
        email: pi['email'] ?? '',
        phone: pi['phone'] ?? '',
        city: pi['city'] ?? '',
        country: pi['country'] ?? '',
        linkedIn: pi['linkedIn'] ?? '',
        github: pi['github'] ?? '',
        portfolio: pi['portfolio'] ?? '',
        website: pi['website'] ?? '',
        jobTitle: pi['jobTitle'] ?? '',
        profileImageUrl: pi['profileImageUrl'] ?? '',
      );
    }

    List<WorkExperience> parseExperiences() {
      final list = data['workExperiences'] as List? ?? [];
      return list.map((e) {
        final exp = e as Map<String, dynamic>;
        return WorkExperience(
          id: exp['id'] ?? _uuid.v4(),
          company: exp['company'] ?? '',
          position: exp['position'] ?? '',
          location: exp['location'] ?? '',
          isCurrent: exp['isCurrent'] ?? false,
          responsibilities: List<String>.from(exp['responsibilities'] ?? []),
          achievements: List<String>.from(exp['achievements'] ?? []),
          startDate: (exp['startDate'] as Timestamp?)?.toDate(),
          endDate: (exp['endDate'] as Timestamp?)?.toDate(),
          employmentType: exp['employmentType'] ?? 'Full-time',
        );
      }).toList();
    }

    List<Education> parseEducation() {
      final list = data['educations'] as List? ?? [];
      return list.map((e) {
        final edu = e as Map<String, dynamic>;
        return Education(
          id: edu['id'] ?? _uuid.v4(),
          institution: edu['institution'] ?? '',
          degree: edu['degree'] ?? '',
          major: edu['major'] ?? '',
          gpa: (edu['gpa'] as num?)?.toDouble(),
          isOngoing: edu['isOngoing'] ?? false,
          startDate: (edu['startDate'] as Timestamp?)?.toDate(),
          endDate: (edu['endDate'] as Timestamp?)?.toDate(),
        );
      }).toList();
    }

    SkillsSection parseSkills() {
      final s = data['skills'] as Map<String, dynamic>? ?? {};
      return SkillsSection(
        technicalSkills: List<String>.from(s['technicalSkills'] ?? []),
        softSkills: List<String>.from(s['softSkills'] ?? []),
        tools: List<String>.from(s['tools'] ?? []),
        frameworks: List<String>.from(s['frameworks'] ?? []),
      );
    }

    return ResumeEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Resume',
      personalInfo: parsePersonalInfo(),
      professionalSummary: data['professionalSummary'] ?? '',
      workExperiences: parseExperiences(),
      educations: parseEducation(),
      skills: parseSkills(),
      projects: [],
      certifications: [],
      templateId: data['templateId'] ?? 'classic_ats',
      atsScore: data['atsScore'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublic: data['isPublic'] ?? false,
      publicUrl: data['publicUrl'],
    );
  }

  Map<String, dynamic> _resumeToFirestore(ResumeEntity resume) {
    return {
      'userId': resume.userId,
      'title': resume.title,
      'personalInfo': {
        'firstName': resume.personalInfo.firstName,
        'lastName': resume.personalInfo.lastName,
        'email': resume.personalInfo.email,
        'phone': resume.personalInfo.phone,
        'city': resume.personalInfo.city,
        'country': resume.personalInfo.country,
        'linkedIn': resume.personalInfo.linkedIn,
        'github': resume.personalInfo.github,
        'portfolio': resume.personalInfo.portfolio,
        'website': resume.personalInfo.website,
        'jobTitle': resume.personalInfo.jobTitle,
        'profileImageUrl': resume.personalInfo.profileImageUrl,
      },
      'professionalSummary': resume.professionalSummary,
      'workExperiences': resume.workExperiences
          .map((e) => {
                'id': e.id,
                'company': e.company,
                'position': e.position,
                'location': e.location,
                'isCurrent': e.isCurrent,
                'responsibilities': e.responsibilities,
                'achievements': e.achievements,
                'startDate': e.startDate != null
                    ? Timestamp.fromDate(e.startDate!)
                    : null,
                'endDate':
                    e.endDate != null ? Timestamp.fromDate(e.endDate!) : null,
                'employmentType': e.employmentType,
              })
          .toList(),
      'educations': resume.educations
          .map((e) => {
                'id': e.id,
                'institution': e.institution,
                'degree': e.degree,
                'major': e.major,
                'gpa': e.gpa,
                'isOngoing': e.isOngoing,
                'startDate': e.startDate != null
                    ? Timestamp.fromDate(e.startDate!)
                    : null,
                'endDate':
                    e.endDate != null ? Timestamp.fromDate(e.endDate!) : null,
              })
          .toList(),
      'skills': {
        'technicalSkills': resume.skills.technicalSkills,
        'softSkills': resume.skills.softSkills,
        'tools': resume.skills.tools,
        'frameworks': resume.skills.frameworks,
      },
      'templateId': resume.templateId,
      'atsScore': resume.atsScore,
      'status': resume.status.name,
      'isPublic': resume.isPublic,
      'publicUrl': resume.publicUrl,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': Timestamp.fromDate(resume.createdAt),
    };
  }
}
