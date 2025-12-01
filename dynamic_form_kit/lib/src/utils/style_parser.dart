import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Optional external icon packs
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// A utility class to parse style values from JSON dynamically.
class StyleParser {
  // --- COLOR ---
  static Color parseColor(dynamic colorString, [Color defaultColor = Colors.black]) {
    if (colorString is! String) return defaultColor;
    String hex = colorString.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex"; // Add full alpha
    }
    if (hex.length == 8) {
      try {
        return Color(int.parse("0x$hex"));
      } catch (_) {
        return defaultColor;
      }
    }
    return defaultColor;
  }

  // --- DOUBLE ---
  static double parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // --- FONT WEIGHT ---
  static FontWeight parseFontWeight(dynamic weight) {
    if (weight == 'bold') return FontWeight.bold;
    if (weight == 'w500') return FontWeight.w500;
    if (weight == 'light') return FontWeight.w300;
    return FontWeight.normal;
  }

  // --- ALIGNMENT ---
  static Alignment parseAlignment(dynamic alignment) {
    if (alignment == 'center') return Alignment.center;
    if (alignment == 'left') return Alignment.centerLeft;
    if (alignment == 'right') return Alignment.centerRight;
    if (alignment == 'top') return Alignment.topCenter;
    if (alignment == 'bottom') return Alignment.bottomCenter;
    return Alignment.center;
  }

  // --- SCROLL PHYSICS ---
  static ScrollPhysics parseScrollPhysics(dynamic physics) {
    if (physics == 'NeverScrollableScrollPhysics') {
      return const NeverScrollableScrollPhysics();
    }
    return const AlwaysScrollableScrollPhysics();
  }

  // --- ICON PARSER (⭐️ the important part) ---
  static IconData? parseIcon(dynamic iconName) {
    if (iconName == null) return null;
    if (iconName is IconData) return iconName;
    if (iconName is! String) return null;

    // Allow formats like "Icons.add", "CupertinoIcons.home", "fa:trash", "mdi:account"
    iconName = iconName.trim();

    // --- Material Icons ---
    if (iconName.startsWith('Icons.')) {
      final name = iconName.split('.')[1];
      return _materialIcons[name];
    }

    // --- Cupertino Icons ---
    if (iconName.startsWith('CupertinoIcons.')) {
      final name = iconName.split('.')[1];
      return _cupertinoIcons[name];
    }

    // --- FontAwesome Icons ---
    if (iconName.startsWith('fa:')) {
      final name = iconName.split(':')[1];
      return _fontAwesomeIcons[name];
    }

    // --- Material Design Icons (mdi) ---
    if (iconName.startsWith('mdi:')) {
      final name = iconName.split(':')[1];
      return _mdiIcons[name];
    }

    // Default fallback
    return Icons.help_outline;
  }

  // --- ICON MAPS ---
  static final Map<String, IconData> _materialIcons = {
    'add': Icons.add,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'save': Icons.save,
    'check': Icons.check,
    'close': Icons.close,
    'search': Icons.search,
    'arrow_forward': Icons.arrow_forward,
    'arrow_back': Icons.arrow_back,
    'home': Icons.home,
    'settings': Icons.settings,
    'info': Icons.info,
    'help_outline': Icons.help_outline,
  };

  static final Map<String, IconData> _cupertinoIcons = {
    'home': CupertinoIcons.home,
    'add': CupertinoIcons.add,
    'delete': CupertinoIcons.delete,
    'info': CupertinoIcons.info,
    'search': CupertinoIcons.search,
    'settings': CupertinoIcons.settings,
    'arrow_right': CupertinoIcons.arrow_right,
    'arrow_left': CupertinoIcons.arrow_left,
  };

  // --- FontAwesome (optional; requires font_awesome_flutter) ---
  static final Map<String, IconData> _fontAwesomeIcons = {
    // Uncomment below if you add the dependency
    // 'trash': FontAwesomeIcons.trash,
    // 'edit': FontAwesomeIcons.edit,
    // 'save': FontAwesomeIcons.save,
    // 'user': FontAwesomeIcons.user,
    // 'home': FontAwesomeIcons.home,
  };

  // --- MaterialDesignIcons (optional; requires material_design_icons_flutter) ---
  static final Map<String, IconData> _mdiIcons = {
    // 'account': MdiIcons.account,
    // 'alert': MdiIcons.alert,
    // 'bell': MdiIcons.bell,
    // 'calendar': MdiIcons.calendar,
  };
}
