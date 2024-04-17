import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Menu({Key? key, required this.scaffoldKey, required Future<void> Function() onSignOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.green],
          ),
        ),
        child: Column(
          children: [
            _buildDrawerItem(
                CupertinoIcons.person_crop_circle, 'Account', () {
              _handleMenuTap('Account');
            }),
            _buildDrawerItem(
                CupertinoIcons.arrow_2_circlepath_circle, 'Targets', () {
              _handleMenuTap('Targets');
            }),
            _buildDrawerItem(
                CupertinoIcons.photo, 'Upload Pic', () {
              _handleMenuTap('Upload Pic');
            }),
            _buildDrawerItem(CupertinoIcons.person_2_alt,
                'Interested Customers', () {
                  _handleMenuTap('Interested Customers');
                }),
            _buildDrawerItem(CupertinoIcons.gear, 'Settings', () {
              _handleMenuTap('Settings');
            }),
            _buildDrawerItem(Icons.exit_to_app, 'Logout', () {
              _handleMenuTap('Logout');
            }),
          ],
        ),
      ),
    );
  }

  void _handleMenuTap(String menuItem) {
    // Handle tap on menu items
  }

  Widget _buildDrawerItem(
      IconData iconData, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(text),
      onTap: onTap,
    );
  }
}