import 'package:flutter/material.dart';
import 'package:dynamic_form_kit/src/manager/form_state_manager.dart';
import 'package:dynamic_form_kit/src/utils/style_parser.dart';

/// A dynamic wrapper for rendering icon-based buttons from JSON config.
class IconWrapper extends StatelessWidget {
  final Map<String, dynamic> field;
  final FormStateManager manager;

  const IconWrapper({
    Key? key,
    required this.field,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Basic config ---
    final String key = field['key'] ?? '';
    final String? tooltip = field['tooltip'];
    final Map<String, dynamic> config = field['config'] ?? {};
    final Map<String, dynamic> style = config['style'] ?? {};
    final Map<String, dynamic> placement = config['placement'] ?? {};
    final Map<String, dynamic> action = field['action'] ?? {};

    // --- Parse icon style ---
    final IconData iconData = StyleParser.parseIcon(style['icon']) ?? Icons.help_outline;
    final Color iconColor = StyleParser.parseColor(style['iconColor'], Colors.black);
    final double size = StyleParser.parseDouble(style['size'], 24.0);
    final bool showBackground = style['showBackground'] == true;
    final Color backgroundColor = StyleParser.parseColor(style['backgroundColor'], Colors.transparent);

    final double width = StyleParser.parseDouble(placement['width'], size + 16);
    final double height = StyleParser.parseDouble(placement['height'], size + 16);

    // --- Action logic ---
    final String actionType = action['type'] ?? '';
    final String? endpoint = action['endpoint'];

    VoidCallback? onPressed;
    if (actionType.isNotEmpty) {
      onPressed = () {
        manager.dispatchAction(
          actionType,
          payload: {
            "endpoint": endpoint,
            "fieldKey": key,
            "extra": field,
          },
        );
      };
    }

    // --- UI widget ---
    Widget iconWidget = IconButton(
      tooltip: tooltip,
      icon: Icon(iconData, color: iconColor, size: size),
      onPressed: onPressed,
    );

    if (showBackground) {
      iconWidget = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: iconWidget),
      );
    }

    return iconWidget;
  }
}
