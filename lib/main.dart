import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:path_provider/path_provider.dart';

import 'main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Firebase
      .initializeApp(); // need to have this to make app work with firebase
  await _initHive();
  //final applicationDocumentDir = await getApplicationDocumentsDirectory();
  //print(applicationDocumentDir);
  runApp(const MainApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox("login");
  //final box = await Hive.openBox('login');
  //print(box.path);
  await Hive.openBox("accounts");
}
