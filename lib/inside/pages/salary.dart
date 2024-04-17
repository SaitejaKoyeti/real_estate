import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDataPagess extends StatefulWidget {
  @override
  _ViewDataPagessState createState() => _ViewDataPagessState();
}

class _ViewDataPagessState extends State<ViewDataPagess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendances Sheet'),
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

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Employee ID: $employeeId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Employee Name: $employeeName', style: TextStyle(fontSize: 16)),
                      Text('Employee Email: $employeeEmail', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text('Login/Logout Logs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      StreamBuilder(
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

                              // Group login and logout times by date
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

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: loginTimesPerDate.entries.map((entry) {
                                  final formattedDate = entry.key;
                                  final loginTimes = entry.value;
                                  final logoutTimes = logoutTimesPerDate[formattedDate] ?? [];
                                  final loginLogoutDurations = _calculateLoginLogoutDurations(loginTimes, logoutTimes);

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text('Date: $formattedDate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 5),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: loginLogoutDurations.map((duration) => Text(duration, style: TextStyle(fontSize: 14))).toList(),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<String> _calculateLoginLogoutDurations(List<DateTime> loginTimes, List<DateTime> logoutTimes) {
    List<String> durations = [];
    double totalAmount = 0;

    for (int i = 0; i < loginTimes.length; i++) {
      if (i < logoutTimes.length) {
        final duration = logoutTimes[i].difference(loginTimes[i]);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        final seconds = duration.inSeconds.remainder(60);
        final formattedLoginTime = '${loginTimes[i].hour}:${loginTimes[i].minute}:${loginTimes[i].second}';
        final formattedLogoutTime = '${logoutTimes[i].hour}:${logoutTimes[i].minute}:${logoutTimes[i].second}';
        final amount = (hours * 60 + minutes + seconds / 60) * 700 / 420; // Assuming 7 hours per day
        totalAmount += amount;
        durations.add('Login: $formattedLoginTime   Logout: $formattedLogoutTime   Duration: $hours hours $minutes minutes $seconds seconds   Amount: \$${amount.toStringAsFixed(2)}');
      } else {
        final formattedLoginTime = '${loginTimes[i].hour}:${loginTimes[i].minute}:${loginTimes[i].second}';
        durations.add('Login: $formattedLoginTime   Logout time missing');
      }
    }

    durations.add('Total Amount for the day: \$${totalAmount.toStringAsFixed(2)}');
    return durations;
  }
}
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // import '../../widgets/employees/employeedetailspage.dart'; // Import the file where EmployeeDetailsService is defined
// //
// //
// // class ViewDataPagess extends StatefulWidget {
// //   @override
// //   _ViewDataPagessState createState() => _ViewDataPagessState();
// // }
// //
// // class _ViewDataPagessState extends State<ViewDataPagess> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('View Data'),
// //       ),
// //       body: StreamBuilder(
// //         stream: FirebaseFirestore.instance.collection('employees').snapshots(),
// //         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           }
// //           if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           }
// //           final employeeDocs = snapshot.data!.docs;
// //
// //           return ListView.builder(
// //             itemCount: employeeDocs.length,
// //             itemBuilder: (context, index) {
// //               final employeeData = employeeDocs[index].data() as Map<String, dynamic>;
// //               final employeeId = employeeDocs[index].id;
// //               final employeeName = employeeData['name'];
// //               final employeeEmail = employeeData['email'];
// //
// //               return FutureBuilder<Map<String, dynamic>>(
// //                 future: EmployeeDetailsScreen.getEmployeeDetails(employeeId),
// //                 builder: (context, snapshot) {
// //                   if (snapshot.connectionState == ConnectionState.waiting) {
// //                     return CircularProgressIndicator();
// //                   }
// //                   if (snapshot.hasError) {
// //                     return Text('Error fetching employee details: ${snapshot.error}');
// //                   }
// //
// //                   final employeeDetails = snapshot.data!;
// //                   final List<DateTime> loginTimes = (employeeDetails['loginTimes'] as List).map((time) => (time as Timestamp).toDate()).toList();
// //                   final List<DateTime> logoutTimes = (employeeDetails['logoutTimes'] as List).map((time) => (time as Timestamp).toDate()).toList();
// //                   final loginLogoutDurations = LoginLogoutService.calculateLoginLogoutDurations(loginTimes, logoutTimes);
// //
// //                   return Card(
// //                     margin: EdgeInsets.all(10),
// //                     elevation: 5,
// //                     child: Padding(
// //                       padding: EdgeInsets.all(10),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text('Employee ID: $employeeId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                           SizedBox(height: 5),
// //                           Text('Employee Name: $employeeName', style: TextStyle(fontSize: 16)),
// //                           Text('Employee Email: $employeeEmail', style: TextStyle(fontSize: 16)),
// //                           SizedBox(height: 10),
// //                           Text('Login/Logout Logs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
// //                           SizedBox(height: 5),
// //                           Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: loginLogoutDurations.map((duration) => Text(duration, style: TextStyle(fontSize: 14))).toList(),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// //
// // class LoginLogoutService {
// //   static calculateLoginLogoutDurations(List<DateTime> loginTimes, List<DateTime> logoutTimes) {}
// // }
