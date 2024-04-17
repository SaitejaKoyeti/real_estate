import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  late String _loggedInEmployeeId;
  final TextEditingController _searchController = TextEditingController();
  String _currentEmployeeSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _getCurrentEmployeeId();
    _searchController.addListener(_onEmployeeSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onEmployeeSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _getCurrentEmployeeId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loggedInEmployeeId = user.uid;
    }
  }

  void _addCustomer() {
    // Implement the logic to add a new customer
    // For example, you can navigate to a new screen to add customer details
  }

  void _onEmployeeSearchTextChanged() {
    setState(() {
      _currentEmployeeSearchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.add),
          //   onPressed: _addCustomer,
          // ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Employees',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: EmployeeStreamBuilder(
              currentEmployeeSearchQuery: _currentEmployeeSearchQuery,
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeStreamBuilder extends StatelessWidget {
  final String currentEmployeeSearchQuery;

  const EmployeeStreamBuilder({
    Key? key,
    required this.currentEmployeeSearchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("assignments")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        }

        Map<String, List<DocumentSnapshot>> employeesByName =
        groupBy(snapshot.data!.docs, (DocumentSnapshot doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['employeeName'].toString();
        });

        employeesByName.removeWhere((key, value) =>
        !key.toLowerCase().contains(currentEmployeeSearchQuery));

        return ListView.builder(
          itemCount: employeesByName.length,
          itemBuilder: (context, index) {
            String employeeName =
            employeesByName.keys.elementAt(index);
            List<DataRow> employeeRows = employeesByName.values
                .elementAt(index)
                .map<DataRow>(
                  (documentSnapshot) {
                var data = documentSnapshot.data() as Map<String, dynamic>;
                String formattedEventTime = (data["eventTime"] as Timestamp).toDate().toString();
                String last4Digits = data["customerPhone"]
                    .toString()
                    .substring(data["customerPhone"].toString().length - 4);
                return DataRow(
                  cells: [
                    DataCell(Text(
                      data["customerName"].toString(),
                      overflow: TextOverflow.ellipsis,
                    )),
                    DataCell(Text(
                      '**$last4Digits',
                      overflow: TextOverflow.ellipsis,
                    )),
                    DataCell(Text(
                      formattedEventTime,
                      overflow: TextOverflow.ellipsis,
                    )),
                    DataCell(Text(
                      data["employeeName"].toString(),
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                );
              },
            ).toList();

            return EmployeeExpansionTile(
              key: ValueKey(employeeName), // Ensure unique key to prevent rebuilding
              employeeName: employeeName,
              employeeRows: employeeRows,

            );

          },
        );
      },
    );
  }
}

class EmployeeExpansionTile extends StatefulWidget {
  final String employeeName;
  final List<DataRow> employeeRows;

  const EmployeeExpansionTile({
    Key? key,
    required this.employeeName,
    required this.employeeRows,
  }) : super(key: key);

  @override
  _EmployeeExpansionTileState createState() => _EmployeeExpansionTileState();
}

class _EmployeeExpansionTileState extends State<EmployeeExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ExpansionTile(
        title: Text(
          'Employee: ${widget.employeeName}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        children: [
          CustomerSearchField(
            employeeRows: widget.employeeRows,
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        initiallyExpanded: _isExpanded,
      ),
    );
  }
}

class CustomerSearchField extends StatefulWidget {
  final List<DataRow> employeeRows;

  const CustomerSearchField({
    Key? key,
    required this.employeeRows,
  }) : super(key: key);

  @override
  _CustomerSearchFieldState createState() => _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends State<CustomerSearchField> {
  late List<DataRow> filteredEmployeeRows;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredEmployeeRows = widget.employeeRows;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      filteredEmployeeRows = widget.employeeRows.where((row) {
        String customerName = row.cells[0].child.runtimeType == Text ? (row.cells[0].child as Text).data! : '';
        return customerName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Customer',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20.0,
            columns: [
              DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Customer Phone', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Event Time', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: filteredEmployeeRows,
          ),
        ),
      ],
    );
  }
}