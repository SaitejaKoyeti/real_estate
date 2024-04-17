import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:provider/provider.dart';

import '../customers/addcustomer.dart';
import '../customers/cus.dart';
import '../login/loginform.dart';
import '../sales_screen.dart';
import '../widgets/employees/addemployeeform.dart';
import 'navigator.dart';

class RealEstateDashboard extends StatefulWidget {
  @override
  State<RealEstateDashboard> createState() => _RealEstateDashboardState();
}

class _RealEstateDashboardState extends State<RealEstateDashboard> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      // Desktop view with sidebar
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 100,
          title: Text(
            'Executive Dashboard',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 50),
          ),
          backgroundColor: Colors.black,
        ),
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Container(
                width: 250,
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    _buildNavigationButton('Add Employee', 0, context, Icons.person_add),
                    _buildNavigationButton('Add Customer', 1, context, Icons.person_add),
                    _buildNavigationButton('All Employees', 2, context, Icons.list),
                    _buildNavigationButton('All Customer', 3, context, Icons.list),
                    _buildNavigationButton('Settings', 4, context, Icons.settings),
                    _buildNavigationButton('Logout', 5, context, Icons.exit_to_app),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildPageView(context),
            ),
          ],
        ),
      );
    } else {
      // Mobile view with drawer
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 100,
          title: Text(
            ' Executive Dashboard',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          backgroundColor: Colors.black54,
        ),
        body: _buildPageView(context),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(),
              _buildDrawerItem('Add Employee', 0, context, Icons.person_add),
              _buildDrawerItem('Add Customer', 1, context, Icons.person_add),
              _buildDrawerItem('All Employees', 2, context, Icons.list),
              _buildDrawerItem('All Customer', 3, context, Icons.list),
              _buildDrawerItem('Settings', 4, context, Icons.settings),
              _buildDrawerItem('Logout', 5, context, Icons.exit_to_app),
            ],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Disable screenshot functionality
    _disableScreenshots();
  }

  void _disableScreenshots() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  Widget _buildPageView(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: PageView(
          controller: context.read<NavigationProvider>().pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            AddEmployeeForm(),
            AddCustomerForm(),
            SalesScreen(),
            CustomersScreen(),
            // Setting(),
            // LogoutScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String label, int index, BuildContext context, IconData iconData) {
    return InkWell(
      onTap: () {
        if (label == 'Logout') {
          _showLogoutConfirmationDialog(context);
        } else {
          context.read<NavigationProvider>().currentIndex = index;
          context.read<NavigationProvider>().pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: context.watch<NavigationProvider>().currentIndex == index ? Colors.orange.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(iconData, color: Colors.white), // Changed icon color to white
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.black87,
      ),
      child: Center(
        child: Text(
          'Real Estate Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String label, int index, BuildContext context, IconData iconData) {
    return ListTile(
      title: Row(
        children: [
          Icon(iconData, color: Colors.orange), // Changed icon color to orange
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(color: Colors.orange),
          ),
        ],
      ),
      onTap: () {
        if (label == 'Logout') {
          _showLogoutConfirmationDialog(context);
        } else {
          context.read<NavigationProvider>().currentIndex = index;
          context.read<NavigationProvider>().pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          Navigator.pop(context); // Close the drawer
        }
      },
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Handle Logout here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}