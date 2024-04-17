import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../inside/pages/calendar.dart';
import '../../custom_card.dart';

class Scheduled extends StatefulWidget {
  Scheduled({Key? key}) : super(key: key);

  @override
  _ScheduledState createState() => _ScheduledState();
}

class _ScheduledState extends State<Scheduled> {
  final TextEditingController _messageController = TextEditingController();
  Color buttonColor = Color(0xFF2F353E);
  bool isEmpty = true; // Variable to track if the text field is empty
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _calendarFormat = CalendarFormat.month;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _sendSMS(String phoneNumber, String message) async {
    final String accountSid = 'ACea352cee8e8c865a91cb95d394c0f079';
    final String authToken = 'c220147ba8c89034363cc98a376686a7';
    final String twilioPhoneNumber = '+12675364671';

    final String twilioApiUrl =
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';

    final Uri uri = Uri.parse(twilioApiUrl);

    try {
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
          'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        },
        body: <String, String>{
          'To': phoneNumber,
          'From': twilioPhoneNumber,
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        _showSnackBar('SMS sent to $phoneNumber successfully!');
      } else {
        _showSnackBar(
            'Failed to send SMS to $phoneNumber. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error sending SMS to $phoneNumber: $e');
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    return phoneNumber.isNotEmpty && phoneNumber.length == 13;
  }

  void _sendSMSToAllEmployees(String message) async {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('employees').get();

    List<String> validPhoneNumbers = querySnapshot.docs
        .where((doc) =>
    doc['phone'] != null && _isValidPhoneNumber(doc['phone']))
        .map((doc) => doc['phone'])
        .cast<String>()
        .toList();

    if (validPhoneNumbers.isNotEmpty) {
      for (String phoneNumber in validPhoneNumbers) {
        try {
          _sendSMS(phoneNumber, message);
          print('SMS sent to valid number: $phoneNumber');
        } catch (e) {
          print('Failed to send SMS to $phoneNumber: $e');
        }
      }
      _showSnackBar('SMS messages sent to valid phone numbers.');
    } else {
      _showSnackBar('No valid phone numbers found.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: CustomCard(
            color: Colors.transparent, // Admin color
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: _onDaySelected,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: CustomCard(
            color: const Color(0xFF2F353E), // Admin color
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  onChanged: (value) {
                    setState(() {
                      // Update isEmpty flag based on text field value
                      isEmpty = value.isEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  color: isEmpty ? Colors.transparent : buttonColor,
                  child: ElevatedButton(
                    onPressed: isEmpty
                        ? null // Disable button if text field is empty
                        : () {
                      // setState(() {
                      //   buttonColor = Colors.deepPurple; // Change button color
                      // });
                      String message = _messageController.text;
                      if (message.isNotEmpty) {
                        _sendSMSToAllEmployees(message);
                        _messageController.clear();
                      }
                    },

                    child: Text('Send to All Employees',style: TextStyle(color: Colors.black),),
                  ),
                ),
                if (isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please enter a message', // Additional message when text field is empty
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}