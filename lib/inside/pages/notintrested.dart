// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:push_notifications_firebase_flutter/pages/calendar.dart';
// class Customer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//         title: Text('View Data'),
//     ),
//     body: SingleChildScrollView(
//     child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//     Text('Customers'),
//     StreamBuilder(
//     stream: FirebaseFirestore.instance.collection('customers').snapshots(),
//     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//     if (snapshot.hasError) {
//     return Text('Error: ${snapshot.error}');
//     }
//
//     if (snapshot.connectionState == ConnectionState.waiting) {
//     return CircularProgressIndicator();
//     }
//
//     List<DataRow> customerRows = snapshot.data!.docs.map((DocumentSnapshot document) {
//     Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//
//     String getLastFourDigits(String phoneNumber) {
//     if (phoneNumber != null && phoneNumber.length >= 4) {
//     return '+91 *** ' + phoneNumber.substring(phoneNumber.length - 4);
//     } else {
//     return phoneNumber ?? '';
//     }
//     }
//
//     return DataRow(
//     cells: [
//     DataCell(Text(data['id'] ?? '')),
//     DataCell(Text(data['name'] ?? '')),
//     DataCell(Text(data['email'] ?? '')),
//     DataCell(Text(getLastFourDigits(data['phone']))),
//     ]
//     );
//
//     });
//
//
//
//     )
//     ]
//
//     ),
//     );
//     }