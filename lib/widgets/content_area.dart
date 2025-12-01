import 'package:flutter/material.dart';
import 'package:timesheet_ui/screens/DashboardFormScreen.dart';

import 'package:timesheet_ui/screens/calendar_form_screen.dart';

class ContentArea extends StatelessWidget {
  final String selectedOption;
  final VoidCallback onMenuToggle;

  const ContentArea({
    super.key,
    required this.selectedOption,
    required this.onMenuToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 6, 23, 155),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onMenuToggle,
        ),
        title: Text(
          _getTitle(selectedOption),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF7F2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: _buildContent(selectedOption),
      ),
    );
  }

  String _getTitle(String option) {
    if (option == 'dashboard') return 'Dashboard';
    if (option == 'timesheet') return 'My Timesheet';
    if (option == 'leave_form') return 'My Leave';
    return 'Dashboard';
  }

  Widget _buildContent(String option) {
    switch (option) {
      case 'dashboard':
        return const DashboardFormScreen(
          formEndpoint:
              "/api/forms/dashboard/charts?empId=f0c6b828-5177-420d-b237-f5e499359eb3",
        );

      case 'timesheet':
        return CalendarFormScreen(
          key: ValueKey("timesheet_screen"), // 👈 UNIQUE KEY
          formEndpoint: "/api/forms/calendar_screen",
        );
      case 'leave_form':
        return CalendarFormScreen(
          key: ValueKey("leave_screen"), // 👈 UNIQUE KEY
          formEndpoint: "/api/forms/leavecalendar_screen",
        );

      default:
        return const DashboardFormScreen(
          formEndpoint:
              "/api/forms/dashboard/charts?empId=f0c6b828-5177-420d-b237-f5e499359eb3",
        );
    }
  }
}
