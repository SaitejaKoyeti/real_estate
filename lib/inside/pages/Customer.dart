import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'calendar.dart';

class Customer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Data'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customers'),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('customers').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                List<DataRow> customerRows = snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                  String getLastFourDigits(String phoneNumber) {
                    if (phoneNumber != null && phoneNumber.length >= 4) {
                      return '+91 * ' + phoneNumber.substring(phoneNumber.length - 4);
                    } else {
                      return phoneNumber ?? '';
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(data['id'] ?? '')),
                      DataCell(Text(data['name'] ?? '')),
                      // DataCell(Text(data['email'] ?? '')),
                      DataCell(Text(getLastFourDigits(data['phone']))),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.call),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Report'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text('Interested'),
                                        leading: Icon(Icons.thumb_up, color: Colors.green, size: 40),
                                        onTap: () {
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
                                                        'id': data['id'],
                                                        'name': data['name'],
                                                        // 'email': data['email'],
                                                        'phone': data['phone'],
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: Text('Not Interested'),
                                        leading: Icon(Icons.thumb_down, color: Colors.red, size: 40),
                                        onTap: () {
                                          _markAsNotInterested(context, data);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Name')),
                      // DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Call')),
                    ],
                    rows: customerRows,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _markAsNotInterested(BuildContext context, Map<String, dynamic> customerData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not Interested'),
          content: Text('Are you sure you want to mark this customer as not interested?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCustomer(customerData['id']);
                _saveNotInterestedData(customerData);
                Navigator.popUntil(context, ModalRoute.withName('/customer'));
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCustomer(String customerId) {
    // Implement your logic to delete a customer from the 'customers' collection
    // For example: FirebaseFirestore.instance.collection('customers').doc(customerId).delete();
  }

  void _saveNotInterestedData(Map<String, dynamic> customerData) {
    // Add 'Not Interested' information to a separate collection in Firestore
    FirebaseFirestore.instance.collection('not_interested_customers').add({
      'customerId': customerData['id'],
      'customerName': customerData['name'],
      // 'customerEmail': customerData['email'],
      'customerPhone': customerData['phone'],
      'timestamp': FieldValue.serverTimestamp(),
      // Optional: Include a timestamp
    });
  }
}