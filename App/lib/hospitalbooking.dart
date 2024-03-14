import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firstapp/getwellsoon.dart';
import 'aboutus.dart';
import 'contactus.dart';
import 'package:firstapp/dbHelper/mongoDB.dart';

class HospitalBedBooking extends StatelessWidget {
  final String username;
  final String password;

  HospitalBedBooking({required this.username, required this.password});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Hospital Bed Booking'),
          leading: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.medical_information_rounded),
              onPressed: () {
                // Navigating to HospitalBed or any other screen
              },
            ),
          ],
        ),
        body: HospitalBedBookingForm(
          username: username,
          password: password,
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
}

class HospitalBedBookingForm extends StatefulWidget {
  final String username;
  final String password;

  HospitalBedBookingForm({required this.username, required this.password});

  @override
  _HospitalBedBookingFormState createState() => _HospitalBedBookingFormState();
}

class _HospitalBedBookingFormState extends State<HospitalBedBookingForm> {
  late GoogleMapController mapController;
  Position? currentPosition;
  String? bookingType;
  List<String> selectedHospitals = [];
  String? selectedReason;
  Set<Marker> _markers = {};
  List<String> hospitalList = [];
  List<List<String>> allHospitalsInfoList = [];

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(8.4, 68.7),
        northeast: LatLng(37.6, 97.3),
      );

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 0),
      );
    });
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _HospitalList();
    _fetchUserData();
    _updateHospitalList();
  }

  void _getCurrentLocation() async {
    Position position = await _getGeoLocationPosition();
    setState(() {
      currentPosition = position;
    });
  }

  void _fetchUserData() async {
    try {
      List<Map<String, dynamic>> userData =
          await MongoDataBase.fetchAmbulanceData();

      List<Marker> markers = userData.map((user) {
        double lat = double.parse(user['latitude'] ?? '0.0');
        double lon = double.parse(user['longitude'] ?? '0.0');
        String username = user['username'] ?? '';

        return Marker(
          markerId: MarkerId(username),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(
            title: username,
          ),
        );
      }).toList();

      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _updateHospitalList() async {
    try {
      List<String> hospitals = await MongoDataBase.getHospital();
      setState(() {
        hospitalList = hospitals;
      });
    } catch (e) {
      print('Error updating hospital list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hospital Bed Booking',
                style: TextStyle(fontSize: 24.0),
              ),
              Container(
                height: 300,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      currentPosition?.latitude ?? 0,
                      currentPosition?.longitude ?? 0,
                    ),
                    zoom: 14.5,
                  ),
                  markers: _markers,
                ),
              ),
              Form(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: bookingType,
                      onChanged: (String? newValue) {
                        setState(() {
                          bookingType = newValue;
                          selectedHospitals.clear(); // Reset selected hospitals
                        });
                      },
                      items: <String>['Emergency', 'Scheduled']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Booking Type',
                      ),
                    ),
                    if (bookingType == 'Scheduled')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Select Hospitals:',
                            style: TextStyle(fontSize: 16),
                          ),
                          // Checkbox for each hospital
                          for (String hospital in hospitalList)
                            CheckboxListTile(
                              title: Text(hospital),
                              value: selectedHospitals.contains(hospital),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null) {
                                    if (value) {
                                      if (!selectedHospitals
                                          .contains(hospital)) {
                                        selectedHospitals.add(hospital);
                                      }
                                    } else {
                                      selectedHospitals.remove(hospital);
                                    }
                                  }
                                });
                              },
                            ),
                        ],
                      ),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedReason = newValue ?? ''; // Ensure non-null
                        });
                      },
                      items: <String>[
                        'Orthopedic',
                        'Cardiology',
                        'Gyneology',
                        'Pulmonology',
                        'Ophthalmologist',
                        'Surgery',
                        'Medicine',
                        'Emergency',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select Reason',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Position position = await _getGeoLocationPosition();
                        Map<String, double> location = {
                          'latitude': position.latitude,
                          'longitude': position.longitude,
                        };
                        String formattedAddress = await _getFormattedAddress(
                          position.latitude,
                          position.longitude,
                        );
                        submitForm(location, selectedHospitals, selectedReason,
                            formattedAddress, bookingType);
                      },
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _HospitalList() async {
    try {
      List<String> hospitalAddresses =
          await MongoDataBase.getAllHospitalAddress();

      if (hospitalAddresses.isNotEmpty) {
        Position position = await _getGeoLocationPosition();
        Map<String, double> location = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
        String currentAddress = await _getFormattedAddress(
          position.latitude,
          position.longitude,
        );

        List<List<String>> individualHospitalsInfoList = [];

        for (String address in hospitalAddresses) {
          double distance = await calculateDistance(
            address,
            currentAddress,
          );
          if(distance<5.00){
            List<String> hospitalInfo = [address, distance.toStringAsFixed(2)];
            individualHospitalsInfoList.add(hospitalInfo);
          }
        }

        // Add the individual hospital info list to the main list
        allHospitalsInfoList.addAll(individualHospitalsInfoList);

        // Now, allHospitalsInfoList contains lists with information about each hospital's address and distance
        // You can display this list in your UI as needed
        _showHospitalModal();
      } else {
        print('No hospital addresses found');
      }
    } catch (e) {
      print('Error updating hospital list: $e');
    }
  }

  Future<String> _getFormattedAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks.first;
      return '${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
    } catch (e) {
      print('Error getting formatted address: $e');
      return '';
    }
  }

  Future<Placemark> _getPlacemark(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      return placemarks.first;
    } catch (e) {
      print('Error getting placemark: $e');
      throw e;
    }
  }

  Future<double> calculateDistance(String address1, String address2) async {
    try {
      List<Location> locations = await locationFromAddress(address1);
      Location location1 = locations.first;

      locations = await locationFromAddress(address2);
      Location location2 = locations.first;

      double distance = await Geolocator.distanceBetween(
        location1.latitude,
        location1.longitude,
        location2.latitude,
        location2.longitude,
      );
      distance = distance / 1000;
      return distance;
    } catch (e) {
      print('Error calculating distance: $e');
      throw e;
    }
  }

  void _showHospitalModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Text(
                  'Nearby Hospitals',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Container(
                  height: 200.0, // Adjust the height based on your content
                  child: ListView.builder(
                    itemCount: allHospitalsInfoList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            'Hospital Address: ${allHospitalsInfoList[index][0]}'),
                        subtitle: Text(
                            'Distance: ${allHospitalsInfoList[index][1]} km'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void submitForm(
    Map<String, double> location,
    List<String> selectedHospitals,
    String? selectedReason,
    String formattedAddress,
    String? bookingType, // Added parameter for booking type
  ) {
    double lat = location['latitude'] ?? 0.0;
    double lon = location['longitude'] ?? 0.0;

    String latString = lat.toString();
    String lonString = lon.toString();

    int randomBookingNumber = Random().nextInt(100000);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Booking Number: $randomBookingNumber'),
              Text('Latitude: $latString'),
              Text('Longitude: $lonString'),
              Text('Formatted Address: $formattedAddress'),
              if (bookingType == 'Scheduled')
                Text('Selected Hospitals: ${selectedHospitals.join(', ')}'),
              Text('Selected Reason: $selectedReason'),
              Text('Booking Type: $bookingType'), // Display booking type
              Text('Username: ${widget.username}'),
              Text('Password: ${widget.password}'),
              Text('booking_types: ${bookingType}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                MongoDataBase.userInsert(
                  selectedReason,
                  latString,
                  lonString,
                  randomBookingNumber,
                  widget.username,
                  widget.password,
                  formattedAddress,
                  bookingType,
                  selectedHospitals, // Pass selected hospitals for scheduled booking
                );

                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GetWellSoon(
                      username: widget.username,
                      password: widget.password,
                      latitude:latString,
                      longitude:lonString,
                    ),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
