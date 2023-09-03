import 'dart:io';

import 'package:login_flutter/auth.dart';
import 'package:login_flutter/ui/mainHome.dart';
import 'package:login_flutter/ui/login.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        print(snapshot.hasData);
        if (snapshot.hasData) {
          return Home();
        } else {
          return Login();
        }
      },
    );
  }
}
