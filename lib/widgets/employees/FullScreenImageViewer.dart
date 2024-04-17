import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Image'),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              // Display a loading indicator while the image is loading
              return Center(child: CircularProgressIndicator());
            }
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            // Handle errors when loading the image
            print('Error loading image: $error');
            return Text('Failed to load image');
          },
        ),
      ),
    );
  }
}
