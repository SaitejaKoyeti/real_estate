// customer_utils.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerUtils {
  static Future<bool> isAssignedToOutsideSales(Map<String, dynamic> customer) async {
    // Replace 'outsideSales' with the actual role or criteria that identifies outside sales employees
    QuerySnapshot outsideSalesSnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('role', isEqualTo: 'Outside Sales')
        .get();

    List<String> outsideSalesEmployeeIds = outsideSalesSnapshot.docs
        .map((employee) => employee.id)
        .toList();

    return outsideSalesEmployeeIds.contains(customer['assignedEmployee']);
  }
}
