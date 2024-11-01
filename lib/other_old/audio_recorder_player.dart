import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

typedef _Fn = void Function();

class AudioRecorderPlayer extends StatefulWidget {
  const AudioRecorderPlayer({super.key});

  @override
  State<AudioRecorderPlayer> createState() => _AudioRecorderPlayerState();
}

class _AudioRecorderPlayerState extends State<AudioRecorderPlayer> {
  Codec _codec = Codec.aacMP4;
  String? _mPath;
  String? _mFolder;
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  @override
  void initState() {
    super.initState();
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  Future<void> record() async {
    // Create a new folder with current date and time
    final now = DateTime.now();
    final folderName = DateFormat('MyDiary/yyyy-MM-dd_HH-mm-ss').format(now);
    _mFolder = await createFolderInAppDocDir(folderName);
    _mPath = '$_mFolder/recording.${_codec == Codec.opusWebM ? 'webm' : 'mp4'}';

    await _mRecorder!.startRecorder(
      toFile: _mPath,
      codec: _codec,
    );
    setState(() {});
  }

  Future<void> stopRecorder() async {
    await _mRecorder!.stopRecorder();
    setState(() {
      _mplaybackReady = true;
    });
  }

  Future<void> play() async {
    assert(_mPlayerIsInited && _mplaybackReady && _mRecorder!.isStopped);
    await _mPlayer!.startPlayer(
      fromURI: _mPath,
      whenFinished: () {
        setState(() {});
      },
    );
    setState(() {});
  }

  Future<void> stopPlayer() async {
    await _mPlayer!.stopPlayer();
    setState(() {});
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  Future<String> createFolderInAppDocDir(String folderName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory appDocDirFolder = Directory('${appDocDir.path}/$folderName/');

    if (await appDocDirFolder.exists()) {
      return appDocDirFolder.path;
    } else {
      final Directory newFolder = await appDocDirFolder.create(recursive: true);
      return newFolder.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: getRecorderFn(),
              child: Icon(_mRecorder!.isRecording ? Icons.stop : Icons.mic),
            ),
            const SizedBox(width: 20),
            FloatingActionButton(
              onPressed: getPlaybackFn(),
              child: Icon(_mPlayer!.isPlaying ? Icons.stop : Icons.play_arrow),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(_mRecorder!.isRecording
            ? "Recording..."
            : _mPlayer!.isPlaying
                ? "Playing..."
                : "Tap to record or play"),
        if (_mFolder != null) const SizedBox(height: 10),
        if (_mFolder != null) Text("Recording saved in: $_mFolder"),
      ],
    );
  }
}