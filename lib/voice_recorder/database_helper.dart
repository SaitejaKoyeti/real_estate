// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<void> insertRecording(String path, String timestamp) async {
//     await _firestore.collection('recordings').add({
//       'path': path,
//       'timestamp': timestamp,
//     });
//   }
//
//   Future<List<Map<String, dynamic>>> getRecordings() async {
//     QuerySnapshot querySnapshot = await _firestore.collection('recordings').get();
//     return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//   }
// }
