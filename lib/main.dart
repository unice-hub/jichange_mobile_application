import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/home_section.dart';
import 'pages/customer_section.dart';
import 'pages/vendor_users_section.dart';
import 'pages/invoices_section.dart';
import 'pages/reports_section.dart';
import 'pages/login/login_page.dart';
import 'pages/login/forgot_password_page.dart';
import 'pages/login/vendor_registration_page.dart';
import 'pages/settings_page.dart';
import 'pages/create_invoice.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestStoragePermissions();
  runApp(const MyApp());
}

Future<void> requestStoragePermissions() async {
  if (await Permission.storage.request().isGranted) {
    print("Storage permission granted.");
  } else if (await Permission.storage.isPermanentlyDenied) {
    print("Storage permission permanently denied. Redirecting to settings...");
    openAppSettings();
  } else {
    print("Storage permission denied.");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Initial theme

  void _updateTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor Management App (jichange)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue, // Primary color base
          brightness: Brightness.light, // Set light mode
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.grey[800], fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue.shade600,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.dark, // Set dark mode
        ),
        scaffoldBackgroundColor: Colors.black, // Set background to a deeper dark color
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
        ),
         inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.white), // White label text
          filled: true,
          fillColor: Colors.transparent, // Transparent background for TextFields
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white, // White cursor
          selectionColor: Colors.lightBlueAccent, // Selected text background
          selectionHandleColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue.shade300,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/register': (context) => const VendorRegistrationPage(),
        '/settings': (context) => SettingsPage(onThemeChanged: _updateTheme),
        '/create_invoice': (context) => const CreateInvoicePage(),
      },
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex = 0});

  final int initialIndex;

  // // Static method to navigate to MainPage and show the HomePage tab
  // static void navigateToHome(BuildContext context) {
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (_) => const HomePage()),
  //     (route) => false,
  //   );
  // }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the initial index from widget properties
  }

  final List<Widget> _pages = [
    const HomeSection(),
    const CustomerSection(),
    const VendorUsersSection(),
    const InvoicesSection(),
    const ReportsSection(),
  ];

  final List<String> _titles = [
    'Home',
    'Customer',
    'Vendor Users',
    'Invoices',
    'Reports',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface // Dark mode
          : Theme.of(context).colorScheme.primary, // Light mode
        automaticallyImplyLeading: false, // Disables the back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                'assets/jichange_logo.png',
                height: 40.0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _titles[_selectedIndex],
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        centerTitle: true,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color:  Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Vendor Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: const Color.fromARGB(255, 1, 63, 114),
        selectedItemColor: Colors.lightBlue,
        onTap: _onItemTapped,
      ),
    );
  }
}
