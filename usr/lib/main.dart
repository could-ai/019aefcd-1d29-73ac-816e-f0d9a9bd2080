import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const LifeSimulatorApp());
}

class LifeSimulatorApp extends StatelessWidget {
  const LifeSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محاكي الحياة - عالم مفتوح',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        textTheme: GoogleFonts.cairoTextTheme(), // Arabic friendly font
      ),
      // Configuration for Arabic Language (RTL)
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const GameScreen(),
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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

  // Game Logic Methods
  void _spendTime(int energyCost, int happinessChange, int moneyChange, String message) {
    if (_energy < energyCost && energyCost > 0) {
      _showNotification("أنت متعب جداً! تحتاج إلى الراحة في المنزل.");
      return;
    }

    setState(() {
      _energy = (_energy - energyCost).clamp(0, 100);
      _happiness = (_happiness + happinessChange).clamp(0, 100);
      _money += moneyChange;
    });

    if (message.isNotEmpty) {
      _showNotification(message);
    }
  }

  void _sleep() {
    setState(() {
      _energy = 100;
      _day++;
      _showNotification("نمت جيداً وبدأ يوم جديد (اليوم $_day)");
    });
  }

  void _showNotification(String message) {
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
        title: const Text("محاكي الحياة"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text("اليوم: $_day", style: const TextStyle(fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primaryContainer,
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "المنزل"),
          NavigationDestination(icon: Icon(Icons.family_restroom), label: "العائلة"),
          NavigationDestination(icon: Icon(Icons.work), label: "العمل"),
          NavigationDestination(icon: Icon(Icons.directions_car), label: "الكراج"),
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
            const Text("منزلك الجميل", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("فيلا فاخرة في حي هادئ", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildActionCard(
              title: "النوم والراحة",
              subtitle: "استعادة الطاقة بالكامل وبدء يوم جديد",
              icon: Icons.bed,
              color: Colors.indigo,
              onTap: _sleep,
            ),
            _buildActionCard(
              title: "مشاهدة التلفاز",
              subtitle: "زيادة السعادة (+10) | تكلفة الطاقة (-5)",
              icon: Icons.tv,
              color: Colors.teal,
              onTap: () => _spendTime(5, 10, 0, "شاهدت فيلماً ممتعاً"),
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
        const Text("عائلتك", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.pinkAccent, child: Icon(Icons.woman, color: Colors.white)),
            title: const Text("الزوجة: سارة"),
            subtitle: const Text("الحالة: سعيدة"),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _spendTime(5, 15, -50, "أهديت زوجتك هدية!"),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.boy, color: Colors.white)),
            title: const Text("الابن: أحمد"),
            subtitle: const Text("العمر: 8 سنوات"),
            trailing: IconButton(
              icon: const Icon(Icons.toys, color: Colors.orange),
              onPressed: () => _spendTime(5, 10, -20, "لعبت مع أحمد"),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.purpleAccent, child: Icon(Icons.girl, color: Colors.white)),
            title: const Text("الابنة: ليلى"),
            subtitle: const Text("العمر: 5 سنوات"),
            trailing: IconButton(
              icon: const Icon(Icons.toys, color: Colors.orange),
              onPressed: () => _spendTime(5, 10, -20, "لعبت مع ليلى"),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildActionCard(
          title: "نزهة عائلية",
          subtitle: "خذ العائلة في رحلة | تكلفة (-200\$) (-30 طاقة)",
          icon: Icons.park,
          color: Colors.green,
          onTap: () {
            if (_money >= 200) {
              _spendTime(30, 40, -200, "قضيتم وقتاً رائعاً في الحديقة!");
            } else {
              _showNotification("لا تملك المال الكافي للنزهة");
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
          const Text("الشركة القابضة", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("المنصب: مدير مشاريع", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 30),
          _buildActionCard(
            title: "الذهاب للعمل",
            subtitle: "كسب المال (+500\$) | تكلفة الطاقة (-40)",
            icon: Icons.work,
            color: Colors.blue,
            onTap: () => _spendTime(40, -10, 500, "عملت بجد وحصلت على 500\$"),
          ),
          _buildActionCard(
            title: "اجتماع سريع",
            subtitle: "كسب المال (+100\$) | تكلفة الطاقة (-10)",
            icon: Icons.meeting_room,
            color: Colors.blueGrey,
            onTap: () => _spendTime(10, -5, 100, "اجتماع ناجح"),
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
                Text("اللون: أزرق معدني | القوة: 617 حصان", style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildActionCard(
            title: "قيادة السيارة",
            subtitle: "جولة في المدينة | سعادة (+20) | طاقة (-15)",
            icon: Icons.speed,
            color: Colors.redAccent,
            onTap: () => _spendTime(15, 20, 0, "صوت المحرك رائع! استمتعت بالقيادة."),
          ),
          _buildActionCard(
            title: "غسيل السيارة",
            subtitle: "تكلفة (-50\$) | سعادة (+5)",
            icon: Icons.local_car_wash,
            color: Colors.cyan,
            onTap: () {
              if (_money >= 50) {
                _spendTime(10, 5, -50, "السيارة تلمع الآن!");
              } else {
                _showNotification("لا تملك المال الكافي");
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
}
