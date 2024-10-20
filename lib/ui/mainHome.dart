import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_flutter/auth.dart';

import 'login.dart';
import 'customerWise.dart';
import 'overallReport.dart';
import 'dateSelect.dart';
import 'deleteCustomerPage.dart'; // Import the delete customer page

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final Box _boxLogin = Hive.box("login");
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<void> _updateStoreId(BuildContext context) async {
    String? newStoreId;

    // Show dialog to get new Store ID
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter New Store ID'),
          content: TextField(
            onChanged: (value) {
              newStoreId = value; // Capture the new Store ID
            },
            decoration: InputDecoration(hintText: "New Store ID"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newStoreId != null && newStoreId!.isNotEmpty) {
                  _boxLogin.put('storeId', newStoreId); // Update Hive box
                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Store ID updated to: $newStoreId'),
                    ),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? username = user?.email;
    String currentStoreId = _boxLogin.get('storeId', defaultValue: 'Not Set') ??
        'Not Set'; // Retrieve current Store ID
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
