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
    this.fullName = 'الهواري بن عبد الله (Houari Benabdallah)',
    this.jobTitle = 'مدرب كرة قدم | مدرب حراس | محلل أداء | منشط مخيمات | مراسل صحفي',
    this.email = 'benabdallahhouari652@gmail.com',
    this.phone = '+213 555 00 00 00',
    this.address = 'الجزائر (Algérie)',
    this.linkedinUrl = 'https://www.linkedin.com/in/benabdallah-houari-18b77334b',
    this.githubOrPortfolioUrl = 'https://cv-dz-fawn.vercel.app',
    this.summary =
        'إطار رياضي وإعلامي متعدد المهارات؛ مدرب كرة قدم متخصص في التكوين وتطوير اللاعبين، مدرب حراس مرمى ومحلل أداء بالفيديو والمؤشرات الرقمية. أمتلك خبرة غنية في التنشيط البيداغوجي للمخيمات الصيفية والشبابية، إلى جانب العمل كمراسل صحفي رياضي للتغطيات والتحقيقات الميدانية وصناعة المحتوى الهادف.',
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
              'التدريب الكروي والتخطيط التكتيكي',
              'تدريب وتأهيل حراس المرمى (GK Coaching)',
              'تحليل الأداء بالفيديو والبيانات (Performance Analyst)',
              'التنشيط التربوي والمخيمات الصيفية (Animation)',
              'الصحافة الرياضية وإعداد التقارير والمراسلات',
              'التواصل الجماهيري وإدارة الفعاليات'
            ],
        spokenLanguages = spokenLanguages ??
            ['العربية (اللغة الأم)', 'الفرنسية (مستوى متقدم ومتقن)', 'الإنجليزية (تواصل مهني)'],
        educations = educations ??
            [
              EducationItem(
                degree: 'شهادة تدريب معتمدة في كرة القدم وتدريب الحراس',
                institution: 'الاتحادية الجزائرية لكرة القدم (FAF)',
                year: '2021 - 2023',
                details: 'تكوين تكتيكي، تقني، وتدريب حراس المرمى، مع رخصة التحليل الفني للأداء.',
              ),
              EducationItem(
                degree: 'شهادة كفاءة في التنشيط البيداغوجي للمخيمات الصيفية',
                institution: 'وزارة الشباب والرياضة / مديرية الشباب والرياضة (DJS)',
                year: '2019 - 2021',
                details: 'تأطير الأنشطة الشبابية والترفيهية وإدارة المجموعات والمخيمات الوطنية.',
              ),
              EducationItem(
                degree: 'تكوين في الصحافة الرياضية والإعلام والاتصال',
                institution: 'معهد الإعلام / ورشات الصحافة الميدانية',
                year: '2018 - 2020',
                details: 'تقنيات التحرير الصحفي، المراسلة الميدانية، واللقاءات الرياضية.',
              ),
            ],
        experiences = experiences ??
            [
              ExperienceItem(
                title: 'مدرب كرة قدم ومحلل أداء فني (Head Coach & Match Analyst)',
                company: 'النادي والأكاديمية الرياضية - الجزائر',
                period: '2022 - الآن',
                description:
                    'قيادة الفريق التكتيكية، تحليل المباريات وتفكيك نقاط قوة وضعف المنافسين، وتحسين التمركز الدفاعي والهجومي عبر الفيديو.',
              ),
              ExperienceItem(
                title: 'مدرب حراس مرمى (Goalkeeper Coach)',
                company: 'أكاديمية حراس المرمى وتكوين المواهب',
                period: '2021 - 2023',
                description:
                    'برامج تدريب نوعية لرد الفعل، التمركز السليم، الكرات العالية، واللعب بالقدمين وبناء الهجمة من الخلف.',
              ),
              ExperienceItem(
                title: 'مراسل صحفي رياضي (Journaliste & Correspondant Sportif)',
                company: 'صحف ومواقع إعلامية رياضية',
                period: '2020 - الآن',
                description:
                    'تغطية المباريات والأحداث الرياضية، إجراء مقابلات صحفية مع المدربين واللاعبين، وكتابة تقارير احترافية موثقة.',
              ),
              ExperienceItem(
                title: 'منشط ومؤطر مخيمات صيفية (Animateur de Colonies de Vacances)',
                company: 'مؤسسات الشباب والمخيمات الصيفية الوطنية',
                period: '2019 - الآن',
                description:
                    'تنظيم الفعاليات الرياضية والترفيهية للناشئة، غرس القيم التربوية والروح الجماعية وإدارة الأنشطة اليومية للمخيم.',
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
