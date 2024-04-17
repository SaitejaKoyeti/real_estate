// import 'dart:js_interop';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
//
//
//
// import 'auth.dart';
// class loginpage extends StatefulWidget {
//   loginpage({super.key});
//
//   @override
//   State<loginpage> createState() => _loginpageState();
// }
//
// class _loginpageState extends State<loginpage> {
//
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//
//
//   FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//
//
//
//       appBar: AppBar(
//         automaticallyImplyLeading: false, title: const Text('firebase login'),backgroundColor:Colors.blue,actions: [
//         IconButton(onPressed: () {}, icon: Icon(Icons.exit_to_app))
//       ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Center(
//           child: Column(
//
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//
//               TextField(
//                 controller: email,
//                 decoration: InputDecoration(label: Text('Email'),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
//               ),
//               SizedBox(height: 10,),
//               TextField(
//                 controller: password,
//                 decoration: InputDecoration(label: Text('Password'),
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
//                 ),
//               ),
//
//               SizedBox(height: 15,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(onPressed: () async {
//                     try{
//                       UserCredential userCredential = await FirebaseAuth.instance
//                           .signInWithEmailAndPassword (
//                         email : email.text,
//                         password : password.text,
//
//
//                       );
//                       User? user = userCredential.user;
//                       print('Sign in : ${user!.uid}');
//
//
//
//                     }
//                     catch (e){
//                       print('sigin error : $e');
//                     }
//                   }, child: Text('sigin')),
//                   SizedBox(width: 10,),
//
//                   ElevatedButton(onPressed: () async {
//                     await FirebaseAuth.instance.createUserWithEmailAndPassword  (
//                       email : email.text,
//                       password : password.text,
//
//                     );
//                     final user = <String, dynamic>{
//
//                       "email" : email.text,
//                       "password" : password.text,
//
//
//                     };
//                     _firebaseFirestore.collection("user").add(user);
//
//                   }, child: Text('sigup')),
//
//                   SizedBox(width: 10,),
//                   ElevatedButton(onPressed: () async {
//                     await FirebaseAuth.instance.createUserWithEmailAndPassword  (
//                       email : email.text,
//                       password : password.text,
//
//
//                     );
//                     final user = <String, dynamic>{
//
//                       "email" : email.text,
//                       "password" : password.text,
//
//
//                     };
//                     _firebaseFirestore.collection("user").add(user);
//
//
//                   }, child: Text('LogIn'))
//
//
//                 ],
//               )
//             ],
//
//           ),
//
//         ),
//       ),
//     );
//   }
// }
