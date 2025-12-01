// In your package: lib/src/wrappers/json_side_bar_wrapper.dart

import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/dynamic_form_kit.dart';


class JsonSideBarWrapper extends StatelessWidget {
  final Map<String, dynamic> config;
  final FormStateManager manager;

  const JsonSideBarWrapper({
    super.key,
    required this.config,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = config['items'] as List<dynamic>? ?? [];
    
    // This dataKey tells the drawer which key in the manager
    // holds the currently selected item's key.
    final String dataKey = config['dataKey'] ?? 'selectedNavKey';

    return Drawer(
      // Listens to the manager so it can rebuild when the selected key changes
      child: ListenableBuilder(
        listenable: manager,
        builder: (context, _) {
          // Get the currently selected key from the manager
          final String? selectedKey = manager.dataContext[dataKey];

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // --- A beautiful header for your drawer ---
              _buildDrawerHeader(config['header']),

              // --- Build the navigation items ---
              ...items.map((item) {
                if (item is! Map<String, dynamic>) return const SizedBox.shrink();
                
                final String itemKey = item['key'];
                final String label = item['label'] ?? 'Menu Item';
                final IconData? icon = StyleParser.parseIcon(item['icon']);
                final bool isSelected = (itemKey == selectedKey);

                return ListTile(
                  leading: Icon(
                    icon,
                    color: isSelected ? Theme.of(context).primaryColor : null,
                  ),
                  title: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  onTap: () {
                    // 1. Close the drawer
                    Navigator.of(context).pop(); 
                    
                    // 2. Dispatch the navigation action
                    // Your HomeScreen will listen for this
                    manager.dispatchAction(
                      'navigate',
                      payload: {'target': itemKey},
                    );
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerHeader(dynamic headerConfig) {
    if (headerConfig is! Map<String, dynamic>) {
      return const DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        child: Text(
          'Menu',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }
    
    // Build a more dynamic header
    final String title = headerConfig['title'] ?? 'Menu';
    final String? subtitle = headerConfig['subtitle'];
    final Color bgColor = StyleParser.parseColor(headerConfig['backgroundColor'], Colors.blue);

    return UserAccountsDrawerHeader(
      accountName: Text(title),
      accountEmail: subtitle != null ? Text(subtitle) : null,
      decoration: BoxDecoration(color: bgColor),
      // You could also make the avatar image dynamic via JSON
      currentAccountPicture: const CircleAvatar(
        child: Icon(Icons.person, size: 50),
      ),
    );
  }
}