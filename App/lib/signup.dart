import 'package:firstapp/aboutus.dart';
import 'package:flutter/material.dart';
import 'ambulancereg.dart';
import 'contactus.dart';
import 'hospitalreg.dart';
import 'userreg.dart';

class Signup extends StatelessWidget {
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
                  'Sign Up Page',
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
                    buildRegistrationButton(
                        'User Registration', 'user_reg', context),
                    buildRegistrationButton('Ambulance Driver Registration',
                        'ambulance_reg', context),
                    // buildRegistrationButton(
                    //     'Hospital Registration', 'hospital_reg', context),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: Color(0xFF192024),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '© Copyright @ HealthLink Architects  ',
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
                    style: TextStyle(color: Colors.white),
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
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      case 'user_reg':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserRegistrationPage()),
        );
        break;
      case 'ambulance_reg':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AmbulanceRegistrationPage()),
        );
        break;
      case 'hospital_reg':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HospitalReg()),
        );
        break;
      default:
        print('Invalid route: $route');
    }
  }
}
