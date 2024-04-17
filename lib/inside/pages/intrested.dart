// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:url_launcher/url_launcher.dart';
//
// class Intrested extends StatefulWidget {
//   const Intrested({Key? key}) : super(key: key);
//
//   @override
//   State<Intrested> createState() => _Intrested();
// }
//
// class _Intrested extends State<Intrested> {
//   final int _rowsPerPage = 10; // Number of rows per page
//   late String _loggedInEmployeeId;
//   bool _showInterestedCustomers = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentEmployeeId();
//   }
//
//   void _getCurrentEmployeeId() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _loggedInEmployeeId = user.uid;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           'Click here',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(_showInterestedCustomers ? Icons.check_circle : Icons.cancel),
//             onPressed: () {
//               setState(() {
//                 _showInterestedCustomers = !_showInterestedCustomers;
//               });
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.black,
//
//       body: Container(
//         padding: EdgeInsets.all(16),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: _showInterestedCustomers
//               ? FirebaseFirestore.instance
//               .collection("interested_customers")
//               .where('employeeId', isEqualTo: _loggedInEmployeeId)
//               .snapshots()
//               : FirebaseFirestore.instance
//               .collection("not_interested_customers")
//               .where('employeeId', isEqualTo: _loggedInEmployeeId)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             }
//
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Text('No data available');
//             }
//
//             return PaginatedDataTable(
//               header: Text(_showInterestedCustomers ? 'Interested Customers' : 'Not Interested Customers'),
//               rowsPerPage: _rowsPerPage,
//               columns: [
//                 DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                 DataColumn(label: Text('Customer Phone', style: TextStyle(fontWeight: FontWeight.bold))),
//                 DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
//               ],
//               source: _MyDataSource(snapshot.data!.docs),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class _MyDataSource extends DataTableSource {
//   final List<DocumentSnapshot> _data;
//
//   _MyDataSource(this._data);
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) {
//       return null;
//     }
//
//     var data = _data[index].data() as Map<String, dynamic>;
//
//     return DataRow(
//       cells: [
//         DataCell(Text(data["customerName"].toString())),
//         DataCell(MaskedPhoneNumber(data["customerPhone"].toString())),
//         DataCell(
//           IconButton(
//             icon: Icon(Icons.message),
//             onPressed: () {
//               _generateAndSendPDF(data["customerPhone"].toString());
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//
//
//   @override
//   int get rowCount => _data.length;
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get selectedRowCount => 0;
//
//   Future<void> _generateAndSendPDF(String customerPhone) async {
//     // Generate PDF
//     final pdf = pw.Document();
//
//     // Add custom font
//     final fontData = await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf");
//     final ttf = pw.Font.ttf(fontData);
//
//     pdf.addPage(pw.Page(
//       build: (context) => pw.Center(
//         child: pw.Text(
//           'Hello World!',
//           style: pw.TextStyle(font: ttf),
//         ),
//       ),
//     ));
//
//     // Convert PDF to bytes
//     final Uint8List pdfBytes = await pdf.save();
//
//     // Upload PDF to Firestore storage
//     final storage = firebase_storage.FirebaseStorage.instance;
//     final ref = storage.ref().child('pdfs').child('customer_$customerPhone.pdf');
//     await ref.putData(pdfBytes);
//
//     // Get PDF download URL
//     final String downloadURL = await ref.getDownloadURL();
//
//     // Send PDF link through WhatsApp
//     _sendPDFViaWhatsApp(downloadURL, customerPhone);
//   }
//
//
//   void _sendPDFViaWhatsApp(String downloadURL, String customerPhone) async {
//     // Construct the WhatsApp message with the download URL
//     String message = "Here is the PDF link: $downloadURL";
//
//     // Encode the message for URL
//     String encodedMessage = Uri.encodeComponent(message);
//
//     // Construct the WhatsApp URL with the encoded message
//     String url = "https://api.whatsapp.com/send?text=$encodedMessage";
//
//     // Check if WhatsApp is installed on the device and launch the URL
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       print('Could not launch $url');
//     }
//   }
//
//
// }
//
// class MaskedPhoneNumber extends StatelessWidget {
//   final String phoneNumber;
//
//   MaskedPhoneNumber(this.phoneNumber);
//
//   @override
//   Widget build(BuildContext context) {
//     // Display only the last 4 digits of the phone number
//     String maskedNumber = '*' + phoneNumber.substring(phoneNumber.length - 4);
//
//     return Text(maskedNumber);
//   }
// }
//
//
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:url_launcher/url_launcher.dart';
//
// class Intrested extends StatefulWidget {
//   const Intrested({Key? key}) : super(key: key);
//
//   @override
//   State<Intrested> createState() => _Intrested();
// }
//
// class _Intrested extends State<Intrested> {
//   final int _rowsPerPage = 10; // Number of rows per page
//   late String _loggedInEmployeeId;
//   bool _showInterestedCustomers = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentEmployeeId();
//   }
//
//   void _getCurrentEmployeeId() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _loggedInEmployeeId = user.uid;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           'Click here',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(_showInterestedCustomers ? Icons.check_circle : Icons.cancel),
//             onPressed: () {
//               setState(() {
//                 _showInterestedCustomers = !_showInterestedCustomers;
//               });
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.black,
//
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           child: StreamBuilder<QuerySnapshot>(
//             stream: _showInterestedCustomers
//                 ? FirebaseFirestore.instance
//                 .collection("interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots()
//                 : FirebaseFirestore.instance
//                 .collection("not_interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }
//
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Text('No data available');
//               }
//
//               return PaginatedDataTable(
//                 header: Text(_showInterestedCustomers
//                     ? 'Interested Customers'
//                     : 'Not Interested Customers'),
//                 rowsPerPage: _rowsPerPage,
//                 columns: [
//                   DataColumn(
//                       label: Text('Customer Name',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(
//                       label: Text('Customer Phone',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(
//                       label: Text('Actions',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//                 source: _MyDataSource(snapshot.data!.docs),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _MyDataSource extends DataTableSource {
//   final List<DocumentSnapshot> _data;
//
//   _MyDataSource(this._data);
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) {
//       return null;
//     }
//
//     var data = _data[index].data() as Map<String, dynamic>;
//
//     return DataRow(
//       cells: [
//         DataCell(Text(data["customerName"].toString())),
//         DataCell(MaskedPhoneNumber(data["customerPhone"].toString())),
//         DataCell(
//           SizedBox(
//             width: 48, // Adjust the width as needed
//             child: IconButton(
//               icon: Icon(Icons.message),
//               onPressed: () {
//                 _generateAndSendPDF(data["customerPhone"].toString());
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   int get rowCount => _data.length;
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get selectedRowCount => 0;
//
//   Future<void> _generateAndSendPDF(String customerPhone) async {
//     // Generate PDF
//     final pdf = pw.Document();
//
//     // Add custom font
//     final fontData = await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf");
//     final ttf = pw.Font.ttf(fontData);
//
//     pdf.addPage(pw.Page(
//       build: (context) => pw.Center(
//         child: pw.Text(
//           'Hello World!',
//           style: pw.TextStyle(font: ttf),
//         ),
//       ),
//     ));
//
//     // Convert PDF to bytes
//     final Uint8List pdfBytes = await pdf.save();
//
//     // Upload PDF to Firestore storage
//     final storage = firebase_storage.FirebaseStorage.instance;
//     final ref = storage.ref().child('pdfs').child('customer_$customerPhone.pdf');
//     await ref.putData(pdfBytes);
//
//     // Get PDF download URL
//     final String downloadURL = await ref.getDownloadURL();
//
//     // Send PDF link through WhatsApp
//     _sendPDFViaWhatsApp(downloadURL, customerPhone);
//   }
//
//
//   void _sendPDFViaWhatsApp(String downloadURL, String customerPhone) async {
//     // Construct the WhatsApp message with the download URL
//     String message = "Here is the PDF link: $downloadURL";
//
//     // Encode the message for URL
//     String encodedMessage = Uri.encodeComponent(message);
//
//     // Construct the WhatsApp URL with the encoded message
//     String url = "https://api.whatsapp.com/send?text=$encodedMessage";
//
//     // Check if WhatsApp is installed on the device and launch the URL
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       print('Could not launch $url');
//     }
//   }
//
//
// }
//
// class MaskedPhoneNumber extends StatelessWidget {
//   final String phoneNumber;
//
//   MaskedPhoneNumber(this.phoneNumber);
//
//   @override
//   Widget build(BuildContext context) {
//     // Display only the last 4 digits of the phone number
//     String maskedNumber = '*' + phoneNumber.substring(phoneNumber.length - 4);
//
//     return Text(maskedNumber);
//   }
// }
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:url_launcher/url_launcher.dart';
//
// class Intrested extends StatefulWidget {
//   const Intrested({Key? key}) : super(key: key);
//
//   @override
//   State<Intrested> createState() => _Intrested();
// }
//
// class _Intrested extends State<Intrested> {
//   final int _rowsPerPage = 10; // Number of rows per page
//   late String _loggedInEmployeeId;
//   bool _showInterestedCustomers = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentEmployeeId();
//   }
//
//   void _getCurrentEmployeeId() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _loggedInEmployeeId = user.uid;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           'Click here',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(_showInterestedCustomers ? Icons.check_circle : Icons.cancel),
//             onPressed: () {
//               setState(() {
//                 _showInterestedCustomers = !_showInterestedCustomers;
//               });
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.email),
//             onPressed: () {
//               // Implement your email action here
//               _sendEmail();
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.black,
//
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           child: StreamBuilder<QuerySnapshot>(
//             stream: _showInterestedCustomers
//                 ? FirebaseFirestore.instance
//                 .collection("interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots()
//                 : FirebaseFirestore.instance
//                 .collection("not_interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }
//
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Text('No data available');
//               }
//
//               return PaginatedDataTable(
//                 header: Text(_showInterestedCustomers
//                     ? 'Interested Customers'
//                     : 'Not Interested Customers'),
//                 rowsPerPage: _rowsPerPage,
//                 columns: [
//                   DataColumn(
//                       label: Text('Customer Name',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(
//                       label: Text('Customer Phone',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(
//                       label: Text('Actions',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//                 source: _MyDataSource(snapshot.data!.docs),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _sendEmail() {
//     // Implement your email action here
//     // Example: launch email client
//     final Uri params = Uri(
//       scheme: 'mailto',
//       path: 'recipient@example.com',
//       query: 'subject=Subject&body=Body',
//     );
//     launch(params.toString());
//   }
// }
//
// class _MyDataSource extends DataTableSource {
//   final List<DocumentSnapshot> _data;
//
//   _MyDataSource(this._data);
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) {
//       return null;
//     }
//
//     var data = _data[index].data() as Map<String, dynamic>;
//
//     return DataRow(
//       cells: [
//         DataCell(Text(data["customerName"].toString())),
//         DataCell(MaskedPhoneNumber(data["customerPhone"].toString())),
//         DataCell(
//           SizedBox(
//             width: 48, // Adjust the width as needed
//             child: IconButton(
//               icon: Icon(Icons.message),
//               onPressed: () {
//                 _generateAndSendPDF(data["customerPhone"].toString());
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   int get rowCount => _data.length;
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get selectedRowCount => 0;
//
//   Future<void> _generateAndSendPDF(String customerPhone) async {
//     // Generate PDF
//     final pdf = pw.Document();
//
//     // Add custom font
//     final fontData = await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf");
//     final ttf = pw.Font.ttf(fontData);
//
//     pdf.addPage(pw.Page(
//       build: (context) => pw.Center(
//         child: pw.Text(
//           'Hello World!',
//           style: pw.TextStyle(font: ttf),
//         ),
//       ),
//     ));
//
//     // Convert PDF to bytes
//     final Uint8List pdfBytes = await pdf.save();
//
//     // Upload PDF to Firestore storage
//     final storage = firebase_storage.FirebaseStorage.instance;
//     final ref = storage.ref().child('pdfs').child('customer_$customerPhone.pdf');
//     await ref.putData(pdfBytes);
//
//     // Get PDF download URL
//     final String downloadURL = await ref.getDownloadURL();
//
//     // Send PDF link through WhatsApp
//     _sendPDFViaWhatsApp(downloadURL, customerPhone);
//   }
//
//
//   // void _sendPDFViaWhatsApp(String downloadURL, String customerPhone) async {
//   //   // Construct the WhatsApp message with the download URL
//   //   String message = "Here is the PDF link: $downloadURL";
//   //
//   //   // Encode the message for URL
//   //   String encodedMessage = Uri.encodeComponent(message);
//   //
//   //   // Construct the WhatsApp URL with the encoded message
//   //   String url = "https://api.whatsapp.com/send?text=$encodedMessage";
//   //
//   //   // Check if WhatsApp is installed on the device and launch the URL
//   //   if (await canLaunch(url)) {
//   //     await launch(url);
//   //   } else {
//   //     print('Could not launch $url');
//   //   }
//   // }
//
//
// }
//
// class MaskedPhoneNumber extends StatelessWidget {
//   final String phoneNumber;
//
//   MaskedPhoneNumber(this.phoneNumber);
//
//   @override
//   Widget build(BuildContext context) {
//     // Display only the last 4 digits of the phone number
//     String maskedNumber = '*' + phoneNumber.substring(phoneNumber.length - 4);
//
//     return Text(maskedNumber);
//   }
// }
//
// class WhatsAppIntegrationPage extends StatefulWidget {
//   @override
//   _WhatsAppIntegrationPageState createState() => _WhatsAppIntegrationPageState();
// }
//
// class _WhatsAppIntegrationPageState extends State<WhatsAppIntegrationPage> {
//   final TextEditingController _messageController = TextEditingController();
//   List<dynamic> _chatMessages = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('WhatsApp Integration'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true,
//               itemCount: _chatMessages.length,
//               itemBuilder: (context, index) {
//                 final message = _chatMessages[index];
//                 if (message is TextMessage && !message.sent) {
//                   return ChatMessage(message: message.message, timestamp: message.timestamp);
//                 } else if (message is FileMessage && !message.sent) {
//                   return FileMessageWidget(fileMessage: message);
//                 } else {
//                   return SizedBox(); // Placeholder for other message types
//                 }
//               },
//             ),
//           ),
//           Divider(height: 0),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     _sendMessage(_messageController.text);
//                   },
//                   icon: Icon(Icons.send),
//                 ),
//                 IconButton(
//                   onPressed: _sharePDF,
//                   icon: Icon(Icons.attach_file),
//                 ),
//                 IconButton(
//                   onPressed: _startVoiceRecording,
//                   icon: Icon(Icons.keyboard_voice),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _sendMessage(String message) {
//     setState(() {
//       _chatMessages.insert(0, TextMessage(message: message, sent: true));
//     });
//     _messageController.clear();
//   }
//
//   void _sharePDF() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//
//     if (result != null) {
//       String filePath = result.files.single.path!;
//       String fileName = result.files.single.name;
//
//       setState(() {
//         _chatMessages.insert(0, FileMessage(filePath: filePath, fileName: fileName, sent: true));
//       });
//
//       try {
//         await Share.shareFiles([filePath], text: 'Check out this PDF: $fileName');
//         _showSnackbar(context, 'PDF shared successfully: $fileName');
//       } catch (e) {
//         print('Error sharing PDF: $e');
//         _showSnackbar(context, 'Error sharing PDF: $e');
//       }
//     } else {
//       print('User canceled the file picker.');
//     }
//   }
//
//   void _startVoiceRecording() {
//     _showSnackbar(context, 'Voice recording feature will be implemented soon.');
//   }
//
//   void _showSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
//
// class ChatMessage extends StatelessWidget {
//   final String message;
//   final DateTime timestamp;
//
//   const ChatMessage({Key? key, required this.message, required this.timestamp}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.blue[100],
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             padding: EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   message,
//                   style: TextStyle(fontSize: 16.0),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   '${timestamp.hour}:${timestamp.minute}',
//                   style: TextStyle(fontSize: 12.0, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class TextMessage {
//   final String message;
//   final DateTime timestamp;
//   final bool sent;
//
//   TextMessage({required this.message, DateTime? timestamp, this.sent = false})
//       : timestamp = timestamp ?? DateTime.now();
// }
//
// class FileMessage {
//   final String filePath;
//   final String fileName;
//   final bool sent;
//
//   FileMessage({required this.filePath, required this.fileName, this.sent = false});
// }
//
// class FileMessageWidget extends StatelessWidget {
//   final FileMessage fileMessage;
//
//   const FileMessageWidget({Key? key, required this.fileMessage}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.green[100],
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             padding: EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Sent file:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   fileMessage.fileName,
//                   style: TextStyle(fontSize: 16.0),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:url_launcher/url_launcher.dart';
//
// class Intrested extends StatefulWidget {
//   const Intrested({Key? key}) : super(key: key);
//
//   @override
//   State<Intrested> createState() => _Intrested();
// }
//
// class _Intrested extends State<Intrested> {
//   final int _rowsPerPage = 10; // Number of rows per page
//   late String _loggedInEmployeeId;
//   bool _showInterestedCustomers = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentEmployeeId();
//   }
//
//   void _getCurrentEmployeeId() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _loggedInEmployeeId = user.uid;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           'Click here',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(_showInterestedCustomers ? Icons.check_circle : Icons.cancel),
//             onPressed: () {
//               setState(() {
//                 _showInterestedCustomers = !_showInterestedCustomers;
//               });
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.email),
//             onPressed: () {
//               // Implement your email action here
//               _sendEmail();
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.black,
//
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           child: StreamBuilder<QuerySnapshot>(
//             stream: _showInterestedCustomers
//                 ? FirebaseFirestore.instance
//                 .collection("interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots()
//                 : FirebaseFirestore.instance
//                 .collection("not_interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }
//
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Text('No data available');
//               }
//
//               return PaginatedDataTable(
//                 header: Text(_showInterestedCustomers
//                     ? 'Interested Customers'
//                     : 'Not Interested Customers'),
//                 rowsPerPage: _rowsPerPage,
//                 columns: [
//                   DataColumn(
//                       label: Text('Customer Name',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(
//                       label: Text('Customer Phone',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(
//                       label: Text('Actions',
//                           style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//                 source: _MyDataSource(snapshot.data!.docs),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _sendEmail() {
//     // Implement your email action here
//     // Example: launch email client
//     final Uri params = Uri(
//       scheme: 'mailto',
//       path: 'recipient@example.com',
//       query: 'subject=Subject&body=Body',
//     );
//     launch(params.toString());
//   }
// }
//
// class _MyDataSource extends DataTableSource {
//   final List<DocumentSnapshot> _data;
//
//   _MyDataSource(this._data);
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) {
//       return null;
//     }
//
//     var data = _data[index].data() as Map<String, dynamic>;
//
//     return DataRow(
//       cells: [
//         DataCell(Text(data["customerName"].toString())),
//         DataCell(MaskedPhoneNumber(data["customerPhone"].toString())),
//         DataCell(
//           SizedBox(
//             width: 48, // Adjust the width as needed
//             child: IconButton(
//               icon: Icon(Icons.message),
//               onPressed: () {
//                 _sendChatMessage(data["customerName"].toString(), data["customerPhone"].toString());
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   int get rowCount => _data.length;
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get selectedRowCount => 0;
//
//   void _sendChatMessage(String customerName, String customerPhone) {
//     // Implement your chat message action here
//     // For example, you can navigate to a chat screen with customer details
//     // or use a messaging service to send a chat message to the customer.
//     // Here's just a placeholder implementation:
//     print('Sending chat message to $customerName ($customerPhone)');
//   }
// }
//
// class MaskedPhoneNumber extends StatelessWidget {
//   final String phoneNumber;
//
//   MaskedPhoneNumber(this.phoneNumber);
//
//   @override
//   Widget build(BuildContext context) {
//     // Display only the last 4 digits of the phone number
//     String maskedNumber = '*' + phoneNumber.substring(phoneNumber.length - 4);
//
//     return Text(maskedNumber);
//   }
// }
// import 'dart:typed_data';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/rendering.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
// import 'package:url_launcher/url_launcher.dart';
//
// class Intrested extends StatefulWidget {
//   const Intrested({Key? key}) : super(key: key);
//
//   @override
//   State<Intrested> createState() => _Intrested();
// }
//
// class _Intrested extends State<Intrested> {
//   final int _rowsPerPage = 10; // Number of rows per page
//   late String _loggedInEmployeeId;
//   bool _showInterestedCustomers = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentEmployeeId();
//   }
//
//   void _getCurrentEmployeeId() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _loggedInEmployeeId = user.uid;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blueAccent,
//         title: Text(
//           'Click here',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(_showInterestedCustomers ? Icons.check_circle : Icons.cancel),
//             onPressed: () {
//               setState(() {
//                 _showInterestedCustomers = !_showInterestedCustomers;
//               });
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.email),
//             onPressed: () {
//               // Implement your email action here
//               // For example, launch email client with a pre-defined email address
//               _sendEmail('recipient@example.com');
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.black,
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.all(16),
//           child: StreamBuilder<QuerySnapshot>(
//             stream: _showInterestedCustomers
//                 ? FirebaseFirestore.instance
//                 .collection("interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots()
//                 : FirebaseFirestore.instance
//                 .collection("not_interested_customers")
//                 .where('employeeId', isEqualTo: _loggedInEmployeeId)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }
//
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Text('No data available');
//               }
//
//               return PaginatedDataTable(
//                 header: Text(_showInterestedCustomers ? 'Interested Customers' : 'Not Interested Customers'),
//                 rowsPerPage: _rowsPerPage,
//                 columns: [
//                   DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Customer Phone', style: TextStyle(fontWeight: FontWeight.bold))),
//                   DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
//                 ],
//                 source: _MyDataSource(snapshot.data!.docs, _sendEmail),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _sendEmail(String recipient) async {
//     final Uri params = Uri(
//       scheme: 'mailto',
//       path: recipient,
//       query: 'subject=Subject&body=Body',
//     );
//     launch(params.toString());
//   }
// }
//
// class _MyDataSource extends DataTableSource {
//   final List<DocumentSnapshot> _data;
//   final Function(String) _sendEmail;
//
//   _MyDataSource(this._data, this._sendEmail);
//
//   @override
//   DataRow? getRow(int index) {
//     if (index >= _data.length) {
//       return null;
//     }
//
//     var data = _data[index].data() as Map<String, dynamic>;
//
//     return DataRow(
//       cells: [
//         DataCell(Text(data["customerName"].toString())),
//         DataCell(MaskedPhoneNumber(data["customerPhone"].toString())),
//         DataCell(
//           Row(
//             children: [
//               IconButton(
//                 icon: Icon(Icons.email),
//                 onPressed: () {
//                   // Implement your email action here
//                   _sendEmail(data["customerEmail"].toString());
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.message),
//                 onPressed: () {
//                   _generateAndSendPDF(data["customerPhone"].toString());
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   int get rowCount => _data.length;
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get selectedRowCount => 0;
//
//   Future<void> _generateAndSendPDF(String customerPhone) async {
//     // Generate PDF
//     final pdf = pw.Document();
//
//     // Add custom font
//     final fontData = await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf");
//     final ttf = pw.Font.ttf(fontData);
//
//     pdf.addPage(pw.Page(
//       build: (context) => pw.Center(
//         child: pw.Text(
//           'Hello World!',
//           style: pw.TextStyle(font: ttf),
//         ),
//       ),
//     ));
//
//     // Convert PDF to bytes
//     final Uint8List pdfBytes = await pdf.save();
//
//     // Upload PDF to Firestore storage
//     final storage = firebase_storage.FirebaseStorage.instance;
//     final ref = storage.ref().child('pdfs').child('customer_$customerPhone.pdf');
//     await ref.putData(pdfBytes);
//
//     // Get PDF download URL
//     final String downloadURL = await ref.getDownloadURL();
//
//     // Send PDF link through WhatsApp
//     _sendPDFViaWhatsApp(downloadURL, customerPhone);
//   }
//
//   void _sendPDFViaWhatsApp(String downloadURL, String customerPhone) async {
//     // Construct the WhatsApp message with the download URL
//     String message = "Here is the PDF link: $downloadURL";
//
//     // Encode the message for URL
//     String encodedMessage = Uri.encodeComponent(message);
//
//     // Construct the WhatsApp URL with the encoded message
//     String url = "https://api.whatsapp.com/send?text=$encodedMessage";
//
//     // Check if WhatsApp is installed on the device and launch the URL
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       print('Could not launch $url');
//     }
//   }
// }
//
// class MaskedPhoneNumber extends StatelessWidget {
//   final String phoneNumber;
//
//   MaskedPhoneNumber(this.phoneNumber);
//
//   @override
//   Widget build(BuildContext context) {
//     // Display only the last 4 digits of the phone number
//     String maskedNumber = '*' + phoneNumber.substring(phoneNumber.length - 4);
//
//     return Text(maskedNumber);
//   }
// }
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:url_launcher/url_launcher.dart';

class Intrested extends StatefulWidget {
  const Intrested({Key? key}) : super(key: key);

  @override
  State<Intrested> createState() => _Intrested();
}

class _Intrested extends State<Intrested> {
  final int _rowsPerPage = 10; // Number of rows per page
  late String _loggedInEmployeeId;
  bool _showInterestedCustomers = true;

  @override
  void initState() {
    super.initState();
    _getCurrentEmployeeId();
  }

  void _getCurrentEmployeeId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loggedInEmployeeId = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Click here',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_showInterestedCustomers ? Icons.check_circle : Icons.cancel),
            onPressed: () {
              setState(() {
                _showInterestedCustomers = !_showInterestedCustomers;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.email),
            onPressed: () {
              // Implement your email action here
              // For example, launch email client with a pre-defined email address
              _sendEmail('recipient@example.com');
            },
          ),

        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: _showInterestedCustomers
                ? FirebaseFirestore.instance
                .collection("interested_customers")
                .where('employeeId', isEqualTo: _loggedInEmployeeId)
                .snapshots()
                : FirebaseFirestore.instance
                .collection("not_interested_customers")
                .where('employeeId', isEqualTo: _loggedInEmployeeId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No data available');
              }

              return PaginatedDataTable(
                header: Text(_showInterestedCustomers ? 'Interested Customers' : 'Not Interested Customers'),
                rowsPerPage: _rowsPerPage,
                columns: [
                  DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Customer Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                source: _MyDataSource(snapshot.data!.docs, _sendEmail),
              );
            },
          ),
        ),
      ),
    );
  }

  void _sendEmail(String recipient) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: recipient,
      query: 'subject=Subject&body=Body',
    );
    launch(params.toString());
  }
}
void _WhatsAppIntegrationPageState(String sms)async{

}
class _MyDataSource extends DataTableSource {
  final List<DocumentSnapshot> _data;
  final Function(String) _sendEmail;

  _MyDataSource(this._data, this._sendEmail);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) {
      return null;
    }

    var data = _data[index].data() as Map<String, dynamic>;

    return DataRow(
      cells: [
        DataCell(Text(data["customerName"].toString())),
        DataCell(MaskedPhoneNumber(data["customerPhone"].toString())),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.email),
                onPressed: () {
                  // Implement your email action here
                  _sendEmail(data["customerEmail"].toString());
                },
              ),
              IconButton(
                icon: Icon(Icons.message),
                onPressed: () {
                  _generateAndSendPDF(data["customerPhone"].toString());
                },
              ),
              IconButton(
                icon: Icon(Icons.message_outlined),
                onPressed: () {
                  _sendMessageThroughWhatsApp(data["customerPhone"].toString());


                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => _data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  Future<void> _generateAndSendPDF(String customerPhone) async {
    // Generate PDF
    final pdf = pw.Document();

    // Add custom font
    final fontData = await rootBundle.load("assets/fonts/IBMPlexSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(pw.Page(
      build: (context) => pw.Center(
        child: pw.Text(
          'Hello World!',
          style: pw.TextStyle(font: ttf),
        ),
      ),
    ));

    // Convert PDF to bytes
    final Uint8List pdfBytes = await pdf.save();

    // Upload PDF to Firestore storage
    final storage = firebase_storage.FirebaseStorage.instance;
    final ref = storage.ref().child('pdfs').child('customer_$customerPhone.pdf');
    await ref.putData(pdfBytes);

    // Get PDF download URL
    final String downloadURL = await ref.getDownloadURL();

    // Send PDF link through WhatsApp
    _sendPDFViaWhatsApp(downloadURL, customerPhone);
  }

  void _sendPDFViaWhatsApp(String downloadURL, String customerPhone) async {
    // Construct the WhatsApp message with the download URL
    String message = "Here is the PDF link: $downloadURL";

    // Encode the message for URL
    String encodedMessage = Uri.encodeComponent(message);

    // Construct the WhatsApp URL with the encoded message
    String url = "https://api.whatsapp.com/send?text=$encodedMessage";

    // Check if WhatsApp is installed on the device and launch the URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
void _sendMessageThroughWhatsApp(String customerPhone) async {
  // Implement your logic here to send a message through WhatsApp
  // You can use a similar approach as you did for sending PDFs
  // For example:
  // 1. Construct your message
  String message = "Your message here";

  // 2. Encode the message for URL
  String encodedMessage = Uri.encodeComponent(message);

  // 3. Construct the WhatsApp URL with the encoded message
  String url = "https://api.whatsapp.com/send?text=$encodedMessage";

  // 4. Check if WhatsApp is installed on the device and launch the URL
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('Could not launch $url');
  }
}


class MaskedPhoneNumber extends StatelessWidget {
  final String phoneNumber;

  MaskedPhoneNumber(this.phoneNumber);

  @override
  Widget build(BuildContext context) {
    // Display only the last 4 digits of the phone number
    String maskedNumber = '*' + phoneNumber.substring(phoneNumber.length - 4);

    return Text(maskedNumber);
  }
}
