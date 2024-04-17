import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'calendar.dart';

class TwilioCredentials {
  static const String accountSid = 'ACea352cee8e8c865a91cb95d394c0f079';
  static const String authToken = 'c220147ba8c89034363cc98a376686a7';
  static const String twilioNumber = '+12675364671';
}

class FirebaseService {
  static Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .doc(userId)
        .get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  static Future<void> addNotInterestedCustomer(Map<String, dynamic> customerData, String employeeName) async {
    await FirebaseFirestore.instance.collection('not_interested_customers').add({
      'customerId': customerData['id'],
      'customerName': customerData['name'],
      'customerPhone': customerData['phone'],
      'employeeId': FirebaseAuth.instance.currentUser?.uid,
      'employeeName': employeeName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> addInterestedCustomer(Map<String, dynamic> customerData, String employeeName, String message) async {
    await FirebaseFirestore.instance.collection('interested_customers').add({
      'customerId': customerData['id'],
      'customerName': customerData['name'],
      'customerPhone': customerData['phone'],
      'employeeId': FirebaseAuth.instance.currentUser?.uid,
      'employeeName': employeeName,
      'timestamp': FieldValue.serverTimestamp(),
      'message': message,
    });
  }
}

class MessagingService {
  static Future<void> sendWhatsAppMessage(String phone, String message) async {
    String url = "https://wa.me/$phone/?text=${Uri.encodeComponent(message)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  static Future<void> sendTextMessage(String phone, String message) async {
    try {
      final serverUrl = 'http://localhost:3000/sendTwilioMessage';

      final response = await http.post(
        Uri.parse(serverUrl),
        body: {
          'toNumber': phone,
          'messageBody': message,
        },
      );

      if (response.statusCode == 200) {
        print('Text message sent successfully');
      } else {
        print('Failed to send text message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending text message: $e');
    }
  }
}

class TargetsList1 extends StatelessWidget {
  final TwilioFlutter twilioFlutter = TwilioFlutter(
    accountSid: TwilioCredentials.accountSid,
    authToken: TwilioCredentials.authToken,
    twilioNumber: TwilioCredentials.twilioNumber,
  );

  @override
  Widget build(BuildContext context) {
    String? loggedInUserId = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('customers')
          .where('assignedEmployee', isEqualTo: loggedInUserId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text(
                  'No assigned customers for this Inside Sales employee'));
        }

        List<Map<String, dynamic>> assignedCustomers = snapshot.data!.docs
            .map((customer) =>
        {
          'id': customer.id,
          'name': customer['name'],
          'phone': customer['phone'],
        })
            .toList();

        Set<String> assignedCustomerIds =
        Set.from(assignedCustomers.map((customer) => customer['id']));

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('assignments').get(),
          builder: (context, assignmentSnapshot) {
            if (assignmentSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (assignmentSnapshot.hasError) {
              return Center(
                  child: Text('Error: ${assignmentSnapshot.error}'));
            }

            Set<String> assignedCustomerIdsFromAssignments = Set.from(
                assignmentSnapshot.data!.docs
                    .map((assignment) => assignment['customerId']));

            assignedCustomers = assignedCustomers
                .where((customer) =>
            !assignedCustomerIdsFromAssignments
                .contains(customer['id']))
                .toList();

            if (assignedCustomers.isEmpty) {
              return Center(
                  child: Text(
                      'All assigned customers have been assigned to outside sales employees'));
            }

            return Scaffold(
              // appBar: AppBar(
              //   backgroundColor: Colors.deepPurpleAccent,
              //   title: Text(
              //     'Leads',
              //     style: TextStyle(fontWeight: FontWeight.bold),
              //   ),
              //   leading: IconButton(
              //     icon: Icon(Icons.arrow_back),
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //   ),
              // ),
              backgroundColor: Colors.white,
              body: ListView.builder(
                itemCount: assignedCustomers.length,
                itemBuilder: (context, index) {
                  String phoneNumber =
                  assignedCustomers[index]['phone'];
                  String hiddenPhoneNumber =
                      '**' + phoneNumber.substring(phoneNumber.length - 4);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          'Name: ${assignedCustomers[index]['name']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Phone: $hiddenPhoneNumber',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.call),
                              onPressed: () {
                                // Add your call functionality here
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.thumb_up, color: Colors.green),
                              onPressed: () {
                                _saveInterestData(
                                  assignedCustomers[index],
                                  'Hello ${assignedCustomers[index]['name']}, I am interested in your services.',
                                );
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: SingleChildScrollView(
                                        child: Container(
                                          width: 400,
                                          height: 600,
                                          child: Calendars(
                                            title: 'title',
                                            customers: {
                                              'id':
                                              assignedCustomers[index]['id'],
                                              'name':
                                              assignedCustomers[index]
                                              ['name'],
                                              'phone':
                                              assignedCustomers[index]
                                              ['phone'],
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.thumb_down, color: Colors.red),
                              onPressed: () {
                                _markAsNotInterested(
                                  context,
                                  assignedCustomers[index],
                                  'Are you sure you want to mark this customer as not interested?',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _markAsNotInterested(BuildContext context,
      Map<String, dynamic> customerData,
      String message,) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String employeeName = userData['name'];

    // Send not interested message
    _sendThankYouMessage(
      customerData['phone'],
      'Thank you for considering our services. We appreciate your time.',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not Interested'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection(
                    'not_interested_customers')
                    .add({
                  'customerId': customerData['id'],
                  'customerName': customerData['name'],
                  'customerPhone': customerData['phone'],
                  'employeeId': FirebaseAuth.instance.currentUser?.uid,
                  'employeeName': employeeName,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Navigator.popUntil(context, ModalRoute.withName('/customer'));
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _saveInterestData(Map<String, dynamic> customerData,
      String message,) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String employeeName = userData['name'];

    // Send interested message
    _sendThankYouMessage(
      customerData['phone'],
      'Thank you for your interest in our services. We will contact you soon.',
    );

    FirebaseFirestore.instance.collection('interested_customers').add({
      'customerId': customerData['id'],
      'customerName': customerData['name'],
      'customerPhone': customerData['phone'],
      'employeeId': FirebaseAuth.instance.currentUser?.uid,
      'employeeName': employeeName,
      'timestamp': FieldValue.serverTimestamp(),
      'message': message,
    });
  }

  void _sendThankYouMessage(String phone, String message) async {
    _sendWhatsAppMessage(phone, message); // Send WhatsApp message
    _sendTextMessage(phone, message); // Send text message
  }

  void _sendWhatsAppMessage(String phone, String message) async {
    String url = "https://wa.me/$phone/?text=${Uri.encodeComponent(message)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void _sendTextMessage(String phone, String message) async {
    try {
      final twilioUrl = 'https://api.twilio.com/2010-04-01/Accounts/${TwilioCredentials.accountSid}/Messages.json';

      final response = await http.post(
        Uri.parse(twilioUrl),
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('${TwilioCredentials.accountSid}:${TwilioCredentials.authToken}')),
        },
        body: {
          'To': phone,
          'From': TwilioCredentials.twilioNumber,
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        print('Text message sent successfully');
      } else {
        print('Failed to send text message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending text message: $e');
    }
  }
}