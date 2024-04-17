// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:audioplayers/src/source.dart' as audio_players_source;
//
// import 'recordings/ViewRecordingsScreen.dart';
// import 'selfies/ViewSelfiesScreen.dart';
//
// class EmployeeDetailsScreen extends StatelessWidget {
//   final DocumentSnapshot employee;
//
//   const EmployeeDetailsScreen({required this.employee});
//
//   Future<void> playRecording(BuildContext context, String audioPath) async {
//     try {
//       // Play the recording using AudioPlayer
//       AudioPlayer audioPlayer = AudioPlayer();
//       audio_players_source.Source urlSource =
//       audio_players_source.UrlSource(audioPath);
//       await audioPlayer.play(urlSource);
//     } catch (e) {
//       print('Error playing recording: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Employee Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             EmployeeDetailTile(
//               label: 'Name',
//               value: employee['name'],
//             ),
//             EmployeeDetailTile(
//               label: 'Sales',
//               value: employee['sales'],
//             ),
//             // Display a button to view all selfies
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         ViewSelfiesScreen(employeeId: employee.id),
//                   ),
//                 );
//               },
//               child: Text('View Selfies'),
//             ),
//             // Display a button to view all recordings
//             RecordingsList(employeeId: employee.id, playRecording: playRecording),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class RecordingsList extends StatelessWidget {
//   final String employeeId;
//
//   final Function(BuildContext, String) playRecording;
//
//   const RecordingsList({required this.employeeId, required this.playRecording});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<QuerySnapshot>(
//       future: FirebaseFirestore.instance
//           .collection('employees')
//           .doc(employeeId)
//           .collection('recordings')
//           .get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         }
//
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Text('No recordings available for this employee');
//         }
//
//         // Extract the list of audio paths
//         List<String> audioPaths = snapshot.data!.docs
//             .map((doc) => doc['audio_path'] as String)
//             .toList();
//
//         // Display list of recordings
//         return Column(
//           children: [
//             // Display a single button to view all recordings
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ViewRecordingsScreen(
//                       audioPaths: audioPaths,
//                       employeeId: employeeId, // Add this line
//                     ),
//                   ),
//                 );
//               },
//               child: Text('View All Recordings'),
//             ),
//
//           ],
//         );
//       },
//     );
//   }
// }
//
// class EmployeeDetailTile extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const EmployeeDetailTile({required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(
//         label,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       subtitle: Text(value),
//     );
//   }
// }
