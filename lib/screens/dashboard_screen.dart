import 'package:flutter/material.dart';
import 'package:timesheet_ui/widgets/side_menu.dart';
import 'package:timesheet_ui/widgets/content_area.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedOption = 'dashboard';
  bool _isMenuVisible = true;

  void _toggleMenu() {
    setState(() => _isMenuVisible = !_isMenuVisible);
  }

  void _onOptionSelected(String option) {
    setState(() => _selectedOption = option);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            isVisible: _isMenuVisible,
            selectedOption: _selectedOption,
            onOptionSelected: _onOptionSelected,
          ),
          Expanded(
            child: ContentArea(
              selectedOption: _selectedOption,
              onMenuToggle: _toggleMenu,
            ),
          ),
        ],
      ),
    );
  }
}
