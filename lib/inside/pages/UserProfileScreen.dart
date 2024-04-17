import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../login/loginform.dart';
import '../../dashboards/Inside dashboard.dart';

class UserProfileScreen extends StatelessWidget {
  final UserProfile userProfile;

  UserProfileScreen({required this.userProfile});

  Future<DocumentSnapshot> getUserProfile(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(userId).get();
      return userDoc;
    } catch (error) {
      // Handle error
      print("Error fetching user profile: $error");
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserProfile(userProfile.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('User Profile')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('User Profile')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.data == null || snapshot.data!.data() == null) {
          return Scaffold(
            appBar: AppBar(title: Text('User Profile')),
            body: Center(child: Text('No data available')),
          );
        } else {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
            appBar: AppBar(
              title: Text('User Profile'),
              elevation: 2,
              backgroundColor: Colors.deepPurpleAccent,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: userData['profilePic'] != null ? NetworkImage(userData['profilePic']) : null,
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    child: userData['profilePic'] != null ? null : Icon(Icons.person, size: 80, color: Colors.black),
                  ),

                  SizedBox(height: 20),
                  Text(
                    'Username: ${userData['name']}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  if (userData['dob'] != null) Text('Date of Birth: ${userData['dob']}'),
                  SizedBox(height: 10),
                  if (userData['email'] != null) Text('Email: ${userData['email']}'),
                  SizedBox(height: 10),
                  if (userData['gender'] != null) Text('Gender: ${userData['gender']}'),
                  SizedBox(height: 10),
                  if (userData['phone'] != null) Text('Phone: ${userData['phone']}'),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(

                      primary: Colors.deepPurpleAccent,
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),

                      child: Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
Future<void> _logout(String userId) async {
  try {
    // Save logout time
    await FirebaseFirestore.instance.collection('employees').doc(userId).collection('logoutTimes').add({
      'time': DateTime.now(),
    });

    // Perform logout logic (e.g., sign out from FirebaseAuth)
    await FirebaseAuth.instance.signOut();
  } catch (error) {
    // Handle error
    print("Error logging out: $error");
    throw error;
  }
}
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../login/loginform.dart';
// import '../../dashboards/Inside dashboard.dart';
//
// class UserProfileScreen extends StatelessWidget {
//   final UserProfile userProfile;
//
//   UserProfileScreen({required this.userProfile});
//
//   Future<Map<String, dynamic>> getUserProfile(String userId) async {
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(userId).get();
//
//       // Fetch login/logout times per hour
//       Map<int, int> loginLogoutCounts = await _fetchLoginLogoutTimes(userId);
//
//       Map<String, dynamic> userData = {
//         'profileData': userDoc.data(),
//         'loginLogoutCounts': loginLogoutCounts,
//       };
//
//       return userData;
//     } catch (error) {
//       // Handle error
//       print("Error fetching user profile: $error");
//       throw error;
//     }
//   }
//
//   // Fetch login/logout times per hour
//   Future<Map<int, int>> _fetchLoginLogoutTimes(String userId) async {
//     try {
//       QuerySnapshot loginSnapshot = await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(userId)
//           .collection('loginTimes')
//           .orderBy('time', descending: true)
//           .get();
//
//       QuerySnapshot logoutSnapshot = await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(userId)
//           .collection('logoutTimes')
//           .orderBy('time', descending: true)
//           .get();
//
//       Map<int, int> hourlyCounts = {};
//
//       // Iterate through each login and logout time and count them per hour
//       loginSnapshot.docs.forEach((loginDoc) {
//         DateTime loginTime = (loginDoc['time'] as Timestamp).toDate();
//         int hour = loginTime.hour;
//         hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
//       });
//
//       logoutSnapshot.docs.forEach((logoutDoc) {
//         DateTime logoutTime = (logoutDoc['time'] as Timestamp).toDate();
//         int hour = logoutTime.hour;
//         hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
//       });
//
//       return hourlyCounts;
//     } catch (e) {
//       print('Error fetching login/logout times: $e');
//       return {};
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: getUserProfile(userProfile.userId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             appBar: AppBar(title: Text('User Profile')),
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasError) {
//           return Scaffold(
//             appBar: AppBar(title: Text('User Profile')),
//             body: Center(child: Text('Error: ${snapshot.error}')),
//           );
//         } else if (snapshot.data == null || snapshot.data!['profileData'] == null) {
//           return Scaffold(
//             appBar: AppBar(title: Text('User Profile')),
//             body: Center(child: Text('No data available')),
//           );
//         } else {
//           var userData = snapshot.data!['profileData'] as Map<String, dynamic>;
//           var loginLogoutCounts = snapshot.data!['loginLogoutCounts'] as Map<int, int>;
//
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('User Profile'),
//               elevation: 2,
//               backgroundColor: Colors.deepPurpleAccent,
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 80,
//                     backgroundImage: userData['profilePic'] != null ? NetworkImage(userData['profilePic']) : null,
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     child: userData['profilePic'] != null ? null : Icon(Icons.person, size: 80, color: Colors.black),
//                   ),
//
//                   SizedBox(height: 20),
//                   Text(
//                     'Username: ${userData['name']}',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   if (userData['dob'] != null) Text('Date of Birth: ${userData['dob']}'),
//                   SizedBox(height: 10),
//                   if (userData['email'] != null) Text('Email: ${userData['email']}'),
//                   SizedBox(height: 10),
//                   if (userData['gender'] != null) Text('Gender: ${userData['gender']}'),
//                   SizedBox(height: 10),
//                   if (userData['phone'] != null) Text('Phone: ${userData['phone']}'),
//                   SizedBox(height: 20),
//                   Text(
//                     'Login/Logout Counts per Hour:',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: 24, // 24 hours in a day
//                       itemBuilder: (context, hour) {
//                         int count = loginLogoutCounts[hour] ?? 0;
//                         return ListTile(
//                           title: Text('Hour $hour: $count times'),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginPage()),
//                             (Route<dynamic> route) => false,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.deepPurpleAccent,
//                       textStyle: TextStyle(fontSize: 18),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Text('Logout'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../login/loginform.dart';
// import '../../dashboards/Inside dashboard.dart';
//
// class UserProfileScreen extends StatelessWidget {
//   final UserProfile userProfile;
//
//   UserProfileScreen({required this.userProfile});
//
//   Future<Map<String, dynamic>> getUserProfile(String userId) async {
//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(userId).get();
//
//       // Fetch login/logout times per hour
//       Map<int, int> loginLogoutCounts = await _fetchLoginLogoutTimes(userId);
//
//       Map<String, dynamic> userData = {
//         'profileData': userDoc.data(),
//         'loginLogoutCounts': loginLogoutCounts,
//       };
//
//       return userData;
//     } catch (error) {
//       // Handle error
//       print("Error fetching user profile: $error");
//       throw error;
//     }
//   }
//
//   // Fetch login/logout times per hour
//   Future<Map<int, int>> _fetchLoginLogoutTimes(String userId) async {
//     try {
//       QuerySnapshot loginSnapshot = await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(userId)
//           .collection('loginTimes')
//           .orderBy('time', descending: true)
//           .get();
//
//       QuerySnapshot logoutSnapshot = await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(userId)
//           .collection('logoutTimes')
//           .orderBy('time', descending: true)
//           .get();
//
//       Map<int, int> hourlyCounts = {};
//
//       // Iterate through each login and logout time and count them per hour
//       loginSnapshot.docs.forEach((loginDoc) {
//         DateTime loginTime = (loginDoc['time'] as Timestamp).toDate();
//         int hour = loginTime.hour;
//         hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
//       });
//
//       logoutSnapshot.docs.forEach((logoutDoc) {
//         DateTime logoutTime = (logoutDoc['time'] as Timestamp).toDate();
//         int hour = logoutTime.hour;
//         hourlyCounts[hour] = (hourlyCounts[hour] ?? 0) + 1;
//       });
//
//       return hourlyCounts;
//     } catch (e) {
//       print('Error fetching login/logout times: $e');
//       return {};
//     }
//   }
//
//   Future<void> _logout(BuildContext context, String userId) async {
//     try {
//       // Save logout time
//       await FirebaseFirestore.instance.collection('employees').doc(userId).collection('logoutTimes').add({
//         'time': DateTime.now(),
//       });
//
//       // Perform logout logic (e.g., sign out from FirebaseAuth)
//       await FirebaseAuth.instance.signOut();
//
//       // Navigate to the login page
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//             (Route<dynamic> route) => false,
//       );
//     } catch (error) {
//       // Handle error
//       print("Error logging out: $error");
//       throw error;
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: getUserProfile(userProfile.userId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             appBar: AppBar(title: Text('User Profile')),
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasError) {
//           return Scaffold(
//             appBar: AppBar(title: Text('User Profile')),
//             body: Center(child: Text('Error: ${snapshot.error}')),
//           );
//         } else if (snapshot.data == null || snapshot.data!['profileData'] == null) {
//           return Scaffold(
//             appBar: AppBar(title: Text('User Profile')),
//             body: Center(child: Text('No data available')),
//           );
//         } else {
//           var userData = snapshot.data!['profileData'] as Map<String, dynamic>;
//           var loginLogoutCounts = snapshot.data!['loginLogoutCounts'] as Map<int, int>;
//
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('User Profile'),
//               elevation: 2,
//               backgroundColor: Colors.deepPurpleAccent,
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 80,
//                     backgroundImage: userData['profilePic'] != null ? NetworkImage(userData['profilePic']) : null,
//                     backgroundColor: Colors.teal,
//                     foregroundColor: Colors.white,
//                     child: userData['profilePic'] != null ? null : Icon(Icons.person, size: 80, color: Colors.black),
//                   ),
//
//                   SizedBox(height: 20),
//                   Text(
//                     'Username: ${userData['name']}',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   if (userData['dob'] != null) Text('Date of Birth: ${userData['dob']}'),
//                   SizedBox(height: 10),
//                   if (userData['email'] != null) Text('Email: ${userData['email']}'),
//                   SizedBox(height: 10),
//                   if (userData['gender'] != null) Text('Gender: ${userData['gender']}'),
//                   SizedBox(height: 10),
//                   if (userData['phone'] != null) Text('Phone: ${userData['phone']}'),
//                   SizedBox(height: 20),
//                   Text(
//                     'Login/Logout Counts per Hour:',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: 24, // 24 hours in a day
//                       itemBuilder: (context, hour) {
//                         int count = loginLogoutCounts[hour] ?? 0;
//                         return ListTile(
//                           title: Text('Hour $hour: $count times'),
//                         );
//                       },
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () async {
//                       await _logout(context, userProfile.userId);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.green[200],
//                       textStyle: TextStyle(fontSize: 18),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Text('Logout'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
// import 'dart:typed_data';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import '../../login/loginform.dart';
// import '../../dashboards/Inside dashboard.dart';
//
// class UserProfileScreen extends StatefulWidget {
//   final UserProfile userProfile;
//   UserProfileScreen({required this.userProfile});
//
//   @override
//   _UserProfileScreenState createState() => _UserProfileScreenState();
// }
//
// class _UserProfileScreenState extends State<UserProfileScreen> {
//   Uint8List? _image;
//   String? _profilePicUrl;
//   bool isObscurePassword = false;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchProfilePic();
//   }
//
//   void fetchProfilePic() async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(widget.userProfile.userId)
//           .get();
//       Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
//       setState(() {
//         _profilePicUrl = userData['profilePic'];
//       });
//     } catch (error) {
//       print("Error fetching profile picture: $error");
//     }
//   }
//
//   Future<void> selectImage() async {
//     Uint8List img = await pickImage(ImageSource.gallery);
//     setState(() {
//       _image = img;
//     });
//     if (_image != null) {
//       // Upload image to Firebase Storage
//       String imagePath =
//           'profile_pictures/${widget.userProfile.userId}.jpg'; // Define a path for the image
//       Reference ref = FirebaseStorage.instance.ref().child(imagePath);
//       UploadTask uploadTask = ref.putData(_image!);
//
//       // Get the download URL and save it to Firestore
//       uploadTask.then((res) {
//         res.ref.getDownloadURL().then((downloadURL) {
//           FirebaseFirestore.instance
//               .collection('employees')
//               .doc(widget.userProfile.userId)
//               .update({
//             'profilePic': downloadURL,
//           });
//           setState(() {
//             _profilePicUrl = downloadURL;
//           });
//         });
//       });
//     }
//   }
//
//   pickImage(ImageSource source) async {
//     final ImagePicker _imagePicker = ImagePicker();
//     XFile? _file = await _imagePicker.pickImage(source: source);
//     if (_file != null) {
//       return await _file.readAsBytes();
//     }
//     print('No Image Selected');
//   }
//
//   Future<void> _logout(BuildContext context) async {
//     try {
//       // Save logout time in the employee's document
//       await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(widget.userProfile.userId)
//           .update({
//         'status': 'loggedOut',
//       });
//
//       // Add logout time to the logout times sub-collection
//       await FirebaseFirestore.instance
//           .collection('employees')
//           .doc(widget.userProfile.userId)
//           .collection('logoutTimes')
//           .add({
//         'time': DateTime.now(),
//       });
//
//       // Perform logout logic (e.g., sign out from FirebaseAuth)
//       await FirebaseAuth.instance.signOut();
//
//       // Navigate to login page after logout
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => LoginPage()),
//             (Route<dynamic> route) => false,
//       );
//     } catch (e) {
//       print('Logout failed: $e');
//       // Handle logout failure (e.g., show error message to user)
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Profile'),
//         elevation: 2,
//         backgroundColor: Colors.blue
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Stack(
//                       children: [
//                         _image != null
//                             ? CircleAvatar(
//                           radius: 64,
//                           backgroundImage: MemoryImage(_image!),
//                         )
//                             : _profilePicUrl != null
//                             ? CircleAvatar(
//                           radius: 64,
//                           backgroundImage:
//                           NetworkImage(_profilePicUrl!),
//                         )
//                             : CircleAvatar(
//                           radius: 64,
//                           backgroundImage: NetworkImage(
//                               'https://cdn.pixabay.com/photo/2018/01/15/08/34/woman-3083453_1280.jpg'),
//                         ),
//                         Positioned(
//                           bottom: -2,
//                           left: 80,
//                           child: IconButton(
//                             onPressed: selectImage,
//                             icon: Icon(
//                               Icons.add_a_photo,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       'Username: ${widget.userProfile.name}',
//                       style:
//                       TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 10),
//                     if (widget.userProfile.dob != null)
//                       Text('Date of Birth: ${widget.userProfile.dob}'),
//                     SizedBox(height: 10),
//                     if (widget.userProfile.email != null)
//                       Text('Email: ${widget.userProfile.email}'),
//                     SizedBox(height: 10),
//                     if (widget.userProfile.gender != null)
//                       Text('Gender: ${widget.userProfile.gender}'),
//                     SizedBox(height: 10),
//                     if (widget.userProfile.phone != null)
//                       Text('Phone: ${widget.userProfile.phone}'),
//                     SizedBox(height: 40),
//                     ElevatedButton(
//                       onPressed: () {
//                         _logout(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         // primary: Colors.deepPurpleAccent,
//                         textStyle: TextStyle(fontSize: 18),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Text('Logout'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }