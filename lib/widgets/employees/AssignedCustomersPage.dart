import 'package:flutter/material.dart';

class AssignedCustomersScreen extends StatelessWidget {
  final String employeeId;
  final List<Map<String, dynamic>> assignedCustomers;

  const AssignedCustomersScreen({
    required this.employeeId,
    required this.assignedCustomers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Customers'),
      ),
      body: ListView.builder(
        itemCount: assignedCustomers.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> customer = assignedCustomers[index];
          return ListTile(
            title: Text('Customer Name: ${customer['customerName']}'),
            subtitle: Text('Phone Number: ${customer['customerPhone']}'),
            trailing: IconButton(
              icon: Icon(Icons.headset),
              onPressed: () {
                _viewRecordings(context, customer);
              },
            ),
          );
        },
      ),
    );
  }

  void _viewRecordings(BuildContext context, Map<String, dynamic> customer) {
    // Navigate to a screen to view recordings for the selected customer
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CustomerRecordingsScreen(
    //       customerId: customer['customerId'],
    //     ),
    //   ),
    // );
  }
}
