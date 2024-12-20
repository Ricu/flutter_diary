import 'package:flutter/material.dart';

class MainRecord extends StatelessWidget {
  final String titleText = 'Record Your Day';
  final String buttonText1 = 'Single Turn Mode';
  final String buttonText2 = 'Multi Turn Mode';
  
  const MainRecord({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/recorder/st/start',
                      );
                    },
                    child: Text(buttonText1),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/recorder/mt/start',
                      );
                    },
                    child: Text(buttonText2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
