import 'dart:typed_data';

enum AppLanguage { ar, fr, en }

class EducationItem {
  String degree;
  String institution;
  String year;
  String details;

  EducationItem({
    required this.degree,
    required this.institution,
    required this.year,
    this.details = '',
  });

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'year': year,
        'details': details,
      };

  factory EducationItem.fromJson(Map<String, dynamic> json) => EducationItem(
        degree: json['degree'] ?? '',
        institution: json['institution'] ?? '',
        year: json['year'] ?? '',
        details: json['details'] ?? '',
      );
}

class ExperienceItem {
  String title;
  String company;
  String period;
  String description;

  ExperienceItem({
    required this.title,
    required this.company,
    required this.period,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'company': company,
        'period': period,
        'description': description,
      };

  factory ExperienceItem.fromJson(Map<String, dynamic> json) => ExperienceItem(
        title: json['title'] ?? '',
        company: json['company'] ?? '',
        period: json['period'] ?? '',
        description: json['description'] ?? '',
      );
}

class UserCVData {
  String fullName;
  String jobTitle;
  String email;
  String phone;
  String address;
  String linkedinUrl;
  String githubOrPortfolioUrl;
  String summary;
  Uint8List? photoBytes;

  List<String> skills;
  List<String> spokenLanguages;
  List<EducationItem> educations;
  List<ExperienceItem> experiences;

  AppLanguage targetLanguage;
  String templateId; // 'modern_emerald', 'executive_navy', 'ruby_prestige', 'minimalist_dark'
  String primaryColorHex; // customizable theme color

  UserCVData({
    this.fullName = 'هوارى بن عبد الله (Houari Benabdallah)',
    this.jobTitle = 'مدرب كرة قدم ومربٍ رياضي (Entraîneur de Football)',
    this.email = 'benabdallahhouari652@gmail.com',
    this.phone = '+213 555 00 00 00',
    this.address = 'الجزائر (Algérie)',
    this.linkedinUrl = 'https://www.linkedin.com/in/benabdallah-houari-18b77334b',
    this.githubOrPortfolioUrl = 'https://cv-dz-fawn.vercel.app',
    this.summary =
        'مدرب كرة قدم ذو كفاءة وشغف كبير في التكوين الرياضي وتطوير مهارات اللاعبين الفردية والجماعية. متخصص في التخطيط التكتيكي، الإعداد البدني، زرع عقلية الفوز والانضباط، واكتشاف وصقل المواهب الكروية الصاعدة.',
    this.photoBytes,
    List<String>? skills,
    List<String>? spokenLanguages,
    List<EducationItem>? educations,
    List<ExperienceItem>? experiences,
    this.targetLanguage = AppLanguage.ar,
    this.templateId = 'modern_emerald',
    this.primaryColorHex = '#0D5C3A',
  })  : skills = skills ??
            [
              'التكتيك واستراتيجيات اللعب الحديثة',
              'الإعداد البدني وتطوير اللياقة (Fitness)',
              'القيادة والتحفيز النفسي (Leadership)',
              'تكوين واكتشاف المواهب الشابة',
              'إدارة المباريات وتحليل الأداء الفني',
              'العمل الجماعي والروح الرياضية'
            ],
        spokenLanguages = spokenLanguages ??
            ['العربية (اللغة الأم)', 'الفرنسية (مستوى متقدم)', 'الإنجليزية (أساسية)'],
        educations = educations ??
            [
              EducationItem(
                degree: 'شهادة تدريب معتمدة في كرة القدم (Diplôme d\'Entraîneur)',
                institution: 'الاتحادية الجزائرية لكرة القدم (FAF / FAF-CAF)',
                year: '2021 - 2023',
                details: 'تكوين متخصص في منهجيات التدريب الحديث، الإعداد البدني، والتحليل التكتيكي.',
              ),
              EducationItem(
                degree: 'تكوين في التربية البدنية والرياضية',
                institution: 'معهد علوم وتقنيات الأنشطة البدنية والرياضية',
                year: '2018 - 2021',
              ),
            ],
        experiences = experiences ??
            [
              ExperienceItem(
                title: 'مدرب كرة قدم (Entraîneur Principal)',
                company: 'نادي وأكاديمية كرة القدم - الجزائر',
                period: '2022 - الآن',
                description:
                    'تخطيط وتنفيذ الحصص التدريبية الأسبوعية، قيادة الفريق في المنافسات الرسمية والودية، وتحقيق نتائج تصاعدية مع تطوير مهارات اللاعبين التكتيكية والبدنية.',
              ),
              ExperienceItem(
                title: 'مدرب فئات صغرى ومكوّن (Éducateur Sportif)',
                company: 'مدرسة تكوين المواهب الكروية',
                period: '2020 - 2022',
                description:
                    'تأطير وتلقين أبجديات اللعبة، صقل المهارات الفردية والانضباط الرياضي للاعبين الناشئين.',
              ),
            ];

  // Calculate ATS Quality Score (0 to 100)
  int calculateAtsScore() {
    int score = 0;
    if (fullName.trim().length > 3) score += 15;
    if (jobTitle.trim().isNotEmpty) score += 10;
    if (email.contains('@')) score += 10;
    if (phone.trim().isNotEmpty) score += 10;
    if (summary.trim().length > 50) score += 15;
    if (skills.length >= 4) score += 15;
    if (experiences.isNotEmpty) score += 15;
    if (educations.isNotEmpty) score += 10;
    return score.clamp(0, 100);
  }
}
