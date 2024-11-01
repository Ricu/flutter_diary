import 'package:flutter/material.dart';

class MainPeople extends StatelessWidget {
  const MainPeople({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: const Center(
        child: Text('This is the Peoples screen'),
      ),
    );
  }
}