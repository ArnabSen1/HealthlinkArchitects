import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:firstapp/dbHelper/mongoDB.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'aboutus.dart';
import 'ambulancelogin.dart';
import 'ambulancereg.dart';
import 'contactus.dart';
import 'userlogin.dart';
import 'userreg.dart';

class Intermediate extends StatefulWidget {
  @override
  _IntermediateState createState() => _IntermediateState();
}

class _IntermediateState extends State<Intermediate> {
  String? _selectedOption;
  String? _selectedRegOption;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  late Widget _barChart;
  bool _showRegistrationDropdown = false;

  @override
  void initState() {
    super.initState();
    _getAccident();
    _updateChartData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _showMap();
                  },
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(20.5937, 78.9629),
                    zoom: 4.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.grey[200]?.withOpacity(0.8),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Saving Lives',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'LogIn Here',
                      style: TextStyle(fontSize: 18),
                    ),
                    buildOptionDropdown(context),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showRegistrationDropdown =
                              !_showRegistrationDropdown;
                        });
                      },
                      child: Text(
                        'Need to register? Click here:',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ),
                    if (_showRegistrationDropdown) ...[
                      buildRegDropdown(context),
                    ],
                    ElevatedButton(
                      onPressed:
                          _selectedOption != null || _selectedRegOption != null
                              ? () {
                                  if (_selectedOption != null) {
                                    redirectTo(_selectedOption!, context);
                                    _showMap();
                                  } else {
                                    redirectTo(_selectedRegOption!, context);
                                    _showMap();
                                  }
                                }
                              : null,
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF007BFF),
                        onPrimary: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Go',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _barChart,
              ),
              SizedBox(height: 20),
              buildFooter(context),
            ],
          ),
        ),
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

  Widget buildOptionDropdown(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedOption,
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue;
        });
      },
      items: <String>[
        'User Login',
        'Ambulance Driver Login',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value.replaceAll(' ', '_').toLowerCase(),
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget buildRegDropdown(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedRegOption,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRegOption = newValue;
        });
      },
      items: <String>[
        'User Registration',
        'Ambulance Driver Registration',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value
              .replaceAll(' ', '_')
              .replaceAll('Registration', 'reg')
              .toLowerCase(),
          child: Text(value),
        );
      }).toList(),
    );
  }

  void redirectTo(String route, BuildContext context) {
    switch (route) {
      case 'user_login':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserLog()),
        );
        break;
      case 'ambulance_driver_login':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AmbulanceLog()),
        );
        break;
      case 'user_reg':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserRegistrationPage()),
        );
        break;
      case 'ambulance_driver_reg':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AmbulanceRegistrationPage()),
        );
        break;
      default:
        print('Invalid route: $route');
    }
  }

  Future<List<String>> _getAccident() async {
    try {
      List<String> pon = await MongoDataBase.redAlertMap();
      print('Pincode list: $pon');
      return pon;
    } catch (e) {
      print('ERROR $e');
      return [];
    }
  }

  void _showMap() async {
    _markers.clear();
    List<String> pinCodes = await _getAccident();
    print("Pincode list: $pinCodes");
    for (String pinCode in pinCodes) {
      await _addMarker(pinCode);
    }

    if (pinCodes.isNotEmpty) {
      CameraPosition initialPosition = CameraPosition(
        target: await _getPinCodeLocation(pinCodes.first),
        zoom: 10.0,
      );

      _mapController
          ?.animateCamera(CameraUpdate.newCameraPosition(initialPosition));
    }
  }

  Future<void> _addMarker(String pinCode) async {
    LatLng pinCodeLocation = await _getPinCodeLocation(pinCode);
    Marker marker = Marker(
      markerId: MarkerId(pinCode),
      position: pinCodeLocation,
      infoWindow: InfoWindow(title: 'Pin Code: $pinCode'),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  Future<LatLng> _getPinCodeLocation(String pinCode) async {
    try {
      List<double> coordinates = await getCoordinatesForPinCode(pinCode);
      return LatLng(coordinates[0], coordinates[1]);
    } catch (e) {
      print('Error getting location for pin code $pinCode: $e');
      return LatLng(0, 0);
    }
  }

  Future<List<double>> getCoordinatesForPinCode(String pinCode) async {
    final String apiKey = 'AIzaSyDbwtf_dATwlZNIgG6UqcVrPwsFheNK0os';
    final String apiUrl =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$pinCode&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      final Map<String, dynamic> data = json.decode(response.body);

      final double lat = data['results'][0]['geometry']['location']['lat'];
      final double lng = data['results'][0]['geometry']['location']['lng'];
      return [lat, lng];
    } catch (e) {
      print('Error getting coordinates for pin code $pinCode: $e');
      return [0.0, 0.0];
    }
  }

  Future<void> _updateChartData() async {
    List<Map<String, dynamic>> graphData = await MongoDataBase.redAlertGraph();
    print("hello $graphData");
    setState(() {
      _barChart = buildBarChart(graphData);
    });
  }

  Widget buildBarChart(List<Map<String, dynamic>> data) {
    List<charts.Series<Map<String, dynamic>, String>> seriesList = [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Accidents Analysis',
        domainFn: (Map<String, dynamic> entry, _) =>
            entry['locality'] as String,
        measureFn: (Map<String, dynamic> entry, _) => entry['count'] as int,
        data: data,
      ),
    ];

    return charts.BarChart(
      seriesList,
      animate: true,
      vertical: true, // Set to true for vertical bars
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis: charts.OrdinalAxisSpec(
        showAxisLine: false,
        renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        showAxisLine: false,
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(fontSize: 10),
        ),
      ),
      behaviors: [charts.SeriesLegend()],
    );
  }
}
