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
      title: 'CV-DZ | المنشئ العالمي للسير الذاتية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Modern Slate-50
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D5C3A),
          primary: const Color(0xFF0D5C3A),
          secondary: const Color(0xFFE11D48),
          surface: Colors.white,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'تعديل الصورة الشخصية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    tileColor: const Color(0xFFF0FDF4),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF0D5C3A),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                    title: const Text('التقاط صورة بكاميرا الهاتف', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('بورتريه مباشر مع إضاءة جيدة'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    tileColor: const Color(0xFFEFF6FF),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.photo_library, color: Colors.white, size: 20),
                    ),
                    title: const Text('اختيار من ألبوم الصور', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('صورة استوديو أو ملف شخصي'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  if (_cvData.photoBytes != null) ...[
                    const SizedBox(height: 10),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      tileColor: const Color(0xFFFFF1F2),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.delete_outline, color: Colors.white, size: 20),
                      ),
                      title: const Text('إزالة الصورة (سيرة بدون صورة)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _cvData.photoBytes = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // AI Assistant Dialog
  void _showAiAssistantDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: _cvData.targetLanguage == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0D5C3A), Color(0xFF10B981)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('المساعد الذكي (AI Copilot)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر نموذج صياغة احترافية يطابق مسارك المهني:',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  _buildAiOptionTile(
                    icon: Icons.business_center_rounded,
                    title: 'صيغة قيادية وإدارية (Executive & Management)',
                    content:
                        'قائد تنفيذي ذو سجل حافل في إدارة المشاريع المعقدة وتوجيه فرق العمل نحو تحقيق أهداف النمو الاستراتيجي، مع كفاءة عالية في تحسين العمليات التشغيلية وتوليد الإيرادات.',
                  ),
                  const SizedBox(height: 10),
                  _buildAiOptionTile(
                    icon: Icons.code_rounded,
                    title: 'صيغة تقنية وهندسية (Software & Tech)',
                    content:
                        'مهندس برمجيات شغوف بتطوير الحلول الرقمية القابلة للتوسع وتطبيق أفضل المعايير الهندسية في الأداء والأمان وتكامل النظم، ذو قدرة مثبتة على تحويل المتطلبات المعقدة إلى منتجات سلسة.',
                  ),
                  const SizedBox(height: 10),
                  _buildAiOptionTile(
                    icon: Icons.trending_up_rounded,
                    title: 'صيغة تسويق ونمو أعمال (Marketing & Sales)',
                    content:
                        'متخصص استراتيجي في تسريع نمو الأعمال واكتساب العملاء وتطوير الحملات الرقمية متعددة القنوات، مع خلفية تحليلية قوية في تحسين العائد على الاستثمار.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(color: Color(0xFF64748B))),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiOptionTile({required IconData icon, required String title, required String content}) {
    return InkWell(
      onTap: () {
        setState(() {
          _summaryController.text = content;
          _cvData.summary = content;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF0D5C3A),
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('تم تطبيق الصياغة بنجاح!'),
              ],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF0D5C3A)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                  ),
                ),
                const Icon(Icons.arrow_back_ios_new_rounded, size: 12, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 6),
            Text(content, style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4)),
          ],
        ),
      ),
    );
  }

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
      textDirection: _cvData.targetLanguage == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Brand Badge with Gradient
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D5C3A), Color(0xFF15803D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF0D5C3A).withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'CV-DZ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                          ),
                          SizedBox(width: 4),
                          Text('🇩🇿', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Live ATS Gauge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: atsScore >= 80 ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: atsScore >= 80 ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            atsScore >= 80 ? Icons.check_circle_rounded : Icons.offline_bolt_rounded,
                            size: 14,
                            color: atsScore >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ATS $atsScore%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: atsScore >= 80 ? const Color(0xFF065F46) : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Multilingual Selector Chips
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildLangPill(AppLanguage.ar, 'عربي'),
                          _buildLangPill(AppLanguage.fr, 'FR'),
                          _buildLangPill(AppLanguage.en, 'EN'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                _buildEditorTab(),
                _buildExperiencesTab(),
                _buildPreviewTab(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, -3)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildNavButton(0, Icons.person_outline_rounded, Icons.person_rounded, 'البيانات الشخصية'),
                  _buildNavButton(1, Icons.business_center_outlined, Icons.business_center_rounded, 'الخبرات والمهارات'),
                  _buildNavButton(2, Icons.picture_as_pdf_outlined, Icons.picture_as_pdf_rounded, 'معاينة وتصدير PDF'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _syncDataFromControllers();
          setState(() {
            _currentTabIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFECFDF5) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                color: isSelected ? const Color(0xFF0D5C3A) : const Color(0xFF64748B),
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0D5C3A) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangPill(AppLanguage lang, String title) {
    final isSelected = _cvData.targetLanguage == lang;
    return GestureDetector(
      onTap: () => _switchLanguage(lang),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? const Color(0xFF0D5C3A) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildEditorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Studio Photo Card with Hero Gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showImagePickerSheet,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF0D5C3A)],
                          ),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 10),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFF334155),
                          backgroundImage: _cvData.photoBytes != null ? MemoryImage(_cvData.photoBytes!) : null,
                          child: _cvData.photoBytes == null
                              ? const Icon(Icons.camera_alt_rounded, size: 34, color: Colors.white70)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'صورة البورتريه الاحترافية',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'التقط صورة بكاميرا هاتفك أو اخترها من الألبوم لضبطها تلقائياً داخل القالب.',
                        style: TextStyle(color: Colors.grey.shade300, fontSize: 12, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _showImagePickerSheet,
                        icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                        label: Text(
                          _cvData.photoBytes != null ? 'تغيير الصورة' : 'التقاط صورة بالهاتف',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Basic Info Modern Card
          _buildModernSectionCard(
            title: 'المعلومات الشخصية والاتصال',
            icon: Icons.person_pin_rounded,
            child: Column(
              children: [
                _buildModernTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  hint: 'مثال: أحمد بن علي',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                _buildModernTextField(
                  controller: _titleController,
                  label: 'المسمى الوظيفي أو التخصص',
                  hint: 'مثال: مهندس برمجيات وتطبيقات الهواتف',
                  icon: Icons.work_outline_rounded,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        hint: '+213 555 12 34 56',
                        icon: Icons.phone_iphone_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        hint: 'name@email.com',
                        icon: Icons.alternate_email_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildModernTextField(
                  controller: _addressController,
                  label: 'العنوان (المدينة، الدولة)',
                  hint: 'الجزائر العاصمة، الجزائر',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: _linkedinController,
                        label: 'رابط LinkedIn (يتحول لـ QR)',
                        hint: 'https://linkedin.com/in/...',
                        icon: Icons.link_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernTextField(
                        controller: _portfolioController,
                        label: 'الموقع أو GitHub',
                        hint: 'https://github.com/...',
                        icon: Icons.language_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Summary Section with AI Copilot
          _buildModernSectionCard(
            title: 'النبذة المهنية (الملخص التنفيذي)',
            icon: Icons.description_outlined,
            trailing: TextButton.icon(
              onPressed: _showAiAssistantDialog,
              icon: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF0D5C3A)),
              label: const Text(
                'صياغة ذكية بالـ AI',
                style: TextStyle(color: Color(0xFF0D5C3A), fontWeight: FontWeight.w800, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFECFDF5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
            child: TextField(
              controller: _summaryController,
              maxLines: 4,
              style: const TextStyle(fontSize: 13, height: 1.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                hintText: 'اكتب باختصار عن شغفك، سنوات خبرتك، وأهم ما يميزك في سوق العمل...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF0D5C3A), width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExperiencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Experience Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Color(0xFF0D5C3A)),
                  SizedBox(width: 8),
                  Text('الخبرات العملية والمهنية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _cvData.experiences.add(
                      ExperienceItem(
                        title: 'المسمى الوظيفي الجديد',
                        company: 'اسم الشركة أو المؤسسة',
                        period: '2024 - الآن',
                        description: 'شرح المهام والإنجازات البارزة...',
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('إضافة خبرة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C3A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ..._cvData.experiences.asMap().entries.map((entry) {
            final idx = entry.key;
            final exp = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: exp.title,
                          onChanged: (val) => exp.title = val,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'المسمى الوظيفي',
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _cvData.experiences.removeAt(idx);
                          });
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: exp.company,
                          onChanged: (val) => exp.company = val,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            labelText: 'الشركة / المؤسسة',
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: exp.period,
                          onChanged: (val) => exp.period = val,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            labelText: 'الفترة الزمنية',
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: exp.description,
                    maxLines: 2,
                    onChanged: (val) => exp.description = val,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'أهم المهام والإنجازات الملموسة',
                      isDense: true,
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Skills Card
          _buildModernSectionCard(
            title: 'المهارات والتقنيات (Skills)',
            icon: Icons.psychology_rounded,
            trailing: TextButton.icon(
              onPressed: () {
                final controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('إضافة مهارة جديدة'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'مثال: الذكاء الاصطناعي، إدارة الفرق...',
                        border: OutlineInputBorder(),
                      ),
                    ),
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D5C3A)),
                        child: const Text('إضافة', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Color(0xFF0D5C3A)),
              label: const Text('إضافة', style: TextStyle(color: Color(0xFF0D5C3A), fontWeight: FontWeight.bold)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cvData.skills
                  .map(
                    (s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      deleteIcon: const Icon(Icons.close_rounded, size: 14),
                      onDeleted: () {
                        setState(() {
                          _cvData.skills.remove(s);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Education Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.school_rounded, color: Color(0xFF0D5C3A)),
                  SizedBox(width: 8),
                  Text('التعليم والمؤهلات الأكاديمية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _cvData.educations.add(
                      EducationItem(
                        degree: 'الدرجة العلمية والتخصص',
                        institution: 'الجامعة أو المعهد',
                        year: '2023',
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('إضافة شهادة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C3A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ..._cvData.educations.asMap().entries.map((entry) {
            final idx = entry.key;
            final edu = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: edu.degree,
                          onChanged: (val) => edu.degree = val,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'الدرجة العلمية والتخصص',
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _cvData.educations.removeAt(idx);
                          });
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
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
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            labelText: 'الجامعة / الكلية',
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: edu.year,
                          onChanged: (val) => edu.year = val,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            labelText: 'سنة التخرج',
                            isDense: true,
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.palette_rounded, size: 18, color: Color(0xFF0D5C3A)),
                const SizedBox(width: 6),
                const Text('اختر القالب العالمي:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(width: 10),
                _buildTemplateChoiceChip('modern_emerald', 'الزمردي الجزائري', const Color(0xFF0D5C3A)),
                const SizedBox(width: 8),
                _buildTemplateChoiceChip('ruby_prestige', 'الياقوتي الفاخر', const Color(0xFF9B111E)),
                const SizedBox(width: 8),
                _buildTemplateChoiceChip('executive_navy', 'الأزرق التنفيذي', const Color(0xFF1A365D)),
                const SizedBox(width: 8),
                _buildTemplateChoiceChip('minimalist_dark', 'الأسود الكلاسيكي', const Color(0xFF212529)),
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

  Widget _buildTemplateChoiceChip(String id, String label, Color color) {
    final isSelected = _cvData.templateId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _cvData.templateId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : const Color(0xFFCBD5E1)),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: isSelected ? Colors.white : color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: const Color(0xFF0D5C3A)),
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF0D5C3A)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D5C3A), width: 1.5),
        ),
      ),
    );
  }
}
