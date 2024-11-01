import 'package:flutter/material.dart';
// import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';

class JournalEntryDetailView extends StatelessWidget {
  final String content;

  const JournalEntryDetailView({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownBody(
          data: content,
          selectable: true,
        ),
      ),
    );
  }
}