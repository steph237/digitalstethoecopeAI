import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mboathoscope/buttons/SaveButton.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'WaveformButton.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' as Path;
import 'package:uuid/uuid.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

class headerHalf extends StatefulWidget {
  const headerHalf({Key? key}) : super(key: key);

  @override
  State<headerHalf> createState() => _headerHalfState();
}

class _headerHalfState extends State<headerHalf> {
  final recorder = SoundRecorder();

  @override
  void initState() {
    super.initState();

    recorder.init();
  }

  @override
  void dispose() {
    super.dispose();

    recorder.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = recorder.isRecording;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 34.0, left: 20, right: 20),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Image.asset(
                  'assets/images/img_head.png',
                  height: 80,
                  width: 80,
                ),
              ),
              const SizedBox(
                width: 150,
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Image.asset(
                          'assets/images/img_notiblack.png',
                          height: 30,
                          width: 32,
                          color: const Color(0xff3D79FD),
                        ),
                      ),
                      const Positioned(
                        bottom: 0.02,
                        right: 3,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xff3D79FD),
                          foregroundColor: Colors.white,
                        ), //CircularAvatar
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
            left: 8.0,
            top: 20.0,
            bottom: 20.0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                //padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/img_round.png',
                        height: 80,
                        width: 80,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/img_heart.png',
                              height: 25,
                              width: 25,
                            ),
                            const Text(
                              'heart',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: GestureDetector(
                  onLongPress: () async {
                    final isRecording = await recorder._toggleRecord();
                    setState(() {
                      backgroundColor:
                      Color(0xffc70018);
                      // foregroundColor: Colors.white,
                    });
                  },
                  onLongPressEnd: (_) async {
                    final isRecording = await recorder._toggleRecord();
                    log("stop recordiing");
                    // stop recording
                  },
                  child: Image.asset(
                    'assets/images/img_record.png',
                    height: 150,
                    width: 150,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 17.0, right: 17.0),
                  child: SaveButton(
                    txt: 'Save',
                    onPress: () {
                      null;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Press and hold the button to transmit the sound',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
          ),
        ),
        const Padding(
          padding:
              EdgeInsets.only(top: 20.0, bottom: 35.0, left: 35.0, right: 35.0),
          child: Text(
            'Please ensure that you are wearing noise cancelling headphones',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 18.0, top: 25.0),
              child: Text(
                'Recordings',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SoundRecorder {
  bool _isRecorderInitialised = false;
  bool get isRecording => _audioRecorder!.isRecording;
  FlutterSoundRecorder? _audioRecorder;

  static final _audioPlayer = AssetsAudioPlayer();

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission denied');
    }
    await _audioRecorder!.openRecorder();
    _isRecorderInitialised = true;
  }

  void dispose() async {
    if (!_isRecorderInitialised) return;

    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    _isRecorderInitialised = false;
  }

  Future _record() async {
    // set codec
    Codec _codec = Codec.aacMP4;
    String pathToSaveAudio = 'audio.mp4';
    const theSource = AudioSource.microphone;

    var tempPath = await getExternalStorageDirectories();
    pathToSaveAudio = "${tempPath?.first.path}/$pathToSaveAudio";

    if (!_isRecorderInitialised) return;
    await _audioRecorder!.startRecorder(
        toFile: pathToSaveAudio, codec: _codec, audioSource: theSource);


    log(pathToSaveAudio);
  }

  Future _stop() async {
    if (!_isRecorderInitialised) return;
    await _audioRecorder!.stopRecorder();
  }

  Future _toggleRecord() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
    log("toggle record");
  }
  static Future<void> openRecording(String recordPath) async {
    _audioPlayer.open(
      Audio.file(recordPath),
      showNotification: true,
    );
  }

  static void play(){
    _audioPlayer.play();
  }

  static void pause(){
    _audioPlayer.pause();
  }

  static Future<void> stopPlaying() async {
    _audioPlayer.stop();
  }

  static Future<List<FileSystemEntity>> getAudio() async {
    try {
      Directory recordings = Directory('/storage/emulated/0/Android/data/com.mboalab.community.opensource.outreachy.mboathoscope/files/');
      List<FileSystemEntity> files = await recordings.list().toList();
      return files;
    } catch (error) {
      print(error);
      return [];
    }
  }
}

