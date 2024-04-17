// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:audio_recorder/audio_recorder.dart';
// import 'package:path/path.dart';
// import 'database_helper.dart';
//
//
//
// class MyHlomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   bool _isRecording = false;
//   late String _recordingPath;
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Voice Recorder'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _isRecording
//                 ? Text('Recording...')
//                 : ElevatedButton(
//               onPressed: _startRecording,
//               child: Text('Start Recording'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _stopRecording,
//               child: Text('Stop Recording and Save'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadRecordings,
//               child: Text('Load Recordings'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _startRecording() async {
//     if (!_isRecording) {
//       bool hasPermissions = await AudioRecorder.hasPermissions;
//       if (!hasPermissions) {
//         return; // Handle permission denied
//       }
//
//       Directory appDocDir = await getApplicationDocumentsDirectory();
//       String timestamp = DateTime.now().toIso8601String();
//       _recordingPath = join(appDocDir.path, 'recording_$timestamp.m4a');
//
//       await AudioRecorder.start(
//         path: _recordingPath,
//         audioOutputFormat: AudioOutputFormat.AAC_ADTS,
//       );
//
//       setState(() {
//         _isRecording = true;
//       });
//     }
//   }
//
//   Future<void> _stopRecording() async {
//     if (_isRecording) {
//       Recording recording = await AudioRecorder.stop();
//
//       setState(() {
//         _isRecording = false;
//       });
//
//       if (recording.status == RecordingStatus.Stopped) {
//         await _databaseHelper.insertRecording(_recordingPath, recording.timestamp);
//         print('Recording saved to Firebase');
//       }
//     }
//   }
//
//   Future<void> _loadRecordings() async {
//     List<Map<String, dynamic>> recordings = await _databaseHelper.getRecordings();
//     print('Loaded recordings from Firebase: $recordings');
//   }
// }
