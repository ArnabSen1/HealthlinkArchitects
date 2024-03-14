import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// final _url = Uri.parse('https://flutter.dev');

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Contact Us'),
          backgroundColor: Colors.teal[700],
        ),
        body: Container(
          margin: EdgeInsets.all(16.0),
          child: ContactCardList(),
        ),
      ),
    );
  }
}

class ContactCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 25.0,
          mainAxisSpacing: 25.0,
          padding: EdgeInsets.all(10.0),
          shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          children: [
            ContactCard1(
              image:
                  'https://www.dropbox.com/scl/fi/gcyx5qx6bh3569lm4j29i/hasan.jpg?rlkey=pgstgc3qhd9ari8iejw7ys4k0&dl=1',
              name: 'Md Hasanuj Jaman Hossain',
              phone: '+91 9330801309',
              email: 'mdhjh786@gmail.com',
            ),
            ContactCard(
              name: 'Ayana Dasgupta',
              image:
                  'https://www.dropbox.com/scl/fi/13144tcuhge7j6pziwz0l/ayana.jpg?rlkey=dhphrx622fpr0bg425s41pm6p&dl=1',
              phone: '+91 6290266728',
              email: 'amdasgupta1920@gmail.com',
            ),
            ContactCard(
              name: 'Arnab Sen',
              image:
                  'https://www.dropbox.com/scl/fi/yoknd2wo6ga7g4xk7g35c/arnab.jpeg?rlkey=e5cgr7zsryascgd0vuhdx2rky&dl=1',
              phone: '+91 9647347752',
              email: 'mdsaoodkhan007@gmail.com',
            ),
            ContactCard(
              name: 'Md Saood Khan',
              image:
                  'https://www.dropbox.com/scl/fi/78l174or4sov12qy17leb/saood.jpg?rlkey=netdq5g51syoauvzeccnxuvv1&dl=1',
              phone: '+91 9836642109',
              email: 'arnabsen236@gmail.com',
            ),
            ContactCard(
              name: 'Swetangshu Saha',
              image:
                  'https://www.dropbox.com/scl/fi/skqkzunneci2z3dcse8wj/swetangshu.jpg?rlkey=m3fmfkbgzhc3zqgdljui2vfhv&dl=1',
              phone: '+919832229874',
              email: 'swetangshus@gmail.com',
            ),
            ContactCard(
              name: 'Rajarshi Sengupta',
              image:
                  'https://www.dropbox.com/scl/fi/yizgg0qunqjrc7m0zhtzd/rajarshi.jpeg?rlkey=ibb4gs6hujj0zgehsqjyksaqn&dl=1',
              phone: '+91 9073105194',
              email: 'senguptarajarshi9@gmail.com',
            ),
          ],
        ),
      ],
    );
  }
}

class ContactCard1 extends StatelessWidget {
  final String name;
  final String image;
  final String phone;
  final String email;

  ContactCard1({
    required this.name,
    required this.image,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showOptionsDialog(context);
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(image),
                  radius: 50.0,
                ),
                SizedBox(height: 5.0),
                Text(
                  name,
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
  _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Call'),
                onTap: () {
                  Navigator.pop(context);
                  _launchCaller(phone, context);
                },
              ),
              ListTile(
                title: Text('Email'),
                onTap: () {
                  Navigator.pop(context);
                  _launchEmail(email);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _launchCaller(String phoneNumber, BuildContext context) async {
    final Uri url=Uri(scheme: 'tel',path: phoneNumber);
    launchUrl(
        url,
        mode: LaunchMode.externalApplication
    );
  }

  _launchEmail(String emailid) async {
    final Uri url=Uri(scheme: 'mailto' ,path:"emailid");
        launchUrl(
          url,
          mode: LaunchMode.externalApplication
        );
  }

  _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Could not make a phone call.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class ContactCard extends StatelessWidget {
  final String name;
  final String image;
  final String phone;
  final String email;

  ContactCard({
    required this.name,
    required this.image,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showOptionsDialog(context);
      },
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(image),
                  radius: 50.0,
                ),
                SizedBox(height: 5.0),
                Text(
                  name,
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Call'),
                onTap: () {
                  Navigator.pop(context);
                  _launchCaller(phone, context);
                },
              ),
              ListTile(
                title: Text('Email'),
                onTap: () {
                  Navigator.pop(context);
                  _launchEmail(email);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _launchCaller(String phoneNumber, BuildContext context) async {
    final Uri url=Uri(scheme: 'tel',path: phoneNumber);
    launchUrl(
          url,
          mode: LaunchMode.externalApplication
    );
  }
  _launchEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      queryParameters: {'to': email}, // Set the recipient's email in the "to" parameter
    );

    launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Could not make a phone call.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
