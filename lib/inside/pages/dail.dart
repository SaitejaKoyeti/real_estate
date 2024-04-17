import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



class CustomerCallDashboard extends StatefulWidget {
  @override
  _CustomerCallDashboardState createState() => _CustomerCallDashboardState();
}

class _CustomerCallDashboardState extends State<CustomerCallDashboard> {
  List<Customer> customers = [
    Customer(name: 'Customer 1', phoneNumber: '9347504124'),
    Customer(name: 'Customer 2', phoneNumber: '8197040469'),
    // Add more customers as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Call Dashboard'),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(customers[index].name),
            subtitle: Text('Phone: ${hideNumber(customers[index].phoneNumber)}'),
            trailing: IconButton(
              icon: Icon(Icons.call),
              onPressed: () {
                _handleCall(customers[index].phoneNumber);
              },
            ),
          );
        },
      ),
    );
  }

  String hideNumber(String phoneNumber) {
    // Replace this with your logic to hide the phone number
    return '****${phoneNumber.substring(phoneNumber.length - 4)}';
  }

  void _handleCall(String phoneNumber) async {
    final completePhoneNumber = 'tel:$phoneNumber';

    if (await canLaunch(completePhoneNumber)) {
      await launch(completePhoneNumber);
    } else {
      // Handle error, e.g., show an error message
      print('Could not launch $completePhoneNumber');
    }
  }
}

class Customer {
  final String name;
  final String phoneNumber;

  Customer({required this.name, required this.phoneNumber});
}