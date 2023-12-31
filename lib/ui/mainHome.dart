import "package:flutter/material.dart";
import 'package:hive_flutter/hive_flutter.dart';
import 'package:login_flutter/ui/overallReport.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_flutter/auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:login_flutter/ui/overallReport.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_flutter/auth.dart';

import "login.dart";
import 'customerWise.dart';
import 'overallReport.dart';
import 'customerWise.dart';
import 'overallReport.dart';
import 'dateSelect.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final Box _boxLogin = Hive.box("login");
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Firebas Auth');
  }

  Widget _userUid() {
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? username = user?.email;
    double width = (MediaQuery.of(context).size.height);
    double height = (MediaQuery.of(context).size.height);
    double containerWidth = 0.45 * width;
    double containerHeight = 0.8 * height;
    double rowButtonH = containerHeight * .25;
    double rowButtonW = containerWidth * .39;
    double buttonFontSize = containerHeight * 0.1;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: const Row(
          children: <Widget>[
            Text('HOME'),
          ],
        ),
        elevation: 0,
        actions: [
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
                  signOut;
                  // _boxLogin.clear();
                  // _boxLogin.put("loginStatus", false);
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
          )
        ],
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          //color: const Color.fromARGB(255, 205, 19, 19),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.29,
                height: height * 0.22,
                child: Center(
                  child: Text(
                    'Welcome \n ${username}',
                    style: TextStyle(fontSize: height / 35),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: rowButtonH,
                      width: rowButtonW,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          //print('Row Button 1');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const DateSelector();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Date Wise Report',
                          style: TextStyle(fontSize: buttonFontSize * .30),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: SizedBox(
                      height: rowButtonH,
                      width: rowButtonW,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          //print('Row Button 2');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const OverallReport();
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Overall Report",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: buttonFontSize * 0.30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: containerHeight * .30,
                width: containerWidth * .83,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    print('Row Button 3');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const CustomerWise();
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Customer Wise Report',
                    style: TextStyle(fontSize: buttonFontSize * 0.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
