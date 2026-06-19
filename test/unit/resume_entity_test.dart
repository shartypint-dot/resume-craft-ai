import 'package:flutter_test/flutter_test.dart';
import 'package:resume_craft_ai/features/resume_builder/domain/entities/resume_entity.dart';

void main() {
  group('ResumeEntity', () {
    late ResumeEntity emptyResume;
    late ResumeEntity fullResume;

    setUp(() {
      emptyResume = ResumeEntity(
        id: 'empty-1',
        userId: 'user-1',
        title: 'Test Resume',
        personalInfo: const PersonalInfo(
          firstName: '', lastName: '', email: '', phone: '',
          address: '', city: '', state: '', country: '', zipCode: '',
          linkedIn: '', portfolio: '', website: '', github: '',
          profileImageUrl: '', jobTitle: '',
        ),
        professionalSummary: '',
        workExperiences: const [],
        educations: const [],
        skills: const SkillsSection(
          technicalSkills: [], softSkills: [],
          languages: [], tools: [], frameworks: [],
        ),
        projects: const [],
        certifications: const [],
        awards: const [],
        volunteerExperiences: const [],
        references: const [],
        templateId: 'classic_ats',
        status: ResumeStatus.draft,
        atsScore: 0,
        isPublic: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      fullResume = emptyResume.copyWith(
        personalInfo: const PersonalInfo(
          firstName: 'Jane', lastName: 'Doe', email: 'jane@example.com',
          phone: '+1234567890', address: '', city: 'SF', state: 'CA',
          country: 'US', zipCode: '', linkedIn: 'linkedin.com/in/janedoe',
          portfolio: '', website: '', github: '', profileImageUrl: '',
          jobTitle: 'Flutter Developer',
        ),
        professionalSummary: 'Experienced Flutter developer with 5 years.',
        workExperiences: [
          WorkExperience(
            id: 'w1', company: 'TechCorp', position: 'Senior Dev',
            location: 'Remote', startDate: DateTime(2020, 1, 1),
            endDate: null, isCurrent: true,
            responsibilities: ['Built apps', 'Led team'],
            achievements: ['Shipped 3 products'],
            companyLogoUrl: null, employmentType: 'Full-time',
          ),
        ],
        educations: [
          Education(
            id: 'e1', institution: 'MIT', degree: 'BS', major: 'CS',
            minor: '', gpa: 3.9, maxGpa: 4.0,
            startDate: DateTime(2014, 9, 1), endDate: DateTime(2018, 5, 1),
            isOngoing: false, achievements: [], relevantCourses: [],
          ),
        ],
        skills: const SkillsSection(
          technicalSkills: ['Flutter', 'Dart', 'Firebase'],
          softSkills: ['Leadership', 'Communication'],
          languages: [], tools: ['VS Code', 'Git'], frameworks: [],
        ),
        certifications: [
          Certification(
            id: 'c1', name: 'Google Associate Android Developer',
            organization: 'Google', issueDate: DateTime(2022, 1, 1),
            expiryDate: null, doesNotExpire: false,
            credentialId: 'ABC123', credentialUrl: '',
          ),
        ],
        atsScore: 88,
        status: ResumeStatus.complete,
      );
    });

    group('completionPercentage', () {
      test('empty resume has 0% completion', () {
        expect(emptyResume.completionPercentage, equals(0));
      });

      test('full resume has > 80% completion', () {
        expect(fullResume.completionPercentage, greaterThan(80));
      });

      test('partial resume returns proportional completion', () {
        final partial = emptyResume.copyWith(
          personalInfo: fullResume.personalInfo,
          professionalSummary: 'Some summary',
        );
        final pct = partial.completionPercentage;
        expect(pct, greaterThan(0));
        expect(pct, lessThan(100));
      });
    });

    group('copyWith', () {
      test('creates a new instance with changed fields', () {
        final updated = emptyResume.copyWith(title: 'Updated Title');
        expect(updated.title, equals('Updated Title'));
        expect(updated.id, equals(emptyResume.id));
      });

      test('original is unchanged after copyWith', () {
        final _ = emptyResume.copyWith(title: 'Updated Title');
        expect(emptyResume.title, equals('Test Resume'));
      });
    });

    group('PersonalInfo', () {
      test('fullName joins firstName and lastName', () {
        expect(fullResume.personalInfo.fullName, equals('Jane Doe'));
      });

      test('fullName handles empty lastName', () {
        const info = PersonalInfo(
          firstName: 'Jane', lastName: '', email: '', phone: '',
          address: '', city: '', state: '', country: '', zipCode: '',
          linkedIn: '', portfolio: '', website: '', github: '',
          profileImageUrl: '', jobTitle: '',
        );
        expect(info.fullName.trim(), equals('Jane'));
      });
    });

    group('SkillsSection', () {
      test('allSkills merges technical, soft, tools, frameworks', () {
        const skills = SkillsSection(
          technicalSkills: ['Flutter', 'Dart'],
          softSkills: ['Leadership'],
          languages: [],
          tools: ['Git'],
          frameworks: ['Provider'],
        );
        expect(skills.allSkills, containsAll(['Flutter', 'Dart', 'Leadership', 'Git', 'Provider']));
      });

      test('allSkills returns empty list when all empty', () {
        const empty = SkillsSection(
          technicalSkills: [], softSkills: [], languages: [], tools: [], frameworks: [],
        );
        expect(empty.allSkills, isEmpty);
      });
    });
  });
}
