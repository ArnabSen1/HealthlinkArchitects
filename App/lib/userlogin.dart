import 'dart:math';

import 'package:firstapp/aboutus.dart';
import 'package:firstapp/contactus.dart';
import 'package:firstapp/hospitalbooking.dart';
import 'package:flutter/material.dart';
import 'package:mailer/smtp_server.dart';
import 'dbHelper/mongoDB.dart';
import 'ambulanceNotification.dart';
import 'package:mailer/mailer.dart';

class UserLog extends StatefulWidget {
  @override
  _UserLogState createState() => _UserLogState();
}

class _UserLogState extends State<UserLog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoggedIn = false; // Track user login status

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Login'),
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Color(0xFFF4F6F7),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 30, 2, 2).withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: isLoggedIn
                ? _buildUserProfile() // Show user profile if logged in
                : _buildLoginForm(), // Show login form if not logged in
          ),
        ),
        bottomNavigationBar: buildFooter(context), // Add the footer
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Ambulance Login',
          style: TextStyle(color: Color(0xFF333), fontSize: 24.0),
        ),
        SizedBox(height: 20.0),
        Form(
          child: Column(
            children: <Widget>[
              buildTextField('Username', 'username',
                  controller: _usernameController),
              buildTextField('Password', 'password',
                  isPassword: true, controller: _passwordController),
            ],
          ),
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Validate and authenticate user
                if (await MongoDataBase.authenticateUser(
                    _usernameController.text, _passwordController.text)) {
                  setState(() {
                    isLoggedIn = true; // Set user login status to true
                  });
                  // Navigate to HospitalBedBooking if authentication is successful
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HospitalBedBooking(
                        username: _usernameController.text,
                        password: _passwordController.text,
                      ),
                    ),
                  );
                } else {
                  // Show error message if authentication fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid username or password'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF333),
                onPrimary: const Color.fromARGB(255, 21, 20, 20),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () {
                // Navigate to Reset Password page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'User Profile',
          style: TextStyle(color: Color(0xFF333), fontSize: 24.0),
        ),
        SizedBox(height: 20.0),
        // Add user profile details here, such as bookings and transactions
        ElevatedButton(
          onPressed: () {
            _logout(); // Logout button
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF333),
            onPrimary: const Color.fromARGB(255, 21, 20, 20),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          child: Text(
            'Logout',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String labelText, String fieldName,
      {bool isPassword = false, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextFormField(
        obscureText: isPassword,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  void _logout() {
    setState(() {
      isLoggedIn = false; // Set user login status to false
    });
    // Additional logout actions can be added here, such as clearing user data, etc.
  }

  Widget buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blueGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '© HealthLink Architects',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUs()),
              );
            },
            child: Text(
              'Contact Us',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUs()),
              );
            },
            child: Text(
              'About Us',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

// Hypothetical Forgot Password page
class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _errorMessage;
  bool _isSentOTP = false;
  String _sentOTP = ''; // Store the OTP sent to the email

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20.0),
            if (!_isSentOTP) ...[
              ElevatedButton(
                onPressed: () async {
                  // Check if email field is not empty
                  if (_emailController.text.isNotEmpty) {
                    // Generate random OTP
                    Random random = Random();
                    _sentOTP = '';
                    for (int i = 0; i < 6; i++) {
                      _sentOTP += random.nextInt(10).toString();
                    }
                    print(_emailController.text);
                    // Send OTP to the provided email
                    String email = _emailController.text;
                    String subject = 'Password Reset OTP';
                    String body = 'Your OTP for password reset is: $_sentOTP';

                    // Replace these placeholders with your email sending configurations
                    String username = 'healthlinkarchitects@gmail.com';
                    String password = 'hzex zsht hnkk ephu';
                    String smtpServer = 'smtp.gmail.com';
                    int smtpPort = 587;

                    // Create the email message
                    final message = Message()
                      ..from = Address(username)
                      ..recipients.add(email)
                      ..subject = subject
                      ..text = body;

                    // Create SMTP server to send the email

                    try {
                      // Send the email
                      await send(
                          message,
                          SmtpServer(
                            smtpServer,
                            username: username,
                            password: password,
                            port: smtpPort,
                          ));
                      // Email sent successfully, set _isSentOTP to true
                      setState(() {
                        _isSentOTP = true;
                        _errorMessage =
                            null; // Clear any previous error message
                      });
                    } catch (e) {
                      // Error occurred while sending the email
                      setState(() {
                        _errorMessage = 'Error sending OTP: $e';
                      });
                    }
                  } else {
                    // Show error message if email field is empty
                    setState(() {
                      _errorMessage = 'Please enter your email';
                    });
                  }
                },
                child: Text('Send OTP'),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: 'Enter New Password'),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
              SizedBox(height: 20.0),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: () async {
                  // Verify OTP and update password
                  final String email = _emailController.text;
                  final otp = _otpController.text;
                  final String newPassword = _newPasswordController.text;
                  final String confirmPassword =
                      _confirmPasswordController.text;

                  // Check if manually typed OTP matches the sent OTP
                  if (otp == _sentOTP) {
                    // OTP verification successful, proceed with password update
                    await MongoDataBase.updatePassword(
                        newPassword, email, confirmPassword);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserLog()));
                  } else {
                    // Show error message if OTP verification fails
                    setState(() {
                      _errorMessage = 'Invalid OTP';
                    });
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}