import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'contactus.dart';
import 'dbHelper/constant.dart';
import 'dbHelper/mongoDB.dart';

class AmbulanceNotification extends StatefulWidget {
  final String username;
  final String password;

  AmbulanceNotification({required this.username, required this.password});

  @override
  _AmbulanceNotificationState createState() => _AmbulanceNotificationState(
        username: username,
        password: password,
      );
}

class _AmbulanceNotificationState extends State<AmbulanceNotification> {
  final String username;
  final String password;

  _AmbulanceNotificationState({
    required this.username,
    required this.password,
  });
  int _currentIndex = 0;
  List<Map<String, dynamic>> pendingData = [];
  List<Map<String, dynamic>> acceptedData = [];
  Timer? locationTimer;

  void acceptRequest(int index) async {
    try {
      Map<String, dynamic> acceptedRequest = pendingData.removeAt(index);
      acceptedData.add(acceptedRequest);
      await MongoDataBase.updateData([acceptedRequest], username, password);
    } catch (e) {
      print('Error accepting request: $e');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchPendingData();
    fetchAcceptedData();

    // Start the timer to fetch the current location every 5 seconds
    locationTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      fetchCurrentLocation();
    });
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchPendingData() async {
    try {
      List<Map<String, dynamic>> data =
          await MongoDataBase.getPendingAmbulanceData(PENDING_AMBULANCE_DATA);
      setState(() {
        pendingData = data;
        print('Pending data length: ${pendingData.length}');
      });
    } catch (e) {
      print('Error fetching pending data: $e');
    }
  }

  Future<void> fetchAcceptedData() async {
    try {
      List<Map<String, dynamic>> data =
          await MongoDataBase.getAcceptedAmbulanceData(ACCEPTED_AMBULANCE_DATA);
      setState(() {
        acceptedData = data;
        print('Accepted data length: ${acceptedData.length}');
      });
    } catch (e) {
      print('Error fetching accepted data: $e');
    }
  }

  Future<void> fetchCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Use the position data as needed
      double latitude = position.latitude;
      double longitude = position.longitude;
      await MongoDataBase.updateLocationAmbulance(
          widget.username, widget.password, latitude, longitude);
      print('Current Location: $latitude, $longitude');
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Requests',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                buildDataTable(pendingData, true),
                SizedBox(height: 20.0),
                Text(
                  'Accepted Requests',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                buildAcceptedDataTable(acceptedData),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactUs()),
            );
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notification Centre',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_phone),
              label: 'Contact Us',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAcceptedDataTable(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: SizedBox(width: 50, child: Center(child: Text('S.No'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Name'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Reason'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Phone'))),
          ),
          DataColumn(
            label: SizedBox(width: 150, child: Center(child: Text('Address'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Actions'))),
          ),
        ],
        rows: data.asMap().entries.map((entry) {
          int index = entry.key + 1; // Adding 1 to make it 1-based index
          Map<String, dynamic> row = entry.value;
          return DataRow(
            cells: [
              DataCell(SizedBox(
                width: 50,
                child: Center(child: Text(index.toString())),
              )),
              DataCell(SizedBox(
                width: 100,
                child: Center(child: Text(row['name']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 100,
                child: Center(child: Text(row['reason']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 100,
                child: Center(child: Text(row['phone']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 150,
                child: Center(child: Text(row['address']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            String patientLatitude = row['latitude'] ?? '0.0';
                            String patientLongitude = row['longitude'] ?? '0.0';
                            launchGoogleMaps(patientLatitude, patientLongitude);
                          },
                          child: Text('Go To Patient'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            String hospitalName = row['SelectedHospital'] ?? '';
                            String? hospitalAddress =
                                await MongoDataBase.getHospitalAddress(
                                    hospitalName);

                            if (hospitalAddress != null) {
                              launchGoogleMapsbyAddress(hospitalAddress);
                            } else {
                              print('Hospital address not found.');
                            }
                          },
                          child: Text('Go To Hospital'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            MongoDataBase.fetchDataAndSendEmail(
                                row['username'] ?? '', row['password'] ?? '');
                          },
                          child: Text('Send Confirmation'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await MongoDataBase.deleteData(
                                row['user_username']);
                            setState(() {
                              acceptedData.removeAt(entry.key);
                            });
                          },
                          child: Text('End Trip'),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildDataTable(List<Map<String, dynamic>> data, bool isPendingData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(
            label: SizedBox(width: 50, child: Center(child: Text('S.No'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Name'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Reason'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Phone'))),
          ),
          DataColumn(
            label: SizedBox(width: 150, child: Center(child: Text('Address'))),
          ),
          DataColumn(
            label: SizedBox(width: 100, child: Center(child: Text('Actions'))),
          ),
        ],
        rows: data.asMap().entries.map((entry) {
          int index = entry.key + 1; // Adding 1 to make it 1-based index
          Map<String, dynamic> row = entry.value;
          return DataRow(
            cells: [
              DataCell(SizedBox(
                width: 50,
                child: Center(child: Text(index.toString())),
              )),
              DataCell(SizedBox(
                width: 100,
                child: Center(child: Text(row['name']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 100,
                child: Center(child: Text(row['reason']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 100,
                child: Center(child: Text(row['phone']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 150,
                child: Center(child: Text(row['address']?.toString() ?? '')),
              )),
              DataCell(SizedBox(
                width: 100,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isPendingData) {
                        // Handle actions for pendingData
                        acceptRequest(entry.key);
                      }
                    },
                    child: Text('Accept'),
                  ),
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

void launchGoogleMaps(String latitudeString, String longitudeString) async {
  try {
    double latitude = double.tryParse(latitudeString) ?? 0.0;
    double longitude = double.tryParse(longitudeString) ?? 0.0;

    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print('Could not launch Google Maps');
    }
  } catch (e) {
    print('Error parsing latitude or longitude: $e');
  }
}

void launchGoogleMapsbyAddress(String address) async {
  try {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$address';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print('Could not launch Google Maps');
    }
  } catch (e) {
    print('Error launching Google Maps: $e');
  }
}
