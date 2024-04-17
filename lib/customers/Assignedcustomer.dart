// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AssignedCustomersScreen extends StatefulWidget {
//   final String employeeId;
//
//   AssignedCustomersScreen({required this.employeeId});
//
//   @override
//   _AssignedCustomersScreenState createState() =>
//       _AssignedCustomersScreenState();
// }
//
// class _AssignedCustomersScreenState extends State<AssignedCustomersScreen> {
//   late List<DocumentSnapshot> assignedCustomers = [];
//   Set<String> selectedCustomerIds = Set<String>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Assigned Customers'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.select_all),
//             onPressed: _selectAllCustomers,
//           ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: _deleteSelectedCustomers,
//           ),
//         ],
//       ),
//       body: assignedCustomers.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           Text('Total Assigned Customers: ${assignedCustomers.length}'),
//           Expanded(
//             child: ListView.builder(
//               itemCount: assignedCustomers.length,
//               itemBuilder: (context, index) {
//                 Map<String, dynamic> customerData =
//                 assignedCustomers[index].data()
//                 as Map<String, dynamic>;
//
//                 return CustomerListTile(
//                   customerData: customerData,
//                   customerId: assignedCustomers[index].id,
//                   isSelected: selectedCustomerIds
//                       .contains(assignedCustomers[index].id),
//                   onSelectPressed: () =>
//                       _toggleCustomerSelection(
//                           assignedCustomers[index].id),
//                   onDeletePressed: () =>
//                       _deleteAssignedCustomer(assignedCustomers[index].id),
//                 );
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
//     _fetchAssignedCustomers();
//   }
//
//   Future<void> _fetchAssignedCustomers() async {
//     try {
//       QuerySnapshot assignedCustomersSnapshot =
//       await FirebaseFirestore.instance
//           .collection('customers')
//           .limit(100) // Limit to 10 customers per day
//           .get();
//
//       setState(() {
//         assignedCustomers = assignedCustomersSnapshot.docs;
//       });
//     } catch (e) {
//       print('Error fetching assigned customers: $e');
//     }
//   }
//   void _deleteAssignedCustomer(String customerId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirmation'),
//           content:
//           Text('Are you sure you want to delete this assigned customer?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
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
//                   assignedCustomers
//                       .removeWhere((customer) => customer.id == customerId);
//                 });
//
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _selectAllCustomers() {
//     setState(() {
//       if (selectedCustomerIds.length < assignedCustomers.length) {
//         selectedCustomerIds =
//             Set.from(assignedCustomers.map((customer) => customer.id));
//       } else {
//         selectedCustomerIds.clear();
//       }
//     });
//   }
//
//   void _toggleCustomerSelection(String customerId) {
//     setState(() {
//       if (selectedCustomerIds.contains(customerId)) {
//         selectedCustomerIds.remove(customerId);
//       } else {
//         selectedCustomerIds.add(customerId);
//       }
//     });
//   }
//
//   void _deleteSelectedCustomers() {
//     if (selectedCustomerIds.isNotEmpty) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Confirmation'),
//             content:
//             Text('Are you sure you want to delete the selected customers?'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                 },
//                 child: Text("Cancel"),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   for (String customerId in selectedCustomerIds) {
//                     await FirebaseFirestore.instance
//                         .collection('customers')
//                         .doc(customerId)
//                         .delete();
//
//                     setState(() {
//                       assignedCustomers.removeWhere(
//                               (customer) => customer.id == customerId);
//                     });
//                   }
//
//                   Navigator.of(context).pop(); // Close the dialog
//                 },
//                 child: Text("Delete"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// }
//
// class CustomerListTile extends StatelessWidget {
//   final Map<String, dynamic> customerData;
//   final String customerId;
//   final bool isSelected;
//   final VoidCallback onSelectPressed;
//   final VoidCallback onDeletePressed;
//
//   CustomerListTile({
//     required this.customerData,
//     required this.customerId,
//     required this.isSelected,
//     required this.onSelectPressed,
//     required this.onDeletePressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 3,
//       child: ListTile(
//         title: Text('Customer Name: ${customerData['name']}'),
//         subtitle: Text('Customer ID: $customerId'),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Checkbox(
//               value: isSelected,
//               onChanged: (value) => onSelectPressed(),
//             ),
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: onDeletePressed,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AssignedCustomersScreen extends StatefulWidget {
//   final String employeeId;
//
//   AssignedCustomersScreen({required this.employeeId});
//
//   @override
//   _AssignedCustomersScreenState createState() =>
//       _AssignedCustomersScreenState();
// }
//
// class _AssignedCustomersScreenState extends State<AssignedCustomersScreen> {
//   late List<DocumentSnapshot> assignedCustomers = [];
//   Set<String> selectedCustomerIds = Set<String>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Assigned Customers'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.select_all),
//             onPressed: _selectAllCustomers,
//           ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: _deleteSelectedCustomers,
//           ),
//         ],
//       ),
//       body: assignedCustomers.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           Text('Total Assigned Customers: ${assignedCustomers.length}'),
//           Expanded(
//             child: ListView.builder(
//               itemCount: assignedCustomers.length,
//               itemBuilder: (context, index) {
//                 Map<String, dynamic> customerData =
//                 assignedCustomers[index].data()
//                 as Map<String, dynamic>;
//
//                 return CustomerListTile(
//                   customerData: customerData,
//                   customerId: assignedCustomers[index].id,
//                   isSelected: selectedCustomerIds
//                       .contains(assignedCustomers[index].id),
//                   onSelectPressed: () =>
//                       _toggleCustomerSelection(assignedCustomers[index].id),
//                   onDeletePressed: () =>
//                       _deleteAssignedCustomer(assignedCustomers[index].id),
//                 );
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
//     _fetchAssignedCustomers();
//   }
//
//   Future<void> _fetchAssignedCustomers() async {
//     try {
//       QuerySnapshot assignedCustomersSnapshot =
//       await FirebaseFirestore.instance
//           .collection('customers')
//           .where('assignedEmployee', isEqualTo: widget.employeeId)
//           .get();
//
//       setState(() {
//         assignedCustomers = assignedCustomersSnapshot.docs;
//       });
//     } catch (e) {
//       print('Error fetching assigned customers: $e');
//     }
//   }
//
//   void _deleteAssignedCustomer(String customerId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirmation'),
//           content:
//           Text('Are you sure you want to delete this assigned customer?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
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
//                   assignedCustomers
//                       .removeWhere((customer) => customer.id == customerId);
//                 });
//
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _selectAllCustomers() {
//     setState(() {
//       if (selectedCustomerIds.length < assignedCustomers.length) {
//         selectedCustomerIds =
//             Set.from(assignedCustomers.map((customer) => customer.id));
//       } else {
//         selectedCustomerIds.clear();
//       }
//     });
//   }
//
//   void _toggleCustomerSelection(String customerId) {
//     setState(() {
//       if (selectedCustomerIds.contains(customerId)) {
//         selectedCustomerIds.remove(customerId);
//       } else {
//         selectedCustomerIds.add(customerId);
//       }
//     });
//   }
//
//   void _deleteSelectedCustomers() {
//     if (selectedCustomerIds.isNotEmpty) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Confirmation'),
//             content:
//             Text('Are you sure you want to delete the selected customers?'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the dialog
//                 },
//                 child: Text("Cancel"),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   for (String customerId in selectedCustomerIds) {
//                     await FirebaseFirestore.instance
//                         .collection('customers')
//                         .doc(customerId)
//                         .delete();
//
//                     setState(() {
//                       assignedCustomers.removeWhere(
//                               (customer) => customer.id == customerId);
//                     });
//                   }
//
//                   Navigator.of(context).pop(); // Close the dialog
//                 },
//                 child: Text("Delete"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// }
//
// class CustomerListTile extends StatelessWidget {
//   final Map<String, dynamic> customerData;
//   final String customerId;
//   final bool isSelected;
//   final VoidCallback onSelectPressed;
//   final VoidCallback onDeletePressed;
//
//   CustomerListTile({
//     required this.customerData,
//     required this.customerId,
//     required this.isSelected,
//     required this.onSelectPressed,
//     required this.onDeletePressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 3,
//       child: ListTile(
//         title: Text('Customer Name: ${customerData['name']}'),
//         subtitle: Text('Customer ID: $customerId'),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Checkbox(
//               value: isSelected,
//               onChanged: (value) => onSelectPressed(),
//             ),
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: onDeletePressed,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignedCustomersScreen extends StatefulWidget {
  final String employeeId;

  AssignedCustomersScreen({required this.employeeId});

  @override
  _AssignedCustomersScreenState createState() =>
      _AssignedCustomersScreenState();
}

class _AssignedCustomersScreenState extends State<AssignedCustomersScreen> {
  late List<DocumentSnapshot> assignedCustomers = [];
  Set<String> selectedCustomerIds = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assigned Customers'),
        actions: [
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: _selectAllCustomers,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteSelectedCustomers,
          ),
        ],
      ),
      body: assignedCustomers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Text('Total Assigned Customers: ${assignedCustomers.length}'),
          Expanded(
            child: ListView.builder(
              itemCount: assignedCustomers.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> customerData =
                assignedCustomers[index].data()
                as Map<String, dynamic>;

                return CustomerListTile(
                  customerData: customerData,
                  customerId: assignedCustomers[index].id,
                  isSelected: selectedCustomerIds
                      .contains(assignedCustomers[index].id),
                  onSelectPressed: () =>
                      _toggleCustomerSelection(assignedCustomers[index].id),
                  onDeletePressed: () =>
                      _deleteAssignedCustomer(assignedCustomers[index].id),
                );
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
    _fetchAssignedCustomers();
  }

  Future<void> _fetchAssignedCustomers() async {
    try {
      QuerySnapshot assignedCustomersSnapshot =
      await FirebaseFirestore.instance
          .collection('customers')
          .where('assignedEmployee', isEqualTo: widget.employeeId)
          .get();

      setState(() {
        assignedCustomers = assignedCustomersSnapshot.docs;
      });
    } catch (e) {
      print('Error fetching assigned customers: $e');
    }
  }

  void _deleteAssignedCustomer(String customerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content:
          Text('Are you sure you want to delete this assigned customer?'),
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
                  assignedCustomers
                      .removeWhere((customer) => customer.id == customerId);
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

  void _selectAllCustomers() {
    setState(() {
      if (selectedCustomerIds.length < assignedCustomers.length) {
        selectedCustomerIds =
            Set.from(assignedCustomers.map((customer) => customer.id));
      } else {
        selectedCustomerIds.clear();
      }
    });
  }

  void _toggleCustomerSelection(String customerId) {
    setState(() {
      if (selectedCustomerIds.contains(customerId)) {
        selectedCustomerIds.remove(customerId);
      } else {
        selectedCustomerIds.add(customerId);
      }
    });
  }

  void _deleteSelectedCustomers() {
    if (selectedCustomerIds.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content:
            Text('Are you sure you want to delete the selected customers?'),
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
                      assignedCustomers.removeWhere(
                              (customer) => customer.id == customerId);
                    });
                  }

                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    }
  }
}

class CustomerListTile extends StatelessWidget {
  final Map<String, dynamic> customerData;
  final String customerId;
  final bool isSelected;
  final VoidCallback onSelectPressed;
  final VoidCallback onDeletePressed;

  CustomerListTile({
    required this.customerData,
    required this.customerId,
    required this.isSelected,
    required this.onSelectPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        title: Text('Customer Name: ${customerData['name']}'),
        subtitle: Text('Customer ID: $customerId'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (value) => onSelectPressed(),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDeletePressed,
            ),
          ],
        ),
      ),
    );
  }
}
