import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('About Us'),
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Who We Are',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to Life Saver Architects! We are a leading technology company dedicated to providing automated ambulance and hospital booking services in terms of scheduled services and emergency services to our clients. With a passion for technology and a commitment to excellence, we are serving businesses of local sizes since September 2023.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Our Mission',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Our mission is to cater to the needs of the people in the situations of emergency, where we can provide the fastest assistance with cutting-edge technology solutions to the patients that drive growth, efficiency, and success. We strive to understand the unique needs of each client and tailor our services to exceed their expectations.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Our Team',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'At Life Saver Architects, our team consists of students who do their best to impart the technologies required for this project as per their knowledge in the required fields. From software developers to database connoisseurs, our diverse team works collaboratively to deliver the best results for our clients.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Why Choose Us',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'When you choose Life Saver Architects, you are choosing a partner dedicated to your success. Here are a few reasons to consider us:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Always available to cater the customer\'s needs and requirements.'),
                        Text('Provide solutions tailored to your needs.'),
                        Text('Exceptional customer service.'),
                        Text('Always at your service, at times of needs.'),
                        Text('Continuous commitment to innovation'),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Contact Us',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'If you have any questions or would like to learn more about our services, please don\'t hesitate to contact us. We look forward to working with you!',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Thank you for choosing us!!!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
