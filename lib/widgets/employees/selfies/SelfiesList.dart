import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../FullScreenImageViewer.dart';

class SelfiesList extends StatelessWidget {
  final String customerId;

  const SelfiesList({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .collection('photos')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text('Error loading image: ${snapshot.error}');
        }


        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No selfies available for this employee');
        }

        // Display list of selfies
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            String selfieUrl = snapshot.data!.docs[index]['image_url'];
            return ListTile(
              title: Text('Selfie ${index + 1}'),
              subtitle: ElevatedButton(
                onPressed: () {
                  _viewSelfie(context, selfieUrl);
                },
                child: Text('View Selfie'),
              ),
            );
          },
        );
      },
    );
  }

  void _viewSelfie(BuildContext context, String selfieUrl) {
    print('Selfie URL: $selfieUrl');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imageUrl: selfieUrl),
      ),
    );
  }
}
