// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'Assignedcustomer.dart';
// import 'addcustomer.dart';
//
// class CustomersScreen extends StatefulWidget {
//   @override
//   _CustomersScreenState createState() => _CustomersScreenState();
// }
//
// class _CustomersScreenState extends State<CustomersScreen> {
//   List<DocumentSnapshot> allCustomers = [];
//   List<Map<String, dynamic>> insideSalesEmployees = [];
//   Set<String> selectedCustomerIds = Set<String>();
//   bool selectAll = false;
//
//   @override
//   Widget build(BuildContext context) {
//     bool noUnassignedCustomers = allCustomers.every((customer) =>
//     (customer.data() as Map<String, dynamic>?)?['assignedEmployee'] !=
//         null);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Assign Screen'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => AddCustomerForm()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 20.0),
//           ElevatedButton(
//             onPressed: _showInsideSalesEmployees,
//             child: Text('Assigned Employees'),
//           ),
//           SizedBox(height: 20.0),
//           if (!noUnassignedCustomers)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: _selectAllCustomers,
//                   child: Text(selectAll ? 'Deselect All' : 'Select All'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _assignTasks(selectedCustomerIds),
//                   child: Text('Assign Task'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _deleteSelectedCustomers,
//                   child: Text('Delete Selected'),
//                 ),
//               ],
//             ),
//           SizedBox(height: 20.0),
//           Expanded(
//             child: ListView.builder(
//               itemCount: allCustomers.length,
//               itemBuilder: (context, index) {
//                 Map<String, dynamic> customerData =
//                 allCustomers[index].data() as Map<String, dynamic>;
//
//                 if (customerData['assignedEmployee'] != null) {
//                   return Card(
//                     margin: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 8),
//                     elevation: 3,
//                     child: ListTile(
//                       title: Text('Customer Name: ${customerData['name']}'),
//                       subtitle:
//                       Text('Customer ID: ${allCustomers[index].id}'),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Checkbox(
//                             value: selectAll ||
//                                 selectedCustomerIds.contains(
//                                     allCustomers[index].id),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value != null) {
//                                   if (selectAll) {
//                                     selectAll = false;
//                                     selectedCustomerIds.clear();
//                                   } else {
//                                     if (value) {
//                                       selectedCustomerIds.add(
//                                           allCustomers[index].id);
//                                     } else {
//                                       selectedCustomerIds.remove(
//                                           allCustomers[index].id);
//                                     }
//                                   }
//                                 }
//                               });
//                             },
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete),
//                             onPressed: () =>
//                                 _deleteCustomer(allCustomers[index].id),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 } else {
//                   return Container();
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchCustomers();
//   }
//
//   void _deleteCustomer(String customerId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirmation'),
//           content: Text('Are you sure you want to delete this customer?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await FirebaseFirestore.instance
//                     .collection('customers')
//                     .doc(customerId)
//                     .delete();
//
//                 setState(() {
//                   allCustomers.removeWhere(
//                           (customer) => customer.id == customerId);
//                 });
//
//                 Navigator.of(context).pop();
//               },
//               child: Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _deleteSelectedCustomers() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirmation'),
//           content:
//           Text('Are you sure you want to delete selected customers?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 for (String customerId in selectedCustomerIds) {
//                   await FirebaseFirestore.instance
//                       .collection('customers')
//                       .doc(customerId)
//                       .delete();
//
//                   setState(() {
//                     allCustomers.removeWhere(
//                             (customer) => customer.id == customerId);
//                   });
//                 }
//
//                 setState(() {
//                   selectedCustomerIds.clear();
//                 });
//
//                 Navigator.of(context).pop();
//               },
//               child: Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _fetchCustomers() async {
//     try {
//       QuerySnapshot allCustomersSnapshot =
//       await FirebaseFirestore.instance.collection('customers').get();
//
//       setState(() {
//         allCustomers = allCustomersSnapshot.docs;
//       });
//
//       if (allCustomers.length > 100) {
//         _autoAssignInsideSales();
//       }
//     } catch (e) {
//       print('Error fetching customers: $e');
//     }
//   }
//
//   Future<void> _showInsideSalesEmployees() async {
//     try {
//       QuerySnapshot insideSalesEmployeesSnapshot = await FirebaseFirestore
//           .instance
//           .collection('employees')
//           .where('sales', isEqualTo: 'Inside Sales')
//           .get();
//
//       insideSalesEmployees = insideSalesEmployeesSnapshot.docs
//           .map((employee) => {
//         'id': employee.id,
//         'name': employee['name'] as String,
//       })
//           .toList();
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           int itemsPerPage = 5;
//           int currentPage = 0;
//
//           return StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return AlertDialog(
//                 title: Text('Inside Sales Employees'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     children: List.generate(
//                       insideSalesEmployees.length,
//                           (index) {
//                         if (index >= currentPage * itemsPerPage &&
//                             index < (currentPage + 1) * itemsPerPage) {
//                           return ListTile(
//                             title: Text(insideSalesEmployees[index]['name']),
//                             trailing: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _showAssignedCustomers(
//                                     insideSalesEmployees[index]['id']);
//                               },
//                               child: Text('Show'),
//                             ),
//                           );
//                         } else {
//                           return SizedBox.shrink();
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       ElevatedButton(
//                         onPressed: currentPage > 0
//                             ? () {
//                           setState(() {
//                             currentPage--;
//                           });
//                         }
//                             : null,
//                         child: Text('Previous Page'),
//                       ),
//                       ElevatedButton(
//                         onPressed: (currentPage + 1) * itemsPerPage <
//                             insideSalesEmployees.length
//                             ? () {
//                           setState(() {
//                             currentPage++;
//                           });
//                         }
//                             : null,
//                         child: Text('Next Page'),
//                       ),
//                     ],
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: Text('Close'),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       );
//     } catch (e) {
//       print('Error fetching Inside Sales employees: $e');
//     }
//   }
//
//   Future<void> _assignTasks(Set<String> customerIds) async {
//     try {
//       if (insideSalesEmployees.isEmpty) {
//         print('No Inside Sales employees available for assignment');
//         await _showInsideSalesEmployees();
//         if (insideSalesEmployees.isEmpty) {
//           return;
//         }
//       }
//
//       int employeeIndex = 0;
//
//       for (String customerId in customerIds) {
//         Map<String, dynamic> selectedEmployee =
//         insideSalesEmployees[employeeIndex];
//
//         await FirebaseFirestore.instance
//             .collection('customers')
//             .doc(customerId)
//             .update({
//           'assignedEmployee': selectedEmployee['id'],
//         });
//
//         print(
//             'Assigned task to employee ${selectedEmployee['id']} for customer $customerId');
//
//         // Remove the selected customer from the list
//         setState(() {
//           allCustomers.removeWhere((customer) => customer.id == customerId);
//           selectedCustomerIds.remove(customerId);
//         });
//
//         employeeIndex = (employeeIndex + 1) % insideSalesEmployees.length;
//       }
//
//       // Update local list of customers after assignment
//       // await _fetchCustomers(); // No need to fetch customers again as we are removing them directly
//
//       // Clear the set of selected customer IDs
//       setState(() {
//         selectedCustomerIds.clear();
//       });
//     } catch (e) {
//       print('Error assigning tasks: $e');
//     }
//   }
//
//   Future<void> _autoAssignInsideSales() async {
//     try {
//       QuerySnapshot insideSalesEmployeesSnapshot = await FirebaseFirestore
//           .instance
//           .collection('employees')
//           .where('sales', isEqualTo: 'InsideSales')
//           .get();
//
//       List<Map<String, dynamic>> insideSalesEmployees = insideSalesEmployeesSnapshot.docs
//           .map((employee) => {
//         'id': employee.id,
//         'name': employee['name'] as String,
//         'assignedCustomersCount': 0, // Track assigned customers count
//       })
//           .toList();
//
//       int maxCustomersPerEmployeePerDay = 10;
//
//       for (int i = 0; i < insideSalesEmployees.length; i++) {
//         int assignedCustomersCount =
//         insideSalesEmployees[i]['assignedCustomersCount'];
//
//         QuerySnapshot unassignedCustomersSnapshot = await FirebaseFirestore.instance
//             .collection('customers')
//             .where('assignedEmployee', isEqualTo: null)
//             .get();
//
//         List<DocumentSnapshot> unassignedCustomers =
//             unassignedCustomersSnapshot.docs;
//
//         for (int j = 0; j < unassignedCustomers.length; j++) {
//           if (assignedCustomersCount < maxCustomersPerEmployeePerDay) {
//             Map<String, dynamic> selectedEmployee = insideSalesEmployees[i];
//             DocumentSnapshot customer = unassignedCustomers[j];
//
//             await FirebaseFirestore.instance
//                 .collection('customers')
//                 .doc(customer.id)
//                 .update({
//               'assignedEmployee': selectedEmployee['id'],
//             });
//
//             // Increment assigned customers count for the employee
//             assignedCustomersCount++;
//             insideSalesEmployees[i]['assignedCustomersCount'] =
//                 assignedCustomersCount;
//
//             print(
//                 'Assigned task to employee ${selectedEmployee['id']} for customer ${customer.id}');
//           } else {
//             // If maximum limit reached for the day, break and continue with next employee
//             break;
//           }
//         }
//       }
//
//       print('Automatic assignment completed');
//     } catch (e) {
//       print('Error in automatic assignment: $e');
//     }
//   }
//
//   Future<void> _showAssignedCustomers(String employeeId) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AssignedCustomersScreen(employeeId: employeeId),
//       ),
//     );
//   }
//
//   void _selectAllCustomers() {
//     setState(() {
//       if (selectAll) {
//         selectAll = false;
//         selectedCustomerIds.clear();
//       } else {
//         selectAll = true;
//         selectedCustomerIds = Set.from(allCustomers
//             .where((customer) =>
//         (customer.data() as Map<String, dynamic>?)?['assignedEmployee'] ==
//             null)
//             .map((customer) => customer.id));
//       }
//     });
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../sales_screen.dart';
import 'Assignedcustomer.dart';
import 'addcustomer.dart';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<DocumentSnapshot> allCustomers = [];
  List<Map<String, dynamic>> insideSalesEmployees = [];
  Set<String> selectedCustomerIds = Set<String>();
  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    bool noUnassignedCustomers = allCustomers.every((customer) =>
    (customer.data() as Map<String, dynamic>?)?['assignedEmployee'] != null);


    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCustomerForm()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20.0),

          ElevatedButton(
            onPressed: _showInsideSalesEmployees,
            child: Text('Assigned Employees'),
          ),
          SizedBox(height: 20.0),
          if (!noUnassignedCustomers) // Show the buttons only if unassigned customers are available
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _selectAllCustomers,
                  child: Text(selectAll ? 'Deselect All' : 'Select All'),
                ),
                ElevatedButton(
                  onPressed: () => _assignTasks(selectedCustomerIds),
                  child: Text('Assign Task'),
                ),
                ElevatedButton(
                  onPressed: _deleteSelectedCustomers,
                  child: Text('Delete Selected'),
                ),
              ],
            ),
          SizedBox(height: 20.0),
          Expanded(
            child: ListView.builder(
              itemCount: allCustomers.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> customerData =
                allCustomers[index].data() as Map<String, dynamic>;

                // Check if the customer is assigned
                if (customerData['assignedEmployee'] == null) {
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    elevation: 3,
                    child: ListTile(
                      title: Text('Customer Name: ${customerData['name']}'),
                      subtitle:
                      Text('Customer ID: ${allCustomers[index].id}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selectAll ||
                                selectedCustomerIds.contains(
                                    allCustomers[index].id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value != null) {
                                  if (selectAll) {
                                    selectAll = false;
                                    selectedCustomerIds.clear();
                                  } else {
                                    if (value) {
                                      selectedCustomerIds.add(
                                          allCustomers[index].id);
                                    } else {
                                      selectedCustomerIds.remove(
                                          allCustomers[index].id);
                                    }
                                  }
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteCustomer(
                                allCustomers[index].id),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // Customer is already assigned, hide it from the list
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }


  void _deleteCustomer(String customerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this customer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('customers')
                    .doc(customerId)
                    .delete();

                setState(() {
                  allCustomers.removeWhere((customer) => customer.id == customerId);
                });

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }


  void _deleteSelectedCustomers() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete selected customers?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                for (String customerId in selectedCustomerIds) {
                  await FirebaseFirestore.instance
                      .collection('customers')
                      .doc(customerId)
                      .delete();

                  setState(() {
                    allCustomers.removeWhere(
                            (customer) => customer.id == customerId);
                  });
                }

                setState(() {
                  selectedCustomerIds.clear();
                });

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchCustomers() async {
    try {
      QuerySnapshot allCustomersSnapshot =
      await FirebaseFirestore.instance.collection('customers').get();

      setState(() {
        allCustomers = allCustomersSnapshot.docs;
      });

      if (allCustomers.length > 100) {
        _autoAssignInsideSales();
      }
    } catch (e) {
      print('Error fetching customers: $e');
    }
  }

  Future<void> _showInsideSalesEmployees() async {
    try {
      QuerySnapshot insideSalesEmployeesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('sales', isEqualTo: 'Inside Sales')
          .get();

      insideSalesEmployees = insideSalesEmployeesSnapshot.docs
          .map((employee) => {
        'id': employee.id,
        'name': employee['name'] as String,
      })
          .toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Inside Sales Employees'),
            content: Column(
              children: insideSalesEmployees
                  .map((employee) => ListTile(
                title: Text(employee['name']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAssignedCustomers(employee['id']);
                  },
                  child: Text('Show'),
                ),
              ))
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error fetching Inside Sales employees: $e');
    }
  }

  Future<void> _assignTasks(Set<String> customerIds) async {
    try {
      if (insideSalesEmployees.isEmpty) {
        print('No Inside Sales employees available for assignment');
        // Fetch inside sales employees again in case it wasn't loaded before
        await _showInsideSalesEmployees();
        if (insideSalesEmployees.isEmpty) {
          return;  // If still no employees, exit the function
        }
      }

      int employeeIndex = 0;

      for (String customerId in customerIds) {
        Map<String, dynamic> selectedEmployee = insideSalesEmployees[employeeIndex];

        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .update({
          'assignedEmployee': selectedEmployee['id'],
        });

        print('Assigned task to employee ${selectedEmployee['id']} for customer $customerId');

        // Move to the next employee in a circular manner
        employeeIndex = (employeeIndex + 1) % insideSalesEmployees.length;
      }

      // Fetch the updated list of customers after assigning tasks
      await _fetchCustomers();

      setState(() {
        selectedCustomerIds.clear();
      });
    } catch (e) {
      print('Error assigning tasks: $e');
    }
  }


  Future<void> _autoAssignInsideSales() async {
    try {
      QuerySnapshot insideSalesEmployeesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('sales', isEqualTo: 'InsideSales')
          .get();

      QuerySnapshot unassignedCustomersSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('assignedEmployee', isEqualTo: null)
          .get();

      List<Map<String, dynamic>> insideSalesEmployees = insideSalesEmployeesSnapshot.docs
          .map((employee) => {
        'id': employee.id,
        'name': employee['name'] as String,
      })
          .toList();

      int maxCustomersPerEmployee = 9000000;

      for (int i = 0; i < insideSalesEmployees.length; i++) {
        for (int j = 0; j < maxCustomersPerEmployee; j++) {
          if (unassignedCustomersSnapshot.docs.isNotEmpty) {
            Map<String, dynamic> selectedEmployee = insideSalesEmployees[i];
            DocumentSnapshot customer = unassignedCustomersSnapshot.docs.removeAt(0);

            await FirebaseFirestore.instance
                .collection('customers')
                .doc(customer.id)
                .update({
              'assignedEmployee': selectedEmployee['id'],
            });

            print('Assigned task to employee ${selectedEmployee['id']} for customer ${customer.id}');
          } else {
            break; // Break if there are no more unassigned customers
          }
        }
      }

      print('Automatic assignment completed');
    } catch (e) {
      print('Error in automatic assignment: $e');
    }
  }


  Future<void> _showAssignedCustomers(String employeeId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignedCustomersScreen(employeeId: employeeId),
      ),
    );
  }

  void _selectAllCustomers() {
    setState(() {
      if (selectAll) {
        selectAll = false;
        selectedCustomerIds.clear();
      } else {
        selectAll = true;
        selectedCustomerIds = Set.from(allCustomers
            .where((customer) => (customer.data() as Map<String, dynamic>?)?['assignedEmployee'] == null)
            .map((customer) => customer.id));
      }
    });
  }
}