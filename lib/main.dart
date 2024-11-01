import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/pages/people/main_people.dart';
import 'package:flutter_application_2/pages/record/main_record.dart';
import 'package:flutter_application_2/pages/record/st_record_flow.dart';

import 'pages/record/recorder.dart'; // Assuming this contains the Recorder widget
import 'pages/insights/main_insights.dart';
import 'pages/journal/main_journal.dart';
import 'pages/settings/main_settings.dart';
import 'theme.dart';
import 'pages/record/transcription_screen.dart'; // Create this new file for TranscriptionScreen


void main() {
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
        '/recorder/st/start': (context) => StRecordingFlow(),
        // '/edit_transcription': (context) => const TranscriptionScreen(),
      },
      initialRoute: '/',
    );
  }
}

// This is your home screen widget that will hold the bottom navigation bar and the Recorder
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Open settings',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people_outlined, 
              // color: Theme.of(context).colorScheme.secondary
            ),
            label: 'People',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined, 
              // color: Theme.of(context).colorScheme.secondary
            ),
            label: 'Recorder Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.mic_outlined, 
              // color: Theme.of(context).colorScheme.secondary
            ),
            label: 'Recorder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            label: 'Insights',
          ),
        ],
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

  Widget _buildBody() {
    // You can add more cases for different screens like Home, Journal, etc.
    switch (_currentIndex) {
      case 0:
        return MainJournal();
      case 1:
        return MainPeople();
      case 2:
        return MainRecord();
      case 3:
        return Recorder(
            onStop: (path) {
              if (kDebugMode) print('Recorded file path: $path');
            },
          );
      case 4:
        return MainInsights();
      default:
        return Recorder(onStop: (path) {},);
    }
  }
}
