import 'package:firstapp/aboutus.dart';
import 'package:firstapp/ambulancelogin.dart';
import 'package:firstapp/hospitallog.dart';
import 'package:firstapp/userlogin.dart';
import 'package:flutter/material.dart';
import 'contactus.dart';
import 'ambulancereg.dart';
import 'hospitalreg.dart';
import 'userreg.dart';

class AuthenticationPage extends StatelessWidget {
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
                  'Welcome to Get Well Soon',
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
                    buildOptionButton('User Login', 'user_Log', context),
                    buildOptionButton(
                        'Ambulance Driver Login', 'Ambulance_Log', context),
                    buildOptionButton('Hospital Login', 'hospital_Log', context),
                    buildOptionButton('User Registration', 'user_reg', context),
                    buildOptionButton('Ambulance Driver Registration',
                        'ambulance_reg', context),
                    buildOptionButton(
                        'Hospital Registration', 'hospital_reg', context),
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

  Widget buildOptionButton(
      String text, String route, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HospitalLog()),
        );
        break;
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

void main() {
  runApp(AuthenticationPage());
}
