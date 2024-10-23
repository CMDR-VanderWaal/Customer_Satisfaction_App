import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_flutter/auth.dart';

import 'login.dart';
import 'customerWise.dart';
import 'overallReport.dart';
import 'dateSelect.dart';
import 'deleteCustomerPage.dart';

import 'package:http/http.dart' as http; // For API calls
import 'dart:convert';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final Box _boxLogin = Hive.box("login");
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> _updateStoreId(BuildContext context) async {
    String? newStoreId;
    bool isValid = false;
    String? errorMessage;

    // Loop until a valid store ID is entered
    while (!isValid) {
      // Show dialog to get new Store ID using StatefulBuilder to dynamically update the UI
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Enter New Store ID'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        newStoreId = value; // Capture the new Store ID
                      },
                      decoration: InputDecoration(
                        hintText: "New Store ID",
                        errorText: errorMessage, // Display error message if any
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      isValid = true; // Close dialog on cancel
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (newStoreId != null && newStoreId!.isNotEmpty) {
                        // Call the API to verify the store ID
                        bool isStoreIdValid = await _verifyStoreId(newStoreId!);

                        if (isStoreIdValid) {
                          _boxLogin.put(
                              'storeId', newStoreId); // Update Hive box
                          isValid = true; // Set flag to true to break the loop
                          Navigator.of(context).pop(); // Close dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Store ID updated to: $newStoreId'),
                            ),
                          );
                        } else {
                          // Invalid store ID, show error message
                          setState(() {
                            errorMessage =
                                'Invalid Store ID. Please try again.';
                          });
                        }
                      }
                    },
                    child: Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  // Function to call the API and verify the store ID
  Future<bool> _verifyStoreId(String storeId) async {
    // Replace with your API URL
    final String apiUrl =
        'https://us-central1-sensorsprok.cloudfunctions.net/api/api/customers/$storeId/list';

    try {
      print('calling');
      final response = await http.get(Uri.parse(apiUrl));
      print(response);
      if (response.statusCode == 200) {
        // Parse response body
        final data = json.decode(response.body);
        // If the data is not empty, consider it a valid store ID
        if (data != null && data.isNotEmpty) {
          return true;
        }
      }
      // If the status code is not 200 or data is empty, return false
      return false;
    } catch (e) {
      // Handle any errors
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? username = user?.email;
    String currentStoreId =
        _boxLogin.get('storeId', defaultValue: 'Not Set') ?? 'Not Set';
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double containerWidth = width * 0.85;
    double containerHeight = height * 0.7;
    double buttonHeight = containerHeight * 0.15;
    double buttonWidth = containerWidth * 0.4;
    double buttonFontSize = height * 0.025;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: const Text('Home',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          // Button to update Store ID
          IconButton(
            icon: Icon(Icons.store),
            onPressed: () {
              _updateStoreId(context); // Call the method to update Store ID
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: IconButton(
                onPressed: () {
                  Auth().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Login();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: containerWidth,
                height: height * 0.15,
                child: Center(
                  child: Text(
                    'Welcome to store: $currentStoreId \n$username', // Display current Store ID
                    style: TextStyle(
                      fontSize: height / 30,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: EdgeInsets.all(8.0),
                  children: [
                    _buildElevatedButton(
                      context,
                      'Date Wise Report',
                      const DateSelector(),
                      buttonHeight,
                      buttonWidth,
                      buttonFontSize,
                    ),
                    _buildElevatedButton(
                      context,
                      'Overall Report',
                      const OverallReport(),
                      buttonHeight,
                      buttonWidth,
                      buttonFontSize,
                    ),
                    _buildElevatedButton(
                      context,
                      'Customer Wise Report',
                      const CustomerWise(),
                      containerHeight * 0.3,
                      containerWidth * 0.83,
                      buttonFontSize * 0.8,
                    ),
                    _buildElevatedButton(
                      context,
                      'Delete Customers',
                      const DeleteCustomerPage(), // Navigate to DeleteCustomerPage
                      containerHeight * 0.3,
                      containerWidth * 0.83,
                      buttonFontSize * 0.8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(BuildContext context, String text, Widget page,
      double height, double width, double fontSize) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          elevation: 5,
          minimumSize: Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return page;
              },
            ),
          );
        },
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
