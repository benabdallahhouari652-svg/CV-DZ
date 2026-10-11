import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class PdfGeneratorService {
  static Future<Uint8List> generateCvPdf(UserCVData cv) async {
    final pdf = pw.Document();

    // Multilingual font loading
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();
    final latinFont = await PdfGoogleFonts.poppinsRegular();
    final latinBoldFont = await PdfGoogleFonts.poppinsBold();

    final isArabic = cv.targetLanguage == AppLanguage.ar;
    final primaryFont = isArabic ? arabicFont : latinFont;
    final primaryBoldFont = isArabic ? arabicBoldFont : latinBoldFont;
    final textDirection = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    // Dynamic Color Schemes based on chosen template
    PdfColor primaryColor;
    PdfColor accentColor;

    switch (cv.templateId) {
      case 'ruby_prestige':
        primaryColor = PdfColor.fromHex('#9B111E'); // Royal Algerian Ruby
        accentColor = PdfColor.fromHex('#D4AF37'); // Gold
        break;
      case 'executive_navy':
        primaryColor = PdfColor.fromHex('#1A365D');
        accentColor = PdfColor.fromHex('#D69E2E');
        break;
      case 'minimalist_dark':
        primaryColor = PdfColor.fromHex('#212529');
        accentColor = PdfColor.fromHex('#495057');
        break;
      case 'modern_emerald':
      default:
        primaryColor = PdfColor.fromHex('#0D5C3A'); // Algerian Deep Emerald
        accentColor = PdfColor.fromHex('#C53030'); // Algerian Red
        break;
    }

    final lightBg = PdfColor.fromHex('#F8F9FA');
    final textColor = PdfColor.fromHex('#2D3748');
    final subtleTextColor = PdfColor.fromHex('#718096');

    pw.ImageProvider? userImage;
    if (cv.photoBytes != null && cv.photoBytes!.isNotEmpty) {
      userImage = pw.MemoryImage(cv.photoBytes!);
    }

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
              : 'Skills & Tools',
      'languages': isArabic
          ? 'اللغات'
          : cv.targetLanguage == AppLanguage.fr
              ? 'Langues'
              : 'Languages',
    };

    // QR Code generation target (LinkedIn or Portfolio)
    final qrTarget = cv.linkedinUrl.isNotEmpty
        ? cv.linkedinUrl
        : cv.githubOrPortfolioUrl.isNotEmpty
            ? cv.githubOrPortfolioUrl
            : 'https://cv-dz-fawn.vercel.app';

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
              // HEADER BANNER WITH QR CODE
              pw.Container(
                color: primaryColor,
                padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 26),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (userImage != null) ...[
                      pw.Container(
                        width: 88,
                        height: 88,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.white, width: 3),
                          image: pw.DecorationImage(
                            image: userImage,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 20),
                    ],
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            cv.fullName,
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              font: primaryBoldFont,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            cv.jobTitle,
                            style: pw.TextStyle(
                              fontSize: 13,
                              color: PdfColor.fromHex('#E2E8F0'),
                              font: primaryFont,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Wrap(
                            spacing: 14,
                            runSpacing: 4,
                            children: [
                              if (cv.phone.isNotEmpty)
                                pw.Text(
                                  cv.phone,
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 9.5),
                                ),
                              if (cv.email.isNotEmpty)
                                pw.Text(
                                  cv.email,
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 9.5),
                                ),
                              if (cv.address.isNotEmpty)
                                pw.Text(
                                  cv.address,
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 9.5),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Live Interactive Barcode / QR Code
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: qrTarget,
                        width: 52,
                        height: 52,
                      ),
                    ),
                  ],
                ),
              ),

              // MAIN CONTENT BODY
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // LEFT / PRIMARY COLUMN
                      pw.Expanded(
                        flex: 66,
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
                                  fontSize: 10,
                                  color: textColor,
                                  lineSpacing: 1.8,
                                ),
                              ),
                              pw.SizedBox(height: 16),
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
                                              fontSize: 10.5,
                                              color: textColor,
                                            ),
                                          ),
                                          pw.Text(
                                            exp.period,
                                            style: pw.TextStyle(
                                              fontSize: 9,
                                              color: subtleTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pw.Text(
                                        exp.company,
                                        style: pw.TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: pw.FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      if (exp.description.isNotEmpty) ...[
                                        pw.SizedBox(height: 3),
                                        pw.Text(
                                          exp.description,
                                          style: pw.TextStyle(
                                            fontSize: 9,
                                            color: textColor,
                                            lineSpacing: 1.4,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                              pw.SizedBox(height: 8),
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
                                              fontSize: 10,
                                              color: textColor,
                                            ),
                                          ),
                                          pw.Text(
                                            edu.year,
                                            style: pw.TextStyle(
                                              fontSize: 9,
                                              color: subtleTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      pw.Text(
                                        edu.institution,
                                        style: pw.TextStyle(
                                          fontSize: 9,
                                          color: primaryColor,
                                        ),
                                      ),
                                      if (edu.details.isNotEmpty) ...[
                                        pw.SizedBox(height: 2),
                                        pw.Text(
                                          edu.details,
                                          style: pw.TextStyle(
                                            fontSize: 8.5,
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

                      pw.SizedBox(width: 20),

                      // RIGHT / SIDEBAR COLUMN
                      pw.Expanded(
                        flex: 34,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(12),
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
                                  margin: const pw.EdgeInsets.only(bottom: 5),
                                  child: pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 4,
                                        height: 4,
                                        decoration: pw.BoxDecoration(
                                          color: accentColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                      ),
                                      pw.SizedBox(width: 6),
                                      pw.Expanded(
                                        child: pw.Text(
                                          skill,
                                          style: pw.TextStyle(fontSize: 9, color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              pw.SizedBox(height: 16),

                              // Languages Section
                              _buildSectionTitle(titles['languages']!, primaryColor, primaryBoldFont),
                              pw.SizedBox(height: 8),
                              ...cv.spokenLanguages.map(
                                (lang) => pw.Container(
                                  margin: const pw.EdgeInsets.only(bottom: 5),
                                  child: pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 4,
                                        height: 4,
                                        decoration: pw.BoxDecoration(
                                          color: primaryColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                      ),
                                      pw.SizedBox(width: 6),
                                      pw.Expanded(
                                        child: pw.Text(
                                          lang,
                                          style: pw.TextStyle(fontSize: 9, color: textColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (cv.linkedinUrl.isNotEmpty || cv.githubOrPortfolioUrl.isNotEmpty) ...[
                                pw.SizedBox(height: 14),
                                _buildSectionTitle('روابط مهنية', primaryColor, primaryBoldFont),
                                pw.SizedBox(height: 6),
                                if (cv.linkedinUrl.isNotEmpty)
                                  pw.Text(
                                    'LinkedIn Profile',
                                    style: pw.TextStyle(fontSize: 8.5, color: primaryColor, fontWeight: pw.FontWeight.bold),
                                  ),
                                if (cv.githubOrPortfolioUrl.isNotEmpty) ...[
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    'Portfolio / GitHub',
                                    style: pw.TextStyle(fontSize: 8.5, color: primaryColor, fontWeight: pw.FontWeight.bold),
                                  ),
                                ],
                              ],

                              pw.Spacer(),

                              // Official CV-DZ Stamp
                              pw.Center(
                                child: pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(color: subtleTextColor),
                                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                                  ),
                                  child: pw.Text(
                                    'Made with CV-DZ • ATS Certified',
                                    style: pw.TextStyle(
                                      fontSize: 7.5,
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
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: color,
            font: boldFont,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(
          width: 28,
          height: 1.5,
          color: color,
        ),
      ],
    );
  }
}
