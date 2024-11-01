import 'package:flutter/material.dart';
import 'recorder.dart';
import 'transcription_screen.dart';
import '/utils/transcribe.dart';
import '/utils/llm_prettifying.dart';

import '../../utils/file_handler.dart';

class StRecordingFlow extends StatefulWidget {
  const StRecordingFlow({Key? key}) : super(key: key);

  @override
  State<StRecordingFlow> createState() => _StRecordingFlowState();
}

class _StRecordingFlowState extends State<StRecordingFlow> {
  String? _recordedFilePath;
  String? _transcription;
  String? _processedText;
  bool _isLoading = false;  // Add loading state

  void _transcribeAudio(String path) async {
    if (path.isEmpty) return;

    setState(() {
      _isLoading = true;
      _recordedFilePath = path;
    });

    try {
      String transcription = await transcribeAudio(path);  // Use path directly
      setState(() {
        _transcription = transcription;
        _isLoading = false;
      });

      if (!mounted) return;  // Check if widget is still mounted
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TranscriptionScreen(
            transcription: transcription,
            onContinue: _processTranscription,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error transcribing audio: $e')),
      );
    }
  }

  void _processTranscription(String editedTranscription) async {
    setState(() {
      _isLoading = true;
      _transcription = editedTranscription;
    });

    try {
      String processedText = await LlmPrettifying.prettifySingleRecording(editedTranscription);
      setState(() {
        _processedText = processedText;
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TranscriptionScreen(
            transcription: processedText,
            onContinue: _handleFinalContinue,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing transcription: $e')),
      );
    }
  }

  void _handleFinalContinue(String finalText) {
    // Here you can implement the final step of your flow
    print('Final text: $finalText');
    saveText(finalText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recording')),
      body: Stack(
        children: [
          Recorder(onStop: _transcribeAudio),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}