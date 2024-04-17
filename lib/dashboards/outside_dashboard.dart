// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
//
// import 'Inside dashboard.dart';
// import '../inside/pages/TargetScreen.dart';
// import '../inside/pages/UserProfileScreen.dart';
// import '../inside/pages/assign.dart';
// import '../inside/pages/intrested.dart';
// import '../login/loginform.dart';
// import '../widgets/employees/AssignedCustomersPage2.dart';
//
// class OutsideSales extends StatefulWidget {
//   @override
//   _OutsideSalesState createState() => _OutsideSalesState();
// }
//
// class _OutsideSalesState extends State<OutsideSales> with TickerProviderStateMixin {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _selectedIndex = 0;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//
//     // Start the animation when the widget is first built
//     _fadeController.forward();
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     super.dispose();
//   }
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
//   Future<void> _onLogoutPressed() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // Prevent user from dismissing the dialog by tapping outside
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Logout'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('Are you sure you want to logout?'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Yes'),
//               onPressed: () async {
//                 // Handle Logout here
//                 await _auth.signOut();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 );
//               },
//             ),
//             TextButton(
//               child: Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   Widget _buildBodyContent(int selectedIndex, UserProfile? userProfile) {
//     switch (selectedIndex) {
//       case 0:
//       // Home tab content
//         return Center(
//           child: Image.asset(
//             'assets/images/logo.png', // Replace with your image asset path
//             width: 200.0, // Set the width as needed
//             height: 200.0, // Set the height as needed
//           ),
//         );
//
//       case 1:
//       // Calls tab content
//         return AssignedCustomersPage1();
//
//       case 2:
//       // Profile tab content
//         return userProfile != null
//             ? UserProfileScreen(userProfile: userProfile)
//             : Center(child: Text('No user is logged in'));
//
//       default:
//         return Container(); // Placeholder, add additional cases as needed
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.green[200],
//         title: Text(
//           'Real Estate',
//           style: TextStyle(color: Colors.white),
//         ),
//         // Show logout icon in the top right corner when logged in
//         actions: _auth.currentUser != null
//             ? [
//           IconButton(
//             icon: Icon(Icons.logout, color: Colors.white),
//             onPressed: _onLogoutPressed,
//           ),
//         ]
//             : null,
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
//             return FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildBodyContent(_selectedIndex, userProfile),
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.green[200], // Change color as needed
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
//             icon: Icon(Icons.person, color: Colors.white),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.orangeAccent,
//         unselectedItemColor: Colors.white,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
//
// }
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'Inside dashboard.dart';
// import '../inside/pages/TargetScreen.dart';
// import '../inside/pages/UserProfileScreen.dart';
// import '../inside/pages/assign.dart';
// import '../inside/pages/intrested.dart';
// import '../login/loginform.dart';
// import '../widgets/employees/AssignedCustomersPage2.dart';
//
// class OutsideSales extends StatefulWidget {
//   @override
//   _OutsideSalesState createState() => _OutsideSalesState();
// }
//
// class _OutsideSalesState extends State<OutsideSales> with TickerProviderStateMixin {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int _selectedIndex = 0;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//
//     // Start the animation when the widget is first built
//     _fadeController.forward();
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     super.dispose();
//   }
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
//   Future<void> _onLogoutPressed() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // Prevent user from dismissing the dialog by tapping outside
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Logout'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('Are you sure you want to logout?'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Yes'),
//               onPressed: () async {
//                 // Handle Logout here
//                 await _auth.signOut();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginPage()),
//                 );
//               },
//             ),
//             TextButton(
//               child: Text('No'),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildBodyContent(int selectedIndex, UserProfile? userProfile) {
//     switch (selectedIndex) {
//       case 0:
//       // Home tab content
//         return Center(
//           child: Image.asset(
//             'assets/images/logo.png', // Replace with your image asset path
//             width: 200.0, // Set the width as needed
//             height: 200.0, // Set the height as needed
//           ),
//         );
//
//       case 1:
//       // Calls tab content
//         return AssignedCustomersPage1();
//
//       case 2:
//       // Profile tab content
//         return ElevatedButton(
//           onPressed: () {
//             _showProfileDialog(context, userProfile!);
//           },
//           child: Text('View Profile'),
//         );
//
//       default:
//         return Container(); // Placeholder, add additional cases as needed
//     }
//   }
//
//   void _showProfileDialog(BuildContext context, UserProfile userProfile) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('User Profile'),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Name: ${userProfile.name}'),
//               Text('DOB: ${userProfile.dob ?? 'N/A'}'),
//               Text('Email: ${userProfile.email ?? 'N/A'}'),
//               Text('Gender: ${userProfile.gender ?? 'N/A'}'),
//               Text('Phone: ${userProfile.phone ?? 'N/A'}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.blueAccent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(15),
//           ),
//         ),
//         title: Text(
//           'Real Estate',
//           style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
//         ),
//         // Show logout icon in the top right corner when logged in
//         actions: _auth.currentUser != null
//             ? [
//           IconButton(
//             icon: Icon(Icons.logout, color: Colors.white),
//             onPressed: _onLogoutPressed,
//           ),
//         ]
//             : null,
//       ),
//       backgroundColor: Colors.black,
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
//             return FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildBodyContent(_selectedIndex, userProfile),
//             );
//           }
//         },
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(15),
//           ),
//           color: Colors.blueAccent,
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
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
//               icon: Icon(Icons.person, color: Colors.white),
//               label: 'Profile',
//             ),
//           ],
//           currentIndex: _selectedIndex,
//           selectedItemColor: Colors.orangeAccent,
//           unselectedItemColor: Colors.white,
//           onTap: _onItemTapped,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Inside dashboard.dart';
import '../inside/pages/TargetScreen.dart';
import '../inside/pages/UserProfileScreen.dart';
import '../inside/pages/assign.dart';
import '../inside/pages/intrested.dart';
import '../login/loginform.dart';
import '../widgets/employees/AssignedCustomersPage2.dart';

class OutsideSales extends StatefulWidget {
  @override
  _OutsideSalesState createState() => _OutsideSalesState();
}

class _OutsideSalesState extends State<OutsideSales> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start the animation when the widget is first built
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

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

  Future<void> _onLogoutPressed() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to logout?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                // Handle Logout here
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBodyContent(int selectedIndex, UserProfile? userProfile) {
    switch (selectedIndex) {
      case 0:
      // Home tab content
        return Center(
          child: Image.asset(
            'assets/images/logo.png', // Replace with your image asset path
            width: 200.0, // Set the width as needed
            height: 200.0, // Set the height as needed
          ),
        );

      case 1:
      // Calls tab content
        return AssignedCustomersPage1();

      case 2:
      // Profile tab content
        return ElevatedButton(
          onPressed: () {
            _showProfileDialog(context, userProfile!);
          },
          child: Text('View Profile'),
        );

      default:
        return Container(); // Placeholder, add additional cases as needed
    }
  }

  void _showProfileDialog(BuildContext context, UserProfile userProfile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Profile'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${userProfile.name}'),
              Text('DOB: ${userProfile.dob ?? 'N/A'}'),
              Text('Email: ${userProfile.email ?? 'N/A'}'),
              Text('Gender: ${userProfile.gender ?? 'N/A'}'),
              Text('Phone: ${userProfile.phone ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Real Estate',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        // Show logout icon in the top right corner when logged in
        actions: _auth.currentUser != null
            ? [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _onLogoutPressed,
          ),
        ]
            : null,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<UserProfile?>(
        future: getCurrentUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            UserProfile? userProfile = snapshot.data;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildBodyContent(_selectedIndex, userProfile),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
            color: Colors.blueAccent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
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
                icon: Icon(Icons.person, color: Colors.white),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.orangeAccent,
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
