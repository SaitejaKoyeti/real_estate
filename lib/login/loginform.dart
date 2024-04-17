// // import 'dart:async';
// //
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_windowmanager/flutter_windowmanager.dart';
// // import '../dashboards/Admindashboard.dart';
// // import '../dashboards/Inside dashboard.dart';
// // import '../inside/pages/dashboard.dart';
// // import '../services/FirebaseService.dart';
// // import '../dashboards/outside_dashboard.dart';
// // import 'package:geolocator/geolocator.dart';
// //
// // class LoginPage extends StatefulWidget {
// //   @override
// //   _LoginPageState createState() => _LoginPageState();
// // }
// //
// // class _LoginPageState extends State<LoginPage> {
// //   final FirebaseService _firebaseService = FirebaseService();
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //
// //   Timer? _locationTimer;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     // Start listening for location changes when the widget is initialized
// //     _startLocationListener();
// //   }
// //
// //   @override
// //   void dispose() {
// //     // Cancel the location timer when the widget is disposed
// //     _locationTimer?.cancel();
// //     super.dispose();
// //   }
// //
// //
// //   Future<void> _clearSecureFlag() async {
// //     if (!kIsWeb) {
// //       try {
// //         // Use flutter_windowmanager only on Android
// //         await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
// //         await Future.delayed(Duration(milliseconds: 500));
// //         await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
// //
// //         // Add an overlay to cover the content
// //         final overlayEntry = OverlayEntry(
// //           builder: (context) => Stack(
// //             children: [
// //               Positioned.fill(
// //                 child: Container(
// //                   color: Colors.black, // You can change the color or use a transparent color
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //
// //         Overlay.of(context)?.insert(overlayEntry);
// //
// //         // Optionally, you can remove the overlay after a certain duration
// //         await Future.delayed(Duration(seconds: 5));
// //         overlayEntry.remove();
// //       } catch (e) {
// //         // Handle the exception if the plugin methods fail
// //         print("Error during clearFlags or addFlags: $e");
// //       }
// //     }
// //   }
// //
// //   Future<void> _signIn() async {
// //     try {
// //       if (!kIsWeb) {
// //         // Call _clearSecureFlag only if not running on the web
// //         await _clearSecureFlag();
// //       }
// //
// //       final User? user = await _firebaseService.signInWithEmailAndPassword(
// //         _emailController.text,
// //         _passwordController.text,
// //       );
// //
// //       if (user != null) {
// //         if (await _firebaseService.isAdmin(user.uid)) {
// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(builder: (context) => DashBoard()),
// //           );
// //           return;
// //         }
// //
// //         String? userSalesRole = await _firebaseService.getUserSalesRole(user.uid);
// //
// //         if (userSalesRole == 'Inside Sales') {
// //           // Check location for Inside Sales
// //           bool isLocationValid = await _checkLocation();
// //
// //           if (isLocationValid) {
// //             _navigateToPage(InsideSales());
// //           } else {
// //             // Handle invalid location
// //             print("Invalid location for Inside Sales");
// //             // Show a snackbar or display an error message
// //             // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid location")));
// //
// //             // Log out the user
// //             await _signOut();
// //           }
// //         } else if (userSalesRole == 'Outside Sales') {
// //           _navigateToPage(OutsideSales());
// //         } else {
// //           // Handle other roles as needed
// //         }
// //       }
// //     } catch (e) {
// //       // Handle sign-in errors
// //       print("Error during sign-in: $e");
// //       // Show a snackbar or display an error message
// //       // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
// //     }
// //   }
// //
// //
// //
// //   void _startLocationListener() {
// //     const Duration interval = Duration(seconds: 10);
// //
// //     _locationTimer = Timer.periodic(interval, (Timer timer) async {
// //       await _getCurrentLocation();
// //     });
// //   }
// //
// //   void _performAutomaticLogout() {
// //     _signOut();
// //
// //     Navigator.pushReplacement(
// //       context,
// //       MaterialPageRoute(builder: (context) => LoginPage()),
// //     );
// //   }
// //
// //   Future<void> _getCurrentLocation() async {
// //     try {
// //       LocationPermission permission = await Geolocator.checkPermission();
// //
// //       if (permission == LocationPermission.denied) {
// //         permission = await Geolocator.requestPermission();
// //
// //         if (permission != LocationPermission.whileInUse &&
// //             permission != LocationPermission.always) {
// //           print("Location permission denied");
// //           _performAutomaticLogout();
// //           return;
// //         }
// //       }
// //
// //       Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //
// //       print("Location updated: (${position.latitude}, ${position.longitude})");
// //
// //       if (_isUserInsideSales() && !_checkValidLocation(position)) {
// //         print("Invalid location for Inside Sales");
// //         _performAutomaticLogout();
// //       }
// //     } catch (e) {
// //       print("Error during location check: $e");
// //       _performAutomaticLogout();
// //     }
// //   }
// //
// //   bool _isUserInsideSales() {
// //     return true; // Replace with your actual check
// //   }
// //
// //   bool _checkValidLocation(Position position) {
// //     return true; // Replace with your actual check
// //   }
// //
// // // Function to check if the current location is within the allowed range
// //   Future<bool> _checkLocation() async {
// //     try {
// //       LocationPermission permission = await Geolocator.checkPermission();
// //
// //       if (permission == LocationPermission.denied) {
// //         // Request permission if not granted
// //         permission = await Geolocator.requestPermission();
// //
// //         if (permission != LocationPermission.whileInUse &&
// //             permission != LocationPermission.always) {
// //           // Handle case where permission is not granted
// //           print("Location permission denied");
// //           // Show a snackbar or display an error message
// //           // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Location permission denied")));
// //           return false;
// //         }
// //       }
// //
// //       Position position = await Geolocator.getCurrentPosition(
// //         desiredAccuracy: LocationAccuracy.high,
// //       );
// //
// //       // Check if the user is Inside Sales and if the location is valid
// //       if (_isUserInsideSales() && !_checkValidLocation(position)) {
// //         print("Invalid location for Inside Sales");
// //         // Perform automatic logout
// //         _performAutomaticLogout();
// //         return false;
// //       }
// //
// //       // If the location is valid, return true
// //       return true;
// //     } catch (e) {
// //       // Handle location retrieval errors
// //       print("Error during location check: $e");
// //       return false;
// //     }
// //   }
// //
// //
// //
// //
// //
// //   void _navigateToPage(Widget page) {
// //     Navigator.pushReplacement(
// //       context,
// //       MaterialPageRoute(builder: (context) => page),
// //     );
// //   }
// //
// //   Future<void> _signOut() async {
// //     try {
// //       await _firebaseService.signOut();
// //     } catch (e) {
// //       print("Error during sign-out: $e");
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Login'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             TextField(
// //               controller: _emailController,
// //               decoration: InputDecoration(labelText: 'Email'),
// //               keyboardType: TextInputType.emailAddress,
// //             ),
// //             TextField(
// //               controller: _passwordController,
// //               decoration: InputDecoration(labelText: 'Password'),
// //               obscureText: true,
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: _signIn,
// //               child: Text('Sign In'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:real_estate_project/dashboards/Admindashboard.dart';
// import 'package:real_estate_project/dashboards/Inside%20dashboard.dart';
// import 'package:real_estate_project/dashboards/outside_dashboard.dart';
//
// class Employee {
//   late String id;
//   late String email;
//
//   Employee({required this.id, required this.email});
// }
//
// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Color?> _colorAnimation;
//   late Animation<double> _buttonAnimation;
//   late Animation<double> _textAnimation;
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     );
//     _colorAnimation =
//         ColorTween(begin: Colors.brown[200], end: Colors.white).animate(_controller);
//     _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
//     _textAnimation = Tween<double>(begin: 24.0, end: 36.0).animate(_controller);
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.brown[200],
//         title: Text(
//           'Login',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: Stack(
//         children: [
//         // Watermark Image
//         Opacity(
//         opacity: 0.5,
//         child: Image.asset(
//           "assets/images/Splash Screen.png",
//           fit: BoxFit.cover,
//           width: double.infinity,
//           height: double.infinity,
//         ),
//       ),
//
//         AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Container(
//               color: _colorAnimation.value,
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     SizedBox(
//                       height: 100.0,
//                       child: AnimatedDefaultTextStyle(
//                         duration: Duration(seconds: 1),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: _textAnimation.value,
//                           fontWeight: FontWeight.bold,
//                         ),
//
//                       ),
//                     ),
//                     SizedBox(height: 32.0),
//                     Opacity(
//                       opacity: _buttonAnimation.value,
//                       child: TextField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email',
//                           labelStyle: TextStyle(color: Colors.black),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.black),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.black),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.1),
//                         ),
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                     SizedBox(height: 16.0),
//                     Opacity(
//                       opacity: _buttonAnimation.value,
//                       child: TextField(
//                         controller: _passwordController,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           labelStyle: TextStyle(color: Colors.black),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.black),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.black),
//                             borderRadius: BorderRadius.circular(10.0),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.1),
//                         ),
//                         obscureText: true,
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                     SizedBox(height: 24.0),
//                     Opacity(
//                       opacity: _buttonAnimation.value,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           _signInWithEmailAndPassword();
//                         },
//                         child: Text('Login'),
//                         style: ElevatedButton.styleFrom(
//                           shape: StadiumBorder(),
//                           primary: Colors.brown[200],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//     ],
//       )
//
//     );
//   }
//
//   Future<void> _signInWithEmailAndPassword() async {
//     try {
//       // Authenticate user
//       UserCredential userCredential =
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );
//
//       // User authenticated successfully, retrieve user data
//       User? user = userCredential.user;
//       if (user != null) {
//         // Check if user is Inside sales employee
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection('employees')
//             .doc(user.uid)
//             .get();
//         bool isInsideSalesEmployee =
//             userDoc.exists && userDoc['sales'] == 'Inside Sales';
//
//         if (isInsideSalesEmployee) {
//           // Inside sales employee
//           // Check location
//           await _checkLocation(user.uid);
//         } else {
//           // Regular user or admin, navigate to appropriate dashboard
//           if (userDoc.exists && userDoc['sales'] == 'Outside Sales') {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => OutsideSales(),
//               ),
//             );
//           } else {
//             // Check if user is an admin
//             bool isAdmin =
//             await _checkIfAdmin(_emailController.text, _passwordController.text);
//             if (isAdmin) {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => DashBoard(),
//                 ),
//               );
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Login failed: $e');
//       // Handle login failure (e.g., show error message to user)
//     }
//   }
//
//   Future<bool> _checkIfAdmin(String email, String password) async {
//     try {
//       // Get the admin document from Firestore based on the provided email
//       QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
//           .collection('Admin')
//           .where('email', isEqualTo: email)
//           .get();
//
//       // Check if any documents match the provided email
//       if (adminSnapshot.docs.isNotEmpty) {
//         // Check if the password matches (this is just a basic example and is not secure)
//         // You should never store passwords in plain text like this
//         if (adminSnapshot.docs.first['password'] == password) {
//           // Admin document exists and password matches
//           return true;
//         } else {
//           // Password does not match
//           return false;
//         }
//       } else {
//         // Admin document with the provided email does not exist
//         return false;
//       }
//     } catch (e) {
//       // Error occurred while fetching admin document
//       print('Error fetching admin document: $e');
//       return false;
//     }
//   }
//
//   Future<void> _checkLocation(String userId) async {
//     // Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Location services are not enabled, show pop-up message
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Location Services Disabled"),
//             content: Text("Please enable location services to use this app."),
//             actions: <Widget>[
//               TextButton(
//                 child: Text("OK"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//       return;
//     }
//
//     // Request location permission
//     var status = await Permission.location.request();
//     if (status.isDenied) {
//       // Permission denied
//       return;
//     }
//
//     if (status.isGranted) {
//       // Permission granted, get current location
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
//
//       // Define the desired location
//       double desiredLatitude = 12.9225975;
//       double desiredLongitude = 77.5179594;
//
//       // Calculate distance between current location and desired location
//       double distanceInMeters = Geolocator.distanceBetween(
//         position.latitude,
//         position.longitude,
//         desiredLatitude,
//         desiredLongitude,
//       );
//
//       print('Distance to desired location: $distanceInMeters meters');
//
//       if (distanceInMeters > 100) {
//         // User is not within 100 meters of the desired location
//         // Show a blank screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Scaffold(),
//           ),
//         );
//         return;
//       }
//       await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(userId)
//           .collection('loginTimes')
//           .add({
//         'time': DateTime.now(),
//       });
//
//       // Navigate to Inside sales dashboard
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => InsideSales(),
//         ),
//       );
//     }
//   }
//
//   Future<void> _logout(String userId) async {
//     // Save logout time
//     await FirebaseFirestore.instance
//         .collection('employees')
//         .doc(userId)
//         .collection('logoutTimes')
//         .add({
//       'time': DateTime.now(),
//     });
//
//     // Perform logout logic (e.g., sign out from FirebaseAuth)
//     await FirebaseAuth.instance.signOut();
//
//     // Navigate to login page after logout
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => LoginPage(),
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Your App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoginPage(),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../dashboards/Admindashboard.dart';
import '../dashboards/Inside dashboard.dart';
import '../dashboards/outside_dashboard.dart';
import '../executive/RealEstateDashboard.dart';
import '../inside/pages/TargetScreen.dart';

class Employee {
  late String id;
  late String email;

  Employee({required this.id, required this.email});
}

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     'Login',
      //     style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
      //   ),
      // ),
      body: Stack(

        fit: StackFit.expand,
        children: [
          // Background watermark image
        Opacity(
        opacity: 0.5,
          child:
          Image.asset(
            "assets/images/Splash Screen.png",
            fit: BoxFit.cover,
          ),
        ),
          Center(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [


                  SizedBox(height: 32.0),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      _signInWithEmailAndPassword(context);
                    },
                    child: Text('Login',style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      primary: Colors.blue[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
        bool isInsideSalesEmployee = userDoc.exists && userDoc['sales'] == 'Inside Sales';

        if (isInsideSalesEmployee) {
          await _checkLocation(context, user.uid);
        } else {
          if (userDoc.exists && userDoc['sales'] == 'Outside Sales') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OutsideSales(),
              ),
            );
          } else {
            bool isAdmin = await _checkIfAdmin(_emailController.text, _passwordController.text);
            if (isAdmin) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashBoard(),
                ),
              );
            }

            bool checkIfExecutive = await _checkIfExecutive(_emailController.text, _passwordController.text);
            if (checkIfExecutive) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RealEstateDashboard(),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Login failed: $e');
    }
  }

  Future<bool> _checkIfAdmin(String email, String password) async {
    try {
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance.collection('Admin').where('email', isEqualTo: email).get();

      if (adminSnapshot.docs.isNotEmpty) {
        if (adminSnapshot.docs.first['password'] == password) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Error fetching admin document: $e');
      return false;
    }
  }

  Future<bool> _checkIfExecutive(String email, String password) async {
    try {
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance.collection('executive').where('email', isEqualTo: email).get();

      if (adminSnapshot.docs.isNotEmpty) {
        if (adminSnapshot.docs.first['password'] == password) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Error fetching admin document: $e');
      return false;
    }
  }

  Future<void> _checkLocation(BuildContext context, String userId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Location Services Disabled"),
            content: Text("Please enable location services to use this app."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    var status = await Permission.location.request();
    if (status.isDenied) {
      return;
    }

    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      double desiredLatitude = 12.9120906;
      double desiredLongitude = 77.5209867;

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        desiredLatitude,
        desiredLongitude,
      );

      if (distanceInMeters > 1000000) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(),
          ),
        );
        return;
      }
      await FirebaseFirestore.instance.collection('employees').doc(userId).collection('loginTimes').add({
        'time': DateTime.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InsideSales(),
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context, String userId) async {
    await FirebaseFirestore.instance.collection('employees').doc(userId).collection('logoutTimes').add({
      'time': DateTime.now(),
    });

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  Future<void> _clearSecureFlag(BuildContext context) async {
    if (!kIsWeb) {
      try {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
        await Future.delayed(Duration(milliseconds: 500));
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

        final overlayEntry = OverlayEntry(
          builder: (context) => Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );

        Overlay.of(context)?.insert(overlayEntry);

        await Future.delayed(Duration(seconds: 5));
        overlayEntry.remove();
      } catch (e) {
        print("Error during clearFlags or addFlags: $e");
      }
    }
  }
}
