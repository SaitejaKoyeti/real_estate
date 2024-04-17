import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import dart:io to use the File class

class AddEmployeeForm extends StatefulWidget {
  @override
  _AddEmployeeFormState createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<AddEmployeeForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  bool _formSubmitted = false;

  String? _selectedSales;
  String? _selectedGender;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employee'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_nameController, 'Name'),
                SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', isEmail: true),
                SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password', isPassword: true),
                SizedBox(height: 16),
                _buildPhoneTextField(),
                SizedBox(height: 16),
                _buildDropdownButton(),
                SizedBox(height: 16),
                _buildDateOfBirthPicker(),
                SizedBox(height: 16),
                _buildProfilePicField(),
                SizedBox(height: 16),
                _buildGenderRadioButtons(),
                SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool isPassword = false,
        bool isProfilePic = false,
        bool isVisible = true, // Add a visibility flag
        bool isEmail = false, // Add a flag to identify email field
        bool isPhone = false, // Add a flag to identify phone field
      }) {
    return isVisible
        ? TextFormField(
      controller: controller,
      obscureText: isPassword,
      onChanged: (value) {
        setState(() {
          // Reset validation error when user starts typing
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.reset();
          }
        });
      },
      validator: (value) {
        if (_formSubmitted) {
          if (!isProfilePic && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          if (isEmail &&
              !RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
                  .hasMatch(value!)) {
            return 'Please enter a valid email';
          }
          if (isPhone &&
              !RegExp(r'^\+?[0-9]{10,12}$').hasMatch(value!)) {
            return 'Please enter a valid phone number';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        // Show error message only if form is submitted and field is empty
        errorText: _formSubmitted && controller.text.isEmpty
            ? 'Please enter $label'
            : null,
      ),
    )
        : SizedBox.shrink(); // Return an empty widget if not visible
  }

  Widget _buildPhoneTextField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      onChanged: (value) {
        // If the value does not start with "+91", add it
        if (!value.startsWith("+91")) {
          setState(() {
            _phoneController.text = "+91$value";
            // Move the cursor to the end of the text
            _phoneController.selection = TextSelection.fromPosition(
                TextPosition(offset: _phoneController.text.length));
          });
        }
      },
      validator: (value) {
        if (_formSubmitted && (value == null || value.isEmpty)) {
          return 'Please enter phone number';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Phone',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _formSubmitted = true;
        });
        _submitForm();
      },
      child: Text('Submit'),
    );
  }

  Widget _buildProfilePicField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profilePicController.text.isNotEmpty
            ? kIsWeb
            ? Image.network(
          _profilePicController.text,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        )
            : Image.file(
          File(_profilePicController.text),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        )
            : SizedBox(),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            String? profilePicUrl = await _showImagePicker();
            if (profilePicUrl != null) {
              setState(() {
                _profilePicController.text = profilePicUrl;
              });
            }
          },
          child: Text('Upload Profile Picture'),
        ),
      ],
    );
  }




  Future<String?> _showImagePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path; // Return the file path of the picked image
    } else {
      return null;
    }
  }


  Widget _buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: _selectedSales,
      items: ['Inside Sales', 'Outside Sales'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedSales = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select Sales';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Sales',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateOfBirthPicker() {
    return TextFormField(
      controller: _dobController,
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (_formSubmitted && (value == null || value.isEmpty)) {
          return 'Please select DOB';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'DOB',
        border: OutlineInputBorder(),
        // Show error message only if form is submitted and field is empty
        errorText: _formSubmitted && _dobController.text.isEmpty
            ? 'Please select DOB'
            : null,
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _dobController.text) {
      setState(() {
        _dobController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Widget _buildGenderRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender'),
        Row(
          children: [
            Radio(
              value: 'Male',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value.toString();
                });
              },
            ),
            Text('Male'),
            Radio(
              value: 'Female',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value.toString();
                });
              },
            ),
            Text('Female'),
          ],
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Remove the "+91" prefix before saving to the database
      String formattedPhoneNumber = _phoneController.text.replaceAll("+91", "");
      await _registerUser(formattedPhoneNumber);

      // Clear the form after successful submission
      _formKey.currentState?.reset();

      // Reset the _formSubmitted flag
      setState(() {
        _formSubmitted = false;
      });
    }
  }

  Future<void> _registerUser(String formattedPhoneNumber) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection('employees').doc(userCredential.user?.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text.replaceAll("+91", ""), // Save without "+91" prefix
        'sales': _selectedSales,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'profilePic': _profilePicController.text,
      });

      // Simulating registration with FirebaseAuth
      await Future.delayed(Duration(seconds: 2));

      // Simulating user registration data
      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text.replaceAll("+91", ""), // Save without "+91" prefix
        'sales': _selectedSales,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'profilePic': _profilePicController.text,
      };

      // Simulating saving user data to Firestore
      await Future.delayed(Duration(seconds: 2));
      print("User data saved: $userData");

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _dobController.clear();
      _profilePicController.clear();
      setState(() {
        _selectedSales = null;
        _selectedGender = null;
      });

      Navigator.of(context).pop();

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Registration successful!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop();

      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed. Please try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AddEmployeeForm(),
    );
  }
}
