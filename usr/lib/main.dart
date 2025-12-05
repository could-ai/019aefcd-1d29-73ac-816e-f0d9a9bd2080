import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const LifeSimulatorApp());
}

class LifeSimulatorApp extends StatefulWidget {
  const LifeSimulatorApp({super.key});

  @override
  State<LifeSimulatorApp> createState() => _LifeSimulatorAppState();
}

class _LifeSimulatorAppState extends State<LifeSimulatorApp> {
  Locale _locale = const Locale('en', 'US');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en' 
          ? const Locale('ar', 'AE') 
          : const Locale('en', 'US');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Simulator - Open World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(), // Works well for both, or switch based on locale
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'AE'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => GameScreen(onLanguageToggle: _toggleLanguage, currentLocale: _locale),
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  final VoidCallback onLanguageToggle;
  final Locale currentLocale;

  const GameScreen({
    super.key, 
    required this.onLanguageToggle, 
    required this.currentLocale
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game State Variables
  int _money = 5000;
  int _energy = 100;
  int _happiness = 80;
  int _day = 1;
  
  // Navigation State
  int _selectedIndex = 0;

  // Localization Helper
  bool get isArabic => widget.currentLocale.languageCode == 'ar';
  
  String t(String key) {
    return _translations[key]?[isArabic ? 'ar' : 'en'] ?? key;
  }

  // Game Logic Methods
  void _spendTime(int energyCost, int happinessChange, int moneyChange, String messageKey) {
    if (_energy < energyCost && energyCost > 0) {
      _showNotification(t('tired_msg'));
      return;
    }

    setState(() {
      _energy = (_energy - energyCost).clamp(0, 100);
      _happiness = (_happiness + happinessChange).clamp(0, 100);
      _money += moneyChange;
    });

    if (messageKey.isNotEmpty) {
      _showNotification(t(messageKey));
    }
  }

  void _sleep() {
    setState(() {
      _energy = 100;
      _day++;
      _showNotification("${t('sleep_msg')} $_day");
    });
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define screens here to access state directly
    final List<Widget> screens = [
      _buildHomeTab(),
      _buildFamilyTab(),
      _buildWorkTab(),
      _buildGarageTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('app_title')),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.language),
          onPressed: widget.onLanguageToggle,
          tooltip: "Switch Language",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${t('day')}: $_day", 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(Icons.attach_money, "$_money \$", Colors.green),
                _buildStatusItem(Icons.flash_on, "$_energy%", Colors.orange),
                _buildStatusItem(Icons.sentiment_satisfied_alt, "$_happiness%", Colors.pink),
              ],
            ),
          ),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.house), label: t('nav_home')),
          NavigationDestination(icon: const Icon(Icons.family_restroom), label: t('nav_family')),
          NavigationDestination(icon: const Icon(Icons.work), label: t('nav_work')),
          NavigationDestination(icon: const Icon(Icons.directions_car), label: t('nav_garage')),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  // --- TAB 1: HOME ---
  Widget _buildHomeTab() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.house_rounded, size: 100, color: Colors.brown),
            const SizedBox(height: 10),
            Text(t('home_title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(t('home_desc'), style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildActionCard(
              title: t('action_sleep'),
              subtitle: t('action_sleep_desc'),
              icon: Icons.bed,
              color: Colors.indigo,
              onTap: _sleep,
            ),
            _buildActionCard(
              title: t('action_tv'),
              subtitle: t('action_tv_desc'),
              icon: Icons.tv,
              color: Colors.teal,
              onTap: () => _spendTime(5, 10, 0, 'msg_tv'),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: FAMILY ---
  Widget _buildFamilyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t('family_title'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.pinkAccent, child: Icon(Icons.woman, color: Colors.white)),
            title: Text(t('wife_name')),
            subtitle: Text(t('wife_status')),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _spendTime(5, 15, -50, 'msg_gift_wife'),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.boy, color: Colors.white)),
            title: Text(t('son_name')),
            subtitle: Text(t('son_age')),
            trailing: IconButton(
              icon: const Icon(Icons.toys, color: Colors.orange),
              onPressed: () => _spendTime(5, 10, -20, 'msg_play_son'),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.purpleAccent, child: Icon(Icons.girl, color: Colors.white)),
            title: Text(t('daughter_name')),
            subtitle: Text(t('daughter_age')),
            trailing: IconButton(
              icon: const Icon(Icons.toys, color: Colors.orange),
              onPressed: () => _spendTime(5, 10, -20, 'msg_play_daughter'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildActionCard(
          title: t('action_picnic'),
          subtitle: t('action_picnic_desc'),
          icon: Icons.park,
          color: Colors.green,
          onTap: () {
            if (_money >= 200) {
              _spendTime(30, 40, -200, 'msg_picnic');
            } else {
              _showNotification(t('msg_no_money'));
            }
          },
        ),
      ],
    );
  }

  // --- TAB 3: WORK ---
  Widget _buildWorkTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business_center, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 10),
          Text(t('work_company'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(t('work_role'), style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 30),
          _buildActionCard(
            title: t('action_work'),
            subtitle: t('action_work_desc'),
            icon: Icons.work,
            color: Colors.blue,
            onTap: () => _spendTime(40, -10, 500, 'msg_worked'),
          ),
          _buildActionCard(
            title: t('action_meeting'),
            subtitle: t('action_meeting_desc'),
            icon: Icons.meeting_room,
            color: Colors.blueGrey,
            onTap: () => _spendTime(10, -5, 100, 'msg_meeting'),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: GARAGE ---
  Widget _buildGarageTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // BMW Representation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.directions_car_filled, size: 100, color: Colors.blue),
                const SizedBox(height: 10),
                const Text("BMW M5 Competition", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(t('car_details'), style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildActionCard(
            title: t('action_drive'),
            subtitle: t('action_drive_desc'),
            icon: Icons.speed,
            color: Colors.redAccent,
            onTap: () => _spendTime(15, 20, 0, 'msg_drive'),
          ),
          _buildActionCard(
            title: t('action_wash'),
            subtitle: t('action_wash_desc'),
            icon: Icons.local_car_wash,
            color: Colors.cyan,
            onTap: () {
              if (_money >= 50) {
                _spendTime(10, 5, -50, 'msg_wash');
              } else {
                _showNotification(t('msg_no_money'));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // --- TRANSLATIONS ---
  final Map<String, Map<String, String>> _translations = {
    'app_title': {
      'en': 'Life Simulator',
      'ar': 'محاكي الحياة',
    },
    'day': {
      'en': 'Day',
      'ar': 'اليوم',
    },
    'nav_home': {
      'en': 'Home',
      'ar': 'المنزل',
    },
    'nav_family': {
      'en': 'Family',
      'ar': 'العائلة',
    },
    'nav_work': {
      'en': 'Work',
      'ar': 'العمل',
    },
    'nav_garage': {
      'en': 'Garage',
      'ar': 'الكراج',
    },
    'home_title': {
      'en': 'Your Beautiful Home',
      'ar': 'منزلك الجميل',
    },
    'home_desc': {
      'en': 'Luxury Villa in a quiet neighborhood',
      'ar': 'فيلا فاخرة في حي هادئ',
    },
    'action_sleep': {
      'en': 'Sleep & Rest',
      'ar': 'النوم والراحة',
    },
    'action_sleep_desc': {
      'en': 'Restore full energy and start a new day',
      'ar': 'استعادة الطاقة بالكامل وبدء يوم جديد',
    },
    'action_tv': {
      'en': 'Watch TV',
      'ar': 'مشاهدة التلفاز',
    },
    'action_tv_desc': {
      'en': 'Happiness (+10) | Energy Cost (-5)',
      'ar': 'زيادة السعادة (+10) | تكلفة الطاقة (-5)',
    },
    'family_title': {
      'en': 'Your Family',
      'ar': 'عائلتك',
    },
    'wife_name': {
      'en': 'Wife: Sarah',
      'ar': 'الزوجة: سارة',
    },
    'wife_status': {
      'en': 'Status: Happy',
      'ar': 'الحالة: سعيدة',
    },
    'son_name': {
      'en': 'Son: Ahmed',
      'ar': 'الابن: أحمد',
    },
    'son_age': {
      'en': 'Age: 8 years',
      'ar': 'العمر: 8 سنوات',
    },
    'daughter_name': {
      'en': 'Daughter: Laila',
      'ar': 'الابنة: ليلى',
    },
    'daughter_age': {
      'en': 'Age: 5 years',
      'ar': 'العمر: 5 سنوات',
    },
    'action_picnic': {
      'en': 'Family Picnic',
      'ar': 'نزهة عائلية',
    },
    'action_picnic_desc': {
      'en': 'Take family out | Cost (-200\$) (-30 Energy)',
      'ar': 'خذ العائلة في رحلة | تكلفة (-200\$) (-30 طاقة)',
    },
    'work_company': {
      'en': 'Holding Company',
      'ar': 'الشركة القابضة',
    },
    'work_role': {
      'en': 'Role: Project Manager',
      'ar': 'المنصب: مدير مشاريع',
    },
    'action_work': {
      'en': 'Go to Work',
      'ar': 'الذهاب للعمل',
    },
    'action_work_desc': {
      'en': 'Earn Money (+500\$) | Energy Cost (-40)',
      'ar': 'كسب المال (+500\$) | تكلفة الطاقة (-40)',
    },
    'action_meeting': {
      'en': 'Quick Meeting',
      'ar': 'اجتماع سريع',
    },
    'action_meeting_desc': {
      'en': 'Earn Money (+100\$) | Energy Cost (-10)',
      'ar': 'كسب المال (+100\$) | تكلفة الطاقة (-10)',
    },
    'car_details': {
      'en': 'Color: Metallic Blue | Power: 617 HP',
      'ar': 'اللون: أزرق معدني | القوة: 617 حصان',
    },
    'action_drive': {
      'en': 'Drive Car',
      'ar': 'قيادة السيارة',
    },
    'action_drive_desc': {
      'en': 'City Tour | Happiness (+20) | Energy (-15)',
      'ar': 'جولة في المدينة | سعادة (+20) | طاقة (-15)',
    },
    'action_wash': {
      'en': 'Wash Car',
      'ar': 'غسيل السيارة',
    },
    'action_wash_desc': {
      'en': 'Cost (-50\$) | Happiness (+5)',
      'ar': 'تكلفة (-50\$) | سعادة (+5)',
    },
    'tired_msg': {
      'en': 'You are too tired! You need to rest at home.',
      'ar': 'أنت متعب جداً! تحتاج إلى الراحة في المنزل.',
    },
    'sleep_msg': {
      'en': 'Slept well. New day started! Day',
      'ar': 'نمت جيداً وبدأ يوم جديد (اليوم',
    },
    'msg_tv': {
      'en': 'Watched a nice movie!',
      'ar': 'شاهدت فيلماً ممتعاً',
    },
    'msg_gift_wife': {
      'en': 'You gave your wife a gift!',
      'ar': 'أهديت زوجتك هدية!',
    },
    'msg_play_son': {
      'en': 'Played with Ahmed',
      'ar': 'لعبت مع أحمد',
    },
    'msg_play_daughter': {
      'en': 'Played with Laila',
      'ar': 'لعبت مع ليلى',
    },
    'msg_picnic': {
      'en': 'Had a great time at the park!',
      'ar': 'قضيتم وقتاً رائعاً في الحديقة!',
    },
    'msg_no_money': {
      'en': 'You don\'t have enough money',
      'ar': 'لا تملك المال الكافي',
    },
    'msg_worked': {
      'en': 'Worked hard and earned 500\$',
      'ar': 'عملت بجد وحصلت على 500\$',
    },
    'msg_meeting': {
      'en': 'Successful meeting',
      'ar': 'اجتماع ناجح',
    },
    'msg_drive': {
      'en': 'Engine sounds great! Enjoyed the drive.',
      'ar': 'صوت المحرك رائع! استمتعت بالقيادة.',
    },
    'msg_wash': {
      'en': 'Car is sparkling now!',
      'ar': 'السيارة تلمع الآن!',
    },
  };
}
