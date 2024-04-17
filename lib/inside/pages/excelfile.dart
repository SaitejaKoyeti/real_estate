import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';





class ExcelUploadScreen extends StatefulWidget {
  @override
  _ExcelUploadScreenState createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _uploadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      Uint8List bytes = file.bytes!;
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows.skip(1)) { // Skip the first row (header)
          if (row != null && row.isNotEmpty) {
            String? name = row[0]?.value.toString();
            String? email = row[1]?.value.toString();
            String? phoneNumber = row[2]?.value.toString();

            if (name != null && email != null && phoneNumber != null) {
              await firestore.collection('customers').add({
                'name': name,
                'email': email,
                'phoneNumber': phoneNumber,
              });
            }
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name, email, and phone number data uploaded to Firestore'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Excel to Firestore')),
      body: Center(
        child: ElevatedButton(
          onPressed: _uploadExcel,
          child: Text('Upload Excel'),
        ),
      ),
    );
  }
}