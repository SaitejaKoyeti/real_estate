import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TargetsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('employee_targets')
            .where('employeeId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No targets found for the logged-in user.'),
            );
          } else {
            List<DocumentSnapshot> targets = snapshot.data!.docs;

            return ListView.builder(
              itemCount: targets.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> targetData =
                targets[index].data() as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _showTargetDetailsDialog(context, targetData);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Target: ${targetData['target']}'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      );
    } else {
      return Center(
        child: Text('User not logged in.'),
      );
    }
  }

  void _showTargetDetailsDialog(
      BuildContext context, Map<String, dynamic> targetData) {
    TextEditingController feedbackController = TextEditingController();
    bool isSubmitting = false; // Added for loading indicator

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text('Target: ${targetData['target']}'),

                    // Feedback Section
                    SizedBox(height: 20.0),
                    Text(
                      'Provide Feedback:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Type your feedback here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                            setState(() {
                              isSubmitting = true;
                            });

                            if (feedbackController.text.trim().isNotEmpty) {
                              await _saveFeedback(
                                targetData['target'],
                                feedbackController.text,
                                context,
                              );

                              // Close the dialog when feedback is submitted
                              Navigator.pop(context);
                              // Show a confirmation dialog after successfully submitting feedback
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Feedback Submitted'),
                                    content: Text('Thank you for providing feedback.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Close the dialog
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Provide feedback to the user that the feedback cannot be empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please provide feedback before submitting.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }

                            setState(() {
                              isSubmitting = false;
                            });
                          },
                          child: isSubmitting
                              ? CircularProgressIndicator()
                              : Text('Submit Feedback'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveFeedback(
      String target, String feedback, BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('feedbacks').add({
          'userId': user.uid,
          'target': target,
          'feedback': feedback,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Successfully saved feedback to the database
        print('Feedback saved successfully');
        // Show a success message or other visual confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feedback submitted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (error) {
        // Handle errors
        print('Error saving feedback: $error');
        // Show an error message or other user-friendly indication
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $error'), // Include the error message
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
