import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/resume_builder/domain/entities/resume_entity.dart';

class ResumePdfService {
  // Generate and return PDF bytes
  static Future<Uint8List> generatePdf({
    required ResumeEntity resume,
    required bool isPro,
    String templateId = 'modern_dark',
  }) async {
    final doc = pw.Document(
      title: '${resume.personalInfo.firstName} ${resume.personalInfo.lastName} - Resume',
      author: 'ResumeCraft AI',
    );

    // Load fonts
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();
    final italicFont = await PdfGoogleFonts.interItalic();
    final semiBoldFont = await PdfGoogleFonts.interMedium();

    final theme = _buildTheme(templateId, regularFont, boldFont);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: theme,
        ),
        build: (context) => [
          _buildHeader(resume, boldFont, regularFont, italicFont, templateId),
          pw.SizedBox(height: 16),
          if (resume.professionalSummary.isNotEmpty) ...[
            _buildSection('PROFESSIONAL SUMMARY', boldFont, templateId),
            _buildSummaryContent(resume.professionalSummary, regularFont),
            pw.SizedBox(height: 12),
          ],
          if (resume.workExperiences.isNotEmpty) ...[
            _buildSection('WORK EXPERIENCE', boldFont, templateId),
            ..._buildExperienceList(resume.workExperiences, boldFont, regularFont, italicFont, semiBoldFont),
            pw.SizedBox(height: 12),
          ],
          if (resume.educations.isNotEmpty) ...[
            _buildSection('EDUCATION', boldFont, templateId),
            ..._buildEducationList(resume.educations, boldFont, regularFont, italicFont),
            pw.SizedBox(height: 12),
          ],
          if (_hasSkills(resume.skills)) ...[
            _buildSection('SKILLS', boldFont, templateId),
            _buildSkillsContent(resume.skills, regularFont, boldFont, templateId),
            pw.SizedBox(height: 12),
          ],
          if (resume.projects.isNotEmpty) ...[
            _buildSection('PROJECTS', boldFont, templateId),
            ..._buildProjectList(resume.projects, boldFont, regularFont, italicFont),
            pw.SizedBox(height: 12),
          ],
          if (resume.certifications.isNotEmpty) ...[
            _buildSection('CERTIFICATIONS', boldFont, templateId),
            ..._buildCertificationList(resume.certifications, regularFont, boldFont),
            pw.SizedBox(height: 12),
          ],
          if (!isPro) _buildWatermark(regularFont),
        ],
      ),
    );

    return doc.save();
  }

  static pw.ThemeData _buildTheme(String templateId, pw.Font regular, pw.Font bold) {
    return pw.ThemeData.withFont(base: regular, bold: bold);
  }

  static pw.Widget _buildHeader(
    ResumeEntity resume,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font italicFont,
    String templateId,
  ) {
    final info = resume.personalInfo;
    final accentColor = _getAccentColor(templateId);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Name
        pw.Text(
          '${info.firstName} ${info.lastName}'.trim(),
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 28,
            color: PdfColors.grey900,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 4),

        // Job title
        if (info.jobTitle.isNotEmpty)
          pw.Text(
            info.jobTitle,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 14,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
        pw.SizedBox(height: 8),

        // Divider
        pw.Divider(color: accentColor, thickness: 2, height: 4),
        pw.SizedBox(height: 6),

        // Contact row
        pw.Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            if (info.email.isNotEmpty) _contactItem(info.email, regularFont),
            if (info.phone.isNotEmpty) _contactItem(info.phone, regularFont),
            if (info.city.isNotEmpty) _contactItem('${info.city}, ${info.country}'.trim(), regularFont),
            if (info.linkedIn.isNotEmpty) _contactItem(info.linkedIn, regularFont),
            if (info.github.isNotEmpty) _contactItem(info.github, regularFont),
            if (info.portfolio.isNotEmpty) _contactItem(info.portfolio, regularFont),
          ],
        ),
      ],
    );
  }

  static pw.Widget _contactItem(String text, pw.Font font) {
    return pw.Text(
      text,
      style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
    );
  }

  static pw.Widget _buildSection(String title, pw.Font boldFont, String templateId) {
    final accentColor = _getAccentColor(templateId);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(font: boldFont, fontSize: 11, color: accentColor, letterSpacing: 1.5),
        ),
        pw.Divider(color: accentColor, thickness: 0.5, height: 6),
        pw.SizedBox(height: 4),
      ],
    );
  }

  static pw.Widget _buildSummaryContent(String summary, pw.Font regular) {
    return pw.Text(
      summary,
      style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey800, lineSpacing: 2),
    );
  }

  static List<pw.Widget> _buildExperienceList(
    List<WorkExperience> experiences,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font italicFont,
    pw.Font semiBoldFont,
  ) {
    return experiences.map((exp) {
      final startStr = _formatDate(exp.startDate);
      final endStr = exp.isCurrent ? 'Present' : _formatDate(exp.endDate);

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  exp.position,
                  style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.grey900),
                ),
              ),
              pw.Text(
                '$startStr – $endStr',
                style: pw.TextStyle(font: italicFont, fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Text(
            exp.company + (exp.location.isNotEmpty ? ' | ${exp.location}' : ''),
            style: pw.TextStyle(font: italicFont, fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          if (exp.responsibilities.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: exp.responsibilities.map((r) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ', style: pw.TextStyle(font: regularFont, fontSize: 10)),
                    pw.Expanded(
                      child: pw.Text(
                        r,
                        style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.grey800, lineSpacing: 1.5),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          pw.SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  static List<pw.Widget> _buildEducationList(
    List<Education> educations,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font italicFont,
  ) {
    return educations.map((edu) {
      final startStr = _formatDate(edu.startDate);
      final endStr = edu.isOngoing ? 'Present' : _formatDate(edu.endDate);
      final degree = [edu.degree, edu.major].where((s) => s.isNotEmpty).join(' in ');

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  degree,
                  style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.grey900),
                ),
              ),
              pw.Text(
                '$startStr – $endStr',
                style: pw.TextStyle(font: italicFont, fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Text(
            edu.institution,
            style: pw.TextStyle(font: italicFont, fontSize: 10, color: PdfColors.grey700),
          ),
          if (edu.gpa != null && edu.gpa! > 0)
            pw.Text(
              'GPA: ${edu.gpa!.toStringAsFixed(2)} / ${(edu.maxGpa ?? 4.0).toStringAsFixed(1)}',
              style: pw.TextStyle(font: regularFont, fontSize: 9, color: PdfColors.grey600),
            ),
          pw.SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  static pw.Widget _buildSkillsContent(
    SkillsSection skills,
    pw.Font regular,
    pw.Font bold,
    String templateId,
  ) {
    final rows = <pw.Widget>[];
    if (skills.technicalSkills.isNotEmpty) rows.add(_skillRow('Technical', skills.technicalSkills, regular, bold, templateId));
    if (skills.softSkills.isNotEmpty) rows.add(_skillRow('Soft Skills', skills.softSkills, regular, bold, templateId));
    if (skills.tools.isNotEmpty) rows.add(_skillRow('Tools', skills.tools, regular, bold, templateId));
    if (skills.frameworks.isNotEmpty) rows.add(_skillRow('Frameworks', skills.frameworks, regular, bold, templateId));

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rows);
  }

  static pw.Widget _skillRow(String label, List<String> items, pw.Font regular, pw.Font bold, String templateId) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(font: bold, fontSize: 10, color: PdfColors.grey900),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              items.join(' • '),
              style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildProjectList(
    List<Project> projects,
    pw.Font boldFont,
    pw.Font regularFont,
    pw.Font italicFont,
  ) {
    return projects.map((proj) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(proj.name, style: pw.TextStyle(font: boldFont, fontSize: 11, color: PdfColors.grey900)),
              if (proj.url.isNotEmpty)
                pw.Text(proj.url, style: pw.TextStyle(font: italicFont, fontSize: 8, color: PdfColors.blue700)),
            ],
          ),
          if (proj.technologies.isNotEmpty)
            pw.Text(
              proj.technologies.join(' • '),
              style: pw.TextStyle(font: italicFont, fontSize: 9, color: PdfColors.grey600),
            ),
          if (proj.description.isNotEmpty)
            pw.Text(
              proj.description,
              style: pw.TextStyle(font: regularFont, fontSize: 10, color: PdfColors.grey800, lineSpacing: 1.5),
            ),
          if (proj.results.isNotEmpty)
            pw.Text(
              'Result: ${proj.results}',
              style: pw.TextStyle(font: regularFont, fontSize: 9, color: PdfColors.grey700, lineSpacing: 1.5),
            ),
          pw.SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  static List<pw.Widget> _buildCertificationList(
    List<Certification> certifications,
    pw.Font regularFont,
    pw.Font boldFont,
  ) {
    return certifications.map((cert) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(cert.name, style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.grey900)),
                  pw.Text(cert.organization, style: pw.TextStyle(font: regularFont, fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
            ),
            if (cert.issueDate != null)
              pw.Text(
                _formatDate(cert.issueDate),
                style: pw.TextStyle(font: regularFont, fontSize: 9, color: PdfColors.grey600),
              ),
          ],
        ),
      );
    }).toList();
  }

  static pw.Widget _buildWatermark(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Center(
        child: pw.Text(
          'Generated by ResumeCraft AI (Free) — Upgrade to Pro to remove watermark',
          style: pw.TextStyle(font: font, fontSize: 7, color: PdfColors.grey400),
        ),
      ),
    );
  }

  static bool _hasSkills(SkillsSection skills) {
    return skills.technicalSkills.isNotEmpty ||
        skills.softSkills.isNotEmpty ||
        skills.tools.isNotEmpty ||
        skills.frameworks.isNotEmpty;
  }

  static PdfColor _getAccentColor(String templateId) {
    switch (templateId) {
      case 'executive_navy': return PdfColors.indigo900;
      case 'creative_purple': return const PdfColor.fromInt(0xFF6C63FF);
      case 'minimal_green': return PdfColors.green700;
      case 'bold_red': return PdfColors.red800;
      case 'tech_blue': return PdfColors.blue800;
      case 'elegant_gold': return const PdfColor.fromInt(0xFFD4AF37);
      case 'startup_teal': return PdfColors.teal600;
      case 'academic_classic': return PdfColors.blueGrey800;
      default: return const PdfColor.fromInt(0xFF6C63FF);
    }
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Save to device
  static Future<String> savePdfToDevice(Uint8List bytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$filename.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  // Share/print via system share sheet
  static Future<void> printOrShare(Uint8List bytes, String title) async {
    await Printing.sharePdf(bytes: bytes, filename: '$title.pdf');
  }

  // Preview in native PDF viewer (useful for in-app preview)
  static Future<void> previewPdf(Uint8List bytes, String title) async {
    await Printing.layoutPdf(onLayout: (_) async => bytes, name: title);
  }
}
