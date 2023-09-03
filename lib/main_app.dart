import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:login_flutter/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';

import 'ui/login.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(32, 63, 129, 1.0),
        ),
      ),
      home: const WidgetTree(),
    );
  }
}

// class ToLogin extends StatefulWidget {
//   const ToLogin({super.key});

//   @override
//   State<ToLogin> createState() => _ToLoginState();
// }

// class _ToLoginState extends State<ToLogin> {
//   @override
//   Widget build(BuildContext context) {
//     return Login();
//   }
// }
