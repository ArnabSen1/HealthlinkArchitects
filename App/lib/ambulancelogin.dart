import 'dart:math';

import 'package:firstapp/aboutus.dart';
import 'package:firstapp/contactus.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dbHelper/mongoDB.dart';
import 'ambulanceNotification.dart';

class AmbulanceLog extends StatefulWidget {
  @override
  _AmbulanceLogState createState() => _AmbulanceLogState();
}

class _AmbulanceLogState extends State<AmbulanceLog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ambulance Drivers Login'),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text(
                //   'Ambulance Login',
                //   style: TextStyle(color: Color.fromARGB(255, 116, 208, 130), fontSize: 24.0),
                // ),
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
                        // Handle login button press
                        // Navigate to the next screen (replace YourNextScreen with the actual screen)
                        if (await MongoDataBase.authenticateAmbulance(
                            _usernameController.text,
                            _passwordController.text)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AmbulanceNotification(
                                    username: _usernameController.text,
                                    password: _passwordController.text)),
                          );
                        } else {
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
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                        // Navigate to Forgot Password page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPassword()),
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
            ),
          ),
        ),
        bottomNavigationBar: buildFooter(context), // Add the footer
      ),
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

// Hypothetical Forgot Password page
class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _errorMessage;
  bool _isSentOTP = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
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
                  // Generate random OTP
                  Random random = Random();
                  String otp = '';
                  for (int i = 0; i < 6; i++) {
                    otp += random.nextInt(10).toString();
                  }
                  print(_emailController.text);
                  // Send OTP to the provided email
                  String email = _emailController.text;
                  String subject = 'Password Reset OTP';
                  String body = 'Your OTP for password reset is: $otp';

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
                      print("succesfully send");
                    });
                  } catch (e) {
                    // Error occurred while sending the email
                    setState(() {
                      _errorMessage = 'Error sending OTP: $e';
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
                  final String enteredOTP = _otpController.text;
                  final String newPassword = _newPasswordController.text;
                  final String confirmPassword =
                      _confirmPasswordController.text;

                  // Verify if the entered OTP matches the generated OTP
                  if (enteredOTP == generatedOTP) {
                    // OTP matches, update the password
                    await MongoDataBase.updateAmbuPassword(
                        newPassword, email, confirmPassword);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AmbulanceLog()));
                  } else {
                    // OTP does not match, show error message
                    setState(() {
                      _errorMessage = 'Invalid OTP. Please try again.';
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

mixin generatedOTP {
}
