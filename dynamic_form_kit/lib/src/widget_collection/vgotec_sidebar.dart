import 'package:flutter/material.dart';

class VgotecSidebar extends StatelessWidget {
  final bool isVisible;
  final String selectedOption;
  final ValueChanged<String>? onOptionSelected;

  // Style customization
  final Color backgroundColor;
  final Color textColor;
  final Color activeColor;
  final double widthFraction;
  final TextStyle? menuTextStyle;
  final List<Map<String, dynamic>>? customMenuItems;

  const VgotecSidebar({
    super.key,
    this.isVisible = true,
    this.selectedOption = 'dashboard',
    this.onOptionSelected,
    this.backgroundColor = const Color(0xFF06179B),
    this.textColor = Colors.white,
    this.activeColor = Colors.blue,
    this.widthFraction = 0.20,
    this.menuTextStyle,
    this.customMenuItems,
  });

  @override
  Widget build(BuildContext context) {
    final defaultMenu = [
      {'icon': Icons.dashboard_outlined, 'title': 'Dashboard', 'key': 'dashboard'},
      {'icon': Icons.add_box_outlined, 'title': 'Create Project', 'key': 'create_project'},
      {'icon': Icons.list_alt_outlined, 'title': 'All Projects', 'key': 'all_projects'},
      {'icon': Icons.access_time_outlined, 'title': 'My Timesheet', 'key': 'timesheet'},
    ];

    final menuItems = customMenuItems ?? defaultMenu;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isVisible ? MediaQuery.of(context).size.width * widthFraction : 0,
      child: Container(
        color: backgroundColor,
        child: SingleChildScrollView(
          child: isVisible
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfo(),
                    const Divider(color: Colors.white24, height: 1),
                    ...menuItems.map((item) => _buildMenuOption(item)).toList(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'User Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Software Developer',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(Map<String, dynamic> item) {
    final bool isSelected = (selectedOption == item['key']);

    return Material(
      color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
      child: InkWell(
        onTap: () => onOptionSelected?.call(item['key']),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                item['icon'],
                color: isSelected ? activeColor : textColor.withOpacity(0.7),
              ),
              const SizedBox(width: 16),
              Text(
                item['title'],
                style: menuTextStyle ??
                    TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? activeColor : textColor,
                      fontSize: 15,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
