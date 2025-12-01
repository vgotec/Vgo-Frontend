import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/dynamic_form_kit.dart';
// ⭐️ Make sure this path to your StyleParser is correct
import 'package:dynamic_form_kit/src/utils/style_parser.dart';

class JsonDrawerWrapper extends StatelessWidget {
  final Map<String, dynamic> config;
  final FormStateManager manager;

  const JsonDrawerWrapper({
    super.key,
    required this.config,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = config['items'] as List<dynamic>? ?? [];
    final String dataKey = config['dataKey'] ?? 'selectedNavKey';
    final headerConfig = config['header'] as Map<String, dynamic>?;

    return Drawer(
      child: ListenableBuilder(
        listenable: manager,
        builder: (context, _) {
          final String? selectedKey = manager.dataContext[dataKey];

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Build the header
              _buildDrawerHeader(headerConfig),

              // Build the navigation items
              ...items.map((item) {
                if (item is! Map<String, dynamic>) return const SizedBox.shrink();
                
                final String itemKey = item['key'];
                final String label = item['label'] ?? 'Menu Item';
                final IconData icon = StyleParser.parseIcon(item['icon']) ?? Icons.circle_outlined;
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
                    Navigator.of(context).pop(); // Close the drawer
                    
                    // Dispatch the navigate action
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

  Widget _buildDrawerHeader(Map<String, dynamic>? config) {
    if (config == null) {
      return const DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        child: Text(
          'Menu',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }
    
    // Build a dynamic header
    final String title = config['title'] ?? 'Menu';
    final String? subtitle = config['subtitle'];
    final Color bgColor = StyleParser.parseColor(config['backgroundColor'], Colors.blue);

    return UserAccountsDrawerHeader(
      accountName: Text(title),
      accountEmail: subtitle != null ? Text(subtitle) : null,
      decoration: BoxDecoration(color: bgColor),
      currentAccountPicture: CircleAvatar(
        child: Icon(
          StyleParser.parseIcon(config['icon']) ?? Icons.person,
          size: 50,
        ),
      ),
    );
  }
}