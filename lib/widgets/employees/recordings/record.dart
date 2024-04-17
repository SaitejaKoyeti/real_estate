import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/src/source.dart' as audio_players_source;
import 'package:provider/provider.dart';
import 'AudioRecorderProvider.dart';

class AudioRecorder extends StatefulWidget {
  final String userId;

  AudioRecorder({required this.userId});

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  late AudioRecorderProvider audioRecorderProvider;

  String audioPath = '';
  CollectionReference audioCollection = FirebaseFirestore.instance.collection('audio');
  static String? storedAudioPath;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = Record();
    audioRecorderProvider = Provider.of<AudioRecorderProvider>(context, listen: false);
  }

  @override
  void dispose() {
    // audioRecord.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        // Hide the status bar during recording
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
          Brightness.dark, // Set to Brightness.dark to hide the microphone icon
        ));
        audioRecorderProvider.startRecording();
      }
    } catch (e) {
      print('Error Start Recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      audioRecorderProvider.stopRecording();
      setState(() {
        audioPath = path!;
      });

      // Save audio file to Firestore
      await storeRecording(widget.userId, audioPath);

      // Reset status bar color and icon to their defaults
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: null,
        statusBarIconBrightness: null,
      ));
    } catch (e) {
      print('Error Stopping Recording: $e');
    }
  }

  Future<void> storeRecording(String userId, String audio_path) async {
    FirebaseFirestore.instance.collection('employees').doc(userId).collection('recordings').add({
      'audio_path': audio_path,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Store the audio path in the static variable
    storedAudioPath = audio_path;
  }

  Future<void> playRecording() async {
    try {
      audio_players_source.Source urlSource =
      audio_players_source.UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      print('Error playing Recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('visited'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (audioRecorderProvider.isRecording) {
                  await stopRecording();
                } else {
                  await startRecording();
                }

                setState(() {
                  // Update the button text immediately after clicking
                  audioRecorderProvider.isRecording
                      ? 'Completed Visit'
                      : 'Reached location';
                });
              },
              child: Text(
                audioRecorderProvider.isRecording ? 'Completed Visit' : 'Reached location',
              ),
            ),




            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}