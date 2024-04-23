import 'package:flutter/material.dart';
import 'package:opstracker/compliance/time_report/screens/time_report.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Opstracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TimeReportScreen(), // Display TimeReportScreen as the home screen
    );
  }
}
