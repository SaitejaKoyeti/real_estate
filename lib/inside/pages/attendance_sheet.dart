// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/rxdart.dart';
//
// class Attendance_ins extends StatefulWidget {
//   const Attendance_ins({Key? key}) : super(key: key);
//
//   @override
//   State<Attendance_ins> createState() => _Attendance_insState();
// }
//
// class _Attendance_insState extends State<Attendance_ins> {
//   late String loggedInUserEmail;
//
//   late Stream<List<AttendanceData>> _combinedStream;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUserEmail();
//
//     // Combine streams of employees and fetch loginTimes and logoutTimes
//     _combinedStream = _combineStreams();
//   }
//
//   Future<void> _getCurrentUserEmail() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       loggedInUserEmail = user.email!;
//       setState(() {});
//     }
//   }
//
//   Stream<List<AttendanceData>> _combineStreams() {
//     // Create stream controller for employees
//     final employeesController = FirebaseFirestore.instance.collection('employees').snapshots();
//
//     // Merge streams
//     return employeesController.asyncMap((employeesSnapshot) async {
//       final List<AttendanceData> result = [];
//
//       // Iterate over employees documents
//       for (final employeeDoc in employeesSnapshot.docs) {
//         final loginTimesQuerySnapshot = await employeeDoc.reference.collection('loginTimes').get();
//         final logoutTimesQuerySnapshot = await employeeDoc.reference.collection('logoutTimes').get();
//
//         // Iterate over loginTimes documents and convert Timestamp to String
//         final List<String> loginTimes =
//         loginTimesQuerySnapshot.docs.map<String>((doc) => _timestampToString(doc['time'])).toList();
//
//         // Iterate over logoutTimes documents and convert Timestamp to String
//         final List<String> logoutTimes =
//         logoutTimesQuerySnapshot.docs.map<String>((doc) => _timestampToString(doc['time'])).toList();
//
//         // Add data to result
//         result.add(
//           AttendanceData(
//             name: employeeDoc['name'],
//             email: employeeDoc['email'],
//             sales: employeeDoc['sales'],
//             loginTimes: loginTimes,
//             logoutTimes: logoutTimes,
//           ),
//         );
//       }
//
//       return result;
//     });
//   }
//
//   // Helper method to convert Timestamp to String
//   String _timestampToString(Timestamp timestamp) {
//     return timestamp.toDate().toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Attendance'),
//       ),
//       body: SingleChildScrollView(
//         child: StreamBuilder<List<AttendanceData>>(
//           stream: _combinedStream,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Text('Error: ${snapshot.error}'),
//               );
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(
//                 child: Text('No data available'),
//               );
//             } else {
//               return ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: snapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   final data = snapshot.data![index];
//                   // Display data as needed
//                   return Card(
//                     margin: EdgeInsets.all(10),
//                     elevation: 2,
//                     child: ListTile(
//                       title: Text(
//                         data.name,
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 5),
//                           Text(
//                             "Email: ${data.email}",
//                             style: TextStyle(fontSize: 14),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             "Sales: ${data.sales}",
//                             style: TextStyle(fontSize: 14),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             "Login Times:",
//                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                           ),
//                           for (var loginTime in data.loginTimes)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 2),
//                               child: Text(loginTime),
//                             ),
//                           SizedBox(height: 5),
//                           Text(
//                             "Logout Times:",
//                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                           ),
//                           for (var logoutTime in data.logoutTimes)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 2),
//                               child: Text(logoutTime),
//                             ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class AttendanceData {
//   final String name;
//   final String email;
//   final String sales;
//   final List<String> loginTimes;
//   final List<String> logoutTimes;
//
//   AttendanceData({
//     required this.name,
//     required this.email,
//     required this.sales,
//     required this.loginTimes,
//     required this.logoutTimes,
//   });
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: Attendance_ins(),
//   ));
// }