import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isCurrentPasswordObscure = true;
  bool _isNewPasswordObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: Theme.of(context).textTheme.headline6,
            ),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _toggleCurrentPasswordVisibility();
                    });
                  },
                  child: Icon(
                    _isCurrentPasswordObscure
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              obscureText: _isCurrentPasswordObscure,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _toggleNewPasswordVisibility();
                    });
                  },
                  child: Icon(
                    _isNewPasswordObscure
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              obscureText: _isNewPasswordObscure,
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _isCurrentPasswordObscure = !_isCurrentPasswordObscure;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isNewPasswordObscure = !_isNewPasswordObscure;
    });
  }


  Future<void> _changePassword() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);

        // Password changed successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully')),
        );
      }
    } catch (e) {
      // Handle password change errors
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error changing password. Please try again.')),
      );
    }
  }
}
