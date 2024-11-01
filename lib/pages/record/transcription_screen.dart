import 'package:flutter/material.dart';

class TranscriptionScreen extends StatefulWidget {
  final String transcription;
  final Function(String) onContinue;
  
  const TranscriptionScreen({
    Key? key, 
    required this.transcription, 
    required this.onContinue
  }) : super(key: key);

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.transcription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transcription:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _controller.text,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                    if (!_isEditing) {
                      // Save functionality can be implemented here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transcription saved')),
                      );
                    }
                  },
                  child: Text(_isEditing ? 'Save' : 'Edit'),
                ),
                if (!_isEditing)
                  ElevatedButton(
                    onPressed: () => widget.onContinue(_controller.text),
                    child: const Text('Continue'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}