import 'package:flutter/material.dart';
import 'package:flutter_application_2/pages/people/main_people.dart';
import 'package:flutter_application_2/pages/record/main_record.dart';
import 'package:flutter_application_2/pages/record/st_record_flow.dart';
import 'package:flutter_application_2/pages/record/mt_record_flow.dart';
import 'pages/insights/main_insights.dart';
import 'pages/journal/main_journal.dart';
import 'pages/settings/main_settings.dart';
import 'theme.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async{
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialTheme theme = MaterialTheme(ThemeData().textTheme);

    return MaterialApp(
      title: 'Diary App',
      theme: theme.lightMediumContrast(),
      darkTheme: theme.darkMediumContrast(),
      themeMode: ThemeMode.dark,

      // Define the routes in the app
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const MainSettings(),
        '/recorder/st/start': (context) => const StRecordingFlow(),
        '/recorder/mt/start': (context) => const CategoryHomeScreen(),
      },
      initialRoute: '/',
    );
  }
}

// This is your home screen widget that will hold the bottom navigation bar and the Recorder
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final List<Map<String, dynamic>> appSections = [
    {
      'name': 'Journal',
      'widget': const MainJournal(),
      'icon': Icons.book_outlined,
    },
    {
      'name': 'Insights',
      'widget': const MainInsights(),
      'icon': Icons.assessment_outlined,
    },
    {
      'name': 'Recorder Home',
      'widget': const MainRecord(),
      'icon': Icons.home_outlined,
    },
    {
      'name': 'People',
      'widget': const MainPeople(),
      'icon': Icons.people_outlined,
    },
    {
      'name': 'Settings',
      'widget': const MainSettings(),
      'icon': Icons.settings,
    }
  ];

  List<BottomNavigationBarItem> getNavigationBarItems() {
    return appSections.map((section) {
      return BottomNavigationBarItem(
        icon: Icon(section['icon']),
        label: section['name'],
      );
    }).toList();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Tracker'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     tooltip: 'Open settings',
        //     onPressed: () {
        //       Navigator.pushNamed(context, '/settings');
        //     },
        //   ),
        // ],
      ),
      body: appSections[_currentIndex]['widget'],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: getNavigationBarItems(),
        currentIndex: _currentIndex,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
