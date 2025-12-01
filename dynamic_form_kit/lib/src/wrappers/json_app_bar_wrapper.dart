import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/dynamic_form_kit.dart';
// ⭐️ Make sure this path to your StyleParser is correct
import 'package:dynamic_form_kit/src/utils/style_parser.dart'; 

class JsonAppBarWrapper extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic> config;
  final FormStateManager manager;

  const JsonAppBarWrapper({
    super.key,
    required this.config,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    // --- Parse Config ---
    final String title = config['title'] ?? 'Title';
    final String? leadingIconName = config['leadingIcon']; // 'menu', 'back', or null
    final List<dynamic> actions = config['actions'] as List<dynamic>? ?? [];
    
    // --- Style Parsing (using your StyleParser) ---
    final style = config['style'] as Map<String, dynamic>? ?? {};
    final Color backgroundColor = StyleParser.parseColor(
      style['backgroundColor'],
      Theme.of(context).appBarTheme.backgroundColor ?? Colors.blue,
    );
    final Color foregroundColor = StyleParser.parseColor(
      style['foregroundColor'],
      Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
    );
    final double elevation = StyleParser.parseDouble(style['elevation'], 4.0);

    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      
      // Build the leading icon (menu or back)
      leading: _buildLeadingIcon(context, leadingIconName),
      
      // Build the action icons (e.g., notifications, search)
      actions: _buildActionIcons(context, actions),
    );
  }

  // Helper to build the leading icon
  Widget? _buildLeadingIcon(BuildContext context, String? iconName) {
    if (iconName == 'menu') {
      return IconButton(
        icon: Icon(StyleParser.parseIcon('menu') ?? Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      );
    }
    if (iconName == 'back') {
      return IconButton(
        icon: Icon(StyleParser.parseIcon('arrow_back') ?? Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      );
    }
    return null; // Flutter will provide the default
  }

  // Helper to build the list of action icons
  List<Widget> _buildActionIcons(BuildContext context, List<dynamic> actions) {
    return actions.map((actionConfig) {
      if (actionConfig is! Map<String, dynamic>) return const SizedBox.shrink();
      
      final String iconName = actionConfig['icon'] ?? 'help_outline';
      final String? tooltip = actionConfig['tooltip'];
      final Map<String, dynamic>? action = actionConfig['action'];

      return IconButton(
        icon: Icon(StyleParser.parseIcon(iconName)), // Uses your StyleParser
        tooltip: tooltip,
        onPressed: () {
          if (action != null) {
            manager.dispatchAction(
              action['type'],
              payload: action['payload'],
            );
          }
        },
      );
    }).toList();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}