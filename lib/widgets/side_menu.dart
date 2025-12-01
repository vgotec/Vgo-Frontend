import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final bool isVisible;
  final String selectedOption;
  final ValueSetter<String> onOptionSelected;

  const SideMenu({
    super.key,
    required this.isVisible,
    required this.selectedOption,
    required this.onOptionSelected,
  });

 @override
@override
Widget build(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,         // ⬅️ Forces menu to top
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isVisible ? MediaQuery.of(context).size.width * 0.20 : 0,
      height: double.infinity,            // ⬅️ Makes the sidebar full height
      child: Material(
        elevation: 8.0,
        color: const Color.fromARGB(255, 6, 23, 155),
        child: SingleChildScrollView(
          child: isVisible
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfo(),
                    const Divider(height: 1),
                    _buildMenuOption(
                      icon: Icons.dashboard_outlined,
                      title: 'Dashboard',
                      optionKey: 'dashboard',
                    ),
                    _buildMenuOption(
                      icon: Icons.access_time_outlined,
                      title: 'My Timesheet',
                      optionKey: 'timesheet',
                    ),
                    _buildMenuOption(
                      icon: Icons.beach_access,
                      title: 'My Leave Form',
                      optionKey: 'leave_form',
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    ),
  );
}


  // Widget for the user info at the top
  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            // Replace with user image
            backgroundImage: AssetImage('assets/images/myphoto.jpg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donald', // Replace with user.name
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Software Developer', // Replace with user.role
                  style: const TextStyle(
                    color: Colors.grey,
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

  // Reusable widget for a menu item
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String optionKey,
  }) {
    final bool isSelected = (selectedOption == optionKey);

    return Material(
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: () => onOptionSelected(optionKey),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color.fromARGB(255, 93, 186, 202) : const Color.fromARGB(255, 248, 247, 247),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color.fromARGB(255, 33, 240, 243) : const Color.fromARGB(221, 255, 255, 255),
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