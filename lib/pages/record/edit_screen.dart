import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class EditScreen extends StatefulWidget {
  final String transcription;
  final Function(String) onContinue;
  
  const EditScreen({
    super.key, 
    required this.transcription, 
    required this.onContinue
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;
  late String _content;

  @override
  void initState() {
    super.initState();
    _content = widget.transcription;
    _controller = TextEditingController(text: widget.transcription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // Save the edited text when exiting edit mode
        _content = _controller.text;
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _editScreenBody(),
      ),

    );
  }

  Column _editScreenBody() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transcription:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.check : Icons.edit),
                onPressed: _toggleEditMode,
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter transcription here...",
                    ),
                  )
                : SingleChildScrollView(
                    child : MarkdownBody(
                      data: _content,
                      selectable: true,
                    ),
                    // child: Text(
                    //   _content,
                    //   style: const TextStyle(fontSize: 16),
                    // ),
                  ),
          ),
          SizedBox(
              width: double.infinity, // Make the button full-width
              child: ElevatedButton(
                onPressed: () => widget.onContinue(_content),
                child: const Text('Continue'),
            ),
          ),
        ],
      );
  }
}