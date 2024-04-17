import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Customer.dart';
import '../../dashboards/Inside dashboard.dart';

class Event {
  String title;
  final DateTime time;
  String id;

  Event({required this.title, required this.time, required this.id});
}

class Calendars extends StatefulWidget {
  Calendars({Key? key, required this.title, required this.customers}) : super(key: key);

  final String title;
  final Map<String, dynamic> customers;

  @override
  _CalendarsState createState() => _CalendarsState();
}

class _CalendarsState extends State<Calendars> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  String? _selectedEmployee;
  String? _loggedInEmployeeId; // Define _loggedInEmployeeId here

  @override
  void initState() {
    super.initState();
    _getCurrentEmployeeId();
    // Fetch events from Cloud Firestore
    _loadEvents();
  }

  void _getCurrentEmployeeId() {
    // Fetch the current user's ID from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _loggedInEmployeeId = user.uid;
    }
  }

  Future<void> _loadEvents() async {
    Set<String> assignedEventIds = await _getAssignedEventIds();

    QuerySnapshot eventsSnapshot =
    await FirebaseFirestore.instance.collection('events').get();

    eventsSnapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      String title = data['title'];
      DateTime time = (data['time'] as Timestamp).toDate();
      String id = document.id;

      if (!assignedEventIds.contains(id)) {
        Event event = Event(title: title, time: time, id: id);

        if (_events[time] != null) {
          _events[time]!.add(event);
        } else {
          _events[time] = [event];
        }
      }
    });

    setState(() {});
  }

  Future<Set<String>> _getAssignedEventIds() async {
    QuerySnapshot assignmentsSnapshot =
    await FirebaseFirestore.instance.collection('assignments').get();

    Set<String> assignedEventIds = Set();

    assignmentsSnapshot.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String eventId = data['eventId'];

      assignedEventIds.add(eventId);
    });

    return assignedEventIds;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (newTime != null) {
      setState(() {
        _selectedDay = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
          newTime.hour,
          newTime.minute,
        );
      });
    }
  }

  void _addEvent() {
    if (_selectedDay != null) {
      final existingEvents = _events[_selectedDay] ?? [];

      final newEvent = Event(
        title: 'New Event',
        time: _selectedDay!,
        id: '', // Empty ID for new event
      );

      // Add the event to Cloud Firestore
      FirebaseFirestore.instance.collection('events').add({
        'title': newEvent.title,
        'time': newEvent.time,
        'customers': widget.customers, // Pass customer details
      }).then((DocumentReference documentReference) {
        // Use the generated document ID as a unique identifier for the event
        newEvent.id = documentReference.id;

        existingEvents.add(newEvent);

        // Update the events map
        _events[_selectedDay!] = existingEvents;

        setState(() {});
      });
    }
  }

  void _assignWork(Map<String, dynamic> customerDetails, Event event) {
    FirebaseFirestore.instance.collection('assignments').where('customerId', isEqualTo: customerDetails['id']).get().then((QuerySnapshot assignmentSnapshot) {
      if (assignmentSnapshot.docs.isNotEmpty) {
        // Customer is already assigned, show a message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Already Assigned'),
              content: Text('This customer is already assigned to an employee.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Continue with the assignment process
        FirebaseFirestore.instance.collection('employees').get().then((QuerySnapshot employeeSnapshot) {
          if (employeeSnapshot.docs.isNotEmpty) {
            List<Map<String, dynamic>> outsideSalesEmployees = employeeSnapshot.docs
                .where((doc) => doc['sales'] == 'Outside Sales')
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            if (outsideSalesEmployees.isNotEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      List<Map<String, dynamic>> displayedEmployees = List.from(outsideSalesEmployees);

                      return AlertDialog(
                        title: Text('Outside Sales Employees'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  displayedEmployees = outsideSalesEmployees
                                      .where((employee) =>
                                      employee['name'].toLowerCase().contains(value.toLowerCase()))
                                      .toList();
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Search Employee',
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('Name')),
                                  ],
                                  rows: displayedEmployees
                                      .map(
                                        (employee) => DataRow(
                                      cells: [
                                        DataCell(
                                          InkWell(
                                            onTap: () {
                                              _assignWorkToEmployee(customerDetails, event, employee);
                                            },
                                            child: Text(employee['name']),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('No Outside Sales Employees'),
                    content: Text('There are no Outside Sales employees available to assign the work.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            print('No employees found');
          }
        });
      }
    });
  }

  void _assignWorkToEmployee(Map<String, dynamic> customerDetails, Event event, Map<String, dynamic> employeeData) {
    // Check if the employeeData contains the necessary information
    if (employeeData['name'] != null && employeeData['email'] != null) {
      // Fetch the employee ID from the 'employees' collection based on the name and email
      FirebaseFirestore.instance.collection('employees')
          .where('name', isEqualTo: employeeData['name'])
          .where('email', isEqualTo: employeeData['email'])
          .get()
          .then((QuerySnapshot employeeSnapshot) {
        if (employeeSnapshot.docs.isNotEmpty) {
          // Get the auto-generated employee ID
          String employeeId = employeeSnapshot.docs.first.id;

          // Get the ID of the currently logged-in employee from FirebaseAuth
          String? loggedInEmployeeId = _loggedInEmployeeId;

          if (loggedInEmployeeId != null) {
            // Check if the assignment already exists
            FirebaseFirestore.instance.collection('assignments')
                .where('customerId', isEqualTo: customerDetails['id'])
                .where('employeeId', isEqualTo: employeeId)
                .where('eventId', isEqualTo: event.id)
                .get()
                .then((QuerySnapshot assignmentSnapshot) {
              if (assignmentSnapshot.docs.isEmpty) {
                // Add the assignment to Cloud Firestore
                FirebaseFirestore.instance.collection('assignments').add({
                  'customerId': customerDetails['id'],
                  'customerName': customerDetails['name'],
                  'customerEmail': customerDetails['email'],
                  'customerPhone': customerDetails['phone'],
                  'eventId': event.id,
                  'eventTitle': event.title,
                  'eventTime': event.time,
                  'employeeId': employeeId,
                  'employeeName': employeeData['name'],
                  'assignedBy': loggedInEmployeeId, // Add the ID of the logged-in employee
                }).then((DocumentReference documentReference) {
                  print('Work assigned successfully!');

                  // Retrieve the assigned employee details
                  _getAssignedEmployeeDetails(documentReference.id);

                  // Show a pop-up message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Work Assigned'),
                        content: Text('Work has been successfully assigned to ${employeeData['name']}.'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog

                              // Navigate to the Customer page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InsideSales(),
                                ),
                              );
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                });
              } else {
                print('Assignment already exists for this customer and employee.');
              }
            });
          } else {
            print('Error: Could not fetch the ID of the logged-in employee.');
          }
        } else {
          print('Error: Employee not found in the "employees" collection.');
        }
      });
    } else {
      print('Error: Employee data is incomplete or null.');
    }
  }





  void _getAssignedEmployeeDetails(String assignmentId) {
    FirebaseFirestore.instance
        .collection('assignments')
        .doc(assignmentId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> assignmentData = documentSnapshot.data() as Map<String, dynamic>;

        // Get assigned employee details
        String employeeId = assignmentData['employeeId'];
        String employeeName = assignmentData['employeeName'];
        String employeeEmail = assignmentData['employeeEmail'];
        String employeePhone = assignmentData['employeePhone'];

        // Navigate to the Customer page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Customer(
              // employeeId: employeeId,
              // employeeName: employeeName,
              // employeeEmail: employeeEmail,
              // employeePhone: employeePhone,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TableCalendar(
                calendarFormat: _calendarFormat,
                availableCalendarFormats: {
                  CalendarFormat.month: 'Month',
                  CalendarFormat.week: 'Week',
                },
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return _selectedDay != null && isSameDay(_selectedDay!, day);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = selectedDay;
                  });
                },
                firstDay: DateTime(2000, 1, 1),
                lastDay: DateTime(4024, 12, 31),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: true,
                  weekendTextStyle: TextStyle(color: Colors.red),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.black),
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Colors.red),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
                ),
              ),
              SizedBox(height: 16),
              Text('Selected date: ${_selectedDay?.toString() ?? 'None'}'),
              SizedBox(height: 16),
              if (_selectedDay != null) ...[
                ElevatedButton(
                  onPressed: () {
                    _selectTime(context);
                  },
                  child: Text('Select time'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _addEvent();
                  },
                  child: Text('Add Event'),
                ),
                SizedBox(height: 16),
                if (_events.containsKey(_selectedDay))
                  ListView(
                    shrinkWrap: true,
                    children: _events[_selectedDay]!
                        .map((event) => ListTile(
                      title: Text('Event: ${event.title}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _assignWork(widget.customers, event);
                          print('Button pressed for ${event.title}');
                        },
                        child: Text('Employee'),
                      ),
                    ))
                        .toList(),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}