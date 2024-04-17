import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/src/source.dart' as audio_players_source;

class ViewRecordingsScreen extends StatefulWidget {
  final String employeeId;
  final List<String> audioPaths;

  const ViewRecordingsScreen({
    required this.employeeId,
    required this.audioPaths,
    required Function(BuildContext p1, String p2) playRecording,
  });

  @override
  _ViewRecordingsScreenState createState() => _ViewRecordingsScreenState();
}

class _ViewRecordingsScreenState extends State<ViewRecordingsScreen> {
  late AudioPlayer audioPlayer;
  late List<Map<String, dynamic>> recordings;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    recordings = []; // Initialize the recordings list
    fetchRecordings();
  }

  Future<void> fetchRecordings() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(widget.employeeId)
          .collection('recordings')
          .get();

      setState(() {
        recordings = snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (error) {
      print('Error fetching recordings: $error');
    }
  }

  Future<void> playRecording(BuildContext context, String audioPath) async {
    try {
      // Play the recording using AudioPlayer
      audio_players_source.Source urlSource =
      audio_players_source.UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  void pauseRecording() {
    audioPlayer.pause();
  }

  void stopRecording() {
    audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recordings'),
      ),
      body: recordings.isEmpty
          ? Center(
        child: Text('No recordings available for this employee'),
      )
          : ListView.builder(
        itemCount: recordings.length,
        itemBuilder: (context, index) {
          String audioPath = recordings[index]['audio_path'];
          String customerId = recordings[index]['customer_id'];

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('customers')
                .doc(customerId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return ListTile(
                  title: Text('Recording $index'),
                  subtitle: Text('Customer details not available'),
                );
              } else {
                Map<String, dynamic> customerData =
                snapshot.data!.data()!;
                String customerName = customerData['name'];

                return ListTile(
                  title: Text('Recording for $customerName'),
                  subtitle: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => playRecording(context, audioPath),
                        child: Text('Play'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: pauseRecording,
                        child: Text('Pause'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: stopRecording,
                        child: Text('Stop'),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}