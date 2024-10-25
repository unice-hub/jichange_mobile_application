import 'package:flutter/material.dart';
import 'pages/home_section.dart';
import 'pages/customer_section.dart';
import 'pages/vendor_users_section.dart';
import 'pages/invoices_section.dart';
import 'pages/reports_section.dart';
import 'pages/login/login_page.dart';
import 'pages/login/forgot_password_page.dart';
import 'pages/login/vendor_registration_page.dart';
import 'pages/profile_page.dart';
import 'pages/create_invoice.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor Management App (jichange)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,  // Material Design 3
      ),
      debugShowCheckedModeBanner: false, // Disable debug banner
      home: const LoginPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/register': (context) => const VendorRegistrationPage(),
        '/profile': (context) => const ProfilePage(),
        '/create_invoice': (context) => const CreateInvoicePage(),
        // '/edit_invoice': (context) => const EditInvoicePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
        automaticallyImplyLeading: false, // Disables the back button
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
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
