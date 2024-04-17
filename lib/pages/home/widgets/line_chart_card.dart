import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../sales_screen.dart';
import '../../../widgets/custom_card.dart';
import '../../../widgets/employees/employeedetailspage.dart';

enum EmployeeType {
  Inside,
  Outside,
}

class Employee {
  final String name;
  final String gender;
  final DateTime dob;
  final String email;
  final String sales;
  final String recordingUrl;

  Employee({
    required this.name,
    required this.gender,
    required this.dob,
    required this.email,
    required this.sales,
    required this.recordingUrl,
  });
}

class LineChartCard extends StatefulWidget {
  LineChartCard({Key? key});

  @override
  _LineChartCardState createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  late List<Employee> employees;
  EmployeeType selectedEmployeeType = EmployeeType.Inside;
  SalesType selectedSalesType = SalesType.All;
  bool showAllEmployees = false;

  @override
  void initState() {
    super.initState();
    // Initialize employees as an empty list
    employees = [];
    // Fetch employees data from Firestore
    fetchEmployees();
  }

  // Fetch all employees from Firestore
  Future<void> fetchEmployees() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('employees').get();

      List<Employee> fetchedEmployees = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Employee(
          name: data['name'] ?? "",
          gender: data['gender'] ?? "",
          dob: data['dob'] != null
              ? (data['dob'] is Timestamp
              ? (data['dob'] as Timestamp).toDate()
              : (data['dob'] is String
              ? DateTime.parse(data['dob'])
              : DateTime.now()))
              : DateTime.now(),
          email: data['email'] ?? "",
          sales: data['sales'] ?? "",
          recordingUrl: data['recordingUrl'] ?? "",
        );
      }).toList();

      setState(() {
        employees = fetchedEmployees;
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard( // Wrap LineChartCard inside CustomCard
      child: StreamBuilder<QuerySnapshot>(
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
            List<DocumentSnapshot> employeeDocs = snapshot.data!.docs;

            // Filter employees based on selectedSalesType and selectedEmployeeType
            List<DocumentSnapshot> filteredEmployees;
            if (selectedSalesType == SalesType.All) {
              filteredEmployees = employeeDocs;
            } else {
              filteredEmployees = employeeDocs.where((employee) =>
              employee['sales'] ==
                  (selectedSalesType == SalesType.Inside ? 'Inside Sales' : 'Outside Sales')).toList();
            }

            if (!showAllEmployees && filteredEmployees.length > 4) {
              filteredEmployees = filteredEmployees.sublist(0, 4);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                      child: ToggleButtons(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                            child: Text('Inside'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                            child: Text('Outside'),
                          ),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            if (index == 0) {
                              selectedSalesType = SalesType.Inside;
                            } else {
                              selectedSalesType = SalesType.Outside;
                            }
                          });
                        },
                        isSelected: [
                          selectedSalesType == SalesType.Inside,
                          selectedSalesType == SalesType.Outside,
                        ],
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> employeeData = filteredEmployees[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      elevation: 0,
                      color: const Color(0xFF2F353E),
                      child: ListTile(
                        title: Text('Name: ${employeeData['name']}'),
                        subtitle: Text('Role : ${employeeData['sales']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editEmployeeDetails(context, filteredEmployees[index]);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteEmployee(context, filteredEmployees[index]);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.assistant),
                              onPressed: () {
                                _setTarget(context, filteredEmployees[index]);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.info),
                              onPressed: () {
                                _showEmployeeDetails(context, filteredEmployees[index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (!showAllEmployees && filteredEmployees.length > 3)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.6, // Adjust the width according to your design
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAllEmployees = true;
                          });
                        },
                        child: Text('View All'),
                      ),
                    ),
                  ),

                if (showAllEmployees)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.6, // Adjust the width according to your design
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            showAllEmployees = false;
                          });
                        },
                        child: Text('View Less'),
                      ),
                    ),
                  ),

              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _editEmployeeDetails(BuildContext context, DocumentSnapshot employee) async {
    TextEditingController nameController = TextEditingController(text: employee['name']);
    TextEditingController salesController = TextEditingController(text: employee['sales']);

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
                controller: salesController,
                decoration: InputDecoration(labelText: 'Sales'),
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
                await _updateEmployeeDetails(employee.id, nameController.text, salesController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEmployeeDetails(String employeeId, String newName, String newSales) async {
    await FirebaseFirestore.instance.collection('employees').doc(employeeId).update({
      'name': newName,
      'sales': newSales,
      // Add other fields to update as needed
    });
  }

  Future<void> _deleteEmployee(BuildContext context, DocumentSnapshot employee) async {
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
                await _performDelete(employee.id);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete(String employeeId) async {
    await FirebaseFirestore.instance.collection('employees').doc(employeeId).delete();
  }

  Future<void> _setTarget(BuildContext context, DocumentSnapshot employee) async {
    TextEditingController targetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Target for ${employee['name']}'),
          content: Column(
            children: [
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Target'),
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
                await _saveTarget(employee.id, targetController.text);
                Navigator.pop(context);
              },
              child: Text('Set Target'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTarget(String employeeId, String target) async {
    await FirebaseFirestore.instance.collection('employee_targets').doc(employeeId).set({
      'target': target,
      'employeeId': employeeId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _showEmployeeDetails(BuildContext context, DocumentSnapshot employee) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailsScreen(employee: employee),
      ),
    );
  }

}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: LineChartCard(),
      ),
    ),
  );
}
