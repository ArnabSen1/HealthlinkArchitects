import 'package:flutter/material.dart';
import 'aboutus.dart';
import 'ambulancelogin.dart';
import 'contactus.dart';
import 'dbHelper/mongoDB.dart';

class AmbulanceRegistrationPage extends StatefulWidget {
  @override
  _AmbulanceRegistrationPageState createState() =>
      _AmbulanceRegistrationPageState();
}

class _AmbulanceRegistrationPageState extends State<AmbulanceRegistrationPage> {
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();
  final TextEditingController AgeController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController DrivingLicenseController =
      TextEditingController();
  final TextEditingController UserNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    driverNameController.dispose();
    carNumberController.dispose();
    AgeController.dispose();
    panNumberController.dispose();
    DrivingLicenseController.dispose();
    UserNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: [
            Container(
              padding: EdgeInsets.all(20),
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
                    'Ambulance Driver Registration',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTextField('Name of the Driver', 'driverName',
                            driverNameController),
                        buildTextField(
                            'Car Number', 'carNumber', carNumberController),
                        buildNumberField('Age', 'driverAge', AgeController),
                        buildTextField(
                            'PAN Number', 'panNumber', panNumberController),
                        buildTextField('Driving License', 'license',
                            DrivingLicenseController),
                        buildTextField(
                            'User Name', 'username', UserNameController),
                        buildPasswordField(
                            'Password', 'password', passwordController),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              Map<String, dynamic> ambulanceData = {
                                'driverName': driverNameController.text,
                                'carNumber': carNumberController.text,
                                'driverAge': int.parse(AgeController.text),
                                'panNumber': panNumberController.text,
                                'license': DrivingLicenseController.text,
                                'username': UserNameController.text,
                                'password': passwordController.text,
                              };

                              print('Ambulance Data: $ambulanceData');

                              await MongoDataBase.insertAmbulance(
                                  ambulanceData);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AmbulanceLog(),
                                ),
                              );
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget buildNumberField(
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
        keyboardType: TextInputType.number,
        onChanged: (value) {
          // You can handle the changes in the number field here
        },
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
