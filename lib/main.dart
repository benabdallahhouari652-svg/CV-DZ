import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'models/cv_data.dart';
import 'services/pdf_generator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CvDzApp());
}

class CvDzApp extends StatelessWidget {
  const CvDzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV-DZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C3A), // Algerian Emerald
          primary: const Color(0xFF0D5C3A),
          secondary: const Color(0xFFC53030), // Algerian Red
        ),
        fontFamily: 'Cairo',
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final UserCVData _cvData = UserCVData();
  final ImagePicker _picker = ImagePicker();
  int _currentTabIndex = 0;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _summaryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _cvData.fullName);
    _titleController = TextEditingController(text: _cvData.jobTitle);
    _emailController = TextEditingController(text: _cvData.email);
    _phoneController = TextEditingController(text: _cvData.phone);
    _addressController = TextEditingController(text: _cvData.address);
    _summaryController = TextEditingController(text: _cvData.summary);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _syncDataFromControllers() {
    _cvData.fullName = _nameController.text;
    _cvData.jobTitle = _titleController.text;
    _cvData.email = _emailController.text;
    _cvData.phone = _phoneController.text;
    _cvData.address = _addressController.text;
    _cvData.summary = _summaryController.text;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _cvData.photoBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تحميل الصورة: $e')),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اختر صورة البورتريه الشخصية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.camera_alt, color: Color(0xFF0D5C3A)),
                    ),
                    title: const Text('التقاط صورة بالهاتف الآن'),
                    subtitle: const Text('صورة مباشرة واضحة مع إضاءة جيدة'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.photo_library, color: Colors.blue),
                    ),
                    title: const Text('اختيار من معرض الصور'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_cvData.photoBytes != null)
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(Icons.delete, color: Colors.red),
                      ),
                      title: const Text('حذف الصورة (سيرة بدون صورة)'),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _cvData.photoBytes = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Quick translation/preset switcher
  void _switchLanguage(AppLanguage lang) {
    _syncDataFromControllers();
    setState(() {
      _cvData.targetLanguage = lang;
      if (lang == AppLanguage.fr) {
        if (_cvData.fullName == 'أحمد بن علي') {
          _cvData.fullName = 'Ahmed Benali';
          _cvData.jobTitle = 'Ingénieur Logiciel & Développeur Mobile';
          _cvData.address = 'Alger, Algérie';
          _cvData.summary =
              'Ingénieur logiciel avec plus de 4 ans d\'expérience dans le développement d\'applications mobiles et web. Passionné par l\'architecture propre et les interfaces modernes.';
        }
      } else if (lang == AppLanguage.en) {
        if (_cvData.fullName == 'أحمد بن علي' || _cvData.fullName == 'Ahmed Benali') {
          _cvData.fullName = 'Ahmed Benali';
          _cvData.jobTitle = 'Senior Mobile Application Engineer';
          _cvData.address = 'Algiers, Algeria';
          _cvData.summary =
              'Software Engineer with 4+ years of hands-on experience building performant, modern mobile applications. Proven track record in shipping successful products to production.';
        }
      } else {
        if (_cvData.fullName == 'Ahmed Benali') {
          _cvData.fullName = 'أحمد بن علي';
          _cvData.jobTitle = 'مهندس برمجيات ومطور تطبيقات';
          _cvData.address = 'الجزائر العاصمة، الجزائر';
          _cvData.summary =
              'مهندس برمجيات ذو خبرة تزيد عن 4 سنوات في تطوير تطبيقات الهواتف الذكية وحلول الويب. متمكن من إنشاء تطبيقات متكاملة وسلسة الأداء وتصميم واجهات عصرية تتوافق مع المعايير العالمية.';
        }
      }
      _nameController.text = _cvData.fullName;
      _titleController.text = _cvData.jobTitle;
      _addressController.text = _cvData.address;
      _summaryController.text = _cvData.summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _cvData.targetLanguage == AppLanguage.ar
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5C3A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'CV-DZ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'المنشئ الذكي',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          actions: [
            // Language selector dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SegmentedButton<AppLanguage>(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment(value: AppLanguage.ar, label: Text('عربي')),
                  ButtonSegment(value: AppLanguage.fr, label: Text('FR')),
                  ButtonSegment(value: AppLanguage.en, label: Text('EN')),
                ],
                selected: {_cvData.targetLanguage},
                onSelectionChanged: (Set<AppLanguage> newSelection) {
                  _switchLanguage(newSelection.first);
                },
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildEditorTab(),
            _buildExperiencesTab(),
            _buildPreviewTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTabIndex,
          onDestinationSelected: (idx) {
            _syncDataFromControllers();
            setState(() {
              _currentTabIndex = idx;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'البيانات الشخصية',
            ),
            NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'الخبرة والتعليم',
            ),
            NavigationDestination(
              icon: Icon(Icons.picture_as_pdf_outlined),
              selectedIcon: Icon(Icons.picture_as_pdf),
              label: 'معاينة وتصدير PDF',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo selector card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerSheet,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFE8F5E9),
                          backgroundImage: _cvData.photoBytes != null
                              ? MemoryImage(_cvData.photoBytes!)
                              : null,
                          child: _cvData.photoBytes == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                  color: Color(0xFF0D5C3A),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFF0D5C3A),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'صورة البورتريه الاحترافية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'التقط صورة بكاميرا الهاتف أو اختر صورة وسيقوم CV-DZ بضبطها في السيرة.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _showImagePickerSheet,
                          icon: const Icon(Icons.add_a_photo, size: 16),
                          label: Text(
                            _cvData.photoBytes != null
                                ? 'تغيير الصورة'
                                : 'التقاط صورة بالهاتف',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D5C3A),
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Basic Info
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المعلومات الأساسية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'المسمى الوظيفي أو التخصص',
                      prefixIcon: Icon(Icons.work_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon: Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان (المدينة، الدولة)',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'النبذة المهنية (الملخص)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'AI-Ready',
                          style: TextStyle(
                            color: Color(0xFF0D5C3A),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _summaryController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'اكتب باختصار عن شغفك، سنوات خبرتك، وأهم ما يميزك...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Experiences Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الخبرات العملية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    _cvData.experiences.add(
                      ExperienceItem(
                        title: 'وظيفة جديدة',
                        company: 'اسم الشركة',
                        period: '2024 - الآن',
                        description: 'وصف المهام والإنجازات...',
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ..._cvData.experiences.asMap().entries.map((entry) {
            final idx = entry.key;
            final exp = entry.value;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: exp.title,
                            onChanged: (val) => exp.title = val,
                            decoration: const InputDecoration(
                              labelText: 'المسمى الوظيفي',
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _cvData.experiences.removeAt(idx);
                            });
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: exp.company,
                            onChanged: (val) => exp.company = val,
                            decoration: const InputDecoration(
                              labelText: 'الشركة / المؤسسة',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: exp.period,
                            onChanged: (val) => exp.period = val,
                            decoration: const InputDecoration(
                              labelText: 'الفترة الزمنية',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: exp.description,
                      maxLines: 2,
                      onChanged: (val) => exp.description = val,
                      decoration: const InputDecoration(
                        labelText: 'أهم الإنجازات والمهام',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Education Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التعليم والشهادات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    _cvData.educations.add(
                      EducationItem(
                        degree: 'الشهادة / التخصص',
                        institution: 'الجامعة / المعهد',
                        year: '2023',
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ..._cvData.educations.asMap().entries.map((entry) {
            final idx = entry.key;
            final edu = entry.value;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: edu.degree,
                            onChanged: (val) => edu.degree = val,
                            decoration: const InputDecoration(
                              labelText: 'الدرجة العلمية',
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _cvData.educations.removeAt(idx);
                            });
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: edu.institution,
                            onChanged: (val) => edu.institution = val,
                            decoration: const InputDecoration(
                              labelText: 'الجامعة / المدرسة',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: edu.year,
                            onChanged: (val) => edu.year = val,
                            decoration: const InputDecoration(
                              labelText: 'سنة التخرج',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    _syncDataFromControllers();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(Icons.palette_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('اختر القالب: '),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('الزمردي (الجزائر)'),
                selected: _cvData.templateId == 'modern_emerald',
                onSelected: (val) {
                  setState(() {
                    _cvData.templateId = 'modern_emerald';
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('الأزرق التنفيذي'),
                selected: _cvData.templateId == 'executive_navy',
                onSelected: (val) {
                  setState(() {
                    _cvData.templateId = 'executive_navy';
                  });
                },
              ),
            ],
          ),
        ),
      ),
      body: PdfPreview(
        build: (format) => PdfGeneratorService.generateCvPdf(_cvData),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName:
            'CV_DZ_${_cvData.fullName.replaceAll(' ', '_')}.pdf',
      ),
    );
  }
}
