import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print("Error during sign-in: $e");
      return null;
    }
  }

  Future<bool> isAdmin(String userId) async {
    try {
      DocumentSnapshot adminDocument = await _firestore
          .collection('Admin')
          .doc(userId)
          .get();

      return adminDocument.exists;
    } catch (e) {
      print("Error checking admin status: $e");
      return false;
    }
  }

  Future<String?> getUserSalesRole(String userId) async {
    try {
      DocumentSnapshot employeeDocument = await _firestore
          .collection('employees')
          .doc(userId)
          .get();

      if (employeeDocument.exists) {
        return employeeDocument['sales'];
      } else {
        print("Document does not exist for user: $userId");
        return null;
      }
    } catch (e) {
      print("Error getting user sales role: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error during sign-out: $e");
    }
  }

  Future<void> signOutInsideSales() async {
    try {
      await _auth.signOut();
      // Add any additional logic needed for Inside Sales sign-out
      // For example, clearing secure flags or performing other cleanup tasks
    } catch (e) {
      print("Error during Inside Sales sign-out: $e");
    }
  }
}

