// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:push_notifications_firebase_flutter/pages/out.dart';
//
//
// class Outside extends StatefulWidget {
//   const Outside({Key? key});
//
//   @override
//   State<Outside> createState() => _OutsideState();
// }
//
// class _OutsideState extends State<Outside> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Outside Sales'),
//         actions: [
//           GestureDetector(
//             onTap: () {
//               _showProfileDetailsDialog(context);
//             },
//             child: Container(
//               margin: const EdgeInsets.all(8.0),
//               child: CircleAvatar(
//                 radius: 15,
//                 backgroundImage:NetworkImage('https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcR1h65X6WJgJLQX__Ji0g_l7lykHKgX2h9afpJHIvey6H-7-4S_ZYWAdW9LcbZ47tVFbEBpo46kWm0huBs'),
//               ),
//             ),
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Colors.blue, Colors.green],
//             ),
//           ),
//           child: Column(
//             children: [
//               _buildDrawerItem(
//                   CupertinoIcons.person_crop_circle, 'Account', () {
//                 _handleMenuTap('Account');
//               }),
//               _buildDrawerItem(
//                   CupertinoIcons.arrow_2_circlepath_circle, 'Targets', () {
//                 _handleMenuTap('Targets');
//               }),
//               _buildDrawerItem(CupertinoIcons.photo, 'Upload Pic', () {
//                 _handleMenuTap('Upload Pic');
//               }),
//               _buildDrawerItem(
//                   CupertinoIcons.person_2_alt, 'Interested Customers', () {
//                 _handleMenuTap('Interested Customers');
//               }),
//               _buildDrawerItem(CupertinoIcons.gear, 'Settings', () {
//                 _handleMenuTap('Settings');
//               }),
//               _buildDrawerItem(Icons.exit_to_app, 'Logout', () {
//                 _handleMenuTap('Logout');
//               }),
//             ],
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue, Colors.green],
//           ),
//         ),
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 borderRadius: const BorderRadius.only(
//                   bottomRight: Radius.circular(50),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 50),
//                 ],
//               ),
//             ),
//             Container(
//               color: Colors.green,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 30),
//                 decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(200))),
//                 child: GridView.count(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 40,
//                   mainAxisSpacing: 30,
//                   children: [
//                     itemDashboard('Account', CupertinoIcons.person_crop_circle, Colors.deepOrange),
//                     itemDashboard('Targets', CupertinoIcons.arrow_2_circlepath_circle, Colors.green),
//                     itemDashboard('Upload pic', CupertinoIcons.chat_bubble_2, Colors.brown),
//                     itemDashboard('Interested Customer', CupertinoIcons.money_dollar_circle, Colors.indigo),
//                     itemDashboard('Setting', CupertinoIcons.add_circled, Colors.teal),
//                     itemDashboard('Logout', CupertinoIcons.question_circle, Colors.blue),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showProfileDetailsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Profile Details'),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Text('Name: Ahad'),
//               Text('Email: ahad@example.com'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _handleMenuTap(String menuItem) {
//     switch (menuItem) {
//       case 'Account':
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>Details()));
//       // Handle tap on 'Account'
//         break;
//       case 'Targets':
//       // Handle tap on 'Targets'
//         break;
//       case 'Upload Pic':
//       // Handle tap on 'Upload Pic'
//         break;
//       case 'Interested Customers':
//       // Handle tap on 'Interested Customers'
//         break;
//       case 'Settings':
//       // Handle tap on 'Settings'
//         break;
//       case 'Logout':
//       // Handle tap on 'Logout'
//         break;
//     }
//   }
//
//   Widget itemDashboard(String title, IconData iconData, Color background) =>
//       Container(
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                   offset: const Offset(0, 5),
//                   color: Theme.of(context).primaryColor.withOpacity(.2),
//                   spreadRadius: 2,
//                   blurRadius: 5)
//             ]),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: background,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(iconData, color: Colors.white)),
//             const SizedBox(height: 8),
//             Text(title.toUpperCase(),
//                 style: Theme.of(context).textTheme.headline6),
//           ],
//         ),
//       );
//
//   Widget _buildDrawerItem(
//       IconData iconData, String text, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(iconData),
//       title: Text(text),
//       onTap: onTap,
//     );
//   }
// }
