import 'package:flutter/material.dart';

class CallHistoryPage extends StatefulWidget {
  final List<Map<String, String>> interestedCustomers;
  final List<Map<String, String>> notInterestedCustomers;

  const CallHistoryPage({
    required this.interestedCustomers,
    required this.notInterestedCustomers,
  });

  @override
  _CallHistoryPageState createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  bool showInterested = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call History'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ToggleButtons(
                  isSelected: [showInterested, !showInterested],
                  onPressed: (index) {
                    setState(() {
                      showInterested = index == 0;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text('Interested'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text('Not Interested'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: showInterested
                    ? widget.interestedCustomers
                    .map(
                      (customer) => Card(
                    child: ListTile(
                      title: Text(
                        'Name: ${customer['name']}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      subtitle: Text(
                        'Phone: ${customer['phone']}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                )
                    .toList()
                    : widget.notInterestedCustomers
                    .map(
                      (customer) => Card(
                    child: ListTile(
                      title: Text(
                        'Name: ${customer['name']}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      subtitle: Text(
                        'Phone: ${customer['phone']}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
