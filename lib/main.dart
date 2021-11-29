import 'package:flutter/material.dart';

import 'home/screen_scan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SCAN",
      debugShowCheckedModeBanner: false,
      home: ScreenScan(),
    );
  }
}
