import 'package:flutter/material.dart';
import 'pages/record/recorder.dart';
import 'theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialTheme theme = MaterialTheme(ThemeData().textTheme);


    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Diary App'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Recorder(onStop: (path) {})],
          )
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: 'Recorder',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: 2
        ),
      ),
      
      theme: theme.lightMediumContrast(), 
      darkTheme: theme.darkMediumContrast(), 
      themeMode: ThemeMode.dark, 
    );
  }
}
