import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../features/resume_builder/domain/entities/resume_entity.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  final String _apiKey;

  OpenAIService({String? apiKey}) : _apiKey = apiKey ?? AppConstants.openAiApiKey;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  Future<String> _chatCompletion({
    required String systemPrompt,
    required String userMessage,
    String model = 'gpt-4o-mini',
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: _headers,
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
    }
  }

  Future<String> generateProfessionalSummary({
    required String firstName,
    required String jobTitle,
    required int yearsOfExperience,
    required String industry,
    required List<String> keyAchievements,
    required String careerGoal,
    String summaryType = 'ats',
  }) async {
    final prompt = '''
Generate a ${_getSummaryTypeDescription(summaryType)} professional summary for:
- Name: $firstName
- Job Title: $jobTitle
- Years of Experience: $yearsOfExperience
- Industry: $industry
- Key Achievements: ${keyAchievements.join(', ')}
- Career Goal: $careerGoal

Requirements:
- 3-4 sentences maximum
- Start with job title and years of experience
- Include 2-3 quantifiable achievements
- End with value proposition
- Use strong action verbs
- ATS-optimized with industry keywords
- Do NOT use "I" - write in third-person professional tone
- Return ONLY the summary text, no labels or formatting
''';

    return await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.6,
    );
  }

  String _getSummaryTypeDescription(String type) {
    switch (type) {
      case 'executive':
        return 'executive-level C-suite focused';
      case 'modern':
        return 'modern dynamic startup-style';
      default:
        return 'ATS-optimized';
    }
  }

  Future<List<String>> transformResponsibilitiesToAts({
    required String position,
    required String company,
    required List<String> rawResponsibilities,
    required String industry,
  }) async {
    final prompt = '''
Transform these job responsibilities into powerful ATS-optimized bullet points:

Position: $position at $company
Industry: $industry
Raw responsibilities: ${rawResponsibilities.join('\n- ')}

Rules:
1. Start each bullet with a strong action verb (Led, Developed, Increased, Reduced, etc.)
2. Quantify achievements where possible (%%, \$, hours, team size)
3. Use industry-specific keywords
4. Follow STAR method (Situation, Task, Action, Result)
5. Keep each bullet to 1-2 lines
6. Remove "Responsible for" and "Duties included"
7. Return ONLY the bullet points as a JSON array of strings
8. Generate ${rawResponsibilities.length} bullets

Return format: ["bullet 1", "bullet 2", ...]
''';

    final response = await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.5,
    );

    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> bullets = jsonDecode(jsonStr);
      return bullets.cast<String>();
    } catch (_) {
      return response
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => l.replaceAll(RegExp(r'^[-•*]\s*'), '').trim())
          .toList();
    }
  }

  Future<List<String>> recommendSkills({
    required String jobTitle,
    required String industry,
    required List<String> existingSkills,
    int count = 10,
  }) async {
    final prompt = '''
Recommend $count additional in-demand skills for:
Job Title: $jobTitle
Industry: $industry
Existing skills: ${existingSkills.join(', ')}

Return ONLY a JSON array of skill names, ordered by importance/demand.
Focus on: technical skills, certifications, tools, and frameworks.
Do not include skills the person already has.

Format: ["skill1", "skill2", ...]
''';

    final response = await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.4,
    );

    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> skills = jsonDecode(jsonStr);
      return skills.cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<String> generateCoverLetter({
    required String candidateName,
    required String jobTitle,
    required String companyName,
    required String industry,
    required String professionalSummary,
    required List<String> topSkills,
    required List<WorkExperience> experiences,
    String style = 'professional',
  }) async {
    final expSummary = experiences.take(2).map((e) =>
      '${e.position} at ${e.company}'
    ).join(', ');

    final prompt = '''
Write a $style cover letter for:
Candidate: $candidateName
Applying for: $jobTitle at $companyName
Industry: $industry
Background: $professionalSummary
Top Skills: ${topSkills.take(5).join(', ')}
Recent Experience: $expSummary

Requirements:
- 3 paragraphs: Opening (enthusiasm + fit), Body (achievements + value), Closing (call to action)
- Personalized to $companyName
- Mention 2-3 specific achievements
- Professional yet engaging tone
- Under 350 words
- Start with "Dear Hiring Manager," or specific name if available
- End with "Sincerely," followed by candidate name
- Return ONLY the letter text
''';

    return await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.7,
      maxTokens: 600,
    );
  }

  Future<String> enhanceAchievement({
    required String weakStatement,
    required String context,
  }) async {
    final prompt = '''
Transform this weak achievement statement into a powerful, quantified bullet point:

Weak: "$weakStatement"
Context: $context

Rules:
- Use the XYZ formula: "Accomplished X as measured by Y, by doing Z"
- Add specific metrics (%, numbers, time saved, revenue impact)
- Start with a strong action verb
- Keep under 2 lines
- Make it ATS-friendly
- Return ONLY the enhanced statement, no explanations
''';

    return await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.5,
    );
  }

  Future<Map<String, dynamic>> analyzeResumeForAts({
    required String resumeText,
    String? jobDescription,
  }) async {
    final prompt = '''
Analyze this resume for ATS compatibility and return a detailed JSON report:

Resume Text:
$resumeText

${jobDescription != null ? 'Target Job Description:\n$jobDescription' : ''}

Analyze and return JSON with this structure:
{
  "overall_score": <0-100>,
  "keyword_score": <0-100>,
  "formatting_score": <0-100>,
  "structure_score": <0-100>,
  "readability_score": <0-100>,
  "skills_score": <0-100>,
  "found_keywords": ["keyword1", "keyword2", ...],
  "missing_keywords": ["keyword1", "keyword2", ...],
  "suggestions": [
    {
      "title": "suggestion title",
      "description": "detailed explanation",
      "priority": "critical|high|medium|low",
      "category": "keyword|formatting|structure|skill|readability"
    }
  ],
  "strengths": ["strength1", "strength2", ...],
  "weaknesses": ["weakness1", "weakness2", ...]
}

Be thorough and specific. Return ONLY valid JSON.
''';

    final response = await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.3,
      maxTokens: 3000,
      model: 'gpt-4o',
    );

    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {
        'overall_score': 65,
        'keyword_score': 60,
        'formatting_score': 70,
        'structure_score': 65,
        'readability_score': 70,
        'skills_score': 60,
        'found_keywords': [],
        'missing_keywords': [],
        'suggestions': [],
        'strengths': [],
        'weaknesses': [],
      };
    }
  }

  Future<Map<String, dynamic>> matchResumeToJob({
    required String resumeText,
    required String jobDescription,
  }) async {
    final prompt = '''
Analyze the match between this resume and job description:

Resume: $resumeText

Job Description: $jobDescription

Return JSON:
{
  "match_score": <0-100>,
  "matched_keywords": ["kw1", "kw2", ...],
  "missing_keywords": ["kw1", "kw2", ...],
  "matched_skills": ["skill1", ...],
  "missing_skills": ["skill1", ...],
  "matched_qualifications": ["qual1", ...],
  "missing_qualifications": ["qual1", ...],
  "recommendations": [
    {"action": "Add X keyword", "section": "Skills", "priority": "high"}
  ],
  "optimized_summary": "Rewritten summary optimized for this role"
}

Return ONLY valid JSON.
''';

    final response = await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.3,
      maxTokens: 2500,
      model: 'gpt-4o',
    );

    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {
        'match_score': 0,
        'matched_keywords': [],
        'missing_keywords': [],
        'matched_skills': [],
        'missing_skills': [],
        'recommendations': [],
      };
    }
  }

  Future<List<Map<String, dynamic>>> generateInterviewQuestions({
    required String jobTitle,
    required String industry,
    required String experienceLevel,
    String questionType = 'all',
    int count = 10,
  }) async {
    final prompt = '''
Generate $count interview questions for:
Job Title: $jobTitle
Industry: $industry
Experience Level: $experienceLevel
Type: ${questionType == 'all' ? 'HR, Behavioral, and Technical' : questionType}

Return JSON array:
[
  {
    "question": "question text",
    "type": "hr|behavioral|technical",
    "difficulty": "easy|medium|hard",
    "tips": "2-3 sentence tip for answering",
    "example_answer_structure": "brief structure guide"
  }
]

Make questions realistic and common in real interviews.
Return ONLY valid JSON array.
''';

    final response = await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.6,
      maxTokens: 3000,
    );

    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> questions = jsonDecode(jsonStr);
      return questions.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> scoreInterviewAnswer({
    required String question,
    required String answer,
    required String jobTitle,
  }) async {
    final prompt = '''
Score this interview answer for a $jobTitle position:

Question: $question
Answer: $answer

Return JSON:
{
  "score": <0-100>,
  "grade": "A|B|C|D|F",
  "strengths": ["strength1", "strength2"],
  "improvements": ["improvement1", "improvement2"],
  "model_answer_tips": "brief guidance for a better answer",
  "star_method_used": true/false
}

Be constructive and specific. Return ONLY valid JSON.
''';

    final response = await _chatCompletion(
      systemPrompt: 'You are an expert interview coach.',
      userMessage: prompt,
      temperature: 0.4,
    );

    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {'score': 70, 'grade': 'B', 'strengths': [], 'improvements': []};
    }
  }

  Stream<String> streamChatResponse({
    required String systemPrompt,
    required List<Map<String, String>> messages,
  }) async* {
    final request = http.Request(
      'POST',
      Uri.parse('$_baseUrl/chat/completions'),
    );
    request.headers.addAll(_headers);
    request.body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
      'stream': true,
      'temperature': 0.7,
      'max_tokens': 1000,
    });

    final client = http.Client();
    final response = await client.send(request);

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ') && line != 'data: [DONE]') {
          try {
            final json = jsonDecode(line.substring(6));
            final content = json['choices'][0]['delta']['content'];
            if (content != null) yield content as String;
          } catch (_) {}
        }
      }
    }
    client.close();
  }

  Future<String> rewriteProjectDescription({
    required String name,
    required String rawDescription,
    required List<String> technologies,
    required String results,
  }) async {
    final prompt = '''
Rewrite this project description professionally for a resume:

Project: $name
Technologies: ${technologies.join(', ')}
Raw Description: $rawDescription
Results: $results

Requirements:
- 2-3 concise bullet points
- Start each with action verb
- Highlight technical skills and impact
- Include measurable results if possible
- ATS-optimized
- Return as JSON array: ["bullet1", "bullet2", "bullet3"]
''';

    final response = await _chatCompletion(
      systemPrompt: AppConstants.systemPromptResume,
      userMessage: prompt,
      temperature: 0.5,
    );

    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> bullets = jsonDecode(jsonStr);
      return bullets.join('\n');
    } catch (_) {
      return response;
    }
  }
}
