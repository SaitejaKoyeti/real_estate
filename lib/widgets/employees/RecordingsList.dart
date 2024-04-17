import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:audioplayers/src/source.dart' as audio_players_source;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordingsList extends StatefulWidget {
  final String customerId;

  const RecordingsList({
    required this.customerId, required String employeeId,
  });

  @override
  _RecordingsListState createState() => _RecordingsListState();
}

class _RecordingsListState extends State<RecordingsList> {
  late List<String> audioPaths = [];
  late AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRecordings();
  }

  void fetchRecordings() async {
    QuerySnapshot recordingsSnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.customerId)
        .collection('recordings')
        .get();

    setState(() {
      audioPaths = recordingsSnapshot.docs
          .map((doc) =>
      (doc.data() as Map<String, dynamic>)['audio_path'] as String?)
          .where((audioPath) => audioPath != null)
          .map((audioPath) => audioPath!)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recordings:'),
        if (audioPaths.isEmpty)
          Text('No recordings available for this customer')
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: audioPaths.length,
            itemBuilder: (context, index) {
              final audioPath = audioPaths[index];
              return ListTile(
                title: Text('Recording ${index + 1}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: () async {
                        // await playRecording(audioPath);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () async {
                        await stopPlayback();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // Future<void> playRecording(String audioPath) async {
  //   try {
  //     if (kIsWeb) {
  //       html.AudioElement audioElement = html.AudioElement()
  //         ..src = audioPath
  //         ..autoplay = true;
  //       html.document.body!.append(audioElement);
  //     } else {
  //       if (audioPath.isNotEmpty) {
  //         audio_players_source.Source urlSource =
  //         audio_players_source.UrlSource(audioPath);
  //         await audioPlayer.play(urlSource);
  //       }
  //     }
  //   } catch (e) {
  //     print('Error playing audio: $e');
  //   }
  // }

  Future<void> stopPlayback() async {
    try {
      if (!kIsWeb) {
        await audioPlayer.stop();
      }
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
