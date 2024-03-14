import 'package:firstapp/aboutus.dart';
import 'package:firstapp/ambulancelogin.dart';
import 'package:firstapp/hospitallog.dart';
import 'package:firstapp/userlogin.dart';
import 'package:flutter/material.dart';
import 'contactus.dart';


// import 'ambulancereg.dart';
class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login Here',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  'Select an option:',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                Column(
                  children: [
                    buildRegistrationButton('User Login', 'user_Log', context),
                    buildRegistrationButton(
                        'Ambulance Driver Login', 'Ambulance_Log', context),
                    // buildRegistrationButton(
                    //     'Hospital Login', 'hospital_Log', context),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: buildFooter(context),
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
            '© Copyright @ Get Well Soon',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              // Handle Contact Us
            },
            child: Text(
              'Contact Us',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              // Handle About Us
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

  Widget buildRegistrationButton(
      String text, String route, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle button press and navigation
          redirectTo(route, context);
        },
        style: ElevatedButton.styleFrom(
          primary: Color(0xFF007BFF),
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void redirectTo(String route, BuildContext context) {
    switch (route) {
      case 'user_Log':
        // Handle user registration navigation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserLog()),
        );
        break;
      case 'Ambulance_Log':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AmbulanceLog()),
        );
        break;
      case 'hospital_Log':
        // Handle hospital registration navigation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HospitalLog()),
        );
        break;
      default:
        print('Invalid route: $route');
    }
  }
}
