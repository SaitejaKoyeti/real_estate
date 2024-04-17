import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PhotosList extends StatelessWidget {
  final String customerId;

  const PhotosList({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Photos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .collection('photos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No photos available for this customer');
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot photo = snapshot.data!.docs[index];
              String? imagePath = photo['image_url'];

              if (imagePath == null || imagePath.isEmpty) {
                // If image path is null or empty, display a placeholder or handle it accordingly
                return Container(
                  color: Colors.grey,
                  child: Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                );
              }

              // Load image from URL
              return GestureDetector(
                onTap: () {
                  // Open the image in full-screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(),
                        body: Center(
                          child: kIsWeb
                              ? Image.network(imagePath)
                              : Image.network(imagePath), // Adjusted for mobile
                        ),
                      ),
                    ),
                  );
                },
                child: kIsWeb
                    ? Image.network(imagePath)
                    : Image.network(imagePath), // Adjusted for mobile
              );
            },
          );
        },
      ),
    );
  }
}
