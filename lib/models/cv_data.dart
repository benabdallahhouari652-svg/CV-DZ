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
  String summary;
  Uint8List? photoBytes;

  List<String> skills;
  List<String> spokenLanguages;
  List<EducationItem> educations;
  List<ExperienceItem> experiences;

  AppLanguage targetLanguage;
  String templateId; // 'modern_emerald', 'executive_navy', 'classic_elegance'

  UserCVData({
    this.fullName = 'أحمد بن علي',
    this.jobTitle = 'مهندس برمجيات ومطور تطبيقات',
    this.email = 'ahmed.benali@email.com',
    this.phone = '+213 555 12 34 56',
    this.address = 'الجزائر العاصمة، الجزائر',
    this.summary =
        'مهندس برمجيات ذو خبرة تزيد عن 4 سنوات في تطوير تطبيقات الهواتف الذكية وحلول الويب. متمكن من إنشاء تطبيقات متكاملة وسلسة الأداء وتصميم واجهات عصرية تتوافق مع المعايير العالمية.',
    this.photoBytes,
    List<String>? skills,
    List<String>? spokenLanguages,
    List<EducationItem>? educations,
    List<ExperienceItem>? experiences,
    this.targetLanguage = AppLanguage.ar,
    this.templateId = 'modern_emerald',
  })  : skills = skills ??
            [
              'Flutter & Dart',
              'Firebase / Supabase',
              'Node.js & REST APIs',
              'Git & GitHub',
              'UI/UX Design',
              'حل المشكلات وإدارة المشاريع'
            ],
        spokenLanguages = spokenLanguages ??
            ['العربية (اللغة الأم)', 'الفرنسية (مستوى متقدم)', 'الإنجليزية (طلاقة احترافية)'],
        educations = educations ??
            [
              EducationItem(
                degree: 'ماستر في هندسة البرمجيات والذكاء الاصطناعي',
                institution: 'جامعة العلوم والتكنولوجيا هواري بومدين (USTHB)',
                year: '2020 - 2022',
                details: 'تخرج بميزة جيد جداً ومشروع تخرج حول الحوسبة المتنقلة.',
              ),
              EducationItem(
                degree: 'ليسانس في الإعلام الآلي (علوم الحاسوب)',
                institution: 'جامعة الجزائر 1',
                year: '2017 - 2020',
              ),
            ],
        experiences = experiences ??
            [
              ExperienceItem(
                title: 'مطور تطبيقات أول (Senior Mobile Developer)',
                company: 'شركة حلول التقنية الرقمية - الجزائر',
                period: '2022 - الآن',
                description:
                    'قيادة فريق تطوير تطبيقات الهواتف باستخدام Flutter، بناء أكثر من 5 تطبيقات ناجحة على Google Play وApp Store، وتحسين أداء التطبيقات بنسبة 35%.',
              ),
              ExperienceItem(
                title: 'مطور واجهات وتطبيقات (Fullstack App Dev)',
                company: 'ستارتاب تكنو - وهران',
                period: '2021 - 2022',
                description:
                    'تطوير الواجهات التفاعلية والربط مع الواجهات البرمجية وتكامل بوابات الدفع الإلكتروني والخرائط.',
              ),
            ];
}
