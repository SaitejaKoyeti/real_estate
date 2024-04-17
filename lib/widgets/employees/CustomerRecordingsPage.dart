import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerRecordingsPage extends StatelessWidget {
  final String customerId;
  final List<String> audioPaths; // Add this parameter

  const CustomerRecordingsPage({
    required this.customerId,
    required this.audioPaths, // Add this required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Recordings'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .collection('recordings')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No recordings available.'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                // Customize the UI to display the recording details
                return ListTile(
                  title: Text('Recording URL: ${data['url']}'),
                  subtitle: Text('Timestamp: ${data['timestamp']}'),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
