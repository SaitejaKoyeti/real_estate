import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('employees').snapshots(),
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
              child: Text('No employees found.'),
            );
          } else {
            List<DocumentSnapshot> employees = snapshot.data!.docs;

            return ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> employeeData = employees[index].data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text('Employee Name: ${employeeData['name']}'),
                    subtitle: Text('Employee ID: ${employees[index].id}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editEmployeeDetails(employees[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteEmployee(employees[index]);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _editEmployeeDetails(DocumentSnapshot employee) async {
    TextEditingController nameController = TextEditingController(text: employee['name']);
    TextEditingController otherDetailsController = TextEditingController(text: employee['otherDetails']);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Employee Details'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: otherDetailsController,
                decoration: InputDecoration(labelText: 'Other Details'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _updateEmployeeDetails(employee, nameController.text, otherDetailsController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEmployeeDetails(DocumentSnapshot employee, String newName, String newOtherDetails) async {
    await FirebaseFirestore.instance.collection('employees').doc(employee.id).update({
      'name': newName,
      'otherDetails': newOtherDetails,
      // Add other fields to update as needed
    });
  }

  Future<void> _deleteEmployee(DocumentSnapshot employee) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Employee'),
          content: Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _performDelete(employee);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete(DocumentSnapshot employee) async {
    await FirebaseFirestore.instance.collection('employees').doc(employee.id).delete();
  }
}
