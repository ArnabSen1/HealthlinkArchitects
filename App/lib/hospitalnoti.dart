import 'package:firstapp/hospital_bed_management.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/dbHelper/constant.dart';
import 'package:firstapp/dbHelper/mongoDB.dart';
import 'contactus.dart';

class HospitalNotification extends StatefulWidget {
  @override
  _HospitalNotificationState createState() => _HospitalNotificationState();
}

class _HospitalNotificationState extends State<HospitalNotification> {
  int _currentIndex = 0;
  List<Map<String,dynamic>> pendingData = [];
  List<Map<String,dynamic>> acceptedData = [];

 @override
  void initState() {
    super.initState();
    fetchPendingData();
    fetchAcceptedData();
  }

  Future<void> fetchPendingData() async {
    try {
      List<Map<String, dynamic>> data =
          await MongoDataBase.getPendingAmbulanceData(PENDING_HOSPITAL_DATA);
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
          await MongoDataBase.getAcceptedAmbulanceData(ACCEPTED_HOSPITAL_DATA);
      setState(() {
        acceptedData = data;
        print('Pending data length: ${acceptedData.length}');
      });
    } catch (e) {
      print('Error fetching pending data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          // title: Image.asset('assets/logo.svg', height: 28),
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
                buildDataTable(pendingData),
                SizedBox(height: 20.0),
                Text(
                  'Accepted Requests',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                buildDataTable(acceptedData),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle location update
                  },
                  child: Text('Update Location'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if(index==0){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HospitalBed()),
              );
            }
            else{
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUs()),
              );
            }
            setState(() {
              _currentIndex = index;
              print('${index}');

            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_information_sharp),
              label: 'Hospital Bed Centre',
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

  Widget buildDataTable(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: SizedBox(width: 50, child: Center(child: Text('S.No')))),
          DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Name')))),
          DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Reason')))),
          DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Phone')))),
          DataColumn(label: SizedBox(width: 150, child: Center(child: Text('Address')))),
          DataColumn(label: SizedBox(width: 100, child: Center(child: Text('Actions')))),
        ],
        rows: data.asMap().entries.map((entry) {
          int index = entry.key + 1; // Adding 1 to make it 1-based index
          Map<String, dynamic> row = entry.value;
          return DataRow(
            cells: [
              DataCell(SizedBox(width: 50, child: Center(child: Text(index.toString())))),
              DataCell(SizedBox(width: 100, child: Center(child: Text(row['name']?.toString() ?? '')))),
              DataCell(SizedBox(width: 100, child: Center(child: Text(row['reason']?.toString() ?? '')))),
              DataCell(SizedBox(width: 100, child: Center(child: Text(row['phone']?.toString() ?? '')))),
              DataCell(SizedBox(width: 150, child: Center(child: Text(row['address']?.toString() ?? '')))),
              DataCell(SizedBox(width: 100, child: Center(child: ElevatedButton(
                onPressed: () {
                  // Handle actions
                },
                child: Text('Action'),
              )))),
            ],
          );
        }).toList(),
      ),
    );
  }

}

