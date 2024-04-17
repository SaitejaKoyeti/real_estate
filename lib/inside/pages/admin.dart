import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class DashboardPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEmployeePage()),
                );
              },
              child: Text('Add Employee'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCustomerPage()),
                );
              },
              child: Text('Add Customer'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataViewPage()),
                );
              },
              child: Text('View Data'),
            ),

          ],
        ),
      ),
    );
  }
}
class AddEmployeePage extends StatefulWidget {
  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _employeeEmailController = TextEditingController();
  final TextEditingController _employeePhoneController = TextEditingController();
  String _employeeType = 'Inside Sales';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee ID'),
            TextFormField(
              controller: _employeeIdController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter employee ID';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            Text('Employee Name'),
            TextFormField(
              controller: _employeeNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter employee name';
                }
                return null;
              },
            ),
            Text('Employee Email'),
            TextFormField(
              controller: _employeeEmailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter employee email';
                }
                return null;
              },
            ),
            Text('Employee Phone Number'),
            TextFormField(
              controller: _employeePhoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter employee phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            Text('Employee Type'),
            DropdownButton<String>(
              value: _employeeType,
              onChanged: (newValue) {
                setState(() {
                  _employeeType = newValue!;
                });
              },
              items: ['Inside Sales', 'Outside Sales'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add the employee to the Firestore collection
                FirebaseFirestore.instance.collection('employees').add({
                  'id': _employeeIdController.text.trim(),
                  'name': _employeeNameController.text.trim(),
                  'email': _employeeEmailController.text.trim(),
                  'phone': _employeePhoneController.text.trim(),
                  'type': _employeeType,//Navigator.push(context, MaterialPageRoute(builder: (context) => ca,))
                });
                // Navigate back to the dashboard page
                Navigator.pop(context);
              },
              child: Text('Add Employee'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCustomerPage extends StatelessWidget {
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerEmailController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Id'),
            TextFormField(
              controller: _customerIdController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer ID';
                }
                return null;
              },
            ),
            Text('Customer Name'),
            TextFormField(
              controller: _customerNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            Text('Customer Email'),
            TextFormField(
              controller: _customerEmailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer email';
                }
                return null;
              },
            ),
            Text('Customer Phone Number'),
            TextFormField(
              controller: _customerPhoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add the customer to the Firestore collection
                FirebaseFirestore.instance.collection('customers').add({
                  'id': _customerIdController.text.trim(),
                  'name': _customerNameController.text.trim(),
                  'email': _customerEmailController.text.trim(),
                  'phone': _customerPhoneController.text.trim(),
                });
                // Navigate back to the dashboard page
                Navigator.pop(context);
              },
              child: Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }
}

class DataViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Data'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employees'),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('employees').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              // Process the employee data and display it in a DataTable
              List<DataRow> employeeRows = snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                return DataRow(
                  cells: [
                    DataCell(Text(data['id'] ?? '')),
                    DataCell(Text(data['name'] ?? '')),
                    DataCell(Text(data['email'] ?? '')),
                    DataCell(Text(data['phone'] ?? '')),
                    DataCell(Text(data['type'] ?? '')),
                  ],
                );
              }).toList();

              return DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Type')),
                ],
                rows: employeeRows,
              );
            },
          ),
          SizedBox(height: 16.0),

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

                return DataRow(
                  cells: [
                    DataCell(Text(data['id'] ?? '')),
                    DataCell(Text(data['name'] ?? '')),
                    DataCell(Text(data['email'] ?? '')),
                    DataCell(Text(data['phone'] ?? '')),
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
                                        // Add your logic for interested action
                                        print('Customer is interested');
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) => Ous
                                        // );

                                      },
                                    ),
                                    ListTile(
                                      title: Text('Not Interested'),
                                      leading: Icon(Icons.thumb_down, color: Colors.red, size: 40),
                                      onTap: () {
                                        // Add your logic for not interested action
                                        print('Customer is not interested');
                                        Navigator.of(context).pop(); // Close the dialog
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

              return DataTable(
                columns: [
                  DataColumn(label: Text('id')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Call')),
                ],
                rows: customerRows,
              );
            },
          ),
        ],
      ),
    );
  }
}
