import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class PdfGeneratorService {
  static Future<Uint8List> generateCvPdf(UserCVData cv) async {
    final pdf = pw.Document();

    // Load appropriate fonts for Arabic and Multilingual support
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();
    final latinFont = await PdfGoogleFonts.poppinsRegular();
    final latinBoldFont = await PdfGoogleFonts.poppinsBold();

    final isArabic = cv.targetLanguage == AppLanguage.ar;
    final primaryFont = isArabic ? arabicFont : latinFont;
    final primaryBoldFont = isArabic ? arabicBoldFont : latinBoldFont;
    final textDirection = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    // Theme Colors
    final primaryColor = cv.templateId == 'modern_emerald'
        ? PdfColor.fromHex('#0D5C3A') // Algerian Deep Emerald
        : cv.templateId == 'executive_navy'
            ? PdfColor.fromHex('#1A365D')
            : PdfColor.fromHex('#2D3748');

    final accentColor = cv.templateId == 'modern_emerald'
        ? PdfColor.fromHex('#C53030') // Algerian Red Accent
        : PdfColor.fromHex('#D69E2E');

    final lightBg = PdfColor.fromHex('#F7FAFC');
    final textColor = PdfColor.fromHex('#2D3748');
    final subtleTextColor = PdfColor.fromHex('#718096');

    pw.ImageProvider? userImage;
    if (cv.photoBytes != null && cv.photoBytes!.isNotEmpty) {
      userImage = pw.MemoryImage(cv.photoBytes!);
    }

    // Section Titles based on language
    final titles = {
      'summary': isArabic
          ? 'نبذة مهنية'
          : cv.targetLanguage == AppLanguage.fr
              ? 'Profil Professionnel'
              : 'Professional Summary',
      'experience': isArabic
          ? 'الخبرات المهنية'
          : cv.targetLanguage == AppLanguage.fr
              ? 'Expériences Professionnelles'
              : 'Work Experience',
      'education': isArabic
          ? 'المؤهلات العلمية والدراسة'
          : cv.targetLanguage == AppLanguage.fr
              ? 'Formations & Diplômes'
              : 'Education',
      'skills': isArabic
          ? 'المهارات والتقنيات'
          : cv.targetLanguage == AppLanguage.fr
              ? 'Compétences'
              : 'Skills',
      'languages': isArabic
          ? 'اللغات'
          : cv.targetLanguage == AppLanguage.fr
              ? 'Langues'
              : 'Languages',
      'contact': isArabic
          ? 'معلومات الاتصال'
          : cv.targetLanguage == AppLanguage.fr
              ? 'Contact'
              : 'Contact Info',
    };

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        textDirection: textDirection,
        theme: pw.ThemeData.withFont(
          base: primaryFont,
          bold: primaryBoldFont,
        ),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // HEADER BANNER
              pw.Container(
                color: primaryColor,
                padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (userImage != null) ...[
                      pw.Container(
                        width: 90,
                        height: 90,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.white, width: 3),
                          image: pw.DecorationImage(
                            image: userImage,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 24),
                    ],
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: isArabic
                            ? pw.CrossAxisAlignment.start
                            : pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            cv.fullName,
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              font: primaryBoldFont,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            cv.jobTitle,
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColor.fromHex('#E2E8F0'),
                              font: primaryFont,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Wrap(
                            spacing: 16,
                            runSpacing: 6,
                            children: [
                              if (cv.phone.isNotEmpty)
                                pw.Text(
                                  cv.phone,
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                                ),
                              if (cv.email.isNotEmpty)
                                pw.Text(
                                  cv.email,
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                                ),
                              if (cv.address.isNotEmpty)
                                pw.Text(
                                  cv.address,
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 10),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BODY CONTENT
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // MAIN COLUMN (Summary, Experience, Education)
                      pw.Expanded(
                        flex: 65,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Summary Section
                            if (cv.summary.isNotEmpty) ...[
                              _buildSectionTitle(titles['summary']!, primaryColor, primaryBoldFont),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                cv.summary,
                                style: pw.TextStyle(
                                  fontSize: 10.5,
                                  color: textColor,
                                  lineSpacing: 2,
                                ),
                              ),
                              pw.SizedBox(height: 18),
                            ],

                            // Experience Section
                            if (cv.experiences.isNotEmpty) ...[
                              _buildSectionTitle(titles['experience']!, primaryColor, primaryBoldFont),
                              pw.SizedBox(height: 8),
                              ...cv.experiences.map((exp) {
                                return pw.Container(
                                  margin: const pw.EdgeInsets.only(bottom: 12),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text(
                                            exp.title,
                                            style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 11,
                                              color: textColor,
                                            ),
                                          ),
                                          pw.Text(
                                            exp.period,
                                            style: pw.TextStyle(
                                              fontSize: 9.5,
                                              color: subtleTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pw.Text(
                                        exp.company,
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      if (exp.description.isNotEmpty) ...[
                                        pw.SizedBox(height: 4),
                                        pw.Text(
                                          exp.description,
                                          style: pw.TextStyle(
                                            fontSize: 9.5,
                                            color: textColor,
                                            lineSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                              pw.SizedBox(height: 10),
                            ],

                            // Education Section
                            if (cv.educations.isNotEmpty) ...[
                              _buildSectionTitle(titles['education']!, primaryColor, primaryBoldFont),
                              pw.SizedBox(height: 8),
                              ...cv.educations.map((edu) {
                                return pw.Container(
                                  margin: const pw.EdgeInsets.only(bottom: 10),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text(
                                            edu.degree,
                                            style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,
                                              fontSize: 10.5,
                                              color: textColor,
                                            ),
                                          ),
                                          pw.Text(
                                            edu.year,
                                            style: pw.TextStyle(
                                              fontSize: 9.5,
                                              color: subtleTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pw.Text(
                                        edu.institution,
                                        style: pw.TextStyle(
                                          fontSize: 9.5,
                                          color: primaryColor,
                                        ),
                                      ),
                                      if (edu.details.isNotEmpty) ...[
                                        pw.SizedBox(height: 2),
                                        pw.Text(
                                          edu.details,
                                          style: pw.TextStyle(
                                            fontSize: 9,
                                            color: subtleTextColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),

                      pw.SizedBox(width: 24),

                      // SIDEBAR COLUMN (Skills, Languages, QR code badge)
                      pw.Expanded(
                        flex: 35,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(14),
                          decoration: pw.BoxDecoration(
                            color: lightBg,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Skills Section
                              _buildSectionTitle(titles['skills']!, primaryColor, primaryBoldFont),
                              pw.SizedBox(height: 8),
                              ...cv.skills.map(
                                (skill) => pw.Container(
                                  margin: const pw.EdgeInsets.only(bottom: 6),
                                  child: pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 5,
                                        height: 5,
                                        decoration: pw.BoxDecoration(
                                          color: accentColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                      ),
                                      pw.SizedBox(width: 6),
                                      pw.Expanded(
                                        child: pw.Text(
                                          skill,
                                          style: pw.TextStyle(fontSize: 9.5, color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              pw.SizedBox(height: 18),

                              // Languages Section
                              _buildSectionTitle(titles['languages']!, primaryColor, primaryBoldFont),
                              pw.SizedBox(height: 8),
                              ...cv.spokenLanguages.map(
                                (lang) => pw.Container(
                                  margin: const pw.EdgeInsets.only(bottom: 6),
                                  child: pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 5,
                                        height: 5,
                                        decoration: pw.BoxDecoration(
                                          color: primaryColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                      ),
                                      pw.SizedBox(width: 6),
                                      pw.Expanded(
                                        child: pw.Text(
                                          lang,
                                          style: pw.TextStyle(fontSize: 9.5, color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              pw.Spacer(),

                              // CV-DZ Badge / Stamp
                              pw.Center(
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(color: subtleTextColor),
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                  ),
                                  child: pw.Text(
                                    'Generated with CV-DZ',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      color: subtleTextColor,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color, pw.Font boldFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: color,
            font: boldFont,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(
          width: 32,
          height: 2,
          color: color,
        ),
      ],
    );
  }
}
