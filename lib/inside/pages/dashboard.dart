// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'Inside Admindashboard.dart';
// import 'assign.dart';
//
// class insideDashboardScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         title: Text('Real Estate', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(colors: [Color.fromARGB(255, 53, 51, 51), Colors.red]),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.white,
//                       backgroundImage: AssetImage('assets/real estate.jpg'),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Center(
//                     child: Text(
//                       'Real Estate',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.people, color: Colors.white),
//               title: Text('Add Employee'),
//               tileColor: Colors.black,
//               textColor: Colors.white,
//               onTap: () {
//                 // Handle navigation to Add Employee screen
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.bookmark_border_outlined, color: Colors.white),
//               title: Text('Inside Sales'),
//               tileColor: Colors.black,
//               textColor: Colors.white,
//               onTap: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => InsideSales()));
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.bookmark_border_outlined, color: Colors.white),
//               title: Text('Outside Sales'),
//               tileColor: Colors.black,
//               textColor: Colors.white,
//               onTap: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => Details()));
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.settings, color: Colors.white),
//               title: Text('Settings'),
//               tileColor: Colors.black,
//               textColor: Colors.white,
//               onTap: () {
//                 // Handle settings logic here
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.exit_to_app, color: Colors.white),
//               title: Text('Logout'),
//               tileColor: Colors.black,
//               textColor: Colors.white,
//               onTap: () {
//                 _logout(context);
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Welcome, Admin!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             // Add your main content widgets here
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Logout function
//   void _logout(BuildContext context) {
//     // Perform logout actions, such as clearing authentication/session data
//
//     // For example, if you are using Firebase Authentication:
//      FirebaseAuth.instance.signOut();
//
//     // After logout, navigate to the login screen
//     Navigator.pushReplacementNamed(context, '/AdminLogin'); // Replace with your login screen route
//   }
// }
