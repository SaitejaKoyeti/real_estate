// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:file_picker/file_picker.dart';
// import "package:share/share.dart";
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
