import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../customers/customersassigned.dart';
import 'CallHistoryScreen.dart';
import 'PhotosList.dart';
import 'RecordingsList.dart';

class EmployeeDetailsScreen extends StatelessWidget {
  final DocumentSnapshot employee;

  const EmployeeDetailsScreen({required this.employee});

  Future<void> _showCallHistory(BuildContext context) async {
    QuerySnapshot interestedCustomersSnapshot = await FirebaseFirestore.instance
        .collection('interested_customers')
        .where('employeeId', isEqualTo: employee.id)
        .get();

    QuerySnapshot notInterestedCustomersSnapshot = await FirebaseFirestore
        .instance
        .collection('not_interested_customers')
        .where('employeeId', isEqualTo: employee.id)
        .get();

    List<Map<String, String>> interestedCustomers = interestedCustomersSnapshot
        .docs
        .map((doc) =>
    {
      'name': doc['customerName'] as String,
      'phone': doc['customerPhone'] as String,
    })
        .toList();

    List<Map<String, String>> notInterestedCustomers = notInterestedCustomersSnapshot.docs
        .map((doc) =>
    {
      'name': doc['customerName'] as String,
      'phone': doc['customerPhone'] as String,
    })
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CallHistoryPage(
              interestedCustomers: interestedCustomers,
              notInterestedCustomers: notInterestedCustomers,
            ),
      ),
    );
  }


  Future<void> _viewAssignedCustomers(BuildContext context) async {
    // Check the sales type of the employee
    String salesType = employee['sales'];

    if (salesType == 'Inside Sales') {
      // Inside Sales navigation logic
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomersAssignedScreen(
            employeeId: employee.id,
          ),
        ),
      );
    } else {
      // Outside Sales navigation logic
      QuerySnapshot assignedCustomersSnapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .where('employeeId', isEqualTo: employee.id)
          .get();

      List<Map<String, dynamic>> assignedCustomers = assignedCustomersSnapshot.docs
          .map((doc) =>
      {
        'customerName': doc['customerName'] as String,
        'customerPhone': doc['customerPhone'] as String,
        'eventId': doc['eventId'] as String,
        'eventTime': doc['eventTime'] as Timestamp,
        'eventTitle': doc['eventTitle'] as String,
        'customerId': doc['customerId'] as String,
      })
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssignedCustomersScreen(
            assignedCustomers: assignedCustomers,
            employeeId:  employee.id,
          ),
        ),
      );
    }
  }


  Future<List<Map<String, dynamic>>> _fetchLoginLogoutTimes(String employeeId) async {
    try {
      QuerySnapshot loginSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .collection('loginTimes')
          .orderBy('time', descending: true)
          .get();

      QuerySnapshot logoutSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .collection('logoutTimes')
          .orderBy('time', descending: true)
          .get();

      List<Map<String, dynamic>> loginLogoutTimes = [];

      int loginIndex = 0;
      int logoutIndex = 0;

      // Merge login and logout times in a paired manner
      while (loginIndex < loginSnapshot.docs.length || logoutIndex < logoutSnapshot.docs.length) {
        DateTime? loginTime;
        DateTime? logoutTime;

        if (loginIndex < loginSnapshot.docs.length) {
          loginTime = (loginSnapshot.docs[loginIndex]['time'] as Timestamp).toDate();
          loginIndex++;
        }

        if (logoutIndex < logoutSnapshot.docs.length) {
          logoutTime = (logoutSnapshot.docs[logoutIndex]['time'] as Timestamp).toDate();
          logoutIndex++;
        }

        loginLogoutTimes.add({
          'loginTime': loginTime,
          'logoutTime': logoutTime,
        });
      }

      return loginLogoutTimes;
    } catch (e) {
      print('Error fetching login/logout times: $e');
      return [];
    }
  }


  Future<void> _showLoginLogoutTimings(BuildContext context) async {
    // Create a DateTime variable to store the selected date
    DateTime? selectedDate;

    // Show calendar picker to select a date
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2051),
    );
    Future<List<Map<String, dynamic>>> _fetchWorkLogs(String employeeId) async {
      try {
        QuerySnapshot workLogsSnapshot = await FirebaseFirestore.instance
            .collection('employees')
            .doc(employeeId)
            .collection('workLogs')
            .orderBy('time', descending: true)
            .get();

        List<Map<String, dynamic>> workLogs = [];

        for (var doc in workLogsSnapshot.docs) {
          workLogs.add({
            'amount': doc['amount'] as double,
            'time': (doc['time'] as Timestamp).toDate(),
          });
        }

        return workLogs;
      } catch (e) {
        print('Error fetching work logs: $e');
        return [];
      }
    }


    if (selectedDate != null) {
      // Fetch login/logout times for the selected date
      QuerySnapshot loginSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(employee.id)
          .collection('loginTimes')
          .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDate))
          .where('time', isLessThan: Timestamp.fromDate(selectedDate.add(Duration(days: 1))))
          .orderBy('time', descending: true)
          .get();

      QuerySnapshot logoutSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .doc(employee.id)
          .collection('logoutTimes')
          .where('time', isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDate))
          .where('time', isLessThan: Timestamp.fromDate(selectedDate.add(Duration(days: 1))))
          .orderBy('time', descending: true)
          .get();

      List<Map<String, dynamic>> loginLogoutTimes = [];

      int loginIndex = 0;
      int logoutIndex = 0;

      // Merge login and logout times in a paired manner
      while (loginIndex < loginSnapshot.docs.length || logoutIndex < logoutSnapshot.docs.length) {
        DateTime? loginTime;
        DateTime? logoutTime;

        if (loginIndex < loginSnapshot.docs.length) {
          loginTime = (loginSnapshot.docs[loginIndex]['time'] as Timestamp).toDate();
          loginIndex++;
        }

        if (logoutIndex < logoutSnapshot.docs.length) {
          logoutTime = (logoutSnapshot.docs[logoutIndex]['time'] as Timestamp).toDate();
          logoutIndex++;
        }

        loginLogoutTimes.add({
          'loginTime': loginTime,
          'logoutTime': logoutTime,
        });
      }

      // Show login/logout times in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login/Logout Timings for ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
            content: Container(
              width: double.maxFinite,
              height: 300.0,
              child: ListView.builder(
                itemCount: loginLogoutTimes.length,
                itemBuilder: (context, index) {
                  DateTime? loginTime = loginLogoutTimes[index]['loginTime'];
                  DateTime? logoutTime = loginLogoutTimes[index]['logoutTime'];

                  return ListTile(
                    title: Text('Login: ${loginTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(loginTime) : 'N/A'}'),
                    subtitle: Text('Logout: ${logoutTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(logoutTime) : 'N/A'}'),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2.0, // Adjust the elevation as needed
                child: EmployeeDetailTile(
                  label: 'Name',
                  value: employee['name'],
                ),
              ),
              Card(
                elevation: 2.0, // Adjust the elevation as needed
                child: EmployeeDetailTile(
                  label: 'Sales',
                  value: employee['sales'],
                ),
              ),
              Card(
                elevation: 3.0, // Adjust the elevation as needed
                child: EmployeeDetailTile(
                  label: 'Gender',
                  value: employee['gender'],
                ),
              ),
              Card(
                elevation: 4.0, // Adjust the elevation as needed
                child: EmployeeDetailTile(
                  label: 'Phone',
                  value: employee['phone'],
                ),
              ), Card(
                elevation: 5.0, // Adjust the elevation as needed
                child: EmployeeDetailTile(
                  label: 'Dob',
                  value: employee['dob'],
                ),
              ),

              if (employee['sales'] == 'Inside Sales')
                Card(
                  elevation: 2.0, // Adjust the elevation as needed
                  child: ElevatedButton(
                    onPressed: () {
                      _showCallHistory(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 8),
                        Text('Call History'),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 10.0),
              Card(
                elevation: 2.0, // Adjust the elevation as needed
                child: ElevatedButton(
                  onPressed: () {
                    _viewAssignedCustomers(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('View Assigned Customers'),
                ),
              ),
              Card(
                elevation: 2.0,
                child: ElevatedButton(
                  onPressed: () async {
                    _showLoginLogoutTimings(context); // Call the method to show login/logout timings
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Show Login/Logout Timings'),
                ),
              ),
            ],
          ),
        ),
      ),);
  }
}

class EmployeeDetailTile extends StatelessWidget {
  final String label;
  final String value;

  const EmployeeDetailTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

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
      body: Expanded(
        child: ListView.builder(
          itemCount: assignedCustomers.length,
          itemBuilder: (context, index) {
            final assignedCustomer = assignedCustomers[index];
            final customerName = assignedCustomer['customerName'];
            final customerPhone = assignedCustomer['customerPhone'];
            final eventId = assignedCustomer['eventId'];

            final Timestamp eventTimeTimestamp = assignedCustomer['eventTime'];
            final DateTime eventTime = eventTimeTimestamp.toDate();

            final eventTitle = assignedCustomer['eventTitle'];
            final customerId = assignedCustomer['customerId'];

            final last4Digits = customerPhone.substring(customerPhone.length - 4);

            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('Customer Name: $customerName'),
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _viewRecordings(context, customerId);
                          },
                          child: Text('View Recordings'),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            _viewPhotos(context, customerId);
                          },
                          child: Text('View Photos'),
                        ),
                      ],
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: $customerPhone'),
                    Text('Event Time: ${DateFormat('yyyy-MM-dd HH:mm').format(eventTime)}'),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            );

          },
        ),
      ),);
  }

  void _viewRecordings(BuildContext context, String customerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Material(
              child: RecordingsList(
                employeeId: employeeId,
                customerId: customerId,
              ),
            ),
      ),
    );
  }

  void _viewPhotos(BuildContext context, String customerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Material(
              child: PhotosList(
                customerId: customerId,
              ),
            ),
      ),
    );
  }
}



