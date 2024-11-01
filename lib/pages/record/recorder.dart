import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';


import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'platform/audio_recorder_platform.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Recorder extends StatefulWidget {
  final void Function(String path) onStop;
  const Recorder({super.key, required this.onStop});

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> with AudioRecorderMixin {
  int _recordDuration = 0;
  Timer? _timer;
  late final AudioRecorder _audioRecorder;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;


  @override
  void initState() {
    _audioRecorder = AudioRecorder();

    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.opus;

        if (!await _isEncoderSupported(encoder)) {
          return;
        }

        final devs = await _audioRecorder.listInputDevices();
        debugPrint(devs.toString());

        const config = RecordConfig(encoder: encoder, numChannels: 1);

        // Record to file
        await recordFile(_audioRecorder, config);

        // Record to stream
        // await recordStream(_audioRecorder, config);

        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<String> transcribeAudio(String filePath) async {
    final url = Uri.parse("https://api.openai.com/v1/audio/transcriptions");

    var request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("file", filePath));
    
    String openAiKey = dotenv.get('OPENAI_API_KEY', fallback: '');
    request.headers.addAll({
      "Authorization": "Bearer $openAiKey",
    });

    request.fields["model"] = "whisper-1";
    request.fields["language"] = "de";

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        String transcription = jsonResponse['text'];
        return transcription;
      } else {
        throw Exception("Failed to transcribe audio. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }


  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
    debugPrint('Output path: $path');
    if (path != null) {
      downloadWebData(path);
      widget.onStop(path);
      if (!mounted) return; // Ensure the widget is still mounted
    }
  }

  Future<void> _pause() => _audioRecorder.pause();

  Future<void> _resume() => _audioRecorder.resume();

  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${e.name}');
        }
      }
    }

    return isSupported;
  }

  @override
  Widget build(BuildContext context) {
    SizedBox separatorBox = const SizedBox(width: 20);
    if (_recordState == RecordState.stop) {
      separatorBox = const SizedBox.shrink();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildRecordStopControl(),
            separatorBox,
            _buildPauseResumeControl(),
          ],
        ),
        const SizedBox(height: 40),
        _buildText(),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;
    double scalingFactor = 3.0;
    final colorScheme = Theme.of(context).colorScheme;
    if (_recordState != RecordState.stop) {
      scalingFactor /= 2;
      icon = Icon(Icons.stop, color: colorScheme.secondary, size: scalingFactor*30);
      color = colorScheme.secondary.withOpacity(0.1);
    } else {
      icon = Icon(Icons.mic, color: colorScheme.secondary, size: scalingFactor*30);
      color = colorScheme.secondary.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: scalingFactor*56, height: scalingFactor*56, child: icon),
          onTap: () {
            (_recordState != RecordState.stop) ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;
    double scalingFactor = 3.0 /2;
    final colorScheme = Theme.of(context).colorScheme;

    if (_recordState == RecordState.record) {
      icon = Icon(Icons.pause, color: colorScheme.secondary, size: scalingFactor*30);
      color = colorScheme.secondary.withOpacity(0.1);
    } else {
      icon = Icon(Icons.play_arrow, color: colorScheme.secondary, size: scalingFactor*30);
      color = colorScheme.secondary.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: scalingFactor*56, height: scalingFactor*56, child: icon),
          onTap: () {
            (_recordState == RecordState.pause) ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }
    return Text(
      "Waiting to record",
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
    );
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}