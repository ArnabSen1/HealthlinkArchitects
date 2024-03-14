import 'dart:async';
import 'dart:math';
import 'package:firstapp/hospitalbooking.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firstapp/dbHelper/mongoDB.dart';

class GetWellSoon extends StatelessWidget {
  final String username;
  final String password;
  final String latitude;
  final String longitude;
  GetWellSoon({
    required this.username,
    required this.password,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: MongoDataBase.getAmbulanceLatLon(username, password),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Text('Error: Unable to retrieve ambulance coordinates.');
        } else {
          Map<String, String> coordinates = snapshot.data!;
          return MaterialApp(
            home: GetWellSoonScreen(
              username: username,
              password: password,
              latitude: latitude,
              longitude: longitude,
            ),
          );
        }
      },
    );
  }
}

class GetWellSoonScreen extends StatefulWidget {
  final String username;
  final String password;
  final String latitude;
  final String longitude;

  GetWellSoonScreen({
    required this.username,
    required this.password,
    required this.latitude,
    required this.longitude,
  });

  @override
  _GetWellSoonScreenState createState() => _GetWellSoonScreenState();
}

class _GetWellSoonScreenState extends State<GetWellSoonScreen> {
  late GoogleMapController mapController;
  late LatLng userLocation;
  LatLng? ambulanceLocation;
  Set<Polyline> polylines = {};
  late Timer timer;

  @override
  void initState() {
    super.initState();
    userLocation = LatLng(
      double.parse(widget.latitude),
      double.parse(widget.longitude),
    );

    timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      getAmbulanceLocation();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getAmbulanceLocation() async {
    try {
      Map<String, String> coordinates = await MongoDataBase.getAmbulanceLatLon(
          widget.username, widget.password);

      setState(() {
        if (coordinates.isNotEmpty) {
          ambulanceLocation = LatLng(
            double.parse(coordinates['ambulanceLat']!),
            double.parse(coordinates['ambulanceLon']!),
          );
        }
      });

      showRouteOnMap();
    } catch (e) {
      print('Error getting ambulance location: $e');
    }
  }

  void showRouteOnMap() {
    if (mapController != null) {
      Polyline polyline;

      if (ambulanceLocation != null) {
        polyline = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: [
            userLocation,
            ambulanceLocation!,
          ],
        );

        double distance = calculateDistance(userLocation, ambulanceLocation!);
        print('Distance between user and ambulance: $distance meters');
      } else {
        polyline = Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: [userLocation],
        );
      }

      setState(() {
        polylines = {polyline};
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(8.4, 68.7),
            northeast: LatLng(37.6, 97.3),
          ),
          50.0,
        ),
      );
    }
  }

  double calculateDistance(LatLng start, LatLng end) {
    const int earthRadius = 6371000;
    double lat1 = start.latitude * (pi / 180.0);
    double lon1 = start.longitude * (pi / 180.0);
    double lat2 = end.latitude * (pi / 180.0);
    double lon2 = end.longitude * (pi / 180.0);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('user_location_marker'),
                  position: userLocation,
                  infoWindow: InfoWindow(title: 'User Location'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
                if (ambulanceLocation != null)
                  Marker(
                    markerId: MarkerId('ambulance_location_marker'),
                    position: ambulanceLocation!,
                    infoWindow: InfoWindow(title: 'Ambulance Location'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              polylines: polylines,
              onMapCreated: (controller) {
                setState(() {
                  mapController = controller;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://www.dropbox.com/scl/fi/3sj9eajlddcz5hkwetj32/getwellsoon.jpeg?rlkey=veyw9ex9221bxul6ux1f64p2i&dl=1'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'We Hope You Get Well Soon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 20),
                  ButtonContainer(
                    username: widget.username,
                    password: widget.password,
                  ), // Pass username and password to ButtonContainer
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Footer(),
        ],
      ),
    );
  }
}

class ButtonContainer extends StatelessWidget {
  final String username;
  final String password;

  ButtonContainer({
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            confirmAction(context, 'cancel', username, password);
          },
          child: Text('Cancel Booking'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            confirmAction(context, 'rebooking', username, password);
          },
          child: Text('ReBooking'),
        ),
      ],
    );
  }

  void confirmAction(BuildContext context, String action, String username,
      String password) async {
    bool? confirmation = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text(
          action == 'cancel'
              ? 'Are you sure you want to cancel the booking?'
              : 'Are you sure to redirect?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
        ],
      ),
    );

    if (confirmation != null && confirmation) {
      // Handle the confirmed action
      if (action == 'cancel') {
        await MongoDataBase.cancelBooking(username, password);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => HospitalBedBooking(username:username, password:password)))); // Closing parenthesis added
      } else if (action == 'rebooking') {
        await MongoDataBase.ReBooking(username, password);
      }
    }
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
