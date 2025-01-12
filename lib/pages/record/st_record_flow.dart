// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'recorder.dart';
import 'edit_screen.dart';
import '/utils/transcribe.dart';
import '/utils/llm_prettifying.dart';
import 'package:intl/intl.dart';
import '../../utils/file_handler.dart';

class StRecordingFlow extends StatefulWidget {
  final DateTime selectedDate;
  const StRecordingFlow({super.key, required this.selectedDate});

  @override
  State<StRecordingFlow> createState() => _StRecordingFlowState();
}

class _StRecordingFlowState extends State<StRecordingFlow> {
  bool _isLoading = false;  // Add loading state

  String _recorderOutputPath = 'placeholder';

  
  @override
  void initState() {
    super.initState();
    _fetchRecorderOutputPath();
  }

  void _fetchRecorderOutputPath() async {
    final String recordingOutputPath = await getRecordingOutputPath(widget.selectedDate);
    setState(() {
      _recorderOutputPath = recordingOutputPath;Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }
    
  void _transcribeAudio(String path) async {
    if (path.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String transcription = await transcribeAudio(path);  // Use path directly
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;  // Check if widget is still mounted
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditScreen(
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
    });

    try {
      String processedText = await LlmPrettifying.prettifySingleRecording(editedTranscription);
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditScreen(
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
    saveText(finalText, widget.selectedDate);
    
  }

  
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM dd, yyyy').format(widget.selectedDate);
    return Scaffold(
      appBar: AppBar(title: Text('Recording: ${formattedDate}')),
      body: Stack(
        children: [
          Recorder(
            onStop: _transcribeAudio,
            outputPath : _recorderOutputPath
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}