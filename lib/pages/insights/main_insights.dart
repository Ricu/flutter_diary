import 'package:flutter/material.dart';

class MainInsights extends StatelessWidget {
  const MainInsights({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: const Center(
        child: Text('This is the Insights screen'),
      ),
    );
  }
}