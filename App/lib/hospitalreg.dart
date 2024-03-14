import 'package:firstapp/aboutus.dart';
import 'package:firstapp/dbHelper/mongoDB.dart';
import 'package:firstapp/hospitallog.dart';
import 'package:flutter/material.dart';

import 'contactus.dart';
// import 'userlogin.dart';

class HospitalReg extends StatefulWidget {
  @override
  _HospitalRegState createState() => _HospitalRegState();
}

class _HospitalRegState extends State<HospitalReg> {
  final TextEditingController incharNameController = TextEditingController();
  final TextEditingController LocationController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController UserNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    incharNameController.dispose();
    LocationController.dispose();
    hospitalNameController.dispose();
    UserNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 1,
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
                  Text(
                    'Hospital Registration',
                    style: TextStyle(
                      color: Color.fromRGBO(4, 14, 6, 1),
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Form(
                    child: Column(
                      children: <Widget>[
                        buildTextField('Name Of Incharge', 'Inchargename',
                            incharNameController),
                        buildTextField(
                            'Location', 'address', LocationController),
                        buildTextField('Name Of Hospital', 'hospitalName',
                            hospitalNameController),
                        buildTextField(
                            'User Name', 'username', UserNameController),
                        buildPasswordField(
                            'Password', 'password', passwordController),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> hospitalData = {
                              'inchargeName': incharNameController.text,
                              'hospitalLocation': LocationController.text,
                              'hospitalName': hospitalNameController.text,
                              'username': UserNameController.text,
                              'password': passwordController.text
                            };
                            print('Hospital Data: $hospitalData');
                            await MongoDataBase.insertHospital(hospitalData);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HospitalLog(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 17, 180, 239),
                            onPrimary: const Color.fromARGB(255, 21, 20, 20),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          color: Color(0xFF192024),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '© Copyright @ HealthLink Architects  ',
                style: TextStyle(color: Colors.white),
              ),
              InkWell(
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
              InkWell(
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
    );
  }

  Widget buildTextField(
      String labelText, String fieldName, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        keyboardType: TextInputType.text,
        onChanged: (value) {
          // You can handle the changes in the text field here
        },
      ),
    );
  }

  Widget buildPasswordField(
      String labelText, String fieldName, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onChanged: (value) {
          // You can handle the changes in the password field here
        },
      ),
    );
  }
}
