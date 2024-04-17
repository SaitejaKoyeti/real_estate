// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:real_estate_project/widgets/employees/addemployeeform.dart';
// import 'package:real_estate_project/widgets/employees/employeedetailspage.dart';
//
//
// class SalesScreen extends StatefulWidget {
//
//   @override
//   _SalesScreenState createState() => _SalesScreenState();
// }
//
// class _SalesScreenState extends State<SalesScreen> {
//   SalesType selectedSalesType = SalesType.All; // Default to show all employees
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Employee Form'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddEmployeeForm()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     selectedSalesType = SalesType.All; // Show all employees
//                   });
//                 },
//                 child: Text("All Employees"),
//               ),
//               SizedBox(width: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     selectedSalesType = SalesType.Inside; // Show inside sales
//                   });
//                 },
//                 child: Text("Inside Sales"),
//               ),
//               SizedBox(width: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     selectedSalesType = SalesType.Outside; // Show outside sales
//                   });
//                 },
//                 child: Text("Outside Sales"),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           SalesEmployeeList(selectedSalesType: selectedSalesType),
//         ],
//       ),
//     );
//   }
// }
//
// enum SalesType {
//   All,
//   Inside,
//   Outside,
// }
//
// class SalesEmployeeList extends StatelessWidget {
//   final SalesType selectedSalesType;
//
//   const SalesEmployeeList({required this.selectedSalesType});
//
//   Future<void> _editEmployeeDetails(BuildContext context, DocumentSnapshot employee) async {
//     TextEditingController nameController = TextEditingController(text: employee['name']);
//     TextEditingController salesController = TextEditingController(text: employee['sales']);
//
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Edit Employee Details'),
//           content: Column(
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Name'),
//               ),
//               TextField(
//                 controller: salesController,
//                 decoration: InputDecoration(labelText: 'Sales'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await _updateEmployeeDetails(employee.id, nameController.text, salesController.text);
//                 Navigator.pop(context);
//               },
//               child: Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _updateEmployeeDetails(String employeeId, String newName, String newSales) async {
//     await FirebaseFirestore.instance.collection('employees').doc(employeeId).update({
//       'name': newName,
//       'sales': newSales,
//       // Add other fields to update as needed
//     });
//   }
//
//   Future<void> _deleteEmployee(BuildContext context, DocumentSnapshot employee) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Employee'),
//           content: Text('Are you sure you want to delete this employee?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await _performDelete(employee.id);
//                 Navigator.pop(context);
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _performDelete(String employeeId) async {
//     await FirebaseFirestore.instance.collection('employees').doc(employeeId).delete();
//   }
//
//   Future<void> _setTarget(BuildContext context, DocumentSnapshot employee) async {
//     TextEditingController targetController = TextEditingController();
//
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Set Target for ${employee['name']}'),
//           content: Column(
//             children: [
//               TextField(
//                 controller: targetController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Target'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await _saveTarget(employee.id, targetController.text);
//                 Navigator.pop(context);
//               },
//               child: Text('Set Target'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _saveTarget(String employeeId, String target) async {
//     await FirebaseFirestore.instance.collection('employee_targets').doc(employeeId).set({
//       'target': target,
//       'employeeId': employeeId,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<void> _showEmployeeDetails(BuildContext context, DocumentSnapshot employee) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EmployeeDetailsScreen(employee: employee),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('employees').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error: ${snapshot.error}'),
//           );
//         } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text('No employees found.'),
//           );
//         } else {
//           List<DocumentSnapshot> employees = snapshot.data!.docs;
//
//           // Filter employees based on selectedSalesType
//           List<DocumentSnapshot> filteredEmployees;
//           if (selectedSalesType == SalesType.All) {
//             filteredEmployees = employees;
//           } else {
//             filteredEmployees = employees.where((employee) =>
//             employee['sales'] ==
//                 (selectedSalesType == SalesType.Inside ? 'Inside Sales' : 'Outside Sales')).toList();
//           }
//
//           return ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: filteredEmployees.length,
//             itemBuilder: (context, index) {
//               Map<String, dynamic> employeeData = filteredEmployees[index].data() as Map<String, dynamic>;
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                 elevation: 3,
//                 child: ListTile(
//                   title: Text('Name: ${employeeData['name']}'),
//                   subtitle: Text('Role : ${employeeData['sales']}'),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.edit),
//                         onPressed: () {
//                           _editEmployeeDetails(context, filteredEmployees[index]);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.delete),
//                         onPressed: () {
//                           _deleteEmployee(context, filteredEmployees[index]);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.assistant),
//                         onPressed: () {
//                           _setTarget(context, filteredEmployees[index]);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.info),
//                         onPressed: () {
//                           _showEmployeeDetails(context, filteredEmployees[index]);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_estate/widgets/employees/addemployeeform.dart';
import 'package:real_estate/widgets/employees/employeedetailspage.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  SalesType selectedSalesType = SalesType.All; // Default to show all employees
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee Details',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacity(0.5), // Adjust opacity or use a different color
            ),
            child: IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Employee',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEmployeeForm()),
                );
              },
              color: Colors.white, // Icon color
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Employees...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 0),
                  decoration: BoxDecoration(
                    color: selectedSalesType == SalesType.All ? Colors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedSalesType = SalesType.All; // Show all employees
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "All Employees",
                        style: TextStyle(
                          color: selectedSalesType == SalesType.All ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: selectedSalesType == SalesType.Inside ? Colors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedSalesType = SalesType.Inside; // Show inside sales
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Inside Sales",
                        style: TextStyle(
                          color: selectedSalesType == SalesType.Inside ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                AnimatedContainer(
                  duration: Duration(milliseconds: 0),
                  decoration: BoxDecoration(
                    color: selectedSalesType == SalesType.Outside ? Colors.orange : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        selectedSalesType = SalesType.Outside; // Show outside sales
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        "Outside Sales",
                        style: TextStyle(
                          color: selectedSalesType == SalesType.Outside ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SalesEmployeeList(selectedSalesType: selectedSalesType, searchQuery: searchQuery),
        ],
      ),
    );
  }
}

enum SalesType {
  All,
  Inside,
  Outside,
}

class SalesEmployeeList extends StatelessWidget {
  final SalesType selectedSalesType;
  final String searchQuery;

  const SalesEmployeeList({required this.selectedSalesType, required this.searchQuery});

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

  Future<void> _showEmployeeDetails(BuildContext context, DocumentSnapshot employee) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailsScreen(employee: employee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

          // Filter employees based on selectedSalesType and searchQuery
          List<DocumentSnapshot> filteredEmployees = employees.where((employee) {
            final String name = employee['name'].toString().toLowerCase();
            return (selectedSalesType == SalesType.All ||
                (selectedSalesType == SalesType.Inside && employee['sales'] == 'Inside Sales') ||
                (selectedSalesType == SalesType.Outside && employee['sales'] == 'Outside Sales')) &&
                (name.startsWith(searchQuery.toLowerCase()));
          }).toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredEmployees.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> employeeData = filteredEmployees[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                elevation: 3,
                child: ListTile(
                  title: Text('Name: ${employeeData['name']}'),
                  subtitle: Text('Role : ${employeeData['sales']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteEmployee(context, filteredEmployees[index]);
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
          );
        }
      },
    );
  }
}