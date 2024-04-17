// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:real_estate_project/inside/pages/intrested.dart';
// import '../inside/pages/TargetScreen.dart';
// import '../inside/pages/UserProfileScreen.dart';
// import '../inside/pages/assign.dart';
//
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
// class InsideSales extends StatefulWidget {
//   @override
//   _InsideSalesState createState() => _InsideSalesState();
// }
//
// class _InsideSalesState extends State<InsideSales> with SingleTickerProviderStateMixin {
//   bool _locationEnabled = false;
//   Position? _currentPosition;
//   double _distance = 0.0; // Initialize distance to 0.0
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _loggedOut = false;
//   late Timer _timer;
//
//   // Target location coordinates (example)
//   final double targetLatitude = 12.9120906;
//   final double targetLongitude = 77.5209867;
//   final double range = 100; // 100 meters range
//
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
//     _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Location Permission Required"),
//               content: Text("This app requires location permission to function properly."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close dialog
//                     setState(() {
//                       _locationEnabled = false;
//                     });
//                   },
//                   child: Text("No Thanks"),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop(); // Close dialog
//                     await Geolocator.requestPermission();
//                     _checkLocationPermission(); // Re-check permission after requesting
//                   },
//                   child: Text("Grant"),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     }
//   }
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
//       //
//       SystemNavigator.pop();
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
//         backgroundColor: Colors.blueAccent,
//
//         actions: [
//           IconButton(onPressed: (){}, icon: Icon(Icons.wallet)),
//           IconButton(
//             icon: Icon(Icons.person),
//
//             onPressed: () async {
//               UserProfile? userProfile = await getCurrentUserProfile();
//               if (userProfile != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => UserProfileScreen(userProfile: userProfile),
//                   ),
//                 );
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
//              Center(
//             child: Image.asset(
//               'assets/images/logo.png', // Replace with your image asset path
//               width: 200.0, // Set the width as needed
//               height: 200.0, // Set the height as needed
//             ),
//
//
//
//                 // Text(
//                 //   'Welcome, ${userProfile?.name ?? "InsideSales"}!',
//                 //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 // ),
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
//         backgroundColor: Colors.blueAccent,
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
//             Navigator.push(context, MaterialPageRoute(builder: (context) => Intrested()));
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
//}

//
//   Widget _buildBodyContent(int selectedIndex, UserProfile? userProfile) {
//     Widget content;
//     switch (selectedIndex) {
//       case 0:
//       // Replace the Center with an Image widget
//         content = Center(
//           child: Image.asset(
//             'assets/images/logo.png', // Replace with your image asset path
//             width: 200.0, // Set the width as needed
//             height: 200.0, // Set the height as needed
//           ),
//         );
//         break;
//       case 1:
//         content = TargetsList1();
//         break;
//       case 2:
//         content = Intrested();
//         break;
//       case 3:
//         content = Details();
//         break;
//       default:
//         content = Container();
//     }
//
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: content,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurpleAccent, // Change color as needed
//         title: Text(
//           'Real Estate', // Replace with your app title
//           style: TextStyle(color: Colors.white), // Customize text color
//         ),
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () async {
//               UserProfile? userProfile = await getCurrentUserProfile();
//               if (userProfile != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => UserProfileScreen(userProfile: userProfile),
//                   ),
//                 );
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
//       ),
//       backgroundColor: Colors.white,
//       body: FutureBuilder<UserProfile?>(
//         future: getCurrentUserProfile(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             UserProfile? userProfile = snapshot.data;
//
//             return Opacity(
//               opacity: _fadeAnimation.value,
//               child: _buildBodyContent(_selectedIndex, userProfile),
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
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
//             label: 'Interested',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.assignment, color: Colors.white),
//             label: 'Assigned',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.orangeAccent,
//         unselectedItemColor: Colors.white,
//         onTap: (int index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//           _pageController.animateToPage(
//             index,
//             duration: Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         },
//       ),
//     );
//   }
// }
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:real_estate_project/inside/pages/intrested.dart';
// import '../inside/pages/TargetScreen.dart';
// import '../inside/pages/UserProfileScreen.dart';
// import '../inside/pages/assign.dart';
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
// class InsideSales extends StatefulWidget {
//   @override
//   _InsideSalesState createState() => _InsideSalesState();
// }
//
// class _InsideSalesState extends State<InsideSales> with SingleTickerProviderStateMixin {
//   bool _locationEnabled = false;
//   Position? _currentPosition;
//   double _distance = 0.0; // Initialize distance to 0.0
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _loggedOut = false;
//   late Timer _timer;
//
//   // Target location coordinates (example)
//   final double targetLatitude = 12.9120906;
//   final double targetLongitude = 77.5209867;
//   final double range = 100; // 100 meters range
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
//     _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Location Permission Required"),
//               content: Text("This app requires location permission to function properly."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close dialog
//                     setState(() {
//                       _locationEnabled = false;
//                     });
//                   },
//                   child: Text("No Thanks"),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop(); // Close dialog
//                     await Geolocator.requestPermission();
//                     _checkLocationPermission(); // Re-check permission after requesting
//                   },
//                   child: Text("Grant"),
//                 ),
//               ],
//             );
//           },
//         );
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
//       //
//       SystemNavigator.pop();
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
//         backgroundColor: Colors.blueAccent,
//         actions: [
//           IconButton(onPressed: () {}, icon: Icon(Icons.wallet)),
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () async {
//               UserProfile? userProfile = await getCurrentUserProfile();
//               if (userProfile != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => UserProfileScreen(userProfile: userProfile),
//                   ),
//                 );
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
//                 Center(
//                   child: Image.asset(
//                     'assets/images/logo.png', // Replace with your image asset path
//                     width: 200.0, // Set the width as needed
//                     height: 200.0, // Set the height as needed
//                   ),
//                 ),
//                 // Text(
//                 //   'Welcome, ${userProfile?.name ?? "InsideSales"}!',
//                 //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 // ),
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
//         backgroundColor: Colors.blueAccent,
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
//             Navigator.push(context, MaterialPageRoute(builder: (context) => Intrested()));
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
//       body: Container(), // No need for a container
//     );
//   }
// }
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:real_estate_project/inside/pages/intrested.dart';
// import '../inside/pages/TargetScreen.dart';
// import '../inside/pages/UserProfileScreen.dart';
// import '../inside/pages/assign.dart';
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
// class InsideSales extends StatefulWidget {
//   @override
//   _InsideSalesState createState() => _InsideSalesState();
// }
//
// class _InsideSalesState extends State<InsideSales> with SingleTickerProviderStateMixin {
//   bool _locationEnabled = false;
//   Position? _currentPosition;
//   double _distance = 0.0; // Initialize distance to 0.0
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _loggedOut = false;
//   late Timer _timer;
//
//   // Target location coordinates (example)
//   final double targetLatitude = 12.922476;
//   final double targetLongitude = 77.5156017;
//   final double range = 100000000; // 100 meters range
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
//     _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Location Permission Required"),
//               content: Text("This app requires location permission to function properly."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close dialog
//                     setState(() {
//                       _locationEnabled = false;
//                     });
//                   },
//                   child: Text("No Thanks"),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop(); // Close dialog
//                     await Geolocator.requestPermission();
//                     _checkLocationPermission(); // Re-check permission after requesting
//                   },
//                   child: Text("Grant"),
//                 ),
//               ],
//             );
//           },
//         );
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
//       //
//       SystemNavigator.pop();
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
//         backgroundColor: Colors.blueAccent,
//         actions: [
//           IconButton(onPressed: () {}, icon: Icon(Icons.wallet)),
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () async {
//               UserProfile? userProfile = await getCurrentUserProfile();
//               if (userProfile != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => UserProfileScreen(userProfile: userProfile),
//                   ),
//                 );
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
//             return Center(
//
//             );
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             UserProfile? userProfile = snapshot.data;
//
//             return Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/logo.png', // Replace with your image asset path
//                     width: 200.0, // Set the width as needed
//                     height: 200.0, // Set the height as needed
//                   ),
//                   SizedBox(height: 20),
//                   userProfile != null
//                       ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Add more user profile information as needed
//                     ],
//                   )
//                       : Icon(
//                     Icons.warning,
//                     size: 40,
//                     color: Colors.red,
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: _locationEnabled
//           ? BottomNavigationBar(
//         backgroundColor: Colors.blueAccent,
//
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
//             Navigator.push(context, MaterialPageRoute(builder: (context) => Intrested()));
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
//       body: Container(), // No need for a container
//     );
//   }
// }
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:real_estate_project/inside/pages/intrested.dart';
// import '../inside/pages/TargetScreen.dart';
// import '../inside/pages/UserProfileScreen.dart';
// import '../inside/pages/assign.dart';
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
// class InsideSales extends StatefulWidget {
//   @override
//   _InsideSalesState createState() => _InsideSalesState();
// }
//
// class _InsideSalesState extends State<InsideSales> with SingleTickerProviderStateMixin {
//   bool _locationEnabled = false;
//   Position? _currentPosition;
//   double _distance = 0.0; // Initialize distance to 0.0
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _loggedOut = false;
//   late Timer _timer;
//
//   // Target location coordinates (example)
//   final double targetLatitude = 12.922476;
//   final double targetLongitude = 77.5156017;
//   final double range = 100000000; // 100 meters range
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
//     _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text("Location Permission Required"),
//               content: Text("This app requires location permission to function properly."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close dialog
//                     setState(() {
//                       _locationEnabled = false;
//                     });
//                   },
//                   child: Text("No Thanks"),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop(); // Close dialog
//                     await Geolocator.requestPermission();
//                     _checkLocationPermission(); // Re-check permission after requesting
//                   },
//                   child: Text("Grant"),
//                 ),
//               ],
//             );
//           },
//         );
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
//       //
//       SystemNavigator.pop();
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
//         backgroundColor: Colors.blueAccent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(15),
//           ),
//         ),
//         actions: [
//           IconButton(onPressed: () {}, icon: Icon(Icons.wallet)),
//           IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () async {
//               UserProfile? userProfile = await getCurrentUserProfile();
//               if (userProfile != null) {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => UserProfileScreen(userProfile: userProfile),
//                   ),
//                 );
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
//             return Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/logo.png', // Replace with your image asset path
//                     width: 200.0, // Set the width as needed
//                     height: 200.0, // Set the height as needed
//                   ),
//                   SizedBox(height: 20),
//                   userProfile != null
//                       ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Add more user profile information as needed
//                     ],
//                   )
//                       : Icon(
//                     Icons.warning,
//                     size: 40,
//                     color: Colors.red,
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: _locationEnabled
//           ? Container(
//         decoration: BoxDecoration(
//           color: Colors.blueAccent,
//
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 6,
//               offset: Offset(0, -3),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(
//               bottom: Radius.circular(15),
//             ),
//           ),
//
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           items: <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home, color: Colors.white),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.phone, color: Colors.white),
//               label: 'Calls',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.interests, color: Colors.white),
//               label: 'Interested',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.assignment, color: Colors.white),
//               label: 'Assigned',
//             ),
//           ],
//           currentIndex: _selectedIndex,
//           selectedItemColor: Colors.orangeAccent,
//           unselectedItemColor: Colors.white,
//           onTap: (int index) async {
//             // Handle navigation for each tab here
//             if (index == 1) {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => TargetsList1()));
//             } else if (index == 2) {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => Intrested()));
//             } else if (index == 3) {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => Details()));
//             } else {
//               // Handle navigation for other tabs if needed
//             }
//           },
//         ),
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
//       body: Container(), // No need for a container
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../inside/pages/TargetScreen.dart';
import '../inside/pages/UserProfileScreen.dart';
import '../inside/pages/assign.dart';
import '../inside/pages/intrested.dart';

class UserProfile {
  final String userId;
  final String profilePic;
  final String? dob;
  final String? email;
  final String? gender;
  final String? name;
  final String? phone;

  UserProfile({
    required this.userId,
    required this.profilePic,
    this.dob,
    this.email,
    this.gender,
    this.name,
    this.phone,
  });
}

class InsideSales extends StatefulWidget {
  @override
  _InsideSalesState createState() => _InsideSalesState();
}

class _InsideSalesState extends State<InsideSales> with SingleTickerProviderStateMixin {
  bool _locationEnabled = false;
  Position? _currentPosition;
  double _distance = 0.0; // Initialize distance to 0.0
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loggedOut = false;
  late Timer _timer;

  // Target location coordinates (example)
  final double targetLatitude = 12.922476;
  final double targetLongitude = 77.5156017;
  final double range = 100000000; // 100 meters range

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _getCurrentLocation(); //_checkLocationPermission();
    });
  }

  void _checkLocationPermission() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      setState(() {
        _locationEnabled = false;
      });
    } else {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        setState(() {
          _locationEnabled = true;
        });
        _startTimer(); // Start timer after ensuring location permission
        _getCurrentLocation(); // Get current location after ensuring location permission
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Location Permission Required"),
              content: Text("This app requires location permission to function properly."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    setState(() {
                      _locationEnabled = false;
                    });
                  },
                  child: Text("No Thanks"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close dialog
                    await Geolocator.requestPermission();
                    _checkLocationPermission(); // Re-check permission after requesting
                  },
                  child: Text("Grant"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });

      // Check if user is within range
      _checkIfInRange(position);
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _checkIfInRange(Position position) {
    double distanceInMeters = Geolocator.distanceBetween(
        position.latitude, position.longitude, targetLatitude, targetLongitude);

    setState(() {
      _distance = distanceInMeters;
    });

    if (distanceInMeters > range) {
      _logoutAndSaveLocation(); // Logout if out of range
    }
  }

  Future<void> _logoutAndSaveLocation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _distance > range && !_loggedOut) {
      setState(() {
        _loggedOut = true;
      });

      // Save location data to Firestore
      await FirebaseFirestore.instance.collection('employees').doc(user.uid).collection('logoutTimes').add({
        'time': DateTime.now(),
      });

      // Perform logout
      await FirebaseAuth.instance.signOut();

      // Navigate to the login page
      //
      SystemNavigator.pop();
    }
  }

  void _navigateToPage(BuildContext context, Widget page) {
    if (!_locationEnabled) {
      // If location permission is not granted, show a message or take appropriate action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission not granted. Enable location to access this feature.'),
        ),
      );
      return;
    }

    if (_loggedOut) {
      // If logged out due to being out of range, prevent navigation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are out of range. Please log in again when within range.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  Future<UserProfile?> getCurrentUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();

      if (userSnapshot.exists) {
        String name = userSnapshot['name'] ?? 'John Doe';
        String profilePic = userSnapshot['profilePic'] ?? '';
        String? dob = userSnapshot['dob'];
        String? email = userSnapshot['email'];
        String? gender = userSnapshot['gender'];
        String? phone = userSnapshot['phone'];

        return UserProfile(
          userId: user.uid,
          name: name,
          profilePic: profilePic,
          dob: dob,
          email: email,
          gender: gender,
          phone: phone,
        );
      } else {
        print('User document does not exist.');
        return null;
      }
    } else {
      return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _locationEnabled
          ? AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.wallet)),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () async {
                UserProfile? userProfile = await getCurrentUserProfile();
                if (userProfile != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(userProfile: userProfile),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No user is logged in.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      )
          : null,
      body: FutureBuilder<UserProfile?>(
        future: getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            UserProfile? userProfile = snapshot.data;
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Replace with your image asset path
                    width: 200.0, // Set the width as needed
                    height: 200.0, // Set the height as needed
                  ),
                  SizedBox(height: 20),
                  userProfile != null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add more user profile information as needed
                    ],
                  )
                      : Icon(
                    Icons.warning,
                    size: 40,
                    color: Colors.red,
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: _locationEnabled
          ? ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.white),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.phone, color: Colors.white),
                label: 'Calls',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.interests, color: Colors.white),
                label: 'Interested',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment, color: Colors.white),
                label: 'Assigned',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orangeAccent,
            unselectedItemColor: Colors.white,
            onTap: (int index) async {
              // Handle navigation for each tab here
              if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TargetsList1()));
              } else if (index == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Intrested()));
              } else if (index == 3) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Details()));
              } else {
                // Handle navigation for other tabs if needed
              }
            },
          ),
        ),
      )
          : null,
    );
  }
}

class BlankPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Container(), // No need for a container
    );
  }
}