// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class Employee extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('View Data'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Employees'),
//           StreamBuilder(
//             stream: FirebaseFirestore.instance.collection('employees').snapshots(),
//             builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }
//
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               }
//
//               // Process the employee data and display it in a DataTable
//               List<DataRow> employeeRows = snapshot.data!.docs.map((DocumentSnapshot document) {
//                 Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//
//                 return DataRow(
//                   cells: [
//                     DataCell(Text(data['id'] ?? '')),
//                     DataCell(Text(data['name'] ?? '')),
//                     DataCell(Text(data['email'] ?? '')),
//                     DataCell(Text(data['phone'] ?? '')),
//                     DataCell(
//                       Text(data['type'] ?? ''),
//                       // Add a Send icon here
//                       onTap: () {
//                         _sendDetails(context, data);
//                       },
//                     ),
//                   ],
//                 );
//               }).toList();
//
//               return DataTable(
//                 columns: [
//                   DataColumn(label: Text('ID')),
//                   DataColumn(label: Text('Name')),
//                   DataColumn(label: Text('Email')),
//                   DataColumn(label: Text('Phone')),
//                   DataColumn(label: Text('Type')),
//                 ],
//                 rows: employeeRows,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Function to send details to a particular customer
//   void _sendDetails(BuildContext context, Map<String, dynamic> employeeData) {
//     // Extract the details you want to send
//     String employeeName = employeeData['name'];
//     String employeeEmail = employeeData['email'];
//     String employeePhone = employeeData['phone'];
//
//     // Replace this with your logic to send the details to the customer
//     // You might want to use a navigation push to another page or some other method
//     // For example, you can use Navigator.push to navigate to another page and pass the details
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CustomerDetailsPage(
//           employeeName: employeeName,
//           employeeEmail: employeeEmail,
//           employeePhone: employeePhone,
//         ),
//       ),
//     );
//   }
// }
//
// // Example of a CustomerDetailsPage
// class CustomerDetailsPage extends StatelessWidget {
//   final String employeeName;
//   final String employeeEmail;
//   final String employeePhone;
//
//   const CustomerDetailsPage({
//     required this.employeeName,
//     required this.employeeEmail,
//     required this.employeePhone,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Implement your UI to display the details
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Customer Details for $employeeName'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Name: $employeeName'),
//           Text('Email: $employeeEmail'),
//           Text('Phone: $employeePhone'),
//           // Add more details as needed
//         ],
//       ),
//     );
//   }
// }
