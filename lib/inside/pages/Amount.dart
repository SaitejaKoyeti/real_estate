import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewDataPagesss extends StatefulWidget {
  @override
  _ViewDataPagesssState createState() => _ViewDataPagesssState();
}

class _ViewDataPagesssState extends State<ViewDataPagesss> {
  DateTime _selectedDay = DateTime.now();
  final double hourlyRate = 10000; // Rate per minute

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Data'),
        actions: [
          IconButton(
            onPressed: () {
              _selectDate(context);
            },
            icon: Icon(Icons.calendar_today),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
              });
            },
            icon: Icon(Icons.today),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('employees').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final employeeDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: employeeDocs.length,
            itemBuilder: (context, index) {
              final employeeData = employeeDocs[index].data() as Map<String, dynamic>;
              final employeeId = employeeDocs[index].id;
              final employeeName = employeeData['name'];
              final employeeEmail = employeeData['email'];
              final totalAmount = employeeData['totalAmount'] ?? 0.0; // Fetch totalAmount from Firestore

              return ListTile(
                title: Text('Employee ID: $employeeId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Employee Name: $employeeName'),
                    Text('Employee Email: $employeeEmail'),
                    Text('Total Amount: Rs.${totalAmount.toStringAsFixed(2)}'),
                    Text('Login/Logout Logs:'),
                    _buildLoginLogoutLogs(employeeId),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime.utc(2022, 1, 1),
      lastDate: DateTime.utc(2025, 12, 31),
    );
    if (picked != null && picked != _selectedDay) {
      setState(() {
        _selectedDay = picked;
      });
    }
  }

  Widget _buildLoginLogoutLogs(String employeeId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .collection('loginTimes')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> loginSnapshot) {
        if (loginSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (loginSnapshot.hasError) {
          return Text('Error: ${loginSnapshot.error}');
        }

        final loginDocs = loginSnapshot.data!.docs;

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('employees')
              .doc(employeeId)
              .collection('logoutTimes')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> logoutSnapshot) {
            if (logoutSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (logoutSnapshot.hasError) {
              return Text('Error: ${logoutSnapshot.error}');
            }

            final logoutDocs = logoutSnapshot.data!.docs;

            Map<String, List<DateTime>> loginTimesPerDate = {};
            Map<String, List<DateTime>> logoutTimesPerDate = {};

            for (var loginDoc in loginDocs) {
              final loginTime = loginDoc['time'].toDate();
              final loginDate = DateTime(loginTime.year, loginTime.month, loginTime.day);
              final formattedDate = '${loginDate.year}-${loginDate.month}-${loginDate.day}';
              if (!loginTimesPerDate.containsKey(formattedDate)) {
                loginTimesPerDate[formattedDate] = [];
              }
              loginTimesPerDate[formattedDate]!.add(loginTime);
            }

            for (var logoutDoc in logoutDocs) {
              final logoutTime = logoutDoc['time'].toDate();
              final logoutDate = DateTime(logoutTime.year, logoutTime.month, logoutTime.day);
              final formattedDate = '${logoutDate.year}-${logoutDate.month}-${logoutDate.day}';
              if (!logoutTimesPerDate.containsKey(formattedDate)) {
                logoutTimesPerDate[formattedDate] = [];
              }
              logoutTimesPerDate[formattedDate]!.add(logoutTime);
            }

            final selectedDateFormatted =
                '${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}';
            final loginTimes = loginTimesPerDate[selectedDateFormatted] ?? [];
            final logoutTimes = logoutTimesPerDate[selectedDateFormatted] ?? [];
            final loginLogoutDurations =
            _calculateLoginLogoutDurations(loginTimes, logoutTimes, employeeId);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: $selectedDateFormatted'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: loginLogoutDurations
                      .map((duration) => Text(duration))
                      .toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _calculateLoginLogoutDurations(
      List<DateTime> loginTimes, List<DateTime> logoutTimes, String employeeId) {
    List<String> durations = [];

    for (int i = 0; i < loginTimes.length; i++) {
      if (i < logoutTimes.length) {
        final loginHour = loginTimes[i].hour;
        final logoutHour = logoutTimes[i].hour;

        // Check if the login and logout times are between 9:00 and 17:00
        if (loginHour >= 9 && loginHour < 24&& logoutHour >= 9 && logoutHour < 24) {
          final duration = logoutTimes[i].difference(loginTimes[i]);
          final minutes = duration.inMinutes;
          final formattedLoginTime =
              '${loginTimes[i].hour}:${loginTimes[i].minute}:${loginTimes[i].second}';
          final formattedLogoutTime =
              '${logoutTimes[i].hour}:${logoutTimes[i].minute}:${logoutTimes[i].second}';

          // Calculate the amount based on the duration and hourly rate
          final amount = (minutes / 60) * hourlyRate;

          // Save the amount to the Firestore database
          FirebaseFirestore.instance
              .collection('employees')
              .doc(employeeId)
              .collection('workLogs')
              .add({
            'loginTime': formattedLoginTime,
            'logoutTime': formattedLogoutTime,
            'duration': minutes,
            'amount': amount,
          });

          durations.add(
              'Login: $formattedLoginTime   Logout: $formattedLogoutTime   Duration: $minutes minutes   Amount: Rs.${amount.toStringAsFixed(2)}');
        } else {
          durations.add('Login/Logout times are not between 9:00 and 17:00');
        }
      } else {
        final formattedLoginTime =
            '${loginTimes[i].hour}:${loginTimes[i].minute}:${loginTimes[i].second}';
        durations.add('Login: $formattedLoginTime   Logout time missing');
      }
    }

    return durations;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: ViewDataPagesss(),
  ));
}