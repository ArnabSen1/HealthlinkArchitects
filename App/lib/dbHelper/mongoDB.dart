// ignore_for_file: await_only_futures
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class AuthManager {
  static String? authenticatedUsername;
  static String? authenticatedPassword;
}

class MongoDataBase {
  static late Db db;
  static late DbCollection userCollection;
  static late DbCollection ambulanceCollection;
  static late DbCollection hospitalCollection;

  static Future<void> connect() async {
    try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();

      print('Connected to MongoDB');
    } catch (e) {
      print('Error connecting to MongoDB: $e');
      rethrow; // Rethrow the exception to propagate the error
    }
  }

  static Future<void> insertUser(Map<String, dynamic> userData) async {
    userCollection = db.collection(USER_COLLECTION);
    try {
      // Ensure the connection is established before attempting to insert
      if (db == null || !db.isConnected) {
        await connect();
      }

      await userCollection.insertOne(userData);
      print('User data inserted successfully.');
    } catch (e) {
      print('Error inserting user data: $e');
    }
  }

  static Future<void> insertAmbulance(
      Map<String, dynamic> ambulanceData) async {
    ambulanceCollection = db.collection(AMBULANCE_COLLECTION);
    try {
      // Ensure the connection is established before attempting to insert
      if (db == null || !db.isConnected) {
        await connect();
      }

      // Ensure ambulanceCollection is initialized
      if (ambulanceCollection == null) {
        throw StateError('ambulanceCollection is not initialized');
      }

      await ambulanceCollection.insertOne(ambulanceData);
      print('Ambulance data inserted successfully.');
    } catch (e) {
      print('Error inserting ambulance data: $e');
    }
  }

  static Future<void> insertHospital(Map<String, dynamic> hospitalData) async {
    hospitalCollection = db.collection(HOSPITAL_COLLECTION);
    try {
      if (db == null || !db.isConnected) {
        await connect();
      }
      if (hospitalCollection == null) {
        throw StateError("hospitalCollection is not initialized");
      }
      await hospitalCollection.insertOne(hospitalData);
      print('Hospital Data inserted successfully');
    } catch (e) {
      print('Error inserting hospital data: $e');
    }
  }

  static Future<bool> authenticateUser(String username, String password) async {
    userCollection = db.collection(USER_COLLECTION);
    AuthManager.authenticatedUsername = username;
    AuthManager.authenticatedPassword = password;

    await MongoDataBase.connect();
    final result = await MongoDataBase.userCollection.findOne({
      'username': username,
      'password': password,
    });

    return result != null;
  }

  static Future<bool> authenticateAmbulance(
      String username, String password) async {
    ambulanceCollection = db.collection(AMBULANCE_COLLECTION);
    await MongoDataBase.connect();
    final result = await MongoDataBase.ambulanceCollection.findOne({
      'username': username,
      'password': password,
    });
    return result != null;
  }

  static Future<bool> authenticateHospital(
      String username, String password) async {
    hospitalCollection = db.collection(HOSPITAL_COLLECTION);
    await MongoDataBase.connect();
    final result = await MongoDataBase.hospitalCollection.findOne({
      'username': username,
      'password': password,
    });
    return result != null;
  }

  static Future<void> userInsert(
      String? reason,
      String latitude,
      String longitude,
      int bookingNumber,
      String username,
      String password,
      String location,
      String? bookingType,
      List<String> selectedHospitals // Updated to non-nullable
      ) async {
    try {
      // Ensure the connection is established before attempting to insert
      await connect();
      print(selectedHospitals);
      DbCollection UserData = db.collection(USER_COLLECTION);
      final result = await UserData.findOne({
        'username': username,
        'password': password,
      });

      String name1 = '';
      String Phone = '';
      String address = '';
      String email = '';

      if (result != null) {
        name1 = result['name'];
        Phone = result['phone'];
        address = result['address'];
        email = result['email'];
      }

      DbCollection ambulancePendingCollection =
          db.collection(PENDING_AMBULANCE_DATA);
      DbCollection hospitalPendingCollection =
          db.collection(PENDING_HOSPITAL_DATA);

      // Ensure ambulancePendingCollection and hospitalPendingCollection are initialized
      if (ambulancePendingCollection == null ||
          hospitalPendingCollection == null) {
        throw StateError('Collections are not initialized');
      }

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedTime = DateFormat('HH:mm').format(now);

      Map<String, dynamic> ambulanceData = {
        'name': name1,
        'user_username': username,
        'reason': reason ?? 'No Reason', // Handle null reason
        'phone': Phone,
        'address': address,
        'email': email,
        'pickup_location': location,
        'password': password,
        'latitude': latitude,
        'longitude': longitude,
        'date': formattedDate,
        'time': formattedTime,
        'booking_type': bookingType,
      };
      print(ambulanceData);
      await ambulancePendingCollection.insertOne(ambulanceData);

      List<String> temp_id = [];
      if (bookingType == 'Scheduled') {
        for (String hospital in selectedHospitals) {
          // Fetch details for each selected hospital
          // Adjust the query to match your database schema
          final hospitalResult = await db
              .collection(HOSPITAL_REG)
              .findOne({'hospitalName': hospital});
          if (hospitalResult != null) {
            temp_id.add(hospitalResult['uid']);
          }
        }
      } else {
        temp_id.add('00000');
      }

      // Insert hospital data using insertOne for each hospital
      Map<String, dynamic> hospitalData = {
        'name': name1,
        'user_username': username,
        'reason': reason ?? 'No Reason',
        'phone': Phone,
        'address': address,
        'email': email,
        'pickup_location': location,
        'latitude': latitude,
        'longitude': longitude,
        'date': formattedDate,
        'time': formattedTime,
        'booking_type': bookingType,
        'ref_id': temp_id,
      };
      DbCollection Booking = db.collection(BOOKING_COLLECTION);
      if (bookingType == "Emergency") {
        await Booking.insertOne({
          'Date': formattedDate,
          'Time': formattedTime,
          'Location': location
        });
      }
      await hospitalPendingCollection.insertOne(hospitalData);

      print('Ambulance data inserted successfully.');
    } catch (e) {
      print('Error inserting ambulance data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingAmbulanceData(
      String collectionName) async {
    DbCollection pendingDataCollections = db.collection(collectionName);

    try {
      if (db == null || !db.isConnected) {
        await connect();
      }

      if (pendingDataCollections == null) {
        throw StateError('$collectionName collection is not initialized');
      }

      final List<Map<String, dynamic>> result =
          await pendingDataCollections.find().toList();

      print('Fetched data: $result'); // Add this line to print the fetched data

      return result;
    } catch (e) {
      print('Error fetching data from $collectionName collection: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAcceptedAmbulanceData(
      String collectionName) async {
    DbCollection acceptedDataCollection = db.collection(collectionName);

    try {
      if (db == null || !db.isConnected) {
        await connect();
      }

      if (acceptedDataCollection == null) {
        throw StateError('$collectionName collection is not initialized');
      }

      final List<Map<String, dynamic>> result =
          await acceptedDataCollection.find().toList();

      print('Fetched data: $result'); // Add this line to print the fetched data

      return result;
    } catch (e) {
      print('Error fetching data from $collectionName collection: $e');
      return [];
    }
  }

  static Future<void> updateData(
    List<Map<String, dynamic>> pendingData,
    String username,
    String password,
  ) async {
    DbCollection pendingDataCollection = db.collection(PENDING_AMBULANCE_DATA);
    DbCollection acceptedDataCollection =
        db.collection(ACCEPTED_AMBULANCE_DATA);
    DbCollection ambulance_reg_Data = db.collection(AMBULANCE_COLLECTION);
    try {
      if (db == null || !db.isConnected) {
        await connect();
      }

      if (pendingDataCollection == null) {
        throw StateError('Collections are not initialized');
      }

      // Adding a null check to result
      final result = await ambulance_reg_Data.findOne({
        'username': username,
        'password': password,
      });

      if (result != null) {
        // Move data from pending to accepted
        for (var data in pendingData) {
          await acceptedDataCollection.insertOne({
            'name': data['name'],
            'user_username': data['user_username'],
            'reason': data['reason'],
            'phone': data['phone'],
            'address': data['address'],
            'email': data['email'],
            'pickup_location': data['pickup_location'],
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'date': data['date'],
            'time': data['time'],
            'booking_type': data['booking_type'],
            'ref_id': result['uid'],
          });
          await pendingDataCollection.remove({'_id': data['_id']});
        }

        print('Data updated successfully.');
      } else {
        print('User not found in ambulance_reg_Data collection.');
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  static Future<void> fetchDataAndSendEmail(
      String username, String password) async {
    userCollection = db.collection(USER_COLLECTION);
    print(username);

    try {
      // Ensure the connection is established before attempting to fetch data
      if (db == null || !db.isConnected) {
        await connect();
      }

      // Fetch user data using AuthManager values
      final result = await userCollection.findOne({
        'username': username,
        'password': password,
      });
      print(result);
      if (result != null) {
        // Check if the password matches
        if (result.containsKey('password') && result['password'] == password) {
          // Extract email ID from the fetched document
          String globalemail = result['userEmail'];
          print(globalemail);
          // Check if email ID is available
          if (globalemail != null && globalemail.isNotEmpty) {
            // Send an email using the sendEmail function
            await sendMail(
                recipientEmail: globalemail, mailMessage: 'Good Morning');
            print('Email sent to $globalemail');
          } else {
            print('Email ID not found in the fetched document');
          }
        } else {
          // Log an error if the password doesn't match
          print('Error: Incorrect password');
          throw Exception('Incorrect password');
        }
      } else {
        // Log an error if the user is not found
        print('Error: User not found with the provided username');
        throw Exception('User not found with the provided username');
      }
    } catch (e) {
      // Log any exceptions that occur during the process
      print('Error fetching data and sending email: $e');
    }
  }

  static sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // change your email here
    String username = 'healthlinkarchitects@gmail.com';
    // change your password here
    String password = 'hzex zsht hnkk ephu';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'HealthLink Architects APP')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail '
      ..text = 'Message: $mailMessage';

    try {
      await send(message, smtpServer);
      print('Email sent successfully');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  static Future<String?> getHospitalAddress(String hospitalName) async {
    DbCollection hospitalCollection = db.collection(HOSPITAL_COLLECTION);

    Map<String, dynamic> query = {'Hospital Name': hospitalName};
    Map<String, dynamic>? result = await hospitalCollection.findOne(query);

    // Check if the result is not null and contains the 'address' field
    if (result != null && result.containsKey('Address')) {
      String address = result['Address'];
      return address;
    }
    return null; // Return null if the result is not found or does not contain the 'address' field
  }

  static Future<List<Map<String, dynamic>>> fetchAmbulanceData() async {
    DbCollection ambulanceData = db.collection(AMBULANCE_COLLECTION);
    final documents = await ambulanceData.find().toList();
    final userDataList = documents.map((doc) {
      return {
        'username': doc['username'],
        'latitude': doc['latitude'],
        'longitude': doc['longitude'],
      };
    }).toList();
    print(userDataList);
    return userDataList;
  }

  static Future<void> Emergency(String address, String emailId) async {
    try {
      DbCollection EmergencyData = db.collection(EMERGENCY);
      Map<String, dynamic> data = {
        'Email': emailId,
        'Address': address,
      };
      await EmergencyData.insertOne(data);
      print('Data successfully submitted');
    } catch (e) {
      print('Error inserting emergency data: $e');
      // Handle the error as needed, e.g., throw an exception or log it.
    }
  }

  static Future<void> updateLocationAmbulance(String username, String password,
      double latitude, double longitude) async {
    DbCollection ambulanceData = db.collection(AMBULANCE_COLLECTION);

    try {
      final result = await ambulanceData.findOne({
        'username': username,
        'password': password,
      });

      if (result != null) {
        final updatedResult = await ambulanceData.update(
          where.eq('username', username).eq('password', password),
          modify
              .set('latitude', latitude.toString())
              .set('longitude', longitude.toString()),
        );

        if (updatedResult['nModified'] != null &&
            updatedResult['nModified'] == 1) {
          print('Location updated successfully');
        } else {
          print('Failed to update location');
        }
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  static Future<Map<String, String>> getAmbulanceLatLon(
      String username, String password) async {
    DbCollection ambulanceData = db.collection(ACCEPTED_AMBULANCE_DATA);
    DbCollection ambulanceReg = db.collection(AMBULANCE_COLLECTION);

    try {
      final result = await ambulanceData.findOne({
        'user_username': username,
        // 'password': password,
      });

      if (result != null) {
        // Assuming 'latitude' and 'longitude' are the keys in your MongoDB document
        final String userLatitude = result['latitude']?.toString() ?? '';
        final String userLongitude = result['longitude']?.toString() ?? '';
        final uid = result['ref_id'];

        final data = await ambulanceReg.findOne({
          'uid': uid,
        });

        String ambulanceLat = '';
        String ambulanceLon = '';

        if (data != null) {
          ambulanceLat = data['latitude']?.toString() ?? '';
          ambulanceLon = data['longitude']?.toString() ?? '';
        }

        // Create and return the Map
        return {
          'userLatitude': userLatitude,
          'userLongitude': userLongitude,
          'ambulanceLat': ambulanceLat,
          'ambulanceLon': ambulanceLon
        };
      } else {
        // Return an empty map if no result is found
        return {};
      }
    } catch (e) {
      // Handle exceptions, e.g., database connection issues
      print('Error in getAmbulanceLatLon: $e');

      // Return an empty map or throw an exception, depending on your requirements
      return {};
    }
  }

  static Future<void> updateAmbuPassword(
      String password, String mail, String newPassword) async {
    DbCollection UserRegData = db.collection(AMBULANCE_COLLECTION);
    try {
      final result = await UserRegData.findOne({
        'email': mail,
      });
      if (result != null) {
        final updatedResult = await UserRegData.update(
            where.eq('email', mail), modify.set('password', newPassword));
        print("Updated Result: $updatedResult");
      } else {
        throw Exception('User Not Found');
      }
    } catch (e) {
      print('Error in finding data $e');
    }
  }

  static Future<void> updatePassword(
      String password, String mail, String newPassword) async {
    DbCollection UserRegData = db.collection(USER_COLLECTION);
    try {
      final result = await UserRegData.findOne({
        'email': mail,
      });
      if (result != null) {
        final updatedResult = await UserRegData.update(
            where.eq('email', mail), modify.set('password', newPassword));
        print("Updated Result: $updatedResult");
      } else {
        throw Exception('User Not Found');
      }
    } catch (e) {
      print('Error in finding data $e');
    }
  }

  static Future<List<String>> getHospital() async {
    DbCollection hospital_details = db.collection(HOSPITAL_COLLECTION);
    List<String> hospitalNames = [];

    try {
      final result = await hospital_details.find();
      await result.forEach((element) {
        hospitalNames.add(element['Hospital Name']);
      });
    } catch (e) {
      print('Error getting hospital data: $e');
    }
    print(hospitalNames);
    hospitalNames.sort();
    return hospitalNames;
  }

  static Future<List<String>> getAllHospitalAddress() async {
    DbCollection hospital_details = db.collection(HOSPITAL_COLLECTION);
    List<String> hospitalAddress = [];
    try {
      final result = await hospital_details.find();
      await result.forEach((element) {
        hospitalAddress.add(element['Address']);
      });
    } catch (e) {
      print('Error getting hospital data: $e');
    }
    hospitalAddress.sort();
    return hospitalAddress;
  }

  static Future<List<String>> redAlertMap() async {
    DbCollection booking = db.collection(BOOKING_COLLECTION);
    Map<String, int> pincodeCountMap = {};

    try {
      await for (var address in booking.find()) {
        String location = address['Location'];
        String? pincode = extractPincode(location);

        if (pincode != null) {
          // Increment count for each pincode
          pincodeCountMap[pincode] = (pincodeCountMap[pincode] ?? 0) + 1;
        }
      }
    } catch (e) {
      print('Error :$e');
    }

    // Filter pincodes with count greater than 5
    List<String> result = pincodeCountMap.entries
        .where((entry) => entry.value > 5)
        .map((entry) => entry.key)
        .toList();

    return result;
  }

  static String? extractPincode(String address) {
    // Assuming the pincode is a 6-digit number in the address
    RegExp pincodeRegex = RegExp(r'\b\d{6}\b');
    RegExpMatch? match = pincodeRegex.firstMatch(address);

    return match?.group(0);
  }

  static Future<List<Map<String, dynamic>>> redAlertGraph() async {
    DbCollection booking = db.collection(BOOKING_COLLECTION);
    Map<String, int> area = {};

    try {
      await for (var address in booking.find()) {
        String location = address['Location'];
        String? locality = extractArea(location);
        if (locality != null) {
          // Increment count for each locality
          area[locality] = (area[locality] ?? 0) + 1;
        }
      }
    } catch (e) {
      print("Error in fetching data $e");
    }

    // Convert the map to a list of maps for each locality
    List<Map<String, dynamic>> result = [];
    area.forEach((key, value) {
      result.add({'locality': key, 'count': value});
    });
    print(result);
    return result;
  }

  static String? extractArea(String location) {
    List<String> addressParts = location.split(', ');

    // Assuming the state name with postal code is the second-to-last part of the address
    String stateWithPostalCode = addressParts[addressParts.length - 2];

    return stateWithPostalCode;
}


  static Future<void> cancelBooking(String username, String password) async {
    DbCollection accepted_ambulance_data =
        db.collection(ACCEPTED_AMBULANCE_DATA);
    DbCollection pending_ambulance_data = db.collection(PENDING_AMBULANCE_DATA);
    DbCollection pending_hospital_data = db.collection(PENDING_HOSPITAL_DATA);
    DbCollection accepted_hospital_data = db.collection(ACCEPTED_HOSPITAL_DATA);
    try {
      await pending_ambulance_data.deleteOne({
        'user_username': username,
        'password': password,
      });
      await accepted_ambulance_data.deleteOne({
        'user_username': username,
        'password': password,
      });
      await pending_hospital_data.deleteOne({
        'user_username': username,
        'password': password,
      });
      await accepted_hospital_data.deleteOne({
        'user_username': username,
        'password': password,
      });
    } catch (e) {
      print("Error in getting $e");
    }
  }

  static Future<void> ReBooking(String username, String password) async {
    DbCollection accepted_ambulance_data =
        db.collection(ACCEPTED_AMBULANCE_DATA);
    try {
      final data = await accepted_ambulance_data.findOne({
        "user_username": username,
      });
      if (data != null) {
        data.remove('ref_id');
        await db.collection(PENDING_AMBULANCE_DATA).insertOne(data);
        await accepted_ambulance_data.deleteOne({"user_username": username});
      }
    } catch (e) {
      print("error in fetching Data $e");
    }
  }
  static Future<void> deleteData(String userUsername) async {
    DbCollection ambulanceAcceptedData = db.collection(ACCEPTED_AMBULANCE_DATA);
    try {
      await ambulanceAcceptedData.deleteOne({'user_username': userUsername});
    } catch (e) {
      print('Error deleting data: $e');
    }
  }
}
