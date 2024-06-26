import 'package:flutter/material.dart';
import 'package:login_flutter/widget_tree.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(32, 63, 129, 1.0),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromRGBO(
              32, 63, 129, 1.0), // Set the AppBar background color
          foregroundColor: Colors.white, // Set the AppBar text/icon color
        ),
      ),
      home: const WidgetTree(),
    );
  }
}
