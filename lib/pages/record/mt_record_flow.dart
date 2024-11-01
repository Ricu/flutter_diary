// home_screen.dart
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart'; // You'll need to add this package

import 'package:flutter/material.dart';
import 'recorder.dart';
import 'edit_screen.dart';
import '/utils/transcribe.dart';
import '/utils/llm_prettifying.dart';

import '../../utils/file_handler.dart';


class CategoryHomeScreen extends StatefulWidget {
  const CategoryHomeScreen({Key? key}) : super(key: key);

  @override
  State<CategoryHomeScreen> createState() => _CategoryHomeScreenState();
}

class _CategoryHomeScreenState extends State<CategoryHomeScreen> {
  // Track recordings made in current session
  final Map<String, List<String>> _sessionRecordings = {};
  
  // Category definitions with icons
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Health & Symptoms',
      'icon': Icons.favorite,
      'colorSeed': Colors.red,
    },
    {
      'name': 'Physical Activity',
      'icon': Icons.directions_run,
      'colorSeed': Colors.green,
    },
    {
      'name': 'Daily Activities & Social Interactions',
      'icon': Icons.people,
      'colorSeed': Colors.blue,
    },
    {
      'name': 'Reflections & Ideas',
      'icon': Icons.lightbulb,
      'colorSeed': Colors.yellow,
    },
    {
      'name': 'Meals & Nutrition',
      'icon': Icons.restaurant,
      'colorSeed': Colors.orange,
    },
    {
      'name': 'Mood Tracker',
      'icon': Icons.emoji_emotions,
      'colorSeed': Colors.purple,
    },
    {
      'name': 'Sleep Patterns',
      'icon': Icons.bedtime,
      'colorSeed': Colors.indigo,
    },
    {
      'name': 'Miscellaneous Notes',
      'icon': Icons.note,
      'colorSeed': Colors.grey,
    },
  ];

  int getRecordingCount(String category) {
    return _sessionRecordings[category]?.length ?? 0;
  }

  void _handleRecordingComplete(String category, String transcribedText) {
    setState(() {
      _sessionRecordings.update(
        category,
        (list) => list..add(transcribedText),
        ifAbsent: () => [transcribedText],
      );
    });
  }

  void _startRecording(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryRecordingFlow(
          category: category,
          onComplete: (String transcribedText) => _handleRecordingComplete(category, transcribedText),
        ),
      ),
    );
  }

  void _processAllRecordings() async {
    if (_sessionRecordings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recordings to process yet!')),
      );
      return;
    }

    // Navigate to a processing screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessAllRecordingsScreen(
          recordings: _sessionRecordings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Journal'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final recordingCount = getRecordingCount(category['name']);
                
                return CategoryTile(
                  name: category['name'],
                  icon: category['icon'],
                  colorSeed: category['colorSeed'],
                  recordingCount: recordingCount,
                  onTap: () => _startRecording(category['name']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processAllRecordings,
                icon: const Icon(Icons.check_circle),
                label: const Text('Process All Recordings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color colorSeed;
  final int recordingCount;
  final VoidCallback onTap;

  const CategoryTile({
    Key? key,
    required this.name,
    required this.icon,
    required this.colorSeed,
    required this.recordingCount,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Create theme-aware colors
    final backgroundColor = isDark
        ? Color.alphaBlend(colorSeed.withOpacity(0.2), theme.cardColor)
        : Color.alphaBlend(colorSeed.withOpacity(0.1), theme.cardColor);

    final foregroundColor = isDark
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface;

    final iconColor = isDark
        ? colorSeed.withOpacity(0.8)
        : colorSeed.withOpacity(0.7);

    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: iconColor,
                ),
                if (recordingCount > 0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      recordingCount.toString(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              name,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// category_recording_flow.dart
class CategoryRecordingFlow extends StatefulWidget {
  final String category;
  final Function(String) onComplete;

  const CategoryRecordingFlow({
    Key? key,
    required this.category,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CategoryRecordingFlow> createState() => _CategoryRecordingFlowState();
}

class _CategoryRecordingFlowState extends State<CategoryRecordingFlow> {
  // String? _recordedFilePath;
  // String? _transcription;
  bool _isLoading = false;

  void _transcribeAudio(String path) async {
    if (path.isEmpty) return;
    setState(() {
      _isLoading = true;
      // _recordedFilePath = path;
    });

    try {
      String transcription = await transcribeAudio(path);
      setState(() {
        // _transcription = transcription;
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditScreen(
            transcription: transcription,
            onContinue: _handleEditComplete,
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

  void _handleEditComplete(String editedTranscription) {
    widget.onComplete(editedTranscription);
    Navigator.popUntil(context, ModalRoute.withName('/recorder/mt/start')); // Return to the specified route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recording: ${widget.category}'),
      ),
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

// process_all_recordings_screen.dart
class ProcessAllRecordingsScreen extends StatefulWidget {
  final Map<String, List<String>> recordings;

  const ProcessAllRecordingsScreen({
    Key? key,
    required this.recordings,
  }) : super(key: key);

  @override
  State<ProcessAllRecordingsScreen> createState() => _ProcessAllRecordingsScreenState();
}

class _ProcessAllRecordingsScreenState extends State<ProcessAllRecordingsScreen> {
  bool _isProcessing = false;
  String? _processedResult;

  @override
  void initState() {
    super.initState();
    _processRecordings();
  }

  Future<void> _processRecordings() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Prepare structured data for LLM processing
      final recordingsMerged = widget.recordings.map((category, recordings) {
        return MapEntry(category, recordings.join('\n'));
      });

      // Join the recordings for each category into one string
      final joinedRecordings = recordingsMerged.values.toList().join('\n\n');
      

      // Process all recordings together
      final result = await LlmPrettifying.prettifySingleRecording(joinedRecordings);

      setState(() {
        _processedResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing recordings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Recordings'),
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing all recordings...'),
                ],
              ),
            )
          : _processedResult != null
              ? EditScreen(
                  transcription: _processedResult!,
                  onContinue: (finalText) {
                    saveText(finalText);
                    // Navigate back to home and clear session
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                )
              : const Center(
                  child: Text('No recordings to process'),
                ),
    );
  }
}