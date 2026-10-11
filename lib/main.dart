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
      title: 'CV-DZ - المنشئ الذكي للسير الذاتية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C3A),
          primary: const Color(0xFF0D5C3A),
          secondary: const Color(0xFFC53030),
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
  late TextEditingController _linkedinController;
  late TextEditingController _portfolioController;
  late TextEditingController _summaryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _cvData.fullName);
    _titleController = TextEditingController(text: _cvData.jobTitle);
    _emailController = TextEditingController(text: _cvData.email);
    _phoneController = TextEditingController(text: _cvData.phone);
    _addressController = TextEditingController(text: _cvData.address);
    _linkedinController = TextEditingController(text: _cvData.linkedinUrl);
    _portfolioController = TextEditingController(text: _cvData.githubOrPortfolioUrl);
    _summaryController = TextEditingController(text: _cvData.summary);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _portfolioController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _syncDataFromControllers() {
    _cvData.fullName = _nameController.text;
    _cvData.jobTitle = _titleController.text;
    _cvData.email = _emailController.text;
    _cvData.phone = _phoneController.text;
    _cvData.address = _addressController.text;
    _cvData.linkedinUrl = _linkedinController.text;
    _cvData.githubOrPortfolioUrl = _portfolioController.text;
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
                    title: const Text('التقاط صورة بكاميرا الهاتف'),
                    subtitle: const Text('صورة بورتريه واضحة وخلفية هادئة'),
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
                    title: const Text('اختيار من ألبوم الصور'),
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

  // AI Assistant Suggestions
  void _showAiAssistantDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: _cvData.targetLanguage == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF0D5C3A)),
                SizedBox(width: 8),
                Text('المساعد الذكي (AI Auto-Writer)'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر صياغة احترافية جاهزة تناسب مجالك لتحسين النبذة المهنية فوراً:',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildAiOptionTile(
                    title: 'صيغة قيادية (Management & Leadership)',
                    content:
                        'خبير مهني ذو سجل حافل في قيادة المشاريع وتحقيق الأهداف الاستراتيجية بكفاءة عالية، مع مهارات تفاوض وتواصل متميزة وبناء فرق عمل فعالة.',
                  ),
                  const SizedBox(height: 8),
                  _buildAiOptionTile(
                    title: 'صيغة تقنية وهندسية (Tech & Engineering)',
                    content:
                        'مهندس شغوف بتطوير الحلول الرقمية المبتكرة وتطبيق أحدث المعايير البرمجية لرفع جودة الأنظمة وكفاءة الأداء التشغيلي بنسب قياسية.',
                  ),
                  const SizedBox(height: 8),
                  _buildAiOptionTile(
                    title: 'صيغة تسويق ومبيعات (Sales & Marketing)',
                    content:
                        'متخصص في نمو الأعمال والتسويق الرقمي وبناء العلاقات الاستراتيجية، ذو قدرة مثبتة على مضاعفة المبيعات وتوسيع الحصة السوقية.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiOptionTile({required String title, required String content}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D5C3A))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(content, style: const TextStyle(fontSize: 12)),
        ),
        trailing: const Icon(Icons.check_circle_outline, color: Color(0xFF0D5C3A)),
        onTap: () {
          setState(() {
            _summaryController.text = content;
            _cvData.summary = content;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تطبيق الصياغة الذكية بنجاح!')),
          );
        },
      ),
    );
  }

  // Multilingual preset switcher
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
    _syncDataFromControllers();
    final atsScore = _cvData.calculateAtsScore();

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
              // ATS Score Badge in Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: atsScore >= 80 ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: atsScore >= 80 ? Colors.green : Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: atsScore >= 80 ? Colors.green : Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      'ATS: $atsScore%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: atsScore >= 80 ? Colors.green.shade900 : Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SegmentedButton<AppLanguage>(
                style: const ButtonStyle(
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
              label: 'الخبرة والمهارات',
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
                          'التقط صورة بكاميرا الهاتف أو اختر صورة وسيقوم التطبيق بقصها وضبطها تلقائياً.',
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _linkedinController,
                          decoration: const InputDecoration(
                            labelText: 'رابط LinkedIn (يتحول لـ QR)',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _portfolioController,
                          decoration: const InputDecoration(
                            labelText: 'رابط الموقع / GitHub',
                            prefixIcon: Icon(Icons.language),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary Card with AI Assistant Trigger
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
                      TextButton.icon(
                        onPressed: _showAiAssistantDialog,
                        icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF0D5C3A)),
                        label: const Text('صياغة بالذكاء الاصطناعي', style: TextStyle(color: Color(0xFF0D5C3A), fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

          // Skills & Languages chips
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('المهارات والتقنيات (Skills)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _cvData.skills.map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        setState(() {
                          _cvData.skills.remove(s);
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      final controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('إضافة مهارة جديدة'),
                          content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'مثال: React Native')),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                            ElevatedButton(
                              onPressed: () {
                                if (controller.text.trim().isNotEmpty) {
                                  setState(() {
                                    _cvData.skills.add(controller.text.trim());
                                  });
                                }
                                Navigator.pop(ctx);
                              },
                              child: const Text('إضافة'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('إضافة مهارة'),
                  ),
                ],
              ),
            ),
          ),

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
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.palette_outlined, size: 20),
                const SizedBox(width: 6),
                const Text('القالب: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('الزمردي الجزائري'),
                  selected: _cvData.templateId == 'modern_emerald',
                  onSelected: (val) {
                    setState(() {
                      _cvData.templateId = 'modern_emerald';
                    });
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('الياقوتي الفاخر'),
                  selected: _cvData.templateId == 'ruby_prestige',
                  onSelected: (val) {
                    setState(() {
                      _cvData.templateId = 'ruby_prestige';
                    });
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('الأزرق التنفيذي'),
                  selected: _cvData.templateId == 'executive_navy',
                  onSelected: (val) {
                    setState(() {
                      _cvData.templateId = 'executive_navy';
                    });
                  },
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('الأسود الكلاسيكي'),
                  selected: _cvData.templateId == 'minimalist_dark',
                  onSelected: (val) {
                    setState(() {
                      _cvData.templateId = 'minimalist_dark';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: PdfPreview(
        build: (format) => PdfGeneratorService.generateCvPdf(_cvData),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'CV_DZ_${_cvData.fullName.replaceAll(' ', '_')}.pdf',
      ),
    );
  }
}
