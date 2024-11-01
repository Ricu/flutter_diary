import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';
import '../../utils/file_handler.dart';

class MainSettings extends StatefulWidget {
  const MainSettings({Key? key}) : super(key: key);

  @override
  State<MainSettings> createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  Future<void> _exportEntries() async {
    final zipFile = await exportAllEntriesToZip();
    if (!mounted) return;
    if (zipFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${zipFile.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No entries to export')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportEntries,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: const Center(
        child: Text('This is the Settings screen'),
      ),
    );
  }
}