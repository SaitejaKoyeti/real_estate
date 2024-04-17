// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:real_estate_project/widgets/employees/recordings/AudioRecorderProvider.dart';
// import 'package:record/record.dart';
// import 'package:twilio_flutter/twilio_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
//
// class AssignedCustomersPage1 extends StatefulWidget {
//   @override
//   _AssignedCustomersPage1State createState() => _AssignedCustomersPage1State();
// }
//
// class _AssignedCustomersPage1State extends State<AssignedCustomersPage1> {
//   late User user;
//   List<Map<String, dynamic>> assignedCustomers = [];
//   late Record audioRecord;
//   late AudioRecorderProvider audioRecorderProvider;
//   final TwilioFlutter twilioFlutter = TwilioFlutter(
//     accountSid: 'ACea352cee8e8c865a91cb95d394c0f079',
//     authToken: 'c220147ba8c89034363cc98a376686a7',
//     twilioNumber: '+12675364671',
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser!;
//     fetchAssignedCustomers();
//     audioRecord = Record();
//   }
//
//   Future<void> fetchAssignedCustomers() async {
//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot =
//       await FirebaseFirestore.instance
//           .collection('assignments')
//           .where('employeeId', isEqualTo: user.uid)
//           .get();
//
//       DateTime currentDate = DateTime.now();
//
//       setState(() {
//         assignedCustomers = snapshot.docs
//             .map((doc) => doc.data())
//             .where((assignment) {
//           DateTime eventTime = assignment['eventTime'].toDate();
//           return eventTime.isBefore(currentDate); // Filter out events after today
//         })
//             .toList();
//       });
//     } catch (error) {
//       print('Error fetching assigned customers: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     audioRecorderProvider = Provider.of<AudioRecorderProvider>(context);
//
//     // Filter the assignedCustomers based on event time
//     List<Map<String, dynamic>> filteredAssignments = assignedCustomers
//         .where((assignment) {
//       DateTime eventTime = assignment['eventTime'].toDate();
//       return eventTime.isBefore(DateTime.now());
//     })
//         .toList();
//
//     // Determine if there are no assigned customers or all events are after today
//     bool noAssignedCustomers = filteredAssignments.isEmpty;
//     bool allEventsAfterToday = filteredAssignments.every((assignment) {
//       DateTime eventTime = assignment['eventTime'].toDate();
//       return eventTime.isAfter(DateTime.now());
//     });
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       body: noAssignedCustomers || allEventsAfterToday
//           ? Center(
//         child: Text('No assigned customers or all events are after today.'),
//       )
//           : ListView.builder(
//         itemCount: filteredAssignments.length,
//         itemBuilder: (context, index) {
//           // Sort the assignments by event time in descending order
//           List<Map<String, dynamic>> sortedAssignments = filteredAssignments
//             ..sort((a, b) => b['eventTime'].compareTo(a['eventTime']));
//
//           Map<String, dynamic> assignment = sortedAssignments[index];
//           return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//             future: FirebaseFirestore.instance
//                 .collection('customers')
//                 .doc(assignment['customerId'])
//                 .get(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return SpinKitDoubleBounce(
//                   color: Colors.blue,
//                   size: 50.0,
//                 );
//               } else if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else if (!snapshot.hasData || !snapshot.data!.exists) {
//                 return ListTile(
//                   title: Text('Customer not found'),
//                   subtitle: Text('Customer details not available'),
//                 );
//               } else {
//                 Map<String, dynamic> customer = snapshot.data!.data()!;
//                 DateTime eventTime = assignment['eventTime'].toDate();
//                 String formattedEventTime =
//                 DateFormat('MMM d, y HH:mm a').format(eventTime);
//
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Card(
//                     elevation: 4,
//                     child: ListTile(
//                       title: Text('Name: ${customer['name']}'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   _launchPhoneCall(customer['phone']);
//                                 },
//                                 child: Row(
//                                   children: [
//                                     Text(
//                                       'Phone: ${formatPhoneNumber(customer['phone'])}',
//                                     ),
//                                     SizedBox(width: 125),
//                                     Icon(
//                                       Icons.phone,
//                                       color: Colors.blue,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Spacer(),
//                               ElevatedButton(
//                                 onPressed: () async {
//                                   if (audioRecorderProvider.isRecording) {
//                                     String? recordingUrl =
//                                     await audioRecord.stop();
//
//                                     FirebaseFirestore.instance
//                                         .collection('customers')
//                                         .doc(assignment['customerId'])
//                                         .collection('recordings')
//                                         .add({
//                                       'audio_path': recordingUrl,
//                                       'timestamp': Timestamp.now(),
//                                     });
//
//                                     audioRecorderProvider.stopRecording();
//                                   } else {
//                                     if (await audioRecord.hasPermission()) {
//                                       await audioRecord.start();
//                                       audioRecorderProvider.startRecording();
//                                     }
//                                   }
//                                 },
//                                 child: Icon(
//                                   audioRecorderProvider.isRecording
//                                       ? Icons.check_circle_outline
//                                       : Icons.location_on,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () async {
//                                   String? imageUrl = await takePhoto();
//                                   if (imageUrl != null) {
//                                     FirebaseFirestore.instance
//                                         .collection('customers')
//                                         .doc(assignment['customerId'])
//                                         .collection('photos')
//                                         .add({
//                                       'image_url': imageUrl,
//                                       'timestamp': Timestamp.now(),
//                                     });
//                                   }
//                                 },
//                                 icon: Icon(
//                                   Icons.camera_alt,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text('Event Time: $formattedEventTime'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Future<String?> takePhoto() async {
//     final picker = ImagePicker();
//     final XFile? image =
//     await picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       Reference reference = FirebaseStorage.instance.ref()
//           .child('photos')
//           .child(DateTime.now().toString());
//       UploadTask uploadTask = reference.putFile(File(image.path));
//       TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
//
//       String downloadURL = await snapshot.ref.getDownloadURL();
//
//       return downloadURL;
//     } else {
//       return null;
//     }
//   }
//
//   String formatPhoneNumber(String fullPhoneNumber) {
//     if (fullPhoneNumber.length >= 4) {
//       return '**${fullPhoneNumber.substring(fullPhoneNumber.length - 4)}';
//     } else {
//       return fullPhoneNumber;
//     }
//   }
//
//   void _launchPhoneCall(String phoneNumber) async {
//     String url = 'tel:$phoneNumber';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       print('Could not launch $url');
//     }
//   }
// }
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:real_estate_project/widgets/employees/recordings/AudioRecorderProvider.dart';
// import 'package:record/record.dart';
// import 'package:twilio_flutter/twilio_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
//
// class AssignedCustomersPage1 extends StatefulWidget {
//   @override
//   _AssignedCustomersPage1State createState() => _AssignedCustomersPage1State();
// }
//
// class _AssignedCustomersPage1State extends State<AssignedCustomersPage1> {
//   late User user;
//   List<Map<String, dynamic>> assignedCustomers = [];
//   late Record audioRecord;
//   late AudioRecorderProvider audioRecorderProvider;
//   final TwilioFlutter twilioFlutter = TwilioFlutter(
//     accountSid: 'ACea352cee8e8c865a91cb95d394c0f079',
//     authToken: 'c220147ba8c89034363cc98a376686a7',
//     twilioNumber: '+12675364671',
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser!;
//     fetchAssignedCustomers();
//     audioRecord = Record();
//   }
//
//   Future<void> fetchAssignedCustomers() async {
//     try {
//       QuerySnapshot<Map<String, dynamic>> snapshot =
//       await FirebaseFirestore.instance
//           .collection('assignments')
//           .where('employeeId', isEqualTo: user.uid)
//           .get();
//
//       DateTime currentDate = DateTime.now();
//
//       setState(() {
//         assignedCustomers = snapshot.docs
//             .map((doc) => doc.data())
//             .where((assignment) {
//           DateTime eventTime = assignment['eventTime'].toDate();
//           return eventTime.isBefore(currentDate); // Filter out events after today
//         })
//             .toList();
//       });
//     } catch (error) {
//       print('Error fetching assigned customers: $error');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     audioRecorderProvider = Provider.of<AudioRecorderProvider>(context);
//
//     // Filter the assignedCustomers based on event time
//     List<Map<String, dynamic>> filteredAssignments = assignedCustomers
//         .where((assignment) {
//       DateTime eventTime = assignment['eventTime'].toDate();
//       return eventTime.isBefore(DateTime.now());
//     })
//         .toList();
//
//     // Determine if there are no assigned customers or all events are after today
//     bool noAssignedCustomers = filteredAssignments.isEmpty;
//     bool allEventsAfterToday = filteredAssignments.every((assignment) {
//       DateTime eventTime = assignment['eventTime'].toDate();
//       return eventTime.isAfter(DateTime.now());
//     });
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: noAssignedCustomers || allEventsAfterToday
//           ? Center(
//         child: Text('No assigned customers or all events are after today.'),
//       )
//           : ListView.builder(
//         itemCount: filteredAssignments.length,
//         itemBuilder: (context, index) {
//           // Sort the assignments by event time in descending order
//           List<Map<String, dynamic>> sortedAssignments = filteredAssignments
//             ..sort((a, b) => b['eventTime'].compareTo(a['eventTime']));
//
//           Map<String, dynamic> assignment = sortedAssignments[index];
//           return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//             future: FirebaseFirestore.instance
//                 .collection('customers')
//                 .doc(assignment['customerId'])
//                 .get(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return SpinKitDoubleBounce(
//                   color: Colors.blue,
//                   size: 50.0,
//                 );
//               } else if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else if (!snapshot.hasData || !snapshot.data!.exists) {
//                 return ListTile(
//                   title: Text('Customer not found'),
//                   subtitle: Text('Customer details not available'),
//                 );
//               } else {
//                 Map<String, dynamic> customer = snapshot.data!.data()!;
//                 DateTime eventTime = assignment['eventTime'].toDate();
//                 String formattedEventTime =
//                 DateFormat('MMM d, y HH:mm a').format(eventTime);
//
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Card(
//                     elevation: 4,
//                     child: ListTile(
//                       title: Text('Name: ${customer['name']}'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     _launchPhoneCall(customer['phone']);
//                                   },
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         'Phone: ${formatPhoneNumber(customer['phone'])}',
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       SizedBox(width: 125),
//                                       Icon(
//                                         Icons.phone,
//                                         color: Colors.blue,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Spacer(),
//                               ElevatedButton(
//                                 onPressed: () async {
//                                   if (audioRecorderProvider.isRecording) {
//                                     String? recordingUrl =
//                                     await audioRecord.stop();
//
//                                     FirebaseFirestore.instance
//                                         .collection('customers')
//                                         .doc(assignment['customerId'])
//                                         .collection('recordings')
//                                         .add({
//                                       'audio_path': recordingUrl,
//                                       'timestamp': Timestamp.now(),
//                                     });
//
//                                     audioRecorderProvider.stopRecording();
//                                   } else {
//                                     if (await audioRecord.hasPermission()) {
//                                       await audioRecord.start();
//                                       audioRecorderProvider.startRecording();
//                                     }
//                                   }
//                                 },
//                                 child: Icon(
//                                   audioRecorderProvider.isRecording
//                                       ? Icons.check_circle_outline
//                                       : Icons.location_on,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () async {
//                                   String? imageUrl = await takePhoto();
//                                   if (imageUrl != null) {
//                                     FirebaseFirestore.instance
//                                         .collection('customers')
//                                         .doc(assignment['customerId'])
//                                         .collection('photos')
//                                         .add({
//                                       'image_url': imageUrl,
//                                       'timestamp': Timestamp.now(),
//                                     });
//                                   }
//                                 },
//                                 icon: Icon(
//                                   Icons.camera_alt,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text('Event Time: $formattedEventTime'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Future<String?> takePhoto() async {
//     final picker = ImagePicker();
//     final XFile? image =
//     await picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       Reference reference = FirebaseStorage.instance.ref()
//           .child('photos')
//           .child(DateTime.now().toString());
//       UploadTask uploadTask = reference.putFile(File(image.path));
//       TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
//
//       String downloadURL = await snapshot.ref.getDownloadURL();
//
//       return downloadURL;
//     } else {
//       return null;
//     }
//   }
//
//   String formatPhoneNumber(String fullPhoneNumber) {
//     if (fullPhoneNumber.length >= 4) {
//       return '**${fullPhoneNumber.substring(fullPhoneNumber.length - 4)}';
//     } else {
//       return fullPhoneNumber;
//     }
//   }
//
//   void _launchPhoneCall(String phoneNumber) async {
//     String url = 'tel:$phoneNumber';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       print('Could not launch $url');
//     }
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/widgets/employees/recordings/AudioRecorderProvider.dart';
import 'package:record/record.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AssignedCustomersPage1 extends StatefulWidget {
  @override
  _AssignedCustomersPage1State createState() => _AssignedCustomersPage1State();
}

class _AssignedCustomersPage1State extends State<AssignedCustomersPage1> {
  late User user;
  List<Map<String, dynamic>> assignedCustomers = [];
  late Record audioRecord;
  late AudioRecorderProvider audioRecorderProvider;
  final TwilioFlutter twilioFlutter = TwilioFlutter(
    accountSid: 'ACea352cee8e8c865a91cb95d394c0f079',
    authToken: 'c220147ba8c89034363cc98a376686a7',
    twilioNumber: '+12675364671',
  );

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    fetchAssignedCustomers();
    audioRecord = Record();
  }

  Future<void> fetchAssignedCustomers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('assignments')
          .where('employeeId', isEqualTo: user.uid)
          .get();

      DateTime currentDate = DateTime.now();

      setState(() {
        assignedCustomers = snapshot.docs
            .map((doc) => doc.data())
            .where((assignment) {
          DateTime eventTime = assignment['eventTime'].toDate();
          return eventTime.isBefore(currentDate); // Filter out events after today
        })
            .toList();
      });
    } catch (error) {
      print('Error fetching assigned customers: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    audioRecorderProvider = Provider.of<AudioRecorderProvider>(context);

    // Filter the assignedCustomers based on event time
    List<Map<String, dynamic>> filteredAssignments = assignedCustomers
        .where((assignment) {
      DateTime eventTime = assignment['eventTime'].toDate();
      return eventTime.isBefore(DateTime.now());
    })
        .toList();

    // Determine if there are no assigned customers or all events are after today
    bool noAssignedCustomers = filteredAssignments.isEmpty;
    bool allEventsAfterToday = filteredAssignments.every((assignment) {
      DateTime eventTime = assignment['eventTime'].toDate();
      return eventTime.isAfter(DateTime.now());
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: noAssignedCustomers || allEventsAfterToday
          ? Center(
        child: Text('No assigned customers or all events are after today.'),
      )
          : ListView.builder(
        itemCount: filteredAssignments.length,
        itemBuilder: (context, index) {
          // Sort the assignments by event time in descending order
          List<Map<String, dynamic>> sortedAssignments = filteredAssignments
            ..sort((a, b) => b['eventTime'].compareTo(a['eventTime']));

          Map<String, dynamic> assignment = sortedAssignments[index];
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('customers')
                .doc(assignment['customerId'])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SpinKitDoubleBounce(
                  color: Colors.blue,
                  size: 50.0,
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return ListTile(
                  title: Text('Customer not found'),
                  subtitle: Text('Customer details not available'),
                );
              } else {
                Map<String, dynamic> customer = snapshot.data!.data()!;
                DateTime eventTime = assignment['eventTime'].toDate();
                String formattedEventTime =
                DateFormat('MMM d, y HH:mm a').format(eventTime);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text('Name: ${customer['name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    _launchPhoneCall(customer['phone']);
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Phone: ${formatPhoneNumber(customer['phone'])}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 10), // Adjust the spacing if necessary
                                      Icon(
                                        Icons.phone,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () async {
                                  if (audioRecorderProvider.isRecording) {
                                    String? recordingUrl =
                                    await audioRecord.stop();

                                    FirebaseFirestore.instance
                                        .collection('customers')
                                        .doc(assignment['customerId'])
                                        .collection('recordings')
                                        .add({
                                      'audio_path': recordingUrl,
                                      'timestamp': Timestamp.now(),
                                    });

                                    audioRecorderProvider.stopRecording();
                                  } else {
                                    if (await audioRecord.hasPermission()) {
                                      await audioRecord.start();
                                      audioRecorderProvider.startRecording();
                                    }
                                  }
                                },
                                child: Icon(
                                  audioRecorderProvider.isRecording
                                      ? Icons.check_circle_outline
                                      : Icons.location_on,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  String? imageUrl = await takePhoto();
                                  if (imageUrl != null) {
                                    FirebaseFirestore.instance
                                        .collection('customers')
                                        .doc(assignment['customerId'])
                                        .collection('photos')
                                        .add({
                                      'image_url': imageUrl,
                                      'timestamp': Timestamp.now(),
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Text('Event Time: $formattedEventTime'),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<String?> takePhoto() async {
    final picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Reference reference = FirebaseStorage.instance.ref()
          .child('photos')
          .child(DateTime.now().toString());
      UploadTask uploadTask = reference.putFile(File(image.path));
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

      String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } else {
      return null;
    }
  }

  String formatPhoneNumber(String fullPhoneNumber) {
    if (fullPhoneNumber.length >= 4) {
      return '**${fullPhoneNumber.substring(fullPhoneNumber.length - 4)}';
    } else {
      return fullPhoneNumber;
    }
  }

  void _launchPhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}