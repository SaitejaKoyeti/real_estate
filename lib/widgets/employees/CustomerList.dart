import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerList extends StatelessWidget {
  final String title;
  final String employeeId;
  final bool interested;

  const CustomerList({
    required this.title,
    required this.employeeId,
    required this.interested,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(interested ? 'interested_customers' : 'not_interested_customers')
          .where('employeeId', isEqualTo: employeeId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No $title found for this employee.'),
          );
        } else {
          List<DocumentSnapshot> customers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              Map<String, dynamic>? customerData = customers[index].data() as Map<String, dynamic>?;

              if (customerData == null) {
                // Handle null customer data
                return SizedBox.shrink(); // or any other fallback widget
              }

              String name = customerData['name'] ?? 'Name not available';
              String contact = customerData['contact'] ?? 'Contact not available';

              return ListTile(
                title: Text(name),
                subtitle: Text(contact),
                // Add more customer details as needed
              );
            },
          );
        }
      },
    );

  }
}
