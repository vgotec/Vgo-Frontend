import 'package:flutter/material.dart';
import 'package:timesheet_ui/screens/dashboard_screen.dart';

void main() {
  runApp(const TimeSheetApp());
}

class TimeSheetApp extends StatelessWidget {
  const TimeSheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}
