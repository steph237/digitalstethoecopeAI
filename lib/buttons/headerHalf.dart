import 'dart:async';
import 'dart:developer';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mboathoscope/buttons/SaveButton.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'WaveformButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:assets_audio_player/assets_audio_player.dart';



class headerHalf extends ConsumerStatefulWidget {
  const headerHalf({Key? key}) : super(key: key);

  @override
  ConsumerState<headerHalf> createState() => _headerHalfState();
}

class _headerHalfState extends ConsumerState<headerHalf> {
  final recorder = SoundRecorder();
  String _recordTxt = '00:00:00';

  @override
  void initState(){
    super.initState();

    recorder.init();
  }

  @override
  void dispose(){
    super.dispose();

    recorder.dispose();
  }

  void initializer() async{

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
        Container(
          child: Text(
            _recordTxt,
            style: const TextStyle(fontSize: 70),
          )
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

                    });

                  },
                  onLongPressEnd: (_) async {
                    final isRecording = await recorder._toggleRecord();
                    log("stop recordiing");

                    // ref.read(listProvider.notifier).state = {
                    //   'refresh list': true
                    // };
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
  String _recordTxt = '00:00:00';
final   pathToSaveAudio = '/storage/MyRecordings/temp.wav';
  Future init() async{
    _audioRecorder =FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted){
      throw RecordingPermissionException('Microphone permission denied');
    }
    await _audioRecorder!.openRecorder();
    _isRecorderInitialised = true;
    await _audioRecorder?.setSubscriptionDuration(const Duration(
        milliseconds: 10));
    await initializeDateFormatting();

    Directory directory = Directory(pathToSaveAudio!);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }
  void dispose() async{

    if (!_isRecorderInitialised) return;

    _audioRecorder!.closeRecorder();
    _audioRecorder = null;
    _isRecorderInitialised = false;
  }

  Future _record() async {
    if (!_isRecorderInitialised) return;
    await _audioRecorder!.startRecorder(
        toFile: pathToSaveAudio,
        codec: Codec.pcm16WAV);


    StreamSubscription _recorderSubscription =
    _audioRecorder!.onProgress!.listen((e) {
      var date = DateTime.fromMillisecondsSinceEpoch(
          e.duration.inMilliseconds,
          isUtc: true);
      var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);


    });

    _recorderSubscription.cancel();

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
    log("start record");
  }

  static Future<List<FileSystemEntity>> getRecordings() async {
    try {
      Directory recordings = Directory('/MyRecordings');
      List<FileSystemEntity> files = await recordings.list().toList();
      return files;
    } catch (error) {
      print(error);
      return [];
    }
  }
}
