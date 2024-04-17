// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// // import 'package:real_estate_project/Inside/Account_Page.dart';
// // import 'package:real_estate_project/Inside/TargetsList1.dart';
// import 'package:real_estate_project/login/loginform.dart';
// import 'assign.dart';
// // Import the file where Details is defined
//
// class UserProfile {
//   final String userId;
//   final String profilePic;
//   final String? dob;
//   final String? email;
//   final String? gender;
//   final String? name;
//   final String? phone;
//
//   UserProfile({
//     required this.userId,
//     required this.profilePic,
//     this.dob,
//     this.email,
//     this.gender,
//     this.name,
//     this.phone,
//   });
// }
//
// class InsideSaless extends StatefulWidget {
//   @override
//   _InsideSalesState createState() => _InsideSalesState();
// }
//
// class _InsideSalesState extends State<InsideSaless> {
//   bool _locationEnabled = false;
//   Position? _currentPosition;
//   double _distance = 0.0; // Initialize distance to 0.0
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _loggedOut = false;
//   late Timer _timer;
//
//   // Target location coordinates (example)
//   final double targetLatitude = 12.9225975;
//   final double targetLongitude = 77.5179594;
//   final double range = 3; // 100 meters range
//
//   @override
//   void initState() {
//     super.initState();
//     _checkLocationPermission();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _timer.cancel();
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 4), (timer) {
//       _getCurrentLocation(); //_checkLocationPermission();
//     });
//   }
//
//   void _checkLocationPermission() async {
//     bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!isLocationServiceEnabled) {
//       setState(() {
//         _locationEnabled = false;
//       });
//     } else {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.always ||
//           permission == LocationPermission.whileInUse) {
//         setState(() {
//           _locationEnabled = true;
//         });
//         _startTimer(); // Start timer after ensuring location permission
//         _getCurrentLocation(); // Get current location after ensuring location permission
//       } else {
//         setState(() {
//           _locationEnabled = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _currentPosition = position;
//       });
//
//       // Check if user is within range
//       _checkIfInRange(position);
//     } catch (e) {
//       print("Error getting current location: $e");
//     }
//   }
//
//   void _checkIfInRange(Position position) {
//     double distanceInMeters = Geolocator.distanceBetween(
//         position.latitude, position.longitude, targetLatitude, targetLongitude);
//
//     setState(() {
//       _distance = distanceInMeters;
//     });
//
//     if (distanceInMeters > range) {
//       _logoutAndSaveLocation(); // Logout if out of range
//     }
//   }
//
//   Future<void> _logoutAndSaveLocation() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null && _distance > range && !_loggedOut) {
//       setState(() {
//         _loggedOut = true;
//       });
//
//       // Save location data to Firestore
//       await FirebaseFirestore.instance.collection('employees').doc(user.uid).collection('logoutTimes').add({
//         'time': DateTime.now(),
//       });
//
//       // Perform logout
//       await FirebaseAuth.instance.signOut();
//
//       // Navigate to the login page
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => BlankPage()),
//       );
//     }
//   }
//
//   void _navigateToPage(BuildContext context, Widget page) {
//     if (!_locationEnabled) {
//       // If location permission is not granted, show a message or take appropriate action
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Location permission not granted. Enable location to access this feature.'),
//         ),
//       );
//       return;
//     }
//
//     if (_loggedOut) {
//       // If logged out due to being out of range, prevent navigation
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('You are out of range. Please log in again when within range.'),
//         ),
//       );
//       return;
//     }
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => page),
//     );
//   }
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _selectedIndex = 0;
//
//   Future<UserProfile?> getCurrentUserProfile() async {
//     User? user = _auth.currentUser;
//
//     if (user != null) {
//       DocumentSnapshot userSnapshot =
//       await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
//
//       if (userSnapshot.exists) {
//         String name = userSnapshot['name'] ?? 'John Doe';
//         String profilePic = userSnapshot['profilePic'] ?? '';
//         String? dob = userSnapshot['dob'];
//         String? email = userSnapshot['email'];
//         String? gender = userSnapshot['gender'];
//         String? phone = userSnapshot['phone'];
//
//         return UserProfile(
//           userId: user.uid,
//           name: name,
//           profilePic: profilePic,
//           dob: dob,
//           email: email,
//           gender: gender,
//           phone: phone,
//         );
//       } else {
//         print('User document does not exist.');
//         return null;
//       }
//     } else {
//       return null;
//     }
//   }
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _locationEnabled
//           ? AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.deepPurple,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () async {
//               UserProfile? userProfile = await getCurrentUserProfile();
//               if (userProfile != null) {
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //     builder: (context) => UserProfileScreen(userProfile: userProfile),
//                 //   ),
//                 // );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('No user is logged in.'),
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       )
//           : null,
//       body: FutureBuilder<UserProfile?>(
//         future: getCurrentUserProfile(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center();
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             UserProfile? userProfile = snapshot.data;
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome, ${userProfile?.name ?? "InsideSales"}!',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 userProfile != null
//                     ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Add more user profile information as needed
//                   ],
//                 )
//                     : Icon(
//                   Icons.warning,
//                   size: 40,
//                   color: Colors.red,
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: _locationEnabled
//           ? BottomNavigationBar(
//         backgroundColor: Colors.deepPurpleAccent,
//         type: BottomNavigationBarType.fixed,
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home, color: Colors.white),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.phone, color: Colors.white),
//             label: 'Calls',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.interests, color: Colors.white),
//             label: 'Intrested',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.assignment, color: Colors.white),
//             label: 'Assigned',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.orangeAccent,
//         unselectedItemColor: Colors.white,
//         onTap: (int index) async {
//           // Handle navigation for each tab here
//           if (index == 1) {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => TargetsList1()));
//           } else if (index == 2) {
//             //  Navigator.push(context, MaterialPageRoute(builder: (context) => Interested()));
//           } else if (index == 3) {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => Details()));
//           } else {
//             // Handle navigation for other tabs if needed
//           }
//         },
//       )
//           : null,
//     );
//   }
// }
//
// class BlankPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//       ),
//
//       body: Container(), // Empty container for a blank page
//     );
//   }
// }