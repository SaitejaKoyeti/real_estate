// import 'dart:io';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//
//   Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String userId) async {
//     return await _firestore.collection('employees').doc(userId).get();
//   }
//
//   Future<void> updateProfileData(
//       String userId,
//       String name,
//       String email,
//       String phone,
//       String sales,
//       String dob,
//       String age,
//       String profilePicUrl,
//       ) async {
//     await _firestore.collection('employees').doc(userId).update({
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'sales': sales,
//       'dob': dob,
//       'age': age,
//       'profilePic': profilePicUrl,
//     });
//   }
//
//   Future<void> uploadProfilePic(File image, String userId) async {
//     String fileName = 'profile_pic_$userId.png';
//     Reference storageReference = _storage.ref().child(fileName);
//     UploadTask uploadTask = storageReference.putFile(image);
//     await uploadTask.whenComplete(() async {
//       String imageUrl = await storageReference.getDownloadURL();
//       await updateProfileData(userId, '', '', '', '', '', '', imageUrl);
//     });
//   }
// }
