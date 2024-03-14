import 'package:firstapp/aboutus.dart';
import 'package:flutter/material.dart';
import 'contactus.dart';
import 'userlogin.dart';
import 'dbHelper/mongoDB.dart';

class UserRegistrationPage extends StatefulWidget {
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController userAgeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    userAgeController.dispose();
    phoneController.dispose();
    userEmailController.dispose();
    usernameController.dispose();
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
                    'User Registration',
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
                        buildTextField('Name', 'name', nameController),
                        buildTextField('Location', 'address', addressController),
                        buildNumberField('Age', 'userAge', userAgeController),
                        buildTextField('Phone No.', 'phone', phoneController),
                        buildTextField('Email', 'userEmail', userEmailController),
                        buildTextField('User Name', 'username', usernameController),
                        buildPasswordField('Password', 'password', passwordController),
                        SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> userData = {
                              'name': nameController.text,
                              'address': addressController.text,
                              'userAge': int.parse(userAgeController.text),
                              'phone': phoneController.text,
                              'userEmail': userEmailController.text,
                              'username': usernameController.text,
                              'password': passwordController.text,
                            };
                            print('User Data: $userData');
                            await MongoDataBase.insertUser(userData);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => UserLog()));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ContactUs()),);
                  },
                  child: Text(
                    'Contact Us',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AboutUs()),);
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

  Widget buildTextField(String labelText, String fieldName, TextEditingController controller) {
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

  Widget buildNumberField(String labelText, String fieldName, TextEditingController controller) {
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

  Widget buildPasswordField(String labelText, String fieldName, TextEditingController controller) {
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
