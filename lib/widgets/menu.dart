import 'package:flutter/material.dart';
import '../dashboards/Admindashboard.dart';
import '../inside/pages/salary.dart';
import '../sales_screen.dart';
import 'employees/employee_screen.dart';
import '../customers/cus.dart';
import '../login/loginform.dart';

class MenuModel {
  final IconData icon;
  final String title;

  MenuModel({
    required this.icon,
    required this.title,
  });
}

class Menu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback onSignOut;

  const Menu({
    Key? key,
    required this.scaffoldKey,
    required this.onSignOut,
  });

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<MenuModel> menu = [
    MenuModel(icon: Icons.home, title: "Dashboard"),
    MenuModel(icon: Icons.work, title: "Employees"),
    MenuModel(icon: Icons.shopping_cart, title: "Sales"),
    MenuModel(icon: Icons.people, title: "Customers"),
    MenuModel(icon: Icons.assessment_outlined, title: "Attendance"),
    MenuModel(icon: Icons.settings, title: "Settings"),
    MenuModel(icon: Icons.exit_to_app, title: "Sign Out"),
  ];

  int selected = 0;

  Future<void> _showSignOutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Are you sure you want to sign out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                widget.onSignOut(); // Call the sign-out callback
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFF21222D),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              color: Colors.transparent, // Set the background color as per your design
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                  width: 190,
                ),
              ),
            ),

            Divider(color: Colors.white),
            Expanded(
              child: ListView.builder(
                itemCount: menu.length,
                itemBuilder: (context, index) {
                  return buildMenuItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          selected = index;
        });
      },
      onExit: (_) {
        setState(() {
          selected = -1; // Reset selected when mouse exits
        });
      },
      child: ListTile(
        onTap: () => handleMenuTap(index),
        selected: selected == index,
        selectedTileColor: Color(0xFF2F2F2F),
        leading: Icon(
          menu[index].icon,
          color: selected == index ? Colors.blue : Colors.grey,
        ),
        title: Text(
          menu[index].title,
          style: TextStyle(
            fontSize: 16,
            color: selected == index ? Colors.blue : Colors.white,
            fontWeight: selected == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void handleMenuTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashBoard()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmployeesScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SalesScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomersScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewDataPagess()),
        );
      // Handle Settings Screen navigation
        break;
      case 5:

        // Handle Settings Screen navigation
        break;

      case 6:
        _showSignOutConfirmationDialog();
        break;
      default:
        setState(() {
          selected = index;
        });
        widget.scaffoldKey.currentState!.openEndDrawer();
    }
  }
}