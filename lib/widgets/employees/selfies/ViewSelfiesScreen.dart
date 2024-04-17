import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SelfiesList.dart';

class ViewSelfiesScreen extends StatelessWidget {
  final String customerId;

  const ViewSelfiesScreen({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Selfies'),
      ),
      body: SelfiesList(customerId: customerId),
    );
  }
}
