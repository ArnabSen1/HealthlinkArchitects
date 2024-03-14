import 'package:flutter/material.dart';

class HospitalBed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hospital Bed Management'),
          backgroundColor: Colors.black,
        ),
        body: HospitalBedManagement(),
      ),
    );
  }
}

class HospitalBedManagement extends StatefulWidget {
  @override
  _HospitalBedManagementState createState() => _HospitalBedManagementState();
}

class _HospitalBedManagementState extends State<HospitalBedManagement> {
  String username = ''; // Initialize with your data
  String password = ''; // Initialize with your data
  List<Map<String, dynamic>> results = []; // Initialize with your data

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Information About the hospital',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                // Add your form widgets here
                // Example:
                TextFormField(
                  decoration: InputDecoration(labelText: 'Orthopedic Beds'),
                  keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Gynocology Beds'),
                    keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Cardical Specialist Beds'),
                  keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Pulmonology Beds'),
                  keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Opthalmonology Beds'),
                  keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Surgery Beds'),
                  keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Medication'),
                  keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Emergency Beds'),
                  keyboardType: TextInputType.number,// Add your controller and other properties as needed
                ),
                // Add more form fields as needed
                ElevatedButton(
                  onPressed: () {
                    // Implement your form submission logic here
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
          if (results.isNotEmpty)
            Container(
              padding: EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.5,
              child: Column(
                children: [
                  Text(
                    'The result',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  // Display your results here
                  // Example:
                  DataTable(
                    columns: [
                      DataColumn(label: Text('ORTHO')),
                      DataColumn(label: Text('GYNE')),
                      // Add more columns as needed
                    ],
                    rows: results.map((result) {
                      return DataRow(
                        cells: [
                          DataCell(Text(result['ORTHO'].toString())),
                          DataCell(Text(result['GYNE'].toString())),
                          // Add more cells as needed
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}